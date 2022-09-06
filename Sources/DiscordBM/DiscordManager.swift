import WebSocketKit
import Logging
import struct NIOCore.TimeAmount
import struct Foundation.Data
import struct Foundation.Date
import class NIO.RepeatedTask
import Atomics

public actor DiscordManager {
    
    var ws: WebSocket? {
        willSet {
            self.closeWebsocket()
        }
    }
    let eventLoopGroup: EventLoopGroup
    public nonisolated let client: DiscordClient
    
    var onEvents: [(Gateway.Event) -> ()] = []
    var onEventParseFilures: [(Error, String) -> ()] = []
    
    let token: String
    let presence: Gateway.Identify.PresenceUpdate?
    let intents: [Gateway.Identify.Intent]
    
    public nonisolated let id: String
    let logger: Logger
    
    var sequenceNumber: Int? = nil
    var lastEventDate = Date()
    var sessionId: String? = nil
    var resumeGatewayUrl: String? = nil
    
    var pingTask: RepeatedTask? = nil
    var zombiedConnectionCheckerTask: RepeatedTask? = nil
    let zombiedConnectionCounter = ManagedAtomic(0)
    
    public init(
        eventLoopGroup: EventLoopGroup,
        token: String,
        appId: String,
        presence: Gateway.Identify.PresenceUpdate? = nil,
        intents: [Gateway.Identify.Intent] = [],
        id: String? = nil
    ) {
        self.eventLoopGroup = eventLoopGroup
        self.client = DiscordClient(
            eventLoopGroupProvider: .shared(eventLoopGroup),
            token: token,
            appId: appId
        )
        self.token = token
        self.presence = presence
        self.intents = intents
        self.id = id ?? "\(Int.random(in: 10_000..<100_000))"
        self.logger = DiscordGlobalConfiguration.makeLogger("DiscordManager_\(self.id)")
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
        let gatewayUrl = await getGatewayUrl()
        var configuration = WebSocketClient.Configuration()
        configuration.maxFrameSize = 1 << 31
        do {
            self.ws = try await WebSocket.asyncConnect(
                to: gatewayUrl + "?v=\(DiscordGlobalConfiguration.apiVersion)",
                configuration: configuration,
                on: eventLoopGroup
            )
            configureWebsocket()
        } catch {
            logger.error("Error while connecting to Discord through websocket.", metadata: [
                "DiscordManagerID": .string(id),
                "error": "\(error)"
            ])
        }
    }
    
    private func configureWebsocket() {
        self.setupOnText()
        self.setupOnClose()
        self.setupzombiedConnectionCheckerTask()
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
                "DiscordManagerID": .string(id)
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
            self.sendResumeOrIdentify()
        case let .ready(payload):
            logger.notice("Received Discord Ready Notice.", metadata: [
                "DiscordManagerID": .string(id)
            ])
            self.sessionId = payload.session_id
            self.resumeGatewayUrl = payload.resume_gateway_url
        case .resumed:
            logger.notice("Received successful resume notice.", metadata: [
                "DiscordManagerID": .string(id)
            ])
        default:
            break
        }
    }
    
    private func getGatewayUrl() async -> String {
        if let gatewayUrl = resumeGatewayUrl {
            return gatewayUrl
        } else if let gatewayUrl = try? await client.getGateway().decode().url {
            return gatewayUrl
        } else {
            logger.error("Cannot get gateway url to connect to. Will retry in 5 seconds.", metadata: [
                "DiscordManagerID": .string(id)
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
                "DiscordManagerID": .string(id)
            ])
            
            return true
        }
        logger.notice("Can't resume last Discord connection.", metadata: [
            "sessionId_length": .stringConvertible(self.sessionId?.count ?? -1),
            "lastSequenceNumber": .stringConvertible(self.sequenceNumber ?? -1),
            "DiscordManagerID": .string(id)
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
            guard let selfi = self else { return }
            Task {
                let code = await selfi.ws?.closeCode
                selfi.logger.log(
                    /// If its `nil` or `.goingAway`, then it's likely just a resume notice.
                    /// Otherwise it might be an error.
                    level: (code == nil || code == .goingAway) ? .warning : .error,
                    "Received Discord Connection Close Notification.",
                    metadata: [
                        "DiscordManagerID": .string(selfi.id),
                        "code": "\(String(describing: code))"
                    ]
                )
                selfi.connect()
            }
        }
    }
    
    private func sendHello() {
        self.send(payload: .init(opcode: .hello))
    }
    
    private func setupzombiedConnectionCheckerTask() {
        self.zombiedConnectionCheckerTask?.cancel()
        let el = self.eventLoopGroup.any()
        self.zombiedConnectionCheckerTask = el.scheduleRepeatedTask(
            initialDelay: .seconds(30),
            delay: .seconds(30)
        ) { [weak self] _ in
            guard let selfi = self else { return }
            Task {
                guard await selfi.lastEventDate.addingTimeInterval(60) < Date() else { return }
                let counter = selfi.zombiedConnectionCounter.load(ordering: .relaxed)
                let ws = await selfi.ws
                if counter != 0 || ws == nil || ws!.isClosed {
                    selfi.logger.error("Detected zombied connection. Will try to reconnect.", metadata: [
                        "DiscordManagerID": .string(selfi.id),
                    ])
                    selfi.connect()
                } else {
                    /// Try to see if discord responds to a ping before trying to reconnect.
                    await selfi.sendPing()
                    selfi.zombiedConnectionCounter.wrappingIncrement(ordering: .relaxed)
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
            guard let selfi = self else { return }
            Task {
                await selfi.sendPing()
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
                "DiscordManagerID": .string(id),
                "payload": "\(payload)",
                "opcode": "\(opcode ?? 255)"
            ])
        }
    }
    
    private func closeWebsocket() {
        ws?.close().whenFailure { [weak self] in
            guard self != nil else { return }
            self!.logger.warning("Connection close error.", metadata: [
                "DiscordManagerID": .string(self!.id),
                "error": "\($0)"
            ])
        }
    }
}

//MARK: - WebSocket
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

private extension EventLoop {
    func wait(_ time: TimeAmount) async {
        try? await self.scheduleTask(in: time, { }).futureResult.get()
    }
}
