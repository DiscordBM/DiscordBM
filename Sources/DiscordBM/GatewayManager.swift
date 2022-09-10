import WebSocketKit
import enum NIOWebSocket.WebSocketErrorCode
import Logging
import struct NIOCore.TimeAmount
import struct Foundation.Data
import struct Foundation.Date
import Atomics
import AsyncHTTPClient
import struct Foundation.UUID
import Foundation

public actor GatewayManager {
    
    public enum State: Int, AtomicValue, CustomStringConvertible {
        case noConnection
        case connecting
        case configured
        case connected
        
        public var description: String {
            switch self {
            case .noConnection: return "noConnection"
            case .connecting: return "connecting"
            case .configured: return "configured"
            case .connected: return "connected"
            }
        }
    }
    
    private weak var ws: WebSocket? {
        didSet {
            self.closeWebSocket(ws: oldValue)
        }
    }
    private nonisolated let eventLoopGroup: EventLoopGroup
    public nonisolated let client: DiscordClient
    private static let idGenerator = ManagedAtomic(0)
    public nonisolated let id = GatewayManager.idGenerator.wrappingIncrementThenLoad(ordering: .relaxed)
    private let logger: Logger
    
    //MARK: Event hooks
    private var onEvents: [(Gateway.Event) -> ()] = []
    private var onEventParseFailures: [(Error, String) -> ()] = []
    
    //MARK: Connection data
    public nonisolated let identifyPayload: Gateway.Identify
    
    //MARK: Connection state
    private nonisolated let _state = ManagedAtomic(State.noConnection)
    public nonisolated var state: State {
        self._state.load(ordering: .relaxed)
    }
    
    //MARK: Current connection properties
    
    /// An ID to keep track of connection changes.
    private nonisolated let connectionId = ManagedAtomic(Int.random(in: Int.min...Int.max))
    
    private var pingTaskInterval = 0
    private var lastEventDate = Date()
    
    //MARK: Resume-related current-connection properties
    
    /// The sequence number for the current payloads sent to us.
    private var sequenceNumber: Int? = nil
    /// The ID of the current Discord-related session.
    private var sessionId: String? = nil
    /// Gateway URL for resuming the connection, so we don't have to make an api call.
    private var resumeGatewayUrl: String? = nil
    
    //MARK: Shard-ing
    
    private var maxConcurrency: Int? = nil
    private var isFirstConnection = true
    
    //MARK: Backoff properties
    
    /// Try count for connections.
    private var connectionTryCount = 0
    /// When last identify happened.
    ///
    /// Discord only cares about the identify payload for rate-limiting and if we send
    /// more than 1000 identifies in a day, Discord will revoke the bot token.
    private var lastIdentifyDate = Date.distantPast
    
    //MARK: Zombied-connection-checker
    
    /// Counter to keep track of how many times in a sequence a zombied connection was detected.
    private nonisolated let zombiedConnectionCounter = ManagedAtomic(0)
    
    //MARK: Ping-pong tracking properties
    private var unsuccessfulPingsCount = 0
    private var lastPongDate = Date()
    
    public init(
        eventLoopGroup: EventLoopGroup,
        httpClient: HTTPClient,
        appId: String,
        identifyPayload: Gateway.Identify
    ) {
        self.eventLoopGroup = eventLoopGroup
        self.client = DiscordClient(
            httpClient: httpClient,
            token: identifyPayload.token,
            appId: appId
        )
        self.identifyPayload = identifyPayload
        var logger = DiscordGlobalConfiguration.makeLogger("GatewayManager")
        logger[metadataKey: "GatewayManager-id"] = .string("\(self.id)")
        self.logger = logger
    }
    
    public init(
        eventLoopGroup: EventLoopGroup,
        httpClient: HTTPClient,
        token: String,
        appId: String,
        presence: Gateway.Identify.PresenceUpdate? = nil,
        intents: [Gateway.Identify.Intent] = [],
        shard: IntPair? = nil
    ) {
        self.eventLoopGroup = eventLoopGroup
        self.client = DiscordClient(
            httpClient: httpClient,
            token: token,
            appId: appId
        )
        self.identifyPayload = .init(
            token: token,
            shard: shard,
            presence: presence,
            intents: .init(values: intents)
        )
        var logger = DiscordGlobalConfiguration.makeLogger("GatewayManager")
        logger[metadataKey: "gateway-manager-id"] = .string("\(self.id)")
        self.logger = logger
    }
    
    public nonisolated func connect() {
        Task {
            await connectAsync()
        }
    }
    
    public func requestGuildMembersChunk(payload: Gateway.RequestGuildMembers) {
        /// This took a lot of time to figure out, not sure why it needs opcode `0x1`.
        self.send(payload: .init(
            opcode: .requestGuildMembers,
            data: .requestGuildMembers(payload)
        ), opcode: 0x1)
    }
    
    public func addEventHandler(_ handler: @escaping (Gateway.Event) -> Void) {
        self.onEvents.append(handler)
    }
    
    public func addEventParseFailureHandler(_ handler: @escaping (Error, String) -> Void) {
        self.onEventParseFailures.append(handler)
    }
    
    public nonisolated func disconnect() {
        Task {
            await self.disconnectAsync()
        }
    }
}

