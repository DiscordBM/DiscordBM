@preconcurrency import AsyncHTTPClient
import NIOHTTP1
import NIOConcurrencyHelpers
import NIOCore
import struct Foundation.Date
import Logging

public enum DiscordClientError: Error {
    case rateLimited(url: String)
    case cantAttemptToDecodeDueToBadStatusCode(raw: HTTPClient.Response)
    case emptyBody(raw: HTTPClient.Response)
    case appIdParameterRequired
    /// Can only send one of those query parameters.
    case queryParametersMutuallyExclusive(queries: [(String, String?)])
    case queryParameterOutOfBounds(name: String, value: String?, lowerBound: Int, upperBound: Int)
}

/// The fact that this could be used by multiple different `DiscordClient`s with
/// different `token`s should not matter because buckets are random anyway.
private let rateLimiter = HTTPRateLimiter(label: "DiscordClientRateLimiter")

public struct DiscordClient {
    
    public struct Response<C> where C: Codable {
        
        public let raw: HTTPClient.Response
        
        public func decode() throws -> C {
            if (200..<300).contains(raw.status.code) {
                if let body = raw.body,
                   let data = body.getData(at: 0, length: body.readableBytes) {
                    return try DiscordGlobalConfiguration.decoder.decode(C.self, from: data)
                } else {
                    throw DiscordClientError.emptyBody(raw: raw)
                }
            } else {
                throw DiscordClientError.cantAttemptToDecodeDueToBadStatusCode(raw: raw)
            }
        }
    }
    
    private let client: HTTPClient
    private let token: Secret
    public let appId: String?
    private let cache: ClientCache?
    private let configuration: Configuration
    
    /// If you provide no app id, you'll need to pass it to some functions on call site.
    public init(
        httpClient: HTTPClient,
        token: Secret,
        appId: String?,
        configuration: Configuration
    ) {
        self.client = httpClient
        self.token = token
        self.appId = appId
        self.configuration = configuration
        if configuration.cachingBehavior.isDisabled {
            self.cache = nil
        } else {
            /// So each token has its own cache, because
            /// answers might be different for different tokens.
            self.cache = ClientCacheStorage.shared.cache(for: token)
        }
    }
    
    private func requireAppId(_ providedAppId: String?) throws -> String {
        if let appId = providedAppId ?? self.appId {
            return appId
        } else {
            /// You have not passed your app id in the init of `DiscordClient`.
            /// You need to pass it in the function parameters.
            throw DiscordClientError.appIdParameterRequired
        }
    }
    
    private func checkRateLimitsAllowRequest(to endpoint: Endpoint) async throws {
        if await !rateLimiter.shouldRequest(to: endpoint) {
            throw DiscordClientError.rateLimited(url: "\(endpoint.url)")
        }
    }
    
    private func includeInRateLimits(
        endpoint: Endpoint,
        headers: HTTPHeaders,
        status: HTTPResponseStatus
    ) async {
        await rateLimiter.include(endpoint: endpoint, headers: headers, status: status)
    }
    
    private func getFromCache(
        identity: CacheableEndpointIdentity?,
        queries: [(String, String?)]
    ) async -> HTTPClient.Response? {
        guard let identity = identity else { return nil }
        return await cache?.get(item: .init(
            identity: identity,
            queries: queries
        ))
    }
    
    private func saveInCache(
        response: HTTPClient.Response,
        identity: CacheableEndpointIdentity?,
        queries: [(String, String?)]
    ) async {
        guard let identity = identity,
              (200..<300).contains(response.status.code),
              let ttl = self.configuration.cachingBehavior.getTTL(for: identity)
        else { return }
        await cache?.add(
            response: response,
            item: .init(
                identity: identity,
                queries: queries
            ), ttl: ttl
        )
    }
    
    private func execute(_ request: HTTPClient.Request) async throws -> HTTPClient.Response {
        try await self.client.execute(
            request: request,
            deadline: .now() + configuration.requestTimeout,
            logger: configuration.enableLoggingForRequests
            ? DiscordGlobalConfiguration.makeLogger("DiscordClientHTTPRequest")
            : Logger(label: "DBM-no-op-logger", factory: { _ in SwiftLogNoOpLogHandler() })
        ).get()
    }
    
