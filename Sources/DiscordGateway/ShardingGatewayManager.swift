import DiscordHTTP
import DiscordModels
import Logging
import AsyncHTTPClient
import Atomics
import NIO

public actor ShardingGatewayManager: GatewayManager {

    /// Configuration for shard-management.
    public struct Configuration: Sendable {

        /// How many.
        public enum Count: Sendable {
            case automatic
            case exact(Int)
        }

        /// How many shards to spin up.
        /// In case of `.automatic`, will use Discord's suggested shard-count.
        public let shardCount: Count
        /// Will make different intents for each shard based on this closure.
        /// `(indexOfShard: Int, totalShardCount: Int) -> [Gateway.Intent]`
        public let makeIntents: (@Sendable (Int, Int) -> [Gateway.Intent])?

        /// - Parameters:
        ///   - shardCount: How many shards to spin up.
        ///   In case of `.automatic`, will use Discord's suggested shard-count.
        ///   - makeIntents: Will make different intents for each shard based on this closure.
        ///   If `nil`, all shards will have all intents passed to the `ShardingGatewayManager`.
        ///   `(indexOfShard: Int, totalShardCount: Int) -> [Gateway.Intent]`
        public init(
            shardCount: Count = .automatic,
            makeIntents: (@Sendable (Int, Int) -> [Gateway.Intent])? = nil
        ) {
            self.shardCount = shardCount
            self.makeIntents = makeIntents
        }
    }

    /// The underlying gateway managers for each shard.
    var managers = [BotGatewayManager]()
    let eventLoopGroup: any EventLoopGroup
    /// A client to send requests to Discord.
    public nonisolated let client: any DiscordClient
    /// Max frame size we accept to receive through the web-socket connection.
    let maxFrameSize: Int
    
    static let idGenerator = ManagedAtomic(UInt(0))
    public nonisolated let id: UInt = idGenerator.wrappingIncrementThenLoad(ordering: .relaxed)

    let logger: Logger

    //MARK: Event streams
    var eventsStreamContinuations = [AsyncStream<Gateway.Event>.Continuation]()
    var eventsParseFailureContinuations = [AsyncStream<(any Error, ByteBuffer)>.Continuation]()

    //MARK: Connection data
    public nonisolated let identifyPayload: Gateway.Identify

    //MARK: GatewayManager-population properties
    var connectionLocked = false
    var hasPopulatedGatewayManagers = false
    var populationWaiters = [CheckedContinuation<Void, Never>]()

    //MARK: Shard-ing
    let shardCoordinator = ShardCoordinator()
    let configuration: Configuration

    /// - Parameters:
    ///   - eventLoopGroup: An `EventLoopGroup`.
    ///   - client: A `DiscordClient` to use.
    ///   - configuration: shard-management configuration.
    ///   - maxFrameSize: Max frame size the WebSocket should allow receiving.
    ///   - identifyPayload: The identification payload that is sent to Discord.
    public init(
        eventLoopGroup: any EventLoopGroup,
        client: any DiscordClient,
        configuration: Configuration = .init(),
        maxFrameSize: Int = 1 << 28,
        identifyPayload: Gateway.Identify
    ) {
        self.eventLoopGroup = eventLoopGroup
        self.client = client
        self.maxFrameSize = maxFrameSize
        self.configuration = configuration
        self.identifyPayload = identifyPayload
        var logger = DiscordGlobalConfiguration.makeLogger("ShardsManager")
        logger[metadataKey: "shards-manager-id"] = .string("\(self.id)")
        self.logger = logger
    }

    /// - Parameters:
    ///   - eventLoopGroup: An `EventLoopGroup`.
    ///   - httpClient: A `HTTPClient`.
    ///   - configuration: shard-management configuration.
    ///   - clientConfiguration: Configuration of the `DiscordClient`.
    ///   - maxFrameSize: Max frame size the WebSocket should allow receiving.
    ///   - appId: Your Discord application-id. If not provided, it'll be extracted from bot-token.
    ///   - identifyPayload: The identification payload that is sent to Discord.
    public init(
        eventLoopGroup: any EventLoopGroup,
        httpClient: HTTPClient,
        configuration: Configuration = .init(),
        clientConfiguration: ClientConfiguration = .init(),
        maxFrameSize: Int = 1 << 28,
        appId: ApplicationSnowflake? = nil,
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
        self.configuration = configuration
        self.identifyPayload = identifyPayload
        var logger = DiscordGlobalConfiguration.makeLogger("ShardsManager")
        logger[metadataKey: "shards-manager-id"] = .string("\(self.id)")
        self.logger = logger
    }

    /// - Parameters:
    ///   - eventLoopGroup: An `EventLoopGroup`.
    ///   - httpClient: A `HTTPClient`.
    ///   - configuration: shard-management configuration.
    ///   - clientConfiguration: Configuration of the `DiscordClient`.
    ///   - maxFrameSize: Max frame size the WebSocket should allow receiving.
    ///   - token: Your Discord bot-token.
    ///   - appId: Your Discord application-id. If not provided, it'll be extracted from bot-token.
    ///   - largeThreshold: Value between 50 and 250, total number of members where the gateway
    ///     will stop sending offline members in the guild member list.
    ///   - presence: The initial presence of the bot.
    ///   - intents: The Discord intents you want to receive messages for.
    public init(
        eventLoopGroup: any EventLoopGroup,
        httpClient: HTTPClient,
        configuration: Configuration = .init(),
        clientConfiguration: ClientConfiguration = .init(),
        maxFrameSize: Int = 1 << 28,
        token: String,
        appId: ApplicationSnowflake? = nil,
        largeThreshold: Int? = nil,
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
        self.configuration = configuration
        self.identifyPayload = .init(
            token: token,
            large_threshold: largeThreshold,
            presence: presence,
            intents: intents
        )

        var logger = DiscordGlobalConfiguration.makeLogger("ShardsManager")
        logger[metadataKey: "shards-manager-id"] = .string("\(self.id)")
        self.logger = logger
    }

    /// Connects all shards to Discord.
    public func connect() async {
        if self.connectionLocked {
            self.logger.error("Attempt to connect shards while the connect function is locked")
            return
        } else {
            self.connectionLocked = true
        }

        if self.managers.isEmpty {
            await self.populateGatewayManagers()
        }

        await withTaskGroup(of: Void.self) { group in
            for manager in self.managers {
                group.addTask { await manager.connect() }
            }
        }

        self.connectionLocked = false
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
        await self.waitForGatewayManagersPopulation()
        await withTaskGroup(of: Void.self) { group in
            for manager in self.managers {
                group.addTask { await manager.disconnect() }
            }
        }
    }
}