extension GatewayManager {
    /// `_state` must be set to an appropriate value before triggering this function.
    private func connectAsync() async {
        logger.trace("Connect method triggered")
        /// Guard if other connections are in process
        let state = self._state.load(ordering: .relaxed)
        guard state == .noConnection || state == .configured else {
            logger.warning("Gateway state doesn't allow a new connection", metadata: [
                "state": .stringConvertible(state)
            ])
            return
        }
        /// Guard we're attempting to connect too fast
        if let connectIn = canTryToConnectIn() {
            logger.warning("Cannot try to connect immediately due to backoff", metadata: [
                "wait-milliseconds": .stringConvertible(connectIn.nanoseconds / 1_000_000)
            ])
            await self.sleep(for: connectIn)
            await self.connectAsync()
            return
        }
        self._state.store(.connecting, ordering: .relaxed)
        self.connectionId.store(.random(in: Int.min...Int.max), ordering: .relaxed)
        self.lastEventDate = Date()
        let gatewayUrl = await getGatewayUrl()
        logger.trace("Will wait for other shards if needed")
        await waitInShardQueueIfNeeded()
        var configuration = WebSocketClient.Configuration()
        configuration.maxFrameSize = DiscordGlobalConfiguration.webSocketMaxFrameSize
        logger.trace("Will try to connect to Discord through web-socket")
        WebSocket.connect(
            to: gatewayUrl + "?v=\(DiscordGlobalConfiguration.apiVersion)&encoding=json",
            configuration: configuration,
            on: eventLoopGroup
        ) { ws in
            self.logger.trace("Connected to Discord through web-socket. Will configure")
            self.ws = ws
            self.configureWebSocket()
        }.whenFailure { [self] error in
            logger.error("WebSocket error while connecting to Discord", metadata: [
                "error": "\(error)"
            ])
            self._state.store(.noConnection, ordering: .relaxed)
            Task {
                await self.sleep(for: .seconds(5))
                await connectAsync()
            }
        }
    }
    
    private func configureWebSocket() {
        let connId = self.connectionId.load(ordering: .relaxed)
        self.setupOnText(forConnectionWithId: connId)
        self.setupOnClose(forConnectionWithId: connId)
        self.setupZombiedConnectionCheckerTask(forConnectionWithId: connId)
        self._state.store(.configured, ordering: .relaxed)
    }
    
    private func processEvent(_ event: Gateway.Event) {
        self.lastEventDate = Date()
        self.zombiedConnectionCounter.store(0, ordering: .relaxed)
        if let sequenceNumber = event.sequenceNumber {
            self.sequenceNumber = sequenceNumber
        }
        
        switch event.opcode {
        case .reconnect:
            break // will reconnect when we get the close notification
        case .heartbeat:
            self.sendPing(forConnectionWithId: self.connectionId.load(ordering: .relaxed))
        case .heartbeatAccepted:
            self.lastPongDate = Date()
        case .invalidSession:
            break /// handeled in event.data
        default:
            break
        }
        
        switch event.data {
        case let .invalidSession(canResume):
            logger.warning("Got invalid session. Will try to reconnect", metadata: [
                "canResume": .stringConvertible(canResume)
            ])
            if !canResume {
                self.sequenceNumber = nil
                self.resumeGatewayUrl = nil
                self.sessionId = nil
            }
            self._state.store(.noConnection, ordering: .relaxed)
            self.connect()
        case let .hello(hello):
            logger.trace("Received 'hello'")
            let interval: TimeAmount = .milliseconds(Int64(hello.heartbeat_interval))
            /// Disable websocket-kit automatic pings
            self.ws?.pingInterval = nil
            self.setupPingTask(
                forConnectionWithId: self.connectionId.load(ordering: .relaxed),
                every: interval
            )
            self.pingTaskInterval = hello.heartbeat_interval
            self.sendResumeOrIdentify()
        case let .ready(payload):
            logger.notice("Received ready notice. The connection is fully established now")
            self.onSuccessfulConnection()
            self.sessionId = payload.session_id
            self.resumeGatewayUrl = payload.resume_gateway_url
        case .resumed:
            logger.notice("Received resume notice. The connection is fully established now")
            self.onSuccessfulConnection()
        default:
            break
        }
    }
    
