@preconcurrency import AsyncHTTPClient
import NIOHTTP1
import NIOConcurrencyHelpers
import NIOCore
import struct Foundation.Date
import Logging

public protocol DiscordClient {
    
    var client: HTTPClient { get }
    var appId: String? { get }
    var configuration: ClientConfiguration { get }
    
    func send(
        to endpoint: Endpoint,
        queries: [(String, String?)]
    ) async throws -> DiscordHTTPResponse
    
    func send<C: Codable>(
        to endpoint: Endpoint,
        queries: [(String, String?)]
    ) async throws -> DiscordClientResponse<C>
    
    func send<E: Encodable>(
        to endpoint: Endpoint,
        queries: [(String, String?)],
        payload: E
    ) async throws -> DiscordHTTPResponse
    
    func send<E: Encodable, C: Codable>(
        to endpoint: Endpoint,
        queries: [(String, String?)],
        payload: E
    ) async throws -> DiscordClientResponse<C>
}

public struct DiscordHTTPResponse: Sendable {
    let _response: HTTPClient.Response
    
    internal init(_response: HTTPClient.Response) {
        self._response = _response
    }
    
    public init(
        host: String,
        status: HTTPResponseStatus,
        version: HTTPVersion,
        headers: HTTPHeaders,
        body: ByteBuffer?
    ) {
        self._response = .init(
            host: host,
            status: status,
            version: version,
            headers: headers,
            body: body
        )
    }
    
    /// Remote host of the request.
    public var host: String {
        _response.host
    }
    /// Response HTTP status.
    public var status: HTTPResponseStatus {
        _response.status
    }
    /// Response HTTP version.
    public var version: HTTPVersion {
        _response.version
    }
    /// Response HTTP headers.
    public var headers: HTTPHeaders {
        _response.headers
    }
    /// Response body.
    public var body: ByteBuffer? {
        _response.body
    }
}

public struct DiscordClientResponse<C> where C: Codable {
    public let raw: DiscordHTTPResponse
    
    public init(raw: DiscordHTTPResponse) {
        self.raw = raw
    }
    
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

//MARK: - ClientConfiguration
public struct ClientConfiguration {
    
    public struct CachingBehavior {
        
        /// [ID: TTL]
        private var storage = [CacheableEndpointIdentity: Double]()
        /// This instance's default TTL for all endpoints.
        public var defaultTTL = 5.0
        public var isDisabled = false
        
        /// Caches all cacheable endpoints for 5 seconds.
        public static let enabled = CachingBehavior()
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
        cachingBehavior: CachingBehavior = .disabled,
        requestTimeout: TimeAmount = .seconds(30),
        enableLoggingForRequests: Bool = false
    ) {
        self.cachingBehavior = cachingBehavior
        self.requestTimeout = requestTimeout
        self.enableLoggingForRequests = enableLoggingForRequests
    }
}

public enum DiscordClientError: Error {
    case rateLimited(url: String)
    case cantAttemptToDecodeDueToBadStatusCode(raw: DiscordHTTPResponse)
    case emptyBody(raw: DiscordHTTPResponse)
    case appIdParameterRequired
    /// Can only send one of those query parameters.
    case queryParametersMutuallyExclusive(queries: [(String, String?)])
    case queryParameterOutOfBounds(name: String, value: String?, lowerBound: Int, upperBound: Int)
}

//MARK: - Private +DiscordClient
private extension DiscordClient {
    
    func execute(_ request: HTTPClient.Request) async throws -> DiscordHTTPResponse {
        DiscordHTTPResponse(
            _response: try await self.client.execute(
                request: request,
                deadline: .now() + configuration.requestTimeout,
                logger: configuration.enableLoggingForRequests
                ? DiscordGlobalConfiguration.makeLogger("DiscordClientHTTPRequest")
                : Logger(label: "DBM-no-op-logger", factory: { _ in SwiftLogNoOpLogHandler() })
            ).get()
        )
    }
    
    func requireAppId(_ providedAppId: String?) throws -> String {
        if let appId = providedAppId ?? self.appId {
            return appId
        } else {
            /// You have not passed your app id in the init of `DiscordClient`.
            /// You need to pass it in the function parameters.
            throw DiscordClientError.appIdParameterRequired
        }
    }
    
    func checkMutuallyExclusive(queries: [(String, String?)]) throws {
        guard queries.filter({ $0.1 != nil }).count < 2 else {
            throw DiscordClientError.queryParametersMutuallyExclusive(queries: queries)
        }
    }
    