    private func send(
        to endpoint: Endpoint,
        queries: [(String, String?)] = []
    ) async throws -> HTTPClient.Response {
        let identity = CacheableEndpointIdentity(endpoint: endpoint)
        if let cached = await self.getFromCache(identity: identity, queries: queries) {
            return cached
        }
        try await self.checkRateLimitsAllowRequest(to: endpoint)
        var request = try HTTPClient.Request(
            url: endpoint.url + queries.makeForURLQuery(),
            method: endpoint.httpMethod
        )
        request.headers = ["Authorization": "Bot \(token._storage)"]
        let response = try await self.execute(request)
        await self.includeInRateLimits(
            endpoint: endpoint,
            headers: response.headers,
            status: response.status
        )
        await self.saveInCache(
            response: response,
            identity: identity,
            queries: queries
        )
        return response
    }
    
    private func send<C: Codable>(
        to endpoint: Endpoint,
        queries: [(String, String?)] = []
    ) async throws -> Response<C> {
        let response = try await self.send(to: endpoint, queries: queries)
        return Response(raw: response)
    }
    
    private func send<E: Encodable>(
        to endpoint: Endpoint,
        queries: [(String, String?)] = [],
        payload: E
    ) async throws -> HTTPClient.Response {
        let identity = CacheableEndpointIdentity(endpoint: endpoint)
        if let cached = await self.getFromCache(identity: identity, queries: queries) {
            return cached
        }
        try await self.checkRateLimitsAllowRequest(to: endpoint)
        let data = try DiscordGlobalConfiguration.encoder.encode(payload)
        var request = try HTTPClient.Request(
            url: endpoint.url + queries.makeForURLQuery(),
            method: endpoint.httpMethod
        )
        request.headers = [
            "Authorization": "Bot \(token._storage)",
            "Content-Type": "application/json"
        ]
        request.body = .bytes(data)
        let response = try await self.execute(request)
        await self.includeInRateLimits(
            endpoint: endpoint,
            headers: response.headers,
            status: response.status
        )
        await self.saveInCache(
            response: response,
            identity: identity,
            queries: queries
        )
        return response
    }
    
    private func send<E: Encodable, C: Codable>(
        to endpoint: Endpoint,
        queries: [(String, String?)] = [],
        payload: E
    ) async throws -> Response<C> {
        let response = try await self.send(to: endpoint, queries: queries, payload: payload)
        return Response(raw: response)
    }
    
    private func checkMutuallyExclusive(queries: [(String, String?)]) throws {
        guard queries.filter({ $0.1 != nil }).count < 2 else {
            throw DiscordClientError.queryParametersMutuallyExclusive(queries: queries)
        }
    }
    
    private func checkInBounds(
        name: String,
        value: Int?,
        lowerBound: Int,
        upperBound: Int
    ) throws {
        guard value.map({ (lowerBound...upperBound).contains($0) }) != false else {
            throw DiscordClientError.queryParameterOutOfBounds(
                name: name,
                value: value.map({ "\($0)" }),
                lowerBound: 1,
                upperBound: 1_000
            )
        }
    }
}

//MARK: - Public functions

extension DiscordClient {
    
    public func getGateway() async throws -> Response<GatewayUrl> {
        let endpoint = Endpoint.getGateway
        return try await self.send(to: endpoint)
    }
    
    public func getGatewayBot() async throws -> Response<GatewayBot> {
        let endpoint = Endpoint.getGatewayBot
        return try await self.send(to: endpoint)
    }
    
    public func createInteractionResponse(
        id: String,
        token: String,
        payload: InteractionResponse
    ) async throws -> Response<InteractionResponse.CallbackData> {
        let endpoint = Endpoint.createInteractionResponse(id: id, token: token)
        return try await self.send(to: endpoint, payload: payload)
    }
    
    public func editInteractionResponse(
        appId: String? = nil,
        token: String,
        payload: InteractionResponse.CallbackData
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.editOriginalInteractionResponse(
            appId: try requireAppId(appId),
            token: token
        )
        return try await self.send(to: endpoint, payload: payload)
    }
    
    public func deleteInteractionResponse(
        appId: String? = nil,
        token: String
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.deleteOriginalInteractionResponse(
            appId: try requireAppId(appId),
            token: token
        )
        return try await self.send(to: endpoint)
    }
    
    public func createFollowupInteractionResponse(
        appId: String? = nil,
        token: String,
        payload: InteractionResponse
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.postFollowupGatewayInteractionResponse(
            appId: try requireAppId(appId),
            token: token
        )
        return try await self.send(to: endpoint, payload: payload)
    }
    
    public func editFollowupInteractionResponse(
        appId: String? = nil,
        id: String,
        token: String,
        payload: InteractionResponse
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.editGatewayInteractionResponseFollowup(
            appId: try requireAppId(appId),
            id: id,
            token: token
        )
        return try await self.send(to: endpoint, payload: payload)
    }
    