    private func getGatewayUrl() async -> String {
        logger.trace("Will try to get Discord gateway url")
        if let gatewayUrl = self.resumeGatewayUrl {
            logger.trace("Got Discord gateway url from `resumeGatewayUrl`")
            return gatewayUrl
        } else {
            if identifyPayload.shard == nil,
               let gatewayUrl = try? await client.getGateway().decode().url {
                logger.trace("Got Discord gateway url from gateway api call")
                return gatewayUrl
            } else if let gatewayBot = try? await client.getGatewayBot().decode() {
                logger.trace("Got Discord gateway url from gateway-bot api call. Max concurrency: \(gatewayBot.session_start_limit.max_concurrency)")
                self.maxConcurrency = gatewayBot.session_start_limit.max_concurrency
                return gatewayBot.url
            } else {
                logger.error("Cannot get gateway url to connect to. Will retry in 5 seconds")
                await self.sleep(for: .seconds(5))
                return await self.getGatewayUrl()
            }
        }
    }
    
    private func sendResumeOrIdentify() {
        if let sessionId = self.sessionId,
           let lastSequenceNumber = self.sequenceNumber {
            self.sendResume(sessionId: sessionId, sequenceNumber: lastSequenceNumber)
        } else {
            logger.debug("Can't resume last Discord connection. Will identify", metadata: [
                "sessionId_length": .stringConvertible(self.sessionId?.count ?? -1),
                "lastSequenceNumber": .stringConvertible(self.sequenceNumber ?? -1)
            ])
            self.sendIdentify()
        }
    }
    
    private func sendResume(sessionId: String, sequenceNumber: Int) {
        let resume = Gateway.Event(
            opcode: .resume,
            data: .resume(.init(
                token: identifyPayload.token,
                session_id: sessionId,
                seq: sequenceNumber
            ))
        )
        self.send(
            payload: resume,
            opcode: UInt8(Gateway.Opcode.identify.rawValue)
        )
        
        /// Invalidate these temporary info for the next connection, incase this one fails.
        self.sequenceNumber = nil
        self.resumeGatewayUrl = nil
        /// Don't invalidate `sessionId` because it'll be needed for the next resumes as well.
        
        logger.trace("Sent resume request to Discord")
    }
    
    private func sendIdentify() {
        self.lastIdentifyDate = Date()
        let identify = Gateway.Event(
            opcode: .identify,
            data: .identify(identifyPayload)
        )
        self.send(payload: identify)
    }
    
    private func setupOnText(forConnectionWithId connectionId: Int) {
        self.ws?.onText { _, text in
            self.logger.trace("Got text from websocket \(text)")
            guard self.connectionId.load(ordering: .relaxed) == connectionId else { return }
            let data = Data(text.utf8)
            do {
                let event = try DiscordGlobalConfiguration.decoder.decode(
                    Gateway.Event.self,
                    from: data
                )
                self.logger.trace("Decoded event: \(event)")
                self.processEvent(event)
                for onEvent in self.onEvents {
                    onEvent(event)
                }
            } catch {
                self.logger.trace("Failed to decode event. Error: \(error)")
                for onEventParseFailure in self.onEventParseFailures {
                    onEventParseFailure(error, text)
                }
            }
        }
    }
    
