import Foundation
import WebSocketKit
import AsyncHTTPClient
import Atomics
import Logging
import enum NIOWebSocket.WebSocketErrorCode
import struct NIOCore.TimeAmount

#if swift(>=5.7)
/// If you're seeing the **Cannot find type 'AnyActor' in scope** error,
/// you need to update to Xcode 14.1. Sorry, this a known Xcode issue.
public protocol DiscordActor: AnyActor { }
#else /// Swift `5.6` doesn't have `AnyActor`.
public protocol DiscordActor: AnyObject { }
#endif

public protocol GatewayManager: DiscordActor {
    /// A client to send requests to Discord.
    nonisolated var client: any DiscordClient { get }
    /// This gateway manager's identifier.
    nonisolated var id: Int { get }
    /// The current state of the gateway manager.
    nonisolated var state: GatewayState { get }
    
    /// Starts connecting to Discord.
    func connect() async
    /// Requests members of guilds from discord.
    /// Refer to the documentation link of ``Gateway.RequestGuildMembers`` for more info.
    func requestGuildMembersChunk(payload: Gateway.RequestGuildMembers) async
    /// Adds a handler to be notified of events.
    func addEventHandler(_ handler: @escaping (Gateway.Event) -> Void) async
    /// Adds a handler to be notified of event parsing failures.
    func addEventParseFailureHandler(_ handler: @escaping (Error, String) -> Void) async
    /// Disconnects from Discord.
    func disconnect() async
}

public enum GatewayState: Int, Sendable, AtomicValue, CustomStringConvertible {
    case stopped
    case noConnection
    case connecting
    case configured
    case connected
    
    public var description: String {
        switch self {
        case .stopped: return "stopped"
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
    /// A client to send requests to Discord.
    public nonisolated let client: any DiscordClient
    /// Max frame size we accept to receive through the websocket connection.
    private nonisolated let maxFrameSize: Int
    private static let idGenerator = ManagedAtomic(0)
    /// This gateway manager's identifier.
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
    /// The current state of the gateway manager.
    public nonisolated var state: GatewayState {
        self._state.load(ordering: .relaxed)
    }
    
    //MARK: Send queue
    /// 120 per 60 seconds (1 every 500ms),
    /// per https://discord.com/developers/docs/topics/gateway#rate-limiting
    private var sendQueue = SerialQueue(waitTime: .milliseconds(500))
    
    //MARK: Current connection properties
    
    /// An ID to keep track of connection changes.
    private nonisolated let connectionId = ManagedAtomic(UInt(0))
    
    //MARK: Resume-related current-connection properties
    
    /// The sequence number for the payloads sent to us.
    private var sequenceNumber: Int? = nil
    /// The ID of the current Discord-related session.
    private var sessionId: String? = nil
    /// Gateway URL for resuming the connection, so we don't need to make an api call.
    private var resumeGatewayUrl: String? = nil
    
    //MARK: Shard-ing
    private var maxConcurrency: Int? = nil
    private var isFirstConnection = true
    
    //MARK: Backoff
    
    /// Discord cares about the identify payload for rate-limiting and if we send
    /// more than 1000 identifies in a day, Discord will revoke the bot token.
    /// This Backoff does not necessarily prevent your bot token getting revoked,
    /// but in the worst case, doesn't let it happen sooner than 8 hours.
    /// This also helps in other situations, for example when there is a Discord outage.
    private let connectionBackoff = Backoff(
        base: 2,
        maxExponentiation: 7,
        coefficient: 1,
        minBackoff: 15
    )
    
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
        presence: Gateway.Identify.Presence? = nil,
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
    
    /// Starts connecting to Discord.
    /// `_state` must be set to an appropriate value before triggering this function.
    public func connect() async {
        logger.debug("Connect method triggered")
        /// Guard we're attempting to connect too fast
        if let connectIn = await connectionBackoff.canPerformIn() {
            logger.warning("Cannot try to connect immediately due to backoff", metadata: [
                "wait-milliseconds": .stringConvertible(connectIn.nanoseconds / 1_000_000)
            ])
            await self.sleep(for: connectIn)
        }
        /// Guard if other connections are in process
        guard [.noConnection, .configured, .stopped].contains(self.state) else {
            logger.warning("Gateway state doesn't allow a new connection", metadata: [
                "state": .stringConvertible(state)
            ])
            return
        }
        self._state.store(.connecting, ordering: .relaxed)
        self.connectionId.wrappingIncrement(ordering: .relaxed)
        await self.sendQueue.reset()
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
            self.logger.debug("Connected to Discord through web-socket. Will configure")
            self.ws = ws
            self.configureWebSocket()
        }.whenFailure { [self] error in
            logger.error("WebSocket error while connecting to Discord", metadata: [
                "error": .string("\(error)")
            ])
            self._state.store(.noConnection, ordering: .relaxed)
            Task {
                await self.connect()
            }
        }
    }
    
    /// Requests members of guilds from discord.
    /// Refer to the documentation link of ``Gateway.RequestGuildMembers`` for more info.
    public func requestGuildMembersChunk(payload: Gateway.RequestGuildMembers) {
        /// This took a lot of time to figure out, not sure why it needs opcode `1`.
        self.send(payload: .init(
            opcode: .requestGuildMembers,
            data: .requestGuildMembers(payload)
        ), opcode: 1)
    }
    
    /// Adds a handler to be notified of events.
    public func addEventHandler(_ handler: @escaping (Gateway.Event) -> Void) {
        self.onEvents.append(handler)
    }
    
    /// Adds a handler to be notified of event parsing failures.
    public func addEventParseFailureHandler(_ handler: @escaping (Error, String) -> Void) {
        self.onEventParseFailures.append(handler)
    }
    
    /// Disconnects from Discord.
    public func disconnect() async {
        logger.debug("Will disconnect", metadata: [
            "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
        ])
        self.connectionId.wrappingIncrement(ordering: .relaxed)
        await connectionBackoff.resetTryCount()
        self.closeWebSocket(ws: self.ws)
        self._state.store(.stopped, ordering: .relaxed)
        self.isFirstConnection = true
        await self.sendQueue.reset()
    }
}

extension BotGatewayManager {
    private func configureWebSocket() {
        let connId = self.connectionId.load(ordering: .relaxed)
        self.setupOnText(forConnectionWithId: connId)
        self.setupOnClose(forConnectionWithId: connId)
        self._state.store(.configured, ordering: .relaxed)
    }
    
