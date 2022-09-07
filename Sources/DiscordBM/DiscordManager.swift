import WebSocketKit
import Logging
import struct NIOCore.TimeAmount
import struct Foundation.Data
import struct Foundation.Date
import class NIO.RepeatedTask
import Atomics
import AsyncHTTPClient
import struct Foundation.UUID

public actor DiscordManager {
    
    enum ConnectionState: Int, AtomicValue {
        case noConnection
        case connecting
        case configuring
        case connected
    }
    
    var ws: WebSocket? {
        didSet {
            self.closeWebsocket(ws: oldValue)
        }
    }
    nonisolated let eventLoopGroup: EventLoopGroup
    public nonisolated let client: DiscordClient
    
    var onEvents: [(Gateway.Event) -> ()] = []
    var onEventParseFilures: [(Error, String) -> ()] = []
    
    let token: String
    let presence: Gateway.Identify.PresenceUpdate?
    let intents: [Gateway.Identify.Intent]
    
    public nonisolated let id = UUID()
    let logger = DiscordGlobalConfiguration.makeLogger("DiscordManager")
    
    var sequenceNumber: Int? = nil
    var lastEventDate = Date()
    var sessionId: String? = nil
    var resumeGatewayUrl: String? = nil
    nonisolated let pingTaskInterval = ManagedAtomic(0)
    nonisolated let connectionState = ManagedAtomic(ConnectionState.noConnection)
    
    var pingTask: RepeatedTask? = nil
    var zombiedConnectionCheckerTask: RepeatedTask? = nil
    nonisolated let zombiedConnectionCounter = ManagedAtomic(0)
    /// An ID to keep track of connection changes.
    nonisolated let connectionId = ManagedAtomic(Int.random(in: 10_000..<100_000))
    
    public init(
        eventLoopGroup: EventLoopGroup,
        httpClient: HTTPClient,
        token: String,
        appId: String,
        presence: Gateway.Identify.PresenceUpdate? = nil,
        intents: [Gateway.Identify.Intent] = []
    ) {
        self.eventLoopGroup = eventLoopGroup
        self.client = DiscordClient(
            httpClient: httpClient,
            token: token,
            appId: appId
        )
        self.token = token
        self.presence = presence
        self.intents = intents
    }
    
    nonisolated public func connect() {
        Task {
            await connectAsync()
        }
    }
    
    public func requestGuildMembersChunk(payload: Gateway.RequestGuildMembers) {
        self.send(payload: .init(
            opcode: .requestGuildMembers,
            data: .requestGuildMembers(payload)
        ), opcode: 0x1)
    }
    
    public func addEventHandler(_ handler: @escaping (Gateway.Event) -> Void) {
        self.onEvents.append(handler)
    }
    
    public func addEventParseFailureHandler(_ handler: @escaping (Error, String) -> Void) {
        self.onEventParseFilures.append(handler)
    }
}

extension DiscordManager {
    private func connectAsync() async {
        guard self.connectionState.compareExchange(
            expected: .noConnection,
            desired: .connecting,
            ordering: .relaxed
        ).exchanged else { return }
        self.lastEventDate = Date()
        let gatewayUrl = await getGatewayUrl()
        var configuration = WebSocketClient.Configuration()
        configuration.maxFrameSize = 1 << 31
        do {
            self.ws = try await WebSocket.asyncConnect(
                to: gatewayUrl + "?v=\(DiscordGlobalConfiguration.apiVersion)",
                configuration: configuration,
                on: eventLoopGroup
            )
            self.connectionState.store(.configuring, ordering: .relaxed)
            configureWebsocket()
        } catch {
            logger.error("Error while connecting to Discord through websocket.", metadata: [
                "DiscordManagerID": .stringConvertible(id),
                "error": "\(error)"
            ])
            self.connectionState.store(.noConnection, ordering: .relaxed)
            await eventLoopGroup.any().wait(.seconds(5))
            await connectAsync()
        }
    }
    
    private func configureWebsocket() {
        self.connectionId.store(.random(in: 10_000..<100_000), ordering: .relaxed)
        self.setupOnText()
        self.setupOnClose()
        self.setupZombiedConnectionCheckerTask(
            forConnectionWithId: connectionId.load(ordering: .relaxed)
        )
        self.sendHello()
    }
    
