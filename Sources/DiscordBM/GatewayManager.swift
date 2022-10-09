import Foundation
import WebSocketKit
import AsyncHTTPClient
import Atomics
import Logging
import enum NIOWebSocket.WebSocketErrorCode
import struct NIOCore.TimeAmount

#if swift(>=5.7)
public protocol GatewayManager: AnyActor {
    nonisolated var client: any DiscordClient { get }
    nonisolated var id: Int { get }
    nonisolated var state: GatewayState { get }
    
    nonisolated func connect()
    func requestGuildMembersChunk(payload: Gateway.RequestGuildMembers) async
    func addEventHandler(_ handler: @escaping (Gateway.Event) -> Void) async
    func addEventParseFailureHandler(_ handler: @escaping (Error, String) -> Void) async
    nonisolated func disconnect()
}
#else
public protocol GatewayManager: AnyObject {
    nonisolated var client: any DiscordClient { get }
    nonisolated var id: Int { get }
    nonisolated var state: GatewayState { get }
    
    nonisolated func connect()
    func requestGuildMembersChunk(payload: Gateway.RequestGuildMembers) async
    func addEventHandler(_ handler: @escaping (Gateway.Event) -> Void) async
    func addEventParseFailureHandler(_ handler: @escaping (Error, String) -> Void) async
    nonisolated func disconnect()
}
#endif

public enum GatewayState: Int, Sendable, AtomicValue, CustomStringConvertible {
    case dead
    case noConnection
    case connecting
    case configured
    case connected
    
    public var description: String {
        switch self {
        case .dead: return "dead"
        case .noConnection: return "noConnection"
        case .connecting: return "connecting"
        case .configured: return "configured"
        case .connected: return "connected"
        }
    }
}