extension ShardingGatewayManager {
    private func populateGatewayManagers() async {
        let gatewayInfo = await self.getGatewayInfo()
        let shardCount: Int = {
            switch self.configuration.shardCount {
            case .automatic: return gatewayInfo.shards
            case let .exact(count): return max(count, 1)
            }
        }()

        for idx in 0..<shardCount {
            let shard = IntPair(idx, shardCount)

            var payload = self.identifyPayload
            payload.shard = shard

            if let intents = self.configuration.makeIntents?(idx, shardCount) {
                payload.intents = .init(intents)
            }

            self.managers.append(
                BotGatewayManager(
                    eventLoopGroup: self.eventLoopGroup,
                    client: self.client,
                    maxFrameSize: self.maxFrameSize,
                    shardInfo: .init(
                        shard: shard,
                        maxConcurrency: gatewayInfo.session_start_limit.max_concurrency,
                        shardCoordinator: self.shardCoordinator
                    ),
                    identifyPayloadWithShard: payload
                )
            )
        }


        /// Notify anyone that was waiting for the `managers` to be populated.
        self.hasPopulatedGatewayManagers = true
        for waiter in self.populationWaiters {
            waiter.resume()
        }
        self.populationWaiters.removeAll()
    }

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

    /// Makes sure the one-time job of populating `managers` has been done already, before
    /// accessing the `managers`. If the functions access `managers` too fast, the array will be
    /// empty nothing will happen, which makes the implementation look buggy.
    private func waitForGatewayManagersPopulation() async {
        if !self.hasPopulatedGatewayManagers {
            await withCheckedContinuation {
                self.populationWaiters.append($0)
            }
        }
    }
}