    private func processEvent(_ event: Gateway.Event) async {
        if let sequenceNumber = event.sequenceNumber {
            self.sequenceNumber = sequenceNumber
        }
        
        /// for `.reconnect`, we will reconnect when we get the close notification
        switch event.opcode {
        case .heartbeat:
            self.sendPing(forConnectionWithId: self.connectionId.load(ordering: .relaxed))
        case .heartbeatAccepted:
            self.lastPongDate = Date()
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
            await self.connect()
        case let .hello(hello):
            logger.debug("Received 'hello'")
            /// Disable websocket-kit automatic pings
            self.ws?.pingInterval = nil
            self.setupPingTask(
                forConnectionWithId: self.connectionId.load(ordering: .relaxed),
                every: .milliseconds(Int64(hello.heartbeat_interval))
            )
            await self.sendResumeOrIdentify()
        case let .ready(payload):
            logger.notice("Received ready notice. The connection is fully established", metadata: [
                "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
            ])
            await self.onSuccessfulConnection()
            self.sessionId = payload.session_id
            self.resumeGatewayUrl = payload.resume_gateway_url
        case .resumed:
            logger.notice("Received resume notice. The connection is fully established", metadata: [
                "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
            ])
            await self.onSuccessfulConnection()
        default:
            break
        }
    }
    
