import DiscordWebSocket
import Foundation
import AsyncHTTPClient
import Atomics
import Logging
import enum NIOWebSocket.WebSocketErrorCode
import struct NIOCore.TimeAmount

public actor BotGatewayManager: GatewayManager {
    
    private weak var ws: WebSocket?
    let eventLoopGroup: any EventLoopGroup
    /// A client to send requests to Discord.
    public nonisolated let client: any DiscordClient
    /// Max frame size we accept to receive through the websocket connection.
    nonisolated let maxFrameSize: Int
    /// Generator of `BotGatewayManager` ids.
    static let idGenerator = ManagedAtomic(UInt(0))
    /// This gateway manager's identifier.
    public nonisolated let id = BotGatewayManager.idGenerator
        .wrappingIncrementThenLoad(ordering: .relaxed)
    let logger: Logger
    
    //MARK: Event handlers
    var eventStreamContinuations = [AsyncStream<Gateway.Event>.Continuation]()
    var eventParseFailureContinuations = [AsyncStream<(Error, ByteBuffer)>.Continuation]()
    
    //MARK: Connection data
    nonisolated let identifyPayload: Gateway.Identify
    
    //MARK: Connection state
    nonisolated let _state = ManagedAtomic(GatewayState.noConnection)
    /// The current state of the gateway manager.
    public nonisolated var state: GatewayState {
        self._state.load(ordering: .relaxed)
    }
    
    //MARK: Send queue
    
    /// 120 per 60 seconds (1 every 500ms),
    /// per https://discord.com/developers/docs/topics/gateway#rate-limiting
    var sendQueue = SerialQueue(waitTime: .milliseconds(500))
    
    //MARK: Current connection properties
    
    /// An ID to keep track of connection changes.
    nonisolated let connectionId = ManagedAtomic(UInt(0))
    
    //MARK: Resume-related current-connection properties
    
    /// The sequence number for the payloads sent to us.
    var sequenceNumber: Int? = nil
    /// The ID of the current Discord-related session.
    var sessionId: String? = nil
    /// Gateway URL for resuming the connection, so we don't need to make an api call.
    var resumeGatewayURL: String? = nil
    
    //MARK: Shard-ing
    var maxConcurrency: Int? = nil
    var isFirstConnection = true
    
    //MARK: Compression
    let compression: Bool
    
    //MARK: Backoff
    
    /// Discord cares about the identify payload for rate-limiting and if we send
    /// more than 1000 identifies in a day, Discord will revoke the bot token.
    /// This Backoff does not necessarily prevent your bot token getting revoked,
    /// but in the worst case, doesn't let it happen sooner than ~6 hours.
    /// This also helps in other situations, for example when there is a Discord outage.
    let connectionBackoff = Backoff(
        base: 2,
        maxExponentiation: 7,
        coefficient: 1,
        minBackoff: 15
    )
    
    //MARK: Ping-pong tracking properties
    var unsuccessfulPingsCount = 0
    var lastPongDate = Date()
    
    /// - Parameters:
    ///   - eventLoopGroup: An `EventLoopGroup`.
    ///   - httpClient: A `HTTPClient`.
    ///   - client: A `DiscordClient` to use.
    ///   - maxFrameSize: Max frame size the WebSocket should allow receiving.
    ///   - compression: Enables transport compression for less network bandwidth usage.
    ///   - appId: Your Discord application id.
    ///   - identifyPayload: The identification payload that is sent to Discord.
    public init(
        eventLoopGroup: EventLoopGroup,
        client: any DiscordClient,
        maxFrameSize: Int =  1 << 31,
        compression: Bool = true,
        identifyPayload: Gateway.Identify
    ) {
        self.eventLoopGroup = eventLoopGroup
        self.client = client
        self.maxFrameSize = maxFrameSize
        self.compression = compression
        self.identifyPayload = identifyPayload
        var logger = DiscordGlobalConfiguration.makeLogger("GatewayManager")
        logger[metadataKey: "gateway-id"] = .string("\(self.id)")
        self.logger = logger
    }
    
    /// - Parameters:
    ///   - eventLoopGroup: An `EventLoopGroup`.
    ///   - httpClient: A `HTTPClient`.
    ///   - clientConfiguration: Configuration of the `DiscordClient`.
    ///   - maxFrameSize: Max frame size the WebSocket should allow receiving.
    ///   - compression: Enables transport compression for less network bandwidth usage
    ///    but more CPU load.
    ///   - appId: Your Discord application id.
    ///   - identifyPayload: The identification payload that is sent to Discord.
    public init(
        eventLoopGroup: EventLoopGroup,
        httpClient: HTTPClient,
        clientConfiguration: ClientConfiguration = .init(),
        maxFrameSize: Int =  1 << 31,
        compression: Bool = true,
        appId: ApplicationSnowflake? = nil,
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
        self.compression = compression
        self.identifyPayload = identifyPayload
        var logger = DiscordGlobalConfiguration.makeLogger("GatewayManager")
        logger[metadataKey: "gateway-id"] = .string("\(self.id)")
        self.logger = logger
    }
    
    /// - Parameters:
    ///   - eventLoopGroup: An `EventLoopGroup`.
    ///   - httpClient: A `HTTPClient`.
    ///   - clientConfiguration: Configuration of the `DiscordClient`.
    ///   - maxFrameSize: Max frame size the WebSocket should allow receiving.
    ///   - compression: Enables transport compression for less network bandwidth usage
    ///    but more CPU load.
    ///   - token: Your Discord bot-token.
    ///   - appId: Your Discord application id.
    ///   - shard: What shard this Manager is representing, incase you use shard-ing at all.
    ///   - presence: The initial presence of the bot.
    ///   - intents: The Discord intents you want to receive messages for.
    public init(
        eventLoopGroup: EventLoopGroup,
        httpClient: HTTPClient,
        clientConfiguration: ClientConfiguration = .init(),
        maxFrameSize: Int =  1 << 31,
        compression: Bool = true,
        token: String,
        appId: ApplicationSnowflake? = nil,
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
        self.compression = compression
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
            logger.error("Gateway state doesn't allow a new connection", metadata: [
                "state": .stringConvertible(state)
            ])
            return
        }
        self._state.store(.connecting, ordering: .relaxed)
        await self.sendQueue.reset()
        let gatewayURL = await getGatewayURL()
        var urlSuffix = "?v=\(DiscordGlobalConfiguration.apiVersion)&encoding=json"
        logger.trace("Will wait for other shards if needed")
        await waitInShardQueueIfNeeded()
        var configuration = WebSocketClient.Configuration(maxFrameSize: self.maxFrameSize)
        if compression {
            urlSuffix += "&compress=zlib-stream"
            configuration.decompression = .enabled
        }
        logger.trace("Will try to connect to Discord through web-socket")
        do {
            let ws = try await WebSocket.connect(
                to: gatewayURL + urlSuffix,
                configuration: configuration,
                on: eventLoopGroup
            )
            self.logger.debug("Connected to Discord through web-socket. Will configure")
            self.closeWebSocket(ws: self.ws)
            self.ws = ws
            self.configureWebSocket()
        } catch {
            logger.error("WebSocket error while connecting to Discord", metadata: [
                "error": .string("\(error)")
            ])
            self._state.store(.noConnection, ordering: .relaxed)
            Task { await self.connect() }
        }
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#request-guild-members
    public func requestGuildMembersChunk(payload: Gateway.RequestGuildMembers) {
        /// This took a lot of time to figure out, not sure why it needs opcode `1`.
        self.send(payload: .init(
            opcode: .requestGuildMembers,
            data: .requestGuildMembers(payload)
        ), opcode: 1)
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#update-presence
    public func updatePresence(payload: Gateway.Identify.Presence) {
        /// This took a lot of time to figure out, not sure why it needs opcode `9` (works with `10` too?!).
        self.send(payload: .init(
            opcode: .presenceUpdate,
            data: .requestPresenceUpdate(payload)
        ), opcode: 9)
    }
    
    /// https://discord.com/developers/docs/topics/gateway-events#update-voice-state
    public func updateVoiceState(payload: VoiceStateUpdate) {
        /// This took a lot of time to figure out, not sure why it needs opcode `10` (works with `9` too?!).
        self.send(payload: .init(
            opcode: .voiceStateUpdate,
            data: .requestVoiceStateUpdate(payload)
        ), opcode: 10)
    }

    /// Makes an stream of Gateway events.
    public func makeEventsStream() -> AsyncStream<Gateway.Event> {
        AsyncStream<Gateway.Event> { continuation in
            self.eventStreamContinuations.append(continuation)
        }
    }

    /// Makes an stream of Gateway event parse failures.
    public func makeEventsParseFailureStream() -> AsyncStream<(Error, ByteBuffer)> {
        AsyncStream<(Error, ByteBuffer)> { continuation in
            self.eventParseFailureContinuations.append(continuation)
        }
    }
    
    /// Disconnects from Discord.
    /// Doesn't end the event streams.
    public func disconnect() async {
        logger.debug("Will disconnect", metadata: [
            "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
        ])
        if self._state.load(ordering: .relaxed) == .stopped {
            logger.debug("Already disconnected", metadata: [
                "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
            ])
            return
        }
        self.connectionId.wrappingIncrement(ordering: .relaxed)
        self._state.store(.stopped, ordering: .relaxed)
        self.isFirstConnection = true
        await connectionBackoff.resetTryCount()
        await self.sendQueue.reset()
        self.closeWebSocket(ws: self.ws)
    }
}

extension BotGatewayManager {
    private func configureWebSocket() {
        let connId = self.connectionId.wrappingIncrementThenLoad(ordering: .relaxed)
        self.setupOnText(forConnectionWithId: connId)
        self.setupOnClose(forConnectionWithId: connId)
        self._state.store(.configured, ordering: .relaxed)
    }
    
    private func processEvent(_ event: Gateway.Event) async {
        if let sequenceNumber = event.sequenceNumber {
            self.sequenceNumber = sequenceNumber
        }
        
        switch event.opcode {
        case .heartbeat:
            self.sendPing(forConnectionWithId: self.connectionId.load(ordering: .relaxed))
        case .heartbeatAccepted:
            self.lastPongDate = Date()
        case .reconnect:
            logger.debug("Received reconnect request. Will reconnect after connection closure")
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
                self.resumeGatewayURL = nil
                self.sessionId = nil
            }
            self._state.store(.noConnection, ordering: .relaxed)
            await self.connect()
        case let .hello(hello):
            logger.debug("Received 'hello'")
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
            self.resumeGatewayURL = payload.resume_gateway_url
        case .resumed:
            logger.debug("Received resume notice. The connection is fully established", metadata: [
                "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
            ])
            await self.onSuccessfulConnection()
        default:
            break
        }
    }
    
    private func getGatewayURL() async -> String {
        logger.debug("Will try to get Discord gateway url")
        if self.sequenceNumber != nil, /// If can resume at all
           let gatewayURL = self.resumeGatewayURL {
            logger.trace("Got Discord gateway url from 'resumeGatewayURL'")
            return gatewayURL
        } else {
            /// If the bot is using shard-ing, we need to call a different endpoint
            /// to get some more info than only the gateway url.
            if identifyPayload.shard == nil {
                if let gatewayURL = try? await client.getGateway().decode().url {
                    logger.trace("Got Discord gateway url from gateway api call")
                    return gatewayURL
                }
            } else {
                if let gatewayBot = try? await client.getBotGateway().decode() {
                    logger.trace("Got Discord gateway url from gateway-bot api call", metadata: [
                        "max_concurrency": .stringConvertible(
                            gatewayBot.session_start_limit.max_concurrency
                        )
                    ])
                    self.maxConcurrency = gatewayBot.session_start_limit.max_concurrency
                    return gatewayBot.url
                }
            }
            logger.error("Cannot get gateway url to connect to. Will retry in 10 seconds")
            await self.sleep(for: .seconds(10))
            return await self.getGatewayURL()
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
                sequence: sequenceNumber
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
        if compression {
            self.ws?.onBinary { buffer in
                self.processBinaryData(buffer, forConnectionWithId: connectionId)
            }
        } else {
            self.ws?.onTextBuffer { buffer in
                self.processBinaryData(buffer, forConnectionWithId: connectionId)
            }
        }
    }
    
    private func processBinaryData(_ buffer: ByteBuffer, forConnectionWithId connectionId: UInt) {
        self.logger.debug("Got text from websocket", metadata: [
            "text": .string(String(buffer: buffer))
        ])
        guard self.connectionId.load(ordering: .relaxed) == connectionId else { return }
        let data = Data(buffer: buffer)
        do {
            let event = try DiscordGlobalConfiguration.decoder.decode(
                Gateway.Event.self,
                from: data
            )
            self.logger.debug("Decoded event", metadata: [
                "event": .string("\(event)")
            ])
            Task { await self.processEvent(event) }
            for continuation in self.eventStreamContinuations {
                continuation.yield(event)
            }
        } catch {
            self.logger.debug("Failed to decode event", metadata: [
                "error": .string("\(error)")
            ])
            for continuation in self.eventParseFailureContinuations {
                continuation.yield((error, buffer))
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
                let isDebugLevelCode = [.goingAway, nil, .unexpectedServerError].contains(code)
                self.logger.log(
                    level: isDebugLevelCode ? .debug : .warning,
                    "Received connection close notification. Will try to reconnect",
                    metadata: [
                        "code": .string(codeDesc),
                        "closedConnectionId": .stringConvertible(
                            self.connectionId.load(ordering: .relaxed)
                        )
                    ]
                )
                if self.canTryReconnect(code: ws.closeCode) {
                    self._state.store(.noConnection, ordering: .relaxed)
                    await self.connect()
                } else {
                    self._state.store(.stopped, ordering: .relaxed)
                    self.connectionId.wrappingIncrement(ordering: .relaxed)
                    self.logger.critical("Will not reconnect because Discord does not allow it. Something is wrong. Your close code is '\(codeDesc)', check Discord docs at https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes and see what it means. Report at https://github.com/MahdiBM/DiscordBM/issues if you think this is a library issue")

                    /// End streams
                    for continuation in await self.eventStreamContinuations {
                        continuation.finish()
                    }
                    for continuation in await self.eventParseFailureContinuations {
                        continuation.finish()
                    }
                    await self.removeAllEventContinuations()
                }
            }
        }
    }

    private func removeAllEventContinuations() {
        self.eventStreamContinuations.removeAll()
        self.eventParseFailureContinuations.removeAll()
    }
    
    private nonisolated  func getCloseCodeAndDescription(
        of ws: WebSocket
    ) -> (WebSocketErrorCode?, String) {
        let code = ws.closeCode
        let description: String
        switch code {
        case let .unknown(codeNumber):
            switch GatewayCloseCode(rawValue: codeNumber) {
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
    
    private nonisolated func canTryReconnect(code: WebSocketErrorCode?) -> Bool {
        switch code {
        case let .unknown(codeNumber):
            guard let discordCode = GatewayCloseCode(rawValue: codeNumber) else { return true }
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
                self.logger.trace("Canceled a ping task", metadata: [
                    "connectionId": .stringConvertible(connectionId)
                ])
                return /// cancel
            }
            self.logger.debug("Will send automatic ping", metadata: [
                "connectionId": .stringConvertible(connectionId)
            ])
            self.sendPing(forConnectionWithId: connectionId)
            self.setupPingTask(forConnectionWithId: connectionId, every: interval)
        }
    }
    
    private func sendPing(forConnectionWithId connectionId: UInt) {
        logger.trace("Will ping", metadata: [
            "connectionId": .stringConvertible(connectionId)
        ])
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
        self.sendQueue.perform { [weak self] in
            guard let self = self else { return }
            Task {
                if let connectionId = connectionId,
                   self.connectionId.load(ordering: .relaxed) != connectionId {
                    return
                }
                
                let opcode = opcode ?? payload.opcode.rawValue
                
                let data: Data
                do {
                    data = try DiscordGlobalConfiguration.encoder.encode(payload)
                } catch {
                    self.logger.error("Could not encode payload", metadata: [
                        "payload": .string("\(payload)"),
                        "opcode": .stringConvertible(opcode),
                        "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
                    ])
                    return
                }
                
                if let ws = await self.ws {
                    do {
                        try await ws.send(
                            raw: data,
                            opcode: .init(encodedWebSocketOpcode: opcode)!
                        )
                    } catch {
                        self.logger.error("Could not send payload through websocket", metadata: [
                            "error": .string("\(error)"),
                            "payload": .string("\(payload)"),
                            "opcode": .stringConvertible(opcode),
                            "connectionId": .stringConvertible(self.connectionId.load(ordering: .relaxed))
                        ])
                    }
                } else {
                    /// Pings aka `heartbeat`s are fine if they are sent when a ws connection
                    /// is not established. Pings are not disabled after a connection goes down
                    /// so long story short, the gateway manager never gets stuck in a bad
                    /// cycle of no-connection.
                    self.logger.log(
                        level: (payload.opcode == .heartbeat) ? .debug : .warning,
                        "Trying to send through ws when a connection is not established",
                        metadata: [
                            "payload": .string("\(payload)"),
                            "state": .stringConvertible(self._state.load(ordering: .relaxed)),
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
        Task {
            do {
                try await ws?.close()
            } catch {
                self.logger.warning("Connection close error", metadata: [
                    "error": .string("\(error)")
                ])
            }
        }
    }
    
    private func sleep(for time: TimeAmount) async {
        do {
            try await Task.sleep(nanoseconds: UInt64(time.nanoseconds))
        } catch {
            logger.warning("Task failed to sleep properly", metadata: [
                "error": .string("\(error)")
            ])
        }
    }
}
