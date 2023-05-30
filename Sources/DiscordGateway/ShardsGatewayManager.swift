import DiscordHTTP
import DiscordModels
import Logging
import AsyncHTTPClient
import Atomics
import NIO

public actor ShardsGatewayManager: GatewayManager {

    /// How many shard to try to spin up.
    public enum MakeShardConfiguration {
        /// `(indexOfShard: Int, totalShardCount: Int) -> Set<Gateway.Intent>`
        public typealias MakeIntentsAutomatic = (Int, Int) -> [Gateway.Intent]
        /// `(indexOfShard: Int) -> Set<Gateway.Intent>`
        public typealias MakeIntentsExact = (Int) -> [Gateway.Intent]

        /// Uses Discord's suggested shard-count.
        /// Allows you to configure the exact intents for each shard if you want.
        case automatic(makeIntents: MakeIntentsAutomatic? = nil)
        /// Uses this exact amount of shards.
        /// Allows you to configure the exact intents for each shard if you want.
        case exact(count: Int, makeIntents: MakeIntentsExact? = nil)

        /// Uses Discord's suggested shard-count.
        public static var automatic: MakeShardConfiguration = .automatic()
    }

    /// The underlying gateway managers for each shard.
    var managers = [BotGatewayManager]()

    var hasPopulatedGatewayManagers = false
    var populationWaiters = [CheckedContinuation<Void, Never>]()

    let eventLoopGroup: any EventLoopGroup
    /// A client to send requests to Discord.
    public nonisolated let client: any DiscordClient
    /// Max frame size we accept to receive through the web-socket connection.
    nonisolated let maxFrameSize: Int
    
    static let idGenerator = ManagedAtomic(UInt(0))
    public nonisolated let id: UInt = idGenerator.wrappingIncrementThenLoad(ordering: .relaxed)

    let logger: Logger

    //MARK: Event streams
    var eventsStreamContinuations = [AsyncStream<Gateway.Event>.Continuation]()
    var eventsParseFailureContinuations = [AsyncStream<(any Error, ByteBuffer)>.Continuation]()

    //MARK: Connection data
    public nonisolated let identifyPayload: Gateway.Identify

    //MARK: Shard-ing
    let shardsCoordinator = ShardsCoordinator()
    let makeShardConfiguration: MakeShardConfiguration

    /// - Parameters:
    ///   - eventLoopGroup: An `EventLoopGroup`.
    ///   - client: A `DiscordClient` to use.
    ///   - maxFrameSize: Max frame size the WebSocket should allow receiving.
    ///   - shardCountStrategy: How many shards to spin up.
    ///   - identifyPayload: The identification payload that is sent to Discord.
    public init(
        eventLoopGroup: any EventLoopGroup,
        client: any DiscordClient,
        maxFrameSize: Int =  1 << 31,
        makeShardConfiguration: MakeShardConfiguration = .automatic,
        identifyPayload: Gateway.Identify
    ) {
        self.eventLoopGroup = eventLoopGroup
        self.client = client
        self.maxFrameSize = maxFrameSize
        self.makeShardConfiguration = makeShardConfiguration
        self.identifyPayload = identifyPayload
        var logger = DiscordGlobalConfiguration.makeLogger("ShardsManager")
        logger[metadataKey: "shards-manager-id"] = .string("\(self.id)")
        self.logger = logger
    }

    /// - Parameters:
    ///   - eventLoopGroup: An `EventLoopGroup`.
    ///   - httpClient: A `HTTPClient`.
    ///   - clientConfiguration: Configuration of the `DiscordClient`.
    ///   - maxFrameSize: Max frame size the WebSocket should allow receiving.
    ///   - appId: Your Discord application-id. If not provided, it'll be extracted from bot-token.
    ///   - shardCountStrategy: How many shards to spin up.
    ///   - identifyPayload: The identification payload that is sent to Discord.
    public init(
        eventLoopGroup: any EventLoopGroup,
        httpClient: HTTPClient,
        clientConfiguration: ClientConfiguration = .init(),
        maxFrameSize: Int =  1 << 31,
        appId: ApplicationSnowflake? = nil,
        makeShardConfiguration: MakeShardConfiguration = .automatic,
        identifyPayload: Gateway.Identify
    ) async {
        self.eventLoopGroup = eventLoopGroup
        self.client = await DefaultDiscordClient(
            httpClient: httpClient,
            token: identifyPayload.token,
            appId: appId,
            configuration: clientConfiguration
        )
        self.maxFrameSize = maxFrameSize
        self.makeShardConfiguration = makeShardConfiguration
        self.identifyPayload = identifyPayload
        var logger = DiscordGlobalConfiguration.makeLogger("ShardsManager")
        logger[metadataKey: "shards-manager-id"] = .string("\(self.id)")
        self.logger = logger
    }

    /// - Parameters:
    ///   - eventLoopGroup: An `EventLoopGroup`.
    ///   - httpClient: A `HTTPClient`.
    ///   - clientConfiguration: Configuration of the `DiscordClient`.
    ///   - maxFrameSize: Max frame size the WebSocket should allow receiving.
    ///   - token: Your Discord bot-token.
    ///   - appId: Your Discord application-id. If not provided, it'll be extracted from bot-token.
    ///   - shardCountStrategy: How many shards to spin up.
    ///   - presence: The initial presence of the bot.
    ///   - intents: The Discord intents you want to receive messages for.
    public init(
        eventLoopGroup: any EventLoopGroup,
        httpClient: HTTPClient,
        clientConfiguration: ClientConfiguration = .init(),
        maxFrameSize: Int =  1 << 31,
        token: String,
        appId: ApplicationSnowflake? = nil,
        makeShardConfiguration: MakeShardConfiguration = .automatic,
        presence: Gateway.Identify.Presence? = nil,
        intents: [Gateway.Intent]
    ) async {
        let token = Secret(token)
        self.eventLoopGroup = eventLoopGroup
        self.client = await DefaultDiscordClient(
            httpClient: httpClient,
            token: token,
            appId: appId,
            configuration: clientConfiguration
        )
        self.maxFrameSize = maxFrameSize
        self.makeShardConfiguration = makeShardConfiguration
        self.identifyPayload = .init(
            token: token,
            presence: presence,
            intents: intents
        )
        var logger = DiscordGlobalConfiguration.makeLogger("ShardsManager")
        logger[metadataKey: "shards-manager-id"] = .string("\(self.id)")
        self.logger = logger
    }

    /// Connects all shards to Discord.
    public func connect() async {
        do {
            let gatewayInfo = await getGatewayInfo()
            let shardCount: Int = {
                switch self.makeShardConfiguration {
                case .automatic: return gatewayInfo.shards
                case let .exact(count, _): return max(count, 1)
                }
            }()
//            let _intents = identifyPayload.intents.representableValues()
//            let allIntents = _intents.values.map(\.rawValue) + _intents.unknown
//#warning("Change intents of identify payload")

            //TODO: ability to configure intents for each shard

            for idx in 0..<shardCount {

                let shard = IntPair(idx, shardCount)
                var payload = self.identifyPayload
                payload.shard = shard

                switch self.makeShardConfiguration {
                case let .automatic(makeIntents):
                    if let intents = makeIntents?(idx, shardCount) {
                        payload.intents = .init(intents)
                    }
                case let .exact(_, makeIntents):
                    if let intents = makeIntents?(idx) {
                        payload.intents = .init(intents)
                    }
                }

                self.managers.append(
                    BotGatewayManager(
                        eventLoopGroup: self.eventLoopGroup,
                        client: self.client,
                        maxFrameSize: self.maxFrameSize,
                        shardInfo: .init(
                            shard: shard,
                            maxConcurrency: gatewayInfo.session_start_limit.max_concurrency,
                            shardsCoordinator: self.shardsCoordinator
                        ),
                        identifyPayloadWithShard: payload
                    )
                )
            }

            self.hasPopulatedGatewayManagers = true
            for waiter in self.populationWaiters {
                waiter.resume()
            }
            self.populationWaiters.removeAll()

            await withTaskGroup(of: Void.self) { group in
                for manager in self.managers {
                    group.addTask { await manager.connect() }
                }
            }
        }
    }

    /// https://discord.com/developers/docs/topics/gateway-events#request-guild-members
    public func requestGuildMembersChunk(payload: Gateway.RequestGuildMembers) async {
        await self.waitForGatewayManagersPopulation()
        await self.managers
            .first(where: { $0.identifyPayload.intents.contains(.guildMembers) })?
            .requestGuildMembersChunk(payload: payload)
    }

    /// https://discord.com/developers/docs/topics/gateway-events#update-presence
    public func updatePresence(payload: Gateway.Identify.Presence) async {
        await self.waitForGatewayManagersPopulation()
        await self.managers.first?.updatePresence(payload: payload)
    }

    /// https://discord.com/developers/docs/topics/gateway-events#update-voice-state
    public func updateVoiceState(payload: VoiceStateUpdate) async {
        await self.waitForGatewayManagersPopulation()
        await self.managers.first?.updateVoiceState(payload: payload)
    }

    /// Makes an stream of Gateway events.
    public func makeEventsStream() async -> AsyncStream<Gateway.Event> {
        await self.waitForGatewayManagersPopulation()
        return AsyncStream<Gateway.Event> { continuation in
            for manager in self.managers {
                Task { await manager.addEventsContinuation(continuation) }
            }
        }
    }

    /// Makes an stream of Gateway event parse failures.
    public func makeEventsParseFailureStream() async -> AsyncStream<(any Error, ByteBuffer)> {
        await self.waitForGatewayManagersPopulation()
        return AsyncStream<(any Error, ByteBuffer)> { continuation in
            for manager in self.managers {
                Task { await manager.addEventsParseFailureContinuation(continuation) }
            }
        }
    }

    /// Disconnects all shards from Discord.
    public func disconnect() async {
        if self.hasPopulatedGatewayManagers {
            await withTaskGroup(of: Void.self) { group in
                for manager in self.managers {
                    group.addTask { await manager.disconnect() }
                }
            }
        } else {
            await self.waitForGatewayManagersPopulation()
            await withTaskGroup(of: Void.self) { group in
                for manager in self.managers {
                    group.addTask { await manager.disconnect() }
                }
            }
        }
    }
}

extension ShardsGatewayManager {
    private func getGatewayInfo() async -> Gateway.BotConnectionInfo {
        logger.debug("Will try to get Discord gateway url")
        if let gatewayBot = try? await client.getBotGateway().decode() {
            logger.trace("Got Discord gateway url from gateway-bot api call", metadata: [
                "info": .string("\(gatewayBot)")
            ])
            return gatewayBot
        }
        logger.error("Cannot get gateway url to connect to. Will retry in 10 seconds")
        try? await Task.sleep(for: .seconds(10))
        return await self.getGatewayInfo()
    }

    private func waitForGatewayManagersPopulation() async {
        if !self.hasPopulatedGatewayManagers {
            await withCheckedContinuation {
                self.populationWaiters.append($0)
            }
        }
    }
}