    private func setupOnClose(forConnectionWithId connectionId: Int) {
        self.ws?.onClose.whenComplete { _ in
            self.logger.trace("Received connection close notification for a web-socket")
            guard self.connectionId.load(ordering: .relaxed) == connectionId else { return }
            Task {
                let code: WebSocketErrorCode?
#if swift(>=5.7)
                code = await self.ws?.closeCode
#else
                code = self.ws?.closeCode
#endif
                self.logger.log(
                    /// If its `nil` or `.goingAway`, then it's likely just a resume notice.
                    /// Otherwise it might be an error.
                    level: (code == nil || code == .goingAway) ? .notice : .error,
                    "Received connection close notification. Will try to reconnect",
                    metadata: ["code": "\(String(describing: code))"]
                )
                self._state.store(.noConnection, ordering: .relaxed)
                self.connect()
            }
        }
    }
    
    private func setupZombiedConnectionCheckerTask(forConnectionWithId connectionId: Int) {
        guard let tolerance = DiscordGlobalConfiguration.zombiedConnectionCheckerTolerance
        else { return }
        Task {
            logger.trace("Will check for zombied connection")
            await self.sleep(for: .seconds(10))
            
            /// If connection has changed then end this instance.
            guard self.connectionId.load(ordering: .relaxed) == connectionId else { return }
            func reschedule(in time: TimeAmount) async {
                await self.sleep(for: time)
                self.setupZombiedConnectionCheckerTask(forConnectionWithId: connectionId)
            }
            let now = Date().timeIntervalSince1970
            let lastEvent = self.lastEventDate.timeIntervalSince1970
            let past = now - lastEvent
            let diff = tolerance - past
            if diff > 0 {
                await reschedule(in: .seconds(Int64(diff) + 1))
            } else {
                let tryToPingBeforeForceReconnect: Bool = {
                    if self.zombiedConnectionCounter.load(ordering: .relaxed) != 0 {
                        return false
                    } else if self.ws == nil {
                        return false
                    } else if self.ws!.isClosed {
                        return false
                    } else if self.pingTaskInterval < Int(tolerance) {
                        return false
                    } else {
                        return true
                    }
                }()
                
                if tryToPingBeforeForceReconnect {
                    logger.trace("Will increase the zombied connection counter")
                    /// Try to see if discord responds to a ping before trying to reconnect.
                    self.sendPing(forConnectionWithId: connectionId)
                    self.zombiedConnectionCounter.wrappingIncrement(ordering: .relaxed)
                    await reschedule(in: .seconds(5))
                } else {
                    self.logger.error("Detected zombied connection. Will try to reconnect")
                    self._state.store(.noConnection, ordering: .relaxed)
                    self.connect()
                    await reschedule(in: .seconds(30))
                }
            }
        }
    }
    
    private func setupPingTask(
        forConnectionWithId connectionId: Int,
        every interval: TimeAmount
    ) {
        Task {
            await self.sleep(for: interval)
            guard self.connectionId.load(ordering: .relaxed) == connectionId else {
                self.logger.trace("Canceled a ping task with connection id: \(connectionId)")
                return // cancel
            }
            self.logger.trace("Will send automatic ping for connection id: \(connectionId)")
            self.sendPing(forConnectionWithId: connectionId)
            self.setupPingTask(forConnectionWithId: connectionId, every: interval)
        }
    }
    
    private func sendPing(forConnectionWithId connectionId: Int) {
        logger.trace("Will ping for connection id \(connectionId)")
        self.send(payload: .init(opcode: .heartbeat))
        Task {
            await self.sleep(for: .seconds(10))
            guard self.connectionId.load(ordering: .relaxed) == connectionId else { return }
            /// 15 == 10 + 5. 10 seconds that we slept, + 5 seconds tolerance.
            /// The tolerance being too long should not matter as pings usually happen
            /// only once in ~45 seconds, and a successful ping will reset the counter anyway.
            if self.lastPongDate.addingTimeInterval(15) > Date() {
                logger.trace("Successful ping")
                /// Successful ping
                self.unsuccessfulPingsCount = 0
            } else {
                logger.trace("Unsuccessful ping")
                /// Unsuccessful ping
                self.unsuccessfulPingsCount += 1
            }
            if unsuccessfulPingsCount > 2 {
                logger.error("Too many unsuccessful pings. Will try to reconnect")
                self._state.store(.noConnection, ordering: .relaxed)
                self.connect()
            }
        }
    }
        