    func checkInBounds(
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

//MARK: - Public +DiscordClient
public extension DiscordClient {
    
    func getGateway() async throws -> DiscordClientResponse<GatewayUrl> {
        let endpoint = Endpoint.getGateway
        return try await self.send(to: endpoint, queries: [])
    }
    
    func getGatewayBot() async throws -> DiscordClientResponse<GatewayBot> {
        let endpoint = Endpoint.getGatewayBot
        return try await self.send(to: endpoint, queries: [])
    }
    
    func createInteractionResponse(
        id: String,
        token: String,
        payload: InteractionResponse
    ) async throws -> DiscordClientResponse<InteractionResponse.CallbackData> {
        let endpoint = Endpoint.createInteractionResponse(id: id, token: token)
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    func editInteractionResponse(
        appId: String? = nil,
        token: String,
        payload: InteractionResponse.CallbackData
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.editOriginalInteractionResponse(
            appId: try requireAppId(appId),
            token: token
        )
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    func deleteInteractionResponse(
        appId: String? = nil,
        token: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteOriginalInteractionResponse(
            appId: try requireAppId(appId),
            token: token
        )
        return try await self.send(to: endpoint, queries: [])
    }
    
    func createFollowupInteractionResponse(
        appId: String? = nil,
        token: String,
        payload: InteractionResponse
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.postFollowupGatewayInteractionResponse(
            appId: try requireAppId(appId),
            token: token
        )
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    func editFollowupInteractionResponse(
        appId: String? = nil,
        id: String,
        token: String,
        payload: InteractionResponse
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.editGatewayInteractionResponseFollowup(
            appId: try requireAppId(appId),
            id: id,
            token: token
        )
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    func createMessage(
        channelId: String,
        payload: ChannelCreateMessage
    ) async throws -> DiscordClientResponse<Gateway.Message> {
        let endpoint = Endpoint.postCreateMessage(channelId: channelId)
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    func editMessage(
        channelId: String,
        messageId: String,
        payload: ChannelEditMessage
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.patchEditMessage(channelId: channelId, messageId: messageId)
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    func deleteMessage(
        channelId: String,
        messageId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteMessage(channelId: channelId, messageId: messageId)
        return try await self.send(to: endpoint, queries: [])
    }
    
    func createApplicationGlobalCommand(
        appId: String? = nil,
        payload: SlashCommand
    ) async throws -> DiscordClientResponse<SlashCommand> {
        let endpoint = Endpoint.createApplicationGlobalCommand(appId: try requireAppId(appId))
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    func getApplicationGlobalCommands(
        appId: String? = nil
    ) async throws -> DiscordClientResponse<[SlashCommand]> {
        let endpoint = Endpoint.getApplicationGlobalCommands(appId: try requireAppId(appId))
        return try await send(to: endpoint, queries: [])
    }
    
    func deleteApplicationGlobalCommand(
        appId: String? = nil,
        id: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteApplicationGlobalCommand(
            appId: try requireAppId(appId),
            id: id
        )
        return try await self.send(to: endpoint, queries: [])
    }
    
    func getGuild(id: String) async throws -> DiscordClientResponse<Guild> {
        let endpoint = Endpoint.getGuild(id: id)
        return try await self.send(to: endpoint, queries: [])
    }
    
    func getChannel(id: String) async throws -> DiscordClientResponse<Gateway.Channel> {
        let endpoint = Endpoint.getChannel(id: id)
        return try await self.send(to: endpoint, queries: [])
    }
    
    func leaveGuild(id: String) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.leaveGuild(id: id)
        return try await self.send(to: endpoint, queries: [])
    }
    
    func createGuildRole(
        guildId: String,
        payload: CreateGuildRole
    ) async throws -> DiscordClientResponse<Gateway.Role> {
        let endpoint = Endpoint.createGuildRole(guildId: guildId)
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    func addGuildMemberRole(
        guildId: String,
        userId: String,
        roleId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.addGuildMemberRole(
            guildId: guildId,
            userId: userId,
            roleId: roleId
        )
        return try await self.send(to: endpoint, queries: [])
    }
    
    func removeGuildMemberRole(
        guildId: String,
        userId: String,
        roleId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.removeGuildMemberRole(
            guildId: guildId,
            userId: userId,
            roleId: roleId
        )
        return try await self.send(to: endpoint, queries: [])
    }
    
    func addReaction(
        channelId: String,
        messageId: String,
        emoji: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.addReaction(
            channelId: channelId,
            messageId: messageId,
            emoji: emoji
        )
        return try await self.send(to: endpoint, queries: [])
    }
    
    func searchGuildMembers(
        guildId: String,
        query: String,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<[Gateway.Member]> {
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
    
    func getGuildMember(
        guildId: String,
        userId: String
    ) async throws -> DiscordClientResponse<Gateway.Member> {
        let endpoint = Endpoint.getGuildMember(id: guildId, userId: userId)
        return try await self.send(to: endpoint, queries: [])
    }
    
    /// NOTE: `around`, `before` and `after` are mutually exclusive.
    func getChannelMessages(
        channelId: String,
        around: String? = nil,
        before: String? = nil,
        after: String? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<[Gateway.Message]> {
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
    
    func getChannelMessage(
        channelId: String,
        messageId: String
    ) async throws -> DiscordClientResponse<Gateway.Message> {
        let endpoint = Endpoint.getChannelMessage(id: channelId, messageId: messageId)
        return try await self.send(to: endpoint, queries: [])
    }
}

/// The fact that this could be used by multiple different `DiscordClient`s with
/// different `token`s should not matter because buckets are random anyway.
private let rateLimiter = HTTPRateLimiter(label: "DiscordClientRateLimiter")

//MARK: - DefaultDiscordClient
public struct DefaultDiscordClient: DiscordClient {
    
    public let client: HTTPClient
    private let token: Secret
    public let appId: String?
    private let cache: ClientCache?
    public let configuration: ClientConfiguration
    
    /// If you provide no app id, you'll need to pass it to some functions on call site.
    public init(
        httpClient: HTTPClient,
        token: Secret,
        appId: String?,
        configuration: ClientConfiguration
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
    
    func checkRateLimitsAllowRequest(to endpoint: Endpoint) async throws {
        if await !rateLimiter.shouldRequest(to: endpoint) {
            throw DiscordClientError.rateLimited(url: "\(endpoint.url)")
        }
    }
    
    func includeInRateLimits(
        endpoint: Endpoint,
        headers: HTTPHeaders,
        status: HTTPResponseStatus
    ) async {
        await rateLimiter.include(endpoint: endpoint, headers: headers, status: status)
    }
    
    func getFromCache(
        identity: CacheableEndpointIdentity?,
        queries: [(String, String?)]
    ) async -> DiscordHTTPResponse? {
        guard let identity = identity else { return nil }
        return await cache?.get(item: .init(
            identity: identity,
            queries: queries
        ))
    }
    
    func saveInCache(
        response: DiscordHTTPResponse,
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
    
    public func send(
        to endpoint: Endpoint,
        queries: [(String, String?)] = []
    ) async throws -> DiscordHTTPResponse {
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
    
    public func send<C: Codable>(
        to endpoint: Endpoint,
        queries: [(String, String?)] = []
    ) async throws -> DiscordClientResponse<C> {
        let response = try await self.send(to: endpoint, queries: queries)
        return DiscordClientResponse(raw: response)
    }
    
    public func send<E: Encodable>(
        to endpoint: Endpoint,
        queries: [(String, String?)] = [],
        payload: E
    ) async throws -> DiscordHTTPResponse {
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
    
    public func send<E: Encodable, C: Codable>(
        to endpoint: Endpoint,
        queries: [(String, String?)] = [],
        payload: E
    ) async throws -> DiscordClientResponse<C> {
        let response = try await self.send(to: endpoint, queries: queries, payload: payload)
        return DiscordClientResponse(raw: response)
    }
}

//MARK: - ClientCacheStorage
private final class ClientCacheStorage {
    
    /// [Token: ClientCache]
    private var storage = [String: ClientCache]()
    private let lock = NIOLock()
    
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
    private var storage = [CacheableItem: DiscordHTTPResponse]()
    
    init() {
        Task {
            await self.setupGarbageCollector()
        }
    }
    
    func add(response: DiscordHTTPResponse, item: CacheableItem, ttl: Double) {
        self.timeTable[item] = Date().timeIntervalSince1970 + ttl
        self.storage[item] = response
    }
    
    func get(item: CacheableItem) -> DiscordHTTPResponse? {
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
extension DefaultDiscordClient: Sendable { }
extension DiscordClientResponse: Sendable where C: Sendable { }
extension ClientConfiguration: Sendable { }
extension ClientConfiguration.CachingBehavior: Sendable { }