    public func createMessage(
        channelId: String,
        payload: ChannelCreateMessage
    ) async throws -> Response<Gateway.Message> {
        let endpoint = Endpoint.postCreateMessage(channelId: channelId)
        return try await self.send(to: endpoint, payload: payload)
    }
    
    public func editMessage(
        channelId: String,
        messageId: String,
        payload: ChannelEditMessage
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.patchEditMessage(channelId: channelId, messageId: messageId)
        return try await self.send(to: endpoint, payload: payload)
    }
    
    public func deleteMessage(
        channelId: String,
        messageId: String
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.deleteMessage(channelId: channelId, messageId: messageId)
        return try await self.send(to: endpoint)
    }
    
    public func createApplicationGlobalCommand(
        appId: String? = nil,
        payload: SlashCommand
    ) async throws -> Response<SlashCommand> {
        let endpoint = Endpoint.createApplicationGlobalCommand(appId: try requireAppId(appId))
        return try await self.send(to: endpoint, payload: payload)
    }
    
    public func getApplicationGlobalCommands(
        appId: String? = nil
    ) async throws -> Response<[SlashCommand]> {
        let endpoint = Endpoint.getApplicationGlobalCommands(appId: try requireAppId(appId))
        return try await send(to: endpoint)
    }
    
    public func deleteApplicationGlobalCommand(
        appId: String? = nil,
        id: String
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.deleteApplicationGlobalCommand(
            appId: try requireAppId(appId),
            id: id
        )
        return try await self.send(to: endpoint)
    }
    
    public func getGuild(id: String) async throws -> Response<Guild> {
        let endpoint = Endpoint.getGuild(id: id)
        return try await self.send(to: endpoint)
    }
    
    public func getChannel(id: String) async throws -> Response<Gateway.Channel> {
        let endpoint = Endpoint.getChannel(id: id)
        return try await self.send(to: endpoint)
    }
    
    public func leaveGuild(id: String) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.leaveGuild(id: id)
        return try await self.send(to: endpoint)
    }
    
    public func createGuildRole(
        guildId: String,
        payload: CreateGuildRole
    ) async throws -> Response<Gateway.Role> {
        let endpoint = Endpoint.createGuildRole(guildId: guildId)
        return try await self.send(to: endpoint, payload: payload)
    }
    
    public func addGuildMemberRole(
        guildId: String,
        userId: String,
        roleId: String
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.addGuildMemberRole(
            guildId: guildId,
            userId: userId,
            roleId: roleId
        )
        return try await self.send(to: endpoint)
    }
    
    public func removeGuildMemberRole(
        guildId: String,
        userId: String,
        roleId: String
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.removeGuildMemberRole(
            guildId: guildId,
            userId: userId,
            roleId: roleId
        )
        return try await self.send(to: endpoint)
    }
    
    public func addReaction(
        channelId: String,
        messageId: String,
        emoji: String
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.addReaction(
            channelId: channelId,
            messageId: messageId,
            emoji: emoji
        )
        return try await self.send(to: endpoint)
    }
    
    public func searchGuildMembers(
        guildId: String,
        query: String,
        limit: Int? = nil
    ) async throws -> Response<[Gateway.Member]> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 1_000)
        let endpoint = Endpoint.searchGuildMembers(id: guildId)
        return try await self.send(
            to: endpoint,
            queries: [
                ("query", query),
                ("limit", limit.map({ "\($0)" }))
            ]
        )
    }
    
    public func getGuildMember(
        guildId: String,
        userId: String
    ) async throws -> Response<Gateway.Member> {
        let endpoint = Endpoint.getGuildMember(id: guildId, userId: userId)
        return try await self.send(to: endpoint)
    }
    
    /// NOTE: `around`, `before` and `after` are mutually exclusive.
    public func getChannelMessages(
        channelId: String,
        around: String? = nil,
        before: String? = nil,
        after: String? = nil,
        limit: Int? = nil
    ) async throws -> Response<[Gateway.Message]> {
        try checkMutuallyExclusive(queries: [
            ("around", around),
            ("before", before),
            ("after", after)
        ])
        let endpoint = Endpoint.getChannelMessages(id: channelId)
        return try await self.send(
            to: endpoint,
            queries: [
                ("around", around),
                ("before", before),
                ("after", after),
                ("limit", limit.map({ "\($0)" }))
            ]
        )
    }
    
    public func getChannelMessage(
        channelId: String,
        messageId: String
    ) async throws -> Response<Gateway.Message> {
        let endpoint = Endpoint.getChannelMessage(id: channelId, messageId: messageId)
        return try await self.send(to: endpoint)
    }
}