public actor BotGatewayManager: GatewayManager {
    
    private weak var ws: WebSocket? {
        didSet {
            self.closeWebSocket(ws: oldValue)
        }
    }
    private let eventLoopGroup: any EventLoopGroup
    public nonisolated let client: any DiscordClient
    private nonisolated let maxFrameSize: Int
    private static let idGenerator = ManagedAtomic(0)
    public nonisolated let id = BotGatewayManager.idGenerator
        .wrappingIncrementThenLoad(ordering: .relaxed)
    private let logger: Logger
    
    //MARK: Event hooks
    private var onEvents: [(Gateway.Event) -> ()] = []
    private var onEventParseFailures: [(Error, String) -> ()] = []
    
    //MARK: Connection data
    private nonisolated let identifyPayload: Gateway.Identify
    
    //MARK: Connection state
    private nonisolated let _state = ManagedAtomic(GatewayState.noConnection)
    public nonisolated var state: GatewayState {
        self._state.load(ordering: .relaxed)
    }
    
    //MARK: Send queue
    private var lastSend = Date.distantPast
    
    //MARK: Current connection properties
    
    /// An ID to keep track of connection changes.
    private nonisolated let connectionId = ManagedAtomic(UInt(0))
    
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
    
    /// Try count for connections, so we can have exponential backoff.
    private var connectionTryCount = 0
    /// When last identify happened.
    ///
    /// Discord cares about the identify payload for rate-limiting and if we send
    /// more than 1000 identifies in a day, Discord will revoke the bot token.
    private var lastIdentifyDate = Date.distantPast
    
    //MARK: Ping-pong tracking properties
    private var unsuccessfulPingsCount = 0
    private var lastPongDate = Date()
    
    public init(
        eventLoopGroup: EventLoopGroup,
        httpClient: HTTPClient,
        client: any DiscordClient,
        maxFrameSize: Int =  1 << 31,
        appId: String? = nil,
        identifyPayload: Gateway.Identify
    ) {
        self.eventLoopGroup = eventLoopGroup
        self.client = client
        self.maxFrameSize = maxFrameSize
        self.identifyPayload = identifyPayload
        var logger = DiscordGlobalConfiguration.makeLogger("GatewayManager")
        logger[metadataKey: "gateway-id"] = .string("\(self.id)")
        self.logger = logger
    }
    
    public init(
        eventLoopGroup: EventLoopGroup,
        httpClient: HTTPClient,
        clientConfiguration: ClientConfiguration = .init(),
        maxFrameSize: Int =  1 << 31,
        appId: String? = nil,
        identifyPayload: Gateway.Identify
    ) {
        self.eventLoopGroup = eventLoopGroup
        self.client = DefaultDiscordClient(
            httpClient: httpClient,
            token: identifyPayload.token,
            appId: appId,
            configuration: clientConfiguration
        )
        self.maxFrameSize = maxFrameSize
        self.identifyPayload = identifyPayload
        var logger = DiscordGlobalConfiguration.makeLogger("GatewayManager")
        logger[metadataKey: "gateway-id"] = .string("\(self.id)")
        self.logger = logger
    }
    
    public init(
        eventLoopGroup: EventLoopGroup,
        httpClient: HTTPClient,
        clientConfiguration: ClientConfiguration = .init(),
        maxFrameSize: Int =  1 << 31,
        token: String,
        appId: String? = nil,
        shard: IntPair? = nil,
        presence: Gateway.Identify.PresenceUpdate? = nil,
        intents: [Gateway.Intent] = []
    ) {
        let token = Secret(token)
        self.eventLoopGroup = eventLoopGroup
        self.client = DefaultDiscordClient(
            httpClient: httpClient,
            token: token,
            appId: appId,
            configuration: clientConfiguration
        )
        self.maxFrameSize = maxFrameSize
        self.identifyPayload = .init(
            token: token,
            shard: shard,
            presence: presence,
            intents: intents
        )
        var logger = DiscordGlobalConfiguration.makeLogger("GatewayManager")
        logger[metadataKey: "gateway-id"] = .string("\(self.id)")
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

extension BotGatewayManager {
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
        self.connectionId.wrappingIncrement(ordering: .relaxed)
        self.lastSend = .distantPast
        let gatewayUrl = await getGatewayUrl()
        logger.trace("Will wait for other shards if needed")
        await waitInShardQueueIfNeeded()
        var configuration = WebSocketClient.Configuration()
        configuration.maxFrameSize = self.maxFrameSize
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
        self._state.store(.configured, ordering: .relaxed)
    }
    
    private func processEvent(_ event: Gateway.Event) {
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
            break /// handled in event.data
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
            self.sendResumeOrIdentify()
        case let .ready(payload):
            logger.notice("Received ready notice. The connection is fully established", metadata: [
                "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
            ])
            self.onSuccessfulConnection()
            self.sessionId = payload.session_id
            self.resumeGatewayUrl = payload.resume_gateway_url
        case .resumed:
            logger.notice("Received resume notice. The connection is fully established", metadata: [
                "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
            ])
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
            if identifyPayload.shard == nil {
                if let gatewayUrl = try? await client.getGateway().decode().url {
                    logger.trace("Got Discord gateway url from gateway api call")
                    return gatewayUrl
                }
            } else {
                if let gatewayBot = try? await client.getGatewayBot().decode() {
                    logger.trace("Got Discord gateway url from gateway-bot api call. Max concurrency: \(gatewayBot.session_start_limit.max_concurrency)")
                    self.maxConcurrency = gatewayBot.session_start_limit.max_concurrency
                    return gatewayBot.url
                }
            }
            logger.error("Cannot get gateway url to connect to. Will retry in 10 seconds")
            await self.sleep(for: .seconds(10))
            return await self.getGatewayUrl()
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
        /// This will be a notice for the next connection to don't try resuming anymore.
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
    
    private func setupOnText(forConnectionWithId connectionId: UInt) {
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
    
    private func setupOnClose(forConnectionWithId connectionId: UInt) {
        self.ws?.onClose.whenComplete { [weak self] _ in
            guard let `self` = self else { return }
            self.logger.trace("Received connection close notification for a web-socket")
            guard self.connectionId.load(ordering: .relaxed) == connectionId else { return }
            Task {
                let (code, codeDesc) = await self.getCloseCodeAndDescription()
                self.logger.log(
                    /// If its `nil` or `.goingAway`, then it's likely just a resume notice.
                    /// Otherwise it might be an error.
                    level: (code == nil || code == .goingAway) ? .notice : .error,
                    "Received connection close notification. Will try to reconnect",
                    metadata: [
                        "code": .string(codeDesc),
                        "closedConnectionId": .stringConvertible(
                            self.connectionId.load(ordering: .relaxed)
                        )
                    ]
                )
                if await self.canTryReconnect() {
                    self._state.store(.noConnection, ordering: .relaxed)
                    self.connect()
                } else {
                    self._state.store(.dead, ordering: .relaxed)
                    self.logger.critical("Will not reconnect because Discord does not allow it. Something is wrong. Your close code is '\(codeDesc)', check Discord docs at https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes and see what it means. Report at https://github.com/MahdiBM/DiscordBM/issues if you think this is a library issue")
                }
            }
        }
    }
    
    private func getCloseCodeAndDescription() -> (WebSocketErrorCode?, String) {
        let code = self.ws?.closeCode
        let description: String
        switch code {
        case let .unknown(codeNumber):
            switch Gateway.CloseCode(rawValue: codeNumber) {
            case let .some(discordCode):
                description = "\(discordCode)"
            case .none:
                description = "\(codeNumber)"
            }
        case let .some(anyOtherCode):
            description = "\(anyOtherCode)"
        case .none:
            description = "nil"
        }
        return (code, description)
    }
    
    private func canTryReconnect() -> Bool {
        guard let code = self.ws?.closeCode else { return true }
        switch code {
        case let .unknown(codeNumber):
            guard let discordCode = Gateway.CloseCode(rawValue: codeNumber) else { return true }
            return discordCode.canTryReconnect
        default: return true
        }
    }
    
    private func setupPingTask(
        forConnectionWithId connectionId: UInt,
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
    
    private func sendPing(forConnectionWithId connectionId: UInt) {
        logger.trace("Will ping for connection id \(connectionId)")
        self.send(payload: .init(
            opcode: .heartbeat,
            data: .heartbeat(lastSequenceNumber: self.sequenceNumber)
        ))
        Task {
            await self.sleep(for: .seconds(10))
            guard self.connectionId.load(ordering: .relaxed) == connectionId else { return }
            /// 15 == 10 + 5. 10 seconds that we slept, + 5 seconds tolerance.
            /// The tolerance being too long should not matter as pings usually happen
            /// only once in ~45 seconds, and a successful ping will reset the counter anyway.
            if self.lastPongDate.addingTimeInterval(15) > Date() {
                logger.trace("Successful ping")
                self.unsuccessfulPingsCount = 0
            } else {
                logger.trace("Unsuccessful ping")
                self.unsuccessfulPingsCount += 1
            }
            if unsuccessfulPingsCount > 2 {
                logger.error("Too many unsuccessful pings. Will try to reconnect", metadata: [
                    "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
                ])
                self._state.store(.noConnection, ordering: .relaxed)
                self.connect()
            }
        }
    }
    
    private func send(
        payload: Gateway.Event,
        opcode: UInt8? = nil,
        connectionId: UInt? = nil,
        tryCount: Int = 0
    ) {
        if let connectionId = connectionId,
           self.connectionId.load(ordering: .relaxed) != connectionId {
            return
        }
        /// Can't keep a payload in queue forever, it'll exhaust bot's resources eventually.
        guard tryCount <= 10 else {
            logger.error("Send queue is too busy, will cancel sending a payload", metadata: [
                "failedTryCount": .stringConvertible(tryCount),
                "payload": "\(payload)",
                "opcode": "\(String(describing: opcode))",
                "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
            ])
            return
        }
        /// If there has been a send in the last `waitTime`, queue this
        /// payload to be sent after its been `waitTime` already.
        let waitTime = 0.25
        let now = Date().timeIntervalSince1970
        let past = now - self.lastSend.timeIntervalSince1970
        guard past > waitTime else {
            let waitMore = Int64((waitTime - past) * 1_000) + 1
            Task {
                await self.sleep(for: .milliseconds(waitMore))
                self.send(
                    payload: payload,
                    opcode: opcode,
                    connectionId: connectionId ?? self.connectionId.load(ordering: .relaxed),
                    tryCount: tryCount + 1
                )
            }
            return
        }
        do {
            let data = try DiscordGlobalConfiguration.encoder.encode(payload)
            let opcode = opcode ?? UInt8(payload.opcode.rawValue)
            if let ws = self.ws {
                self.lastSend = Date()
                ws.send(raw: data, opcode: .init(encodedWebSocketOpcode: opcode)!)
            } else {
                logger.warning("Trying to send through ws when a connection is not established", metadata: [
                    "payload": "\(payload)",
                    "state": .stringConvertible(self._state.load(ordering: .relaxed)),
                    "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
                ])
            }
        } catch {
            logger.error("Could not encode payload. This is a library issue, please report on https://github.com/MahdiBM/DiscordBM/issues", metadata: [
                "payload": "\(payload)",
                "opcode": .stringConvertible(opcode ?? 255),
                "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
            ])
        }
    }
    
    private func onSuccessfulConnection() {
        self._state.store(.connected, ordering: .relaxed)
        self.connectionTryCount = 0
        self.unsuccessfulPingsCount = 0
        self.lastSend = .distantPast
    }
    
    /// Returns `nil` if can connect immediately,
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
                /// These 2 seconds is nothing scientific.
                /// Optimally we should implement managing all shards of a bot together
                /// so we can know when shards connect and can start the new bucket, but
                /// that doesn't seem easy as shards might be running outside only 1
                /// process and we won't be able to manage them easily.
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
        logger.trace("Will disconnect", metadata: [
            "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
        ])
        self.connectionId.wrappingIncrement(ordering: .relaxed)
        self.connectionTryCount = 0
        self.closeWebSocket(ws: self.ws)
        self._state.store(.noConnection, ordering: .relaxed)
        self.isFirstConnection = true
        self.lastSend = .distantPast
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