    private func proccessEvent(_ event: Gateway.Event) {
        self.lastEventDate = Date()
        self.zombiedConnectionCounter.store(0, ordering: .relaxed)
        if let sequenceNumber = event.sequenceNumber {
            self.sequenceNumber = sequenceNumber
        }
        
        switch event.opcode {
        case .reconnect:
            break // will reconnect when we get the close notification
        case .heartbeat:
            self.sendPing()
        case .heartbeatAccepted:
            break // nothing to do
        case .invalidSession:
            logger.warning("Got invalid session. Will try to reconnect.", metadata: [
                "DiscordManagerID": .stringConvertible(id)
            ])
            self.sequenceNumber = nil
            self.resumeGatewayUrl = nil
            self.sessionId = nil
            self.connect()
        default:
            break
        }
        
        switch event.data {
        case let .hello(hello):
            let interval: TimeAmount = .milliseconds(Int64(hello.heartbeat_interval))
            /// Disable ws automatic pings
            self.ws?.pingInterval = nil
            self.schedulePingTask(every: interval)
            self.pingTaskInterval.store(hello.heartbeat_interval, ordering: .relaxed)
            self.sendResumeOrIdentify()
        case let .ready(payload):
            self.connectionState.store(.connected, ordering: .relaxed)
            logger.notice("Received Discord Ready Notice.", metadata: [
                "DiscordManagerID": .stringConvertible(id)
            ])
            self.sessionId = payload.session_id
            self.resumeGatewayUrl = payload.resume_gateway_url
        case .resumed:
            logger.notice("Received successful resume notice.", metadata: [
                "DiscordManagerID": .stringConvertible(id)
            ])
            self.connectionState.store(.connected, ordering: .relaxed)
        default:
            break
        }
    }
    
    private func getGatewayUrl() async -> String {
        if let gatewayUrl = self.resumeGatewayUrl {
            return gatewayUrl
        } else if let gatewayUrl = try? await client.getGateway().decode().url {
            return gatewayUrl
        } else {
            logger.error("Cannot get gateway url to connect to. Will retry in 5 seconds.", metadata: [
                "DiscordManagerID": .stringConvertible(id)
            ])
            await self.eventLoopGroup.any().wait(.seconds(5))
            return await self.getGatewayUrl()
        }
    }
    
    private func sendResumeOrIdentify() {
        if !self.sendResumeAndReport() {
            self.sendIdentify()
        }
    }
    
    /// Returns whether or not it could send the `resume`.
    private func sendResumeAndReport() -> Bool {
        if let sessionId = self.sessionId,
           let lastSequenceNumber = self.sequenceNumber {
            
            let resume = Gateway.Event(
                opcode: .resume,
                data: .resume(.init(
                    token: self.token,
                    session_id: sessionId,
                    seq: lastSequenceNumber
                ))
            )
            self.send(
                payload: resume,
                opcode: UInt8(Gateway.Opcode.identify.rawValue)
            )
            
            /// Invalidate these temporary info before for the next connection trial.
            self.sequenceNumber = nil
            self.resumeGatewayUrl = nil
            self.sessionId = nil
            
            logger.notice("Sent resume request to Discord.", metadata: [
                "DiscordManagerID": .stringConvertible(id)
            ])
            
            return true
        }
        logger.notice("Can't resume last Discord connection.", metadata: [
            "sessionId_length": .stringConvertible(self.sessionId?.count ?? -1),
            "lastSequenceNumber": .stringConvertible(self.sequenceNumber ?? -1),
            "DiscordManagerID": .stringConvertible(id)
        ])
        return false
    }
    
    private func sendIdentify() {
        let identify = Gateway.Event(
            opcode: .identify,
            data: .identify(.init(
                token: self.token,
                presence: self.presence,
                intents: .init(values: intents)
            ))
        )
        self.send(payload: identify)
    }
    
    private func setupOnText() {
        self.ws?.onText { _, text in
            let data = Data(text.utf8)
            do {
                let event = try DiscordGlobalConfiguration.decoder.decode(
                    Gateway.Event.self,
                    from: data
                )
                self.proccessEvent(event)
                for onEvent in self.onEvents {
                    onEvent(event)
                }
            } catch {
                for onEventParseFilure in self.onEventParseFilures {
                    onEventParseFilure(error, text)
                }
            }
        }
    }
    
    private func setupOnClose() {
        self.ws?.onClose.whenComplete { [weak self] _ in
            guard let `self` = self else { return }
            Task {
                let code = await self.ws?.closeCode
                self.logger.log(
                    /// If its `nil` or `.goingAway`, then it's likely just a resume notice.
                    /// Otherwise it might be an error.
                    level: (code == nil || code == .goingAway) ? .warning : .error,
                    "Received Discord Connection Close Notification.",
                    metadata: [
                        "DiscordManagerID": .stringConvertible(self.id),
                        "code": "\(String(describing: code))"
                    ]
                )
                self.connect()
            }
        }
    }
    