    private func getGatewayUrl() async -> String {
        logger.debug("Will try to get Discord gateway url")
        if let gatewayUrl = self.resumeGatewayUrl {
            logger.trace("Got Discord gateway url from `resumeGatewayUrl`")
            return gatewayUrl
        } else {
            /// If the bot is using shard-ing, we need to call a different endpoint
            /// to get some more info than only the gateway url.
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
    
    private func sendResumeOrIdentify() async {
        if let sessionId = self.sessionId,
           let lastSequenceNumber = self.sequenceNumber {
            self.sendResume(sessionId: sessionId, sequenceNumber: lastSequenceNumber)
        } else {
            logger.debug("Can't resume last Discord connection. Will identify", metadata: [
                "sessionId_length": .stringConvertible(self.sessionId?.count ?? -1),
                "lastSequenceNumber": .stringConvertible(self.sequenceNumber ?? -1)
            ])
            await self.sendIdentify()
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
            opcode: Gateway.Opcode.identify.rawValue
        )
        
        /// Invalidate `sequenceNumber` info for the next connection, incase this one fails.
        /// This will be a notice for the next connection to
        /// not try resuming anymore, if this connection has failed.
        self.sequenceNumber = nil
        
        logger.debug("Sent resume request to Discord")
    }
    
    private func sendIdentify() async {
        await connectionBackoff.willTry()
        let identify = Gateway.Event(
            opcode: .identify,
            data: .identify(identifyPayload)
        )
        self.send(payload: identify)
    }
    
    private func setupOnText(forConnectionWithId connectionId: UInt) {
        self.ws?.onText { _, text in
            self.logger.debug("Got text from websocket \(text)")
            guard self.connectionId.load(ordering: .relaxed) == connectionId else { return }
            let data = Data(text.utf8)
            do {
                let event = try DiscordGlobalConfiguration.decoder.decode(
                    Gateway.Event.self,
                    from: data
                )
                self.logger.debug("Decoded event: \(event)")
                Task {
                    await self.processEvent(event)
                }
                for onEvent in self.onEvents {
                    onEvent(event)
                }
            } catch {
                self.logger.debug("Failed to decode event. Error: \(error)")
                for onEventParseFailure in self.onEventParseFailures {
                    onEventParseFailure(error, text)
                }
            }
        }
    }
    
    private func setupOnClose(forConnectionWithId connectionId: UInt) {
        guard let ws = self.ws else {
            logger.error("Cannot setup web-socket on-close because there are no active web-sockets. This is an issue in the library, please report: https://github.com/MahdiBM/DiscordBM/issues")
            return
        }
        ws.onClose.whenComplete { [weak self] _ in
            guard let `self` = self else { return }
            self.logger.debug("Received connection close notification for a web-socket")
            guard self.connectionId.load(ordering: .relaxed) == connectionId else { return }
            Task {
                let (code, codeDesc) = self.getCloseCodeAndDescription(of: ws)
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
                if self.canTryReconnect(ws: ws) {
                    self._state.store(.noConnection, ordering: .relaxed)
                    await self.connect()
                } else {
                    self._state.store(.stopped, ordering: .relaxed)
                    self.connectionId.wrappingIncrement(ordering: .relaxed)
                    self.logger.critical("Will not reconnect because Discord does not allow it. Something is wrong. Your close code is '\(codeDesc)', check Discord docs at https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes and see what it means. Report at https://github.com/MahdiBM/DiscordBM/issues if you think this is a library issue")
                }
            }
        }
    }
    
    private nonisolated  func getCloseCodeAndDescription(
        of ws: WebSocket
    ) -> (WebSocketErrorCode?, String) {
        let code = ws.closeCode
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
    
    private nonisolated func canTryReconnect(ws: WebSocket) -> Bool {
        switch ws.closeCode {
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
            self.logger.debug("Will send automatic ping for connection id: \(connectionId)")
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
                logger.debug("Too many unsuccessful pings. Will try to reconnect", metadata: [
                    "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
                ])
                self._state.store(.noConnection, ordering: .relaxed)
                await self.connect()
            }
        }
    }
    
    private func send(
        payload: Gateway.Event,
        opcode: UInt8? = nil,
        connectionId: UInt? = nil,
        tryCount: Int = 0
    ) {
        self.sendQueue.perform { [self] in
            Task {
                if let connectionId = connectionId,
                   self.connectionId.load(ordering: .relaxed) != connectionId {
                    return
                }
                do {
                    let data = try DiscordGlobalConfiguration.encoder.encode(payload)
                    let opcode = opcode ?? payload.opcode.rawValue
                    if let ws = await self.ws {
                        try await ws.send(
                            raw: data,
                            opcode: .init(encodedWebSocketOpcode: opcode)!
                        )
                    } else {
                        logger.warning("Trying to send through ws when a connection is not established", metadata: [
                            "payload": .string("\(payload)"),
                            "state": .stringConvertible(self._state.load(ordering: .relaxed)),
                            "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
                        ])
                    }
                } catch {
                    logger.error("Could not encode payload. This is a library issue, please report on https://github.com/MahdiBM/DiscordBM/issues", metadata: [
                        "payload": .string("\(payload)"),
                        "opcode": .stringConvertible(opcode ?? .max),
                        "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
                    ])
                }
            }
        }
    }
    
    private func onSuccessfulConnection() async {
        self._state.store(.connected, ordering: .relaxed)
        await connectionBackoff.resetTryCount()
        self.unsuccessfulPingsCount = 0
        await self.sendQueue.reset()
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
        logger.debug("Will possibly close a web-socket")
        ws?.close().whenFailure {
            self.logger.warning("Connection close error", metadata: [
                "error": "\($0)"
            ])
        }
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
}
