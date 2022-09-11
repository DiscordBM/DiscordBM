import Foundation
import AsyncHTTPClient
import NIOHTTP1
import NIOConcurrencyHelpers

public enum DiscordClientError: Error {
    case rateLimited(url: String)
    case cantAttemptToDecode
    case emptyBody
    case appIdParameterNotProvided
}

/// The fact that this could be used by multiple different `DiscordClient`s with
/// different `token`s should not matter because buckets are random anyway.
private let rateLimiter = HTTPRateLimiter(label: "DiscordClientRateLimiter")
private let cache = ClientCache()

public struct DiscordClient {
    
    public struct Response<C> where C: Codable {
        
        public let raw: HTTPClient.Response
        
        public func decode() throws -> C {
            if (200..<300).contains(raw.status.code) {
                if let body = raw.body,
                   let data = body.getData(at: 0, length: body.readableBytes) {
                    return try DiscordGlobalConfiguration.decoder.decode(C.self, from: data)
                } else {
                    throw DiscordClientError.emptyBody
                }
            } else {
                throw DiscordClientError.cantAttemptToDecode
            }
        }
    }
    
    private let client: HTTPClient
    private let token: String
    private let cache: ClientCache?
    private let cachingBehavior: CachingBehavior
    public let appId: String?
    
    /// If you provide no app id, you'll need to pass to every function on call site.
    public init(
        httpClient: HTTPClient,
        token: String,
        appId: String?,
        cachingBehavior: CachingBehavior = .default
    ) {
        self.client = httpClient
        self.token = token
        self.appId = appId
        self.cachingBehavior = cachingBehavior
        if self.cachingBehavior.isDisabled {
            self.cache = nil
        } else {
            self.cache = ClientCacheStorage.shared.cache(for: token)
        }
    }
    
    private func requireAppId(_ providedAppId: String?) throws -> String {
        if let appId = providedAppId ?? self.appId {
            return appId
        } else {
            throw DiscordClientError.appIdParameterNotProvided
        }
    }
    
    private func checkRateLimitsAllowRequest(to endpoint: Endpoint) throws {
        if !rateLimiter.canRequest(to: "\(endpoint.id)") {
            throw DiscordClientError.rateLimited(url: "\(endpoint.url)")
        }
    }
    
    private func includeInRateLimits(endpoint: Endpoint, headers: HTTPHeaders) {
        rateLimiter.include(endpointId: "\(endpoint.id)", headers: headers)
    }
    
    private func getFromCache(
        identity: EndpointIdentity,
        queries: [String: String]
    ) async -> HTTPClient.Response? {
        await cache?.get(item: .init(
            identity: identity,
            queries: queries
        ))
    }
    
    private func saveInCache(
        response: HTTPClient.Response,
        identity: EndpointIdentity,
        queries: [String: String]
    ) async {
        guard (200..<300).contains(response.status.code),
              let ttl = self.cachingBehavior.getTTL(for: identity)
        else { return }
        await cache?.add(
            response: response,
            item: .init(
                identity: identity,
                queries: queries
            ), ttl: ttl
        )
    }
    
    private func send(
        to endpoint: Endpoint,
        queries: [String: String] = [:]
    ) async throws -> HTTPClient.Response {
        let identity = endpoint.identity
        if let cached = await self.getFromCache(identity: identity, queries: queries) {
            return cached
        }
        try self.checkRateLimitsAllowRequest(to: endpoint)
        let request = try HTTPClient.Request(
            url: endpoint.url + queries.makeForURL(),
            method: endpoint.httpMethod,
            headers: ["Authorization": "Bot \(token)"]
        )
        let response = try await client.execute(request: request).get()
        self.includeInRateLimits(endpoint: endpoint, headers: response.headers)
        await self.saveInCache(
            response: response,
            identity: identity,
            queries: queries
        )
        return response
    }
    