    private func send(payload: Gateway.Event, opcode: UInt8? = nil) {
        do {
            let data = try DiscordGlobalConfiguration.encoder.encode(payload)
            let opcode = opcode ?? UInt8(payload.opcode.rawValue)
            if let ws = self.ws {
                ws.send(raw: data, opcode: .init(encodedWebSocketOpcode: opcode)!)
            } else {
                logger.warning("Trying to send through ws when a connection is not established", metadata: [
                    "payload": "\(payload)",
                    "state": "\(self._state.load(ordering: .relaxed))"
                ])
            }
        } catch {
            logger.error("Could not encode payload. This is a library issue, please report", metadata: [
                "payload": "\(payload)",
                "opcode": "\(opcode ?? 255)"
            ])
        }
    }
    
    private func onSuccessfulConnection() {
        self._state.store(.connected, ordering: .relaxed)
        self.connectionTryCount = 0
        self.unsuccessfulPingsCount = 0
    }
    
    /// Retuns `nil` if can connect immediately,
    /// otherwise `TimeAmount` to wait before attempting to connect.
    /// Increases `connectionTryCount`.
    private func canTryToConnectIn() -> TimeAmount? {
        let tryCount = self.connectionTryCount
        let lastIdentify = self.lastIdentifyDate.timeIntervalSince1970
        let now = Date().timeIntervalSince1970
        if tryCount == 0 {
            /// Even if the last connection was successful, don't try to connect too fast.
            let timePast = now - lastIdentify
            let minTimePast = 15.0
            if timePast > minTimePast {
                return nil
            } else {
                let remaining = minTimePast - timePast
                let millis = Int64(remaining * 1_000)
                return .milliseconds(millis)
            }
        } else {
            let effectiveTryCount = min(tryCount, 7)
            let factor = pow(Double(2), Double(effectiveTryCount))
            let timePast = now - lastIdentify
            let waitMore = factor - timePast
            if waitMore > 0 {
                self.connectionTryCount += 1
                let millis = Int64(waitMore * 1_000) + 1
                return .milliseconds(millis)
            } else {
                return nil
            }
        }
    }
    
    private func waitInShardQueueIfNeeded() async {
        if isFirstConnection,
           let shard = identifyPayload.shard,
           let maxConcurrency = maxConcurrency {
            isFirstConnection = false
            let bucketIndex = shard.first / maxConcurrency
            if bucketIndex > 0 {
                /// Wait 2 seconds for each bucket index.
                /// These 2 seconds is just a number I deemed safe.
                /// Optimally we should implement managing all shards of a bot together
                /// so we can know when shards connect and can start the new bucket, but
                /// that doesn't seem easy as shard might be running outside only 1
                /// process and we won't be able to know manage them easily.
                await self.sleep(for: .seconds(Int64(bucketIndex) * 2))
            }
        }
    }
    
    private nonisolated func closeWebSocket(ws: WebSocket?) {
        logger.trace("Will possibly close a web-socket")
        ws?.close().whenFailure {
            self.logger.warning("Connection close error", metadata: [
                "error": "\($0)"
            ])
        }
    }
    
    private func disconnectAsync() {
        self.connectionId.store(.random(in: Int.min...Int.max), ordering: .relaxed)
        self.closeWebSocket(ws: self.ws)
        self._state.store(.noConnection, ordering: .relaxed)
        self.isFirstConnection = true
    }
    
    private func sleep(for time: TimeAmount) async {
        do {
            try await Task.sleep(nanoseconds: UInt64(time.nanoseconds))
        } catch {
            logger.warning("Task failed to sleep properly", metadata: [
                "error": "\(error)"
            ])
        }
    }
    
    // Not yet in use due to Xcode 14 availability check problems in CI
//    private func sleep(for time: TimeAmount) async {
//        do {
//            if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
//#if swift(>=5.7)
//                try await Task.sleep(
//                    until: .now + .nanoseconds(time.nanoseconds),
//                    clock: .continuous
//                )
//#else
//                try await Task.sleep(nanoseconds: UInt64(time.nanoseconds))
//#endif
//            } else {
//                try await Task.sleep(nanoseconds: UInt64(time.nanoseconds))
//            }
//        } catch {
//            logger.warning("Task failed to sleep properly", metadata: [
//                "error": "\(error)"
//            ])
//        }
//    }
}