    private func sendHello() {
        self.send(payload: .init(opcode: .hello))
    }
    
    private nonisolated func setupZombiedConnectionCheckerTask(
        forConnectionWithId connectionId: Int,
        on el: EventLoop? = nil
    ) {
        let el = el ?? self.eventLoopGroup.any()
        el.scheduleTask(in: .seconds(10)) { [weak self] in
            guard let `self` = self else { return }
            /// If connection has changed then end this instance.
            guard self.connectionId.load(ordering: .relaxed) == connectionId else { return }
            @Sendable func reschedule(in time: TimeAmount) {
                el.scheduleTask(in: time) {
                    self.setupZombiedConnectionCheckerTask(forConnectionWithId: connectionId, on: el)
                }
            }
            Task {
                let now = Date().timeIntervalSince1970
                let lastEventInterval = await self.lastEventDate.timeIntervalSince1970
                let past = now - lastEventInterval
                let tolerance = DiscordGlobalConfiguration.zombiedConnectionCheckerTolerance
                let diff = tolerance - past
                if diff > 0 {
                    reschedule(in: .seconds(Int64(diff) + 1))
                } else {
                    let tryToPingBeforeForceReconnect: Bool = await {
                        if self.zombiedConnectionCounter.load(ordering: .relaxed) != 0 {
                            return false
                        } else if await self.ws == nil {
                            return false
                        } else if await self.ws!.isClosed {
                            return false
                        } else if self.pingTaskInterval.load(ordering: .relaxed) < Int(tolerance) {
                            return false
                        } else {
                            return true
                        }
                    }()
                    
                    if tryToPingBeforeForceReconnect {
                        /// Try to see if discord responds to a ping before trying to reconnect.
                        await self.sendPing()
                        self.zombiedConnectionCounter.wrappingIncrement(ordering: .relaxed)
                        reschedule(in: .seconds(5))
                    } else {
                        self.logger.error("Detected zombied connection. Will try to reconnect.", metadata: [
                            "DiscordManagerID": .stringConvertible(self.id),
                        ])
                        self.connectionState.store(.noConnection, ordering: .relaxed)
                        self.connect()
                        reschedule(in: .seconds(30))
                    }
                }
            }
        }
    }
    
    private func schedulePingTask(every interval: TimeAmount) {
        self.pingTask?.cancel()
        let el = self.eventLoopGroup.any()
        self.pingTask = el.scheduleRepeatedTask(
            initialDelay: interval,
            delay: interval
        ) { [weak self] _ in
            guard let `self` = self else { return }
            Task {
                await self.sendPing()
            }
        }
    }
    
    private func sendPing() {
        self.send(payload: .init(opcode: .heartbeat))
    }
        
    private func send(payload: Gateway.Event, opcode: UInt8? = nil) {
        do {
            let data = try DiscordGlobalConfiguration.encoder.encode(payload)
            let opcode = opcode ?? UInt8(payload.opcode.rawValue)
            self.ws?.send(raw: data, opcode: .init(encodedWebSocketOpcode: opcode)!)
        } catch {
            logger.warning("Could not encode payload. This is a library issue, please report.", metadata: [
                "DiscordManagerID": .stringConvertible(id),
                "payload": "\(payload)",
                "opcode": "\(opcode ?? 255)"
            ])
        }
    }
    
    private nonisolated func closeWebsocket(ws: WebSocket?) {
        ws?.close().whenFailure { [weak self] in
            guard let `self` = self else { return }
            self.logger.warning("Connection close error.", metadata: [
                "DiscordManagerID": .stringConvertible(self.id),
                "error": "\($0)"
            ])
        }
    }
}

//MARK: - +WebSocket
private extension WebSocket {
    static func asyncConnect(
        to address: String,
        configuration: WebSocketClient.Configuration,
        on eventLoopGroup: EventLoopGroup
    ) async throws -> WebSocket {
        try await withCheckedThrowingContinuation { cont in
            WebSocket.connect(
                to: address,
                configuration: configuration,
                on: eventLoopGroup
            ) {
                cont.resume(returning: $0)
            }.whenFailure {
                cont.resume(throwing: $0)
            }
        }
    }
}


//MARK: - +EventLoop
private extension EventLoop {
    func wait(_ time: TimeAmount) async {
        try? await self.scheduleTask(in: time, { }).futureResult.get()
    }
}