    private func send<C: Codable>(
        to endpoint: Endpoint,
        queries: [String: String] = [:]
    ) async throws -> Response<C> {
        let response = try await self.send(to: endpoint, queries: queries)
        return Response(raw: response)
    }
    
    private func send<E: Encodable>(
        to endpoint: Endpoint,
        queries: [String: String] = [:],
        payload: E
    ) async throws -> HTTPClient.Response {
        let identity = endpoint.identity
        if let cached = await self.getFromCache(identity: identity, queries: queries) {
            return cached
        }
        try self.checkRateLimitsAllowRequest(to: endpoint)
        let data = try DiscordGlobalConfiguration.encoder.encode(payload)
        let request = try HTTPClient.Request(
            url: endpoint.url + queries.makeForURL(),
            method: endpoint.httpMethod,
            headers: [
                "Authorization": "Bot \(token)",
                "Content-Type": "application/json"
            ],
            body: .bytes(data)
        )
        let response = try await client.execute(request: request).get()
        self.includeInRateLimits(endpoint: endpoint, headers: response.headers)
        await self.saveInCache(
            response: response,
            identity: identity,
            queries: queries
        )
        return response
    }
    
    private func send<E: Encodable, C: Codable>(
        to endpoint: Endpoint,
        queries: [String: String] = [:],
        payload: E
    ) async throws -> Response<C> {
        let response = try await self.send(to: endpoint, queries: queries, payload: payload)
        return Response(raw: response)
    }
}

extension DiscordClient: CustomStringConvertible {
    public var description: String {
        "DiscordClient("
        + "client: \(client), "
        + "token: \(token.dropLast(max(0, token.count - 6)))****, "
        + "appId: \(appId ?? "NULL")"
        + ")"
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
        limit: Int = 1000
    ) async throws -> Response<[Gateway.Member]> {
        let endpoint = Endpoint.searchGuildMembers(id: guildId)
        return try await self.send(
            to: endpoint,
            queries: [
                "query": query,
                "limit": "\(limit)"
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
}

//MARK: - CachingBehavior
public struct CachingBehavior {
    
    /// [ID: TTL]
    private var storage = [EndpointIdentity: Double]()
    /// This instance's default TTL for all endpoints.
    public var defaultTTL = 5.0
    public var isDisabled = false
    
    /// Caches all cacheable endpoints for 5 seconds.
    public static let `default` = CachingBehavior()
    /// Doesn't allow caching at all.
    public static let disabled = CachingBehavior(isDisabled: true)
    
    public mutating func modifyBehavior(for identity: EndpointIdentity, ttl: Double? = nil) {
        guard !self.isDisabled else { return }
        self.storage[identity] = ttl ?? 0
    }
    
    func getTTL(for identity: EndpointIdentity) -> Double? {
        guard !self.isDisabled else { return nil }
        guard let ttl = self.storage[identity] else { return self.defaultTTL }
        if ttl == 0 {
            return nil
        } else {
            return ttl
        }
    }
}

//MARK: - ClientCacheStorage
private final class ClientCacheStorage {
    
    /// [ID: ClientCache]
    private var storage = [String: ClientCache]()
    private let lock = Lock()
    
    private init() { }
    
    static let shared = ClientCacheStorage()
    
    func cache(for id: String) -> ClientCache {
        self.lock.lock()
        defer { self.lock.unlock() }
        if let cache = self.storage[id] {
            return cache
        } else {
            let cache = ClientCache()
            self.storage[id] = cache
            return cache
        }
    }
}

//MARK: - ClientCache
private actor ClientCache {
    
    struct CacheableItem: Hashable {
        let identity: EndpointIdentity
        let queries: [String: String]
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

//MARK: +Dictionary<(String, String)>
private extension Dictionary where Key == String, Value == String {
    func makeForURL() -> String {
        if self.isEmpty {
            return ""
        } else {
            return "?" + self.map({ "\($0)=\($1)" }).joined(separator: "&")
        }
    }
}