//MARK: - Configuration
extension DiscordClient {
    
    public struct Configuration {
        
        public struct CachingBehavior {
            
            /// [ID: TTL]
            private var storage = [CacheableEndpointIdentity: Double]()
            /// This instance's default TTL for all endpoints.
            public var defaultTTL = 5.0
            public var isDisabled = false
            
            /// Caches all cacheable endpoints for 5 seconds.
            public static let `default` = CachingBehavior()
            /// Doesn't allow caching at all.
            public static let disabled = CachingBehavior(isDisabled: true)
            
            public mutating func modifyBehavior(
                of identity: CacheableEndpointIdentity,
                ttl: Double? = nil
            ) {
                guard !self.isDisabled else { return }
                self.storage[identity] = ttl ?? 0
            }
            
            func getTTL(for identity: CacheableEndpointIdentity) -> Double? {
                guard !self.isDisabled else { return nil }
                guard let ttl = self.storage[identity] else { return self.defaultTTL }
                if ttl == 0 {
                    return nil
                } else {
                    return ttl
                }
            }
        }
        
        public let cachingBehavior: CachingBehavior
        public var requestTimeout: TimeAmount
        /// Ask `HTTPClient` to log when needed. Defaults to no logging.
        public var enableLoggingForRequests: Bool
        
        public init(
            cachingBehavior: CachingBehavior = .default,
            requestTimeout: TimeAmount = .seconds(30),
            enableLoggingForRequests: Bool = false
        ) {
            self.cachingBehavior = cachingBehavior
            self.requestTimeout = requestTimeout
            self.enableLoggingForRequests = enableLoggingForRequests
        }
    }
}

//MARK: - ClientCacheStorage
private final class ClientCacheStorage {
    
    /// [Token: ClientCache]
    private var storage = [String: ClientCache]()
    private let lock = Lock()
    
    private init() { }
    
    static let shared = ClientCacheStorage()
    
    func cache(for token: Secret) -> ClientCache {
        let token = token._storage
        self.lock.lock()
        defer { self.lock.unlock() }
        if let cache = self.storage[token] {
            return cache
        } else {
            let cache = ClientCache()
            self.storage[token] = cache
            return cache
        }
    }
}

//MARK: - ClientCache

/// This doesn't use the Cache-Control header because I couldn't find a 2xx response with a Cache-Control header returned by Discord.
private actor ClientCache {
    
    struct CacheableItem: Hashable {
        let identity: CacheableEndpointIdentity
        let queries: [(String, String?)]
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identity)
            for (key, value) in queries {
                hasher.combine(key)
                hasher.combine(value)
            }
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.identity == rhs.identity &&
            lhs.queries.elementsEqual(rhs.queries, by: {
                $0.0 == $1.0 &&
                $0.1 == $1.1
            })
        }
    }
    
    /// [ID: ExpirationTime]
    private var timeTable = [CacheableItem: Double]()
    /// [ID: Response]
    private var storage = [CacheableItem: HTTPClient.Response]()
    
    init() {
        Task {
            await self.setupGarbageCollector()
        }
    }
    
    func add(response: HTTPClient.Response, item: CacheableItem, ttl: Double) {
        self.timeTable[item] = Date().timeIntervalSince1970 + ttl
        self.storage[item] = response
    }
    
    func get(item: CacheableItem) -> HTTPClient.Response? {
        if let time = self.timeTable[item] {
            if time > Date().timeIntervalSince1970 {
                return storage[item]
            } else {
                self.timeTable[item] = nil
                self.storage[item] = nil
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func setupGarbageCollector() async {
        /// Quit in case of task cancelation.
        guard (try? await Task.sleep(nanoseconds: 60 * 1_000_000_000)) != nil else { return }
        let now = Date().timeIntervalSince1970
        for (item, expirationDate) in self.timeTable {
            if expirationDate < now {
                self.timeTable[item] = nil
                self.storage[item] = nil
            }
        }
        await setupGarbageCollector()
    }
}

//MARK: Sendable
extension DiscordClient: Sendable { }
extension DiscordClient.Response: Sendable where C: Sendable { }
extension DiscordClient.Configuration: Sendable { }
extension DiscordClient.Configuration.CachingBehavior: Sendable { }
