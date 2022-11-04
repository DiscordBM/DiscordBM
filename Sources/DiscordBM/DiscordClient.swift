@preconcurrency import AsyncHTTPClient
import NIOHTTP1
import NIOCore

public protocol DiscordClient {
    
    var appId: String? { get }
    
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

//MARK: - Default functions for DiscordClient
public extension DiscordClient {
    @inlinable
    func send<C: Codable>(
        to endpoint: Endpoint,
        queries: [(String, String?)]
    ) async throws -> DiscordClientResponse<C> {
        let response = try await self.send(to: endpoint, queries: queries)
        return DiscordClientResponse(httpResponse: response)
    }
    
    @inlinable
    func send<E: Encodable, C: Codable>(
        to endpoint: Endpoint,
        queries: [(String, String?)],
        payload: E
    ) async throws -> DiscordClientResponse<C> {
        let response = try await self.send(to: endpoint, queries: queries, payload: payload)
        return DiscordClientResponse(httpResponse: response)
    }
}

public struct DiscordHTTPResponse: Sendable, CustomStringConvertible {
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
    
    public var description: String {
        var bodyDescription: String {
            if var body = body {
                return body.readString(length: body.readableBytes) ?? "nil"
            } else {
                return "nil"
            }
        }
        return "DiscordHTTPResponse("
        + "host: \(host), "
        + "status: \(status), "
        + "version: \(version), "
        + "headers: \(headers), "
        + "body: \(bodyDescription)"
        + ")"
    }
    
    @inlinable
    func decode<D: Decodable>(as _: D.Type) throws -> D {
        if (200..<300).contains(self.status.code) {
            if var body = self.body,
               let data = body.readData(length: body.readableBytes) {
                return try DiscordGlobalConfiguration.decoder.decode(D.self, from: data)
            } else {
                throw DiscordClientError.emptyBody(self)
            }
        } else {
            throw DiscordClientError.cantAttemptToDecodeDueToBadStatusCode(self)
        }
    }
}

public struct DiscordClientResponse<C>: Sendable where C: Codable {
    public let httpResponse: DiscordHTTPResponse
    
    public init(httpResponse: DiscordHTTPResponse) {
        self.httpResponse = httpResponse
    }
    
    @inlinable
    public func decode() throws -> C {
        try httpResponse.decode(as: C.self)
    }
}

public enum DiscordClientError: Error {
    case rateLimited(url: String)
    case cantAttemptToDecodeDueToBadStatusCode(DiscordHTTPResponse)
    case emptyBody(DiscordHTTPResponse)
    case appIdParameterRequired
    /// Can only send one of those query parameters.
    case queryParametersMutuallyExclusive(queries: [(String, String?)])
    case queryParameterOutOfBounds(name: String, value: String?, lowerBound: Int, upperBound: Int)
}

//MARK: - Internal +DiscordClient
extension DiscordClient {
    
    @usableFromInline
    func requireAppId(_ providedAppId: String?) throws -> String {
        if let appId = providedAppId ?? self.appId {
            return appId
        } else {
            /// You have not passed your app-id in the init of `DiscordClient`/`GatewayManager`.
            /// You need to pass it in the function parameters.
            throw DiscordClientError.appIdParameterRequired
        }
    }
    
    @usableFromInline
    func checkMutuallyExclusive(queries: [(String, String?)]) throws {
        guard queries.filter({ $0.1 != nil }).count < 2 else {
            throw DiscordClientError.queryParametersMutuallyExclusive(queries: queries)
        }
    }
    
    @usableFromInline
    func checkInBounds(
        name: String,
        value: Int?,
        lowerBound: Int,
        upperBound: Int
    ) throws {
        guard value.map({ (lowerBound...upperBound).contains($0) }) != false else {
            throw DiscordClientError.queryParameterOutOfBounds(
                name: name,
                value: value?.description,
                lowerBound: 1,
                upperBound: 1_000
            )
        }
    }
}

//MARK: - Public +DiscordClient
public extension DiscordClient {
    
    /// https://discord.com/developers/docs/topics/gateway#get-gateway
    @inlinable
    func getGateway() async throws -> DiscordClientResponse<Gateway.Url> {
        let endpoint = Endpoint.getGateway
        return try await self.send(to: endpoint, queries: [])
    }
    
    /// https://discord.com/developers/docs/topics/gateway#get-gateway-bot
    @inlinable
    func getGatewayBot() async throws -> DiscordClientResponse<Gateway.BotConnectionInfo> {
        let endpoint = Endpoint.getGatewayBot
        return try await self.send(to: endpoint, queries: [])
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#create-interaction-response
    @inlinable
    func createInteractionResponse(
        id: String,
        token: String,
        payload: InteractionResponse
    ) async throws -> DiscordClientResponse<InteractionResponse.CallbackData> {
        let endpoint = Endpoint.createInteractionResponse(id: id, token: token)
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#edit-original-interaction-response
    @inlinable
    func editInteractionResponse(
        appId: String? = nil,
        token: String,
        payload: InteractionResponse.CallbackData
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.editInteractionResponse(
            appId: try requireAppId(appId),
            token: token
        )
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#delete-original-interaction-response
    @inlinable
    func deleteInteractionResponse(
        appId: String? = nil,
        token: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteInteractionResponse(
            appId: try requireAppId(appId),
            token: token
        )
        return try await self.send(to: endpoint, queries: [])
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#create-followup-message
    @inlinable
    func createFollowupInteractionResponse(
        appId: String? = nil,
        token: String,
        payload: InteractionResponse
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.postFollowupInteractionResponse(
            appId: try requireAppId(appId),
            token: token
        )
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#edit-followup-message
    @inlinable
    func editFollowupInteractionResponse(
        appId: String? = nil,
        id: String,
        token: String,
        payload: InteractionResponse
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.editFollowupInteractionResponse(
            appId: try requireAppId(appId),
            id: id,
            token: token
        )
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    /// https://discord.com/developers/docs/resources/channel#create-message
    @inlinable
    func createMessage(
        channelId: String,
        payload: DiscordChannel.CreateMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = Endpoint.postCreateMessage(channelId: channelId)
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    /// https://discord.com/developers/docs/resources/channel#edit-message
    @inlinable
    func editMessage(
        channelId: String,
        messageId: String,
        payload: DiscordChannel.EditMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = Endpoint.patchEditMessage(channelId: channelId, messageId: messageId)
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    /// https://discord.com/developers/docs/resources/channel#delete-message
    @inlinable
    func deleteMessage(
        channelId: String,
        messageId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteMessage(channelId: channelId, messageId: messageId)
        return try await self.send(to: endpoint, queries: [])
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#create-global-application-command
    @inlinable
    func createApplicationGlobalCommand(
        appId: String? = nil,
        payload: SlashCommand
    ) async throws -> DiscordClientResponse<SlashCommand> {
        let endpoint = Endpoint.createApplicationGlobalCommand(appId: try requireAppId(appId))
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#get-global-application-commands
    @inlinable
    func getApplicationGlobalCommands(
        appId: String? = nil
    ) async throws -> DiscordClientResponse<[SlashCommand]> {
        let endpoint = Endpoint.getApplicationGlobalCommands(appId: try requireAppId(appId))
        return try await send(to: endpoint, queries: [])
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#delete-global-application-command
    @inlinable
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
    
    /// https://discord.com/developers/docs/resources/guild#get-guild
    @inlinable
    func getGuild(
        id: String,
        withCounts: Bool? = nil
    ) async throws -> DiscordClientResponse<Guild> {
        let endpoint = Endpoint.getGuild(id: id)
        return try await self.send(
            to: endpoint,
            queries: [("with_counts", withCounts?.description)]
        )
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-channel
    @inlinable
    func getChannel(id: String) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = Endpoint.getChannel(id: id)
        return try await self.send(to: endpoint, queries: [])
    }
    
    /// https://discord.com/developers/docs/resources/user#leave-guild
    @inlinable
    func leaveGuild(id: String) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.leaveGuild(id: id)
        return try await self.send(to: endpoint, queries: [])
    }
    
    /// https://discord.com/developers/docs/resources/guild#create-guild-role
    @inlinable
    func createGuildRole(
        guildId: String,
        payload: CreateGuildRole
    ) async throws -> DiscordClientResponse<Role> {
        let endpoint = Endpoint.createGuildRole(guildId: guildId)
        return try await self.send(to: endpoint, queries: [], payload: payload)
    }
    
    /// https://discord.com/developers/docs/resources/guild#delete-guild-role
    @inlinable
    func deleteGuildRole(
        guildId: String,
        roleId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteGuildRole(guildId: guildId, roleId: roleId)
        return try await self.send(to: endpoint, queries: [])
    }
    
    /// https://discord.com/developers/docs/resources/guild#add-guild-member-role
    @inlinable
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
    
    /// https://discord.com/developers/docs/resources/guild#remove-guild-member-role
    @inlinable
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
    
    /// https://discord.com/developers/docs/topics/gateway#message-reaction-add
    @inlinable
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
    
    /// NOTE: `limit`, if provided, must be between `1` and `1_000`.
    /// https://discord.com/developers/docs/resources/guild#search-guild-members
    @inlinable
    func searchGuildMembers(
        guildId: String,
        query: String,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<[Guild.Member]> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 1_000)
        let endpoint = Endpoint.searchGuildMembers(id: guildId)
        return try await self.send(
            to: endpoint,
            queries: [
                ("query", query),
                ("limit", limit?.description)
            ]
        )
    }
    
    /// https://discord.com/developers/docs/resources/guild#get-guild-member
    @inlinable
    func getGuildMember(
        guildId: String,
        userId: String
    ) async throws -> DiscordClientResponse<Guild.Member> {
        let endpoint = Endpoint.getGuildMember(id: guildId, userId: userId)
        return try await self.send(to: endpoint, queries: [])
    }
    
    /// NOTE: `around`, `before` and `after` are mutually exclusive.
    /// https://discord.com/developers/docs/resources/channel#get-channel-messages
    @inlinable
    func getChannelMessages(
        channelId: String,
        around: String? = nil,
        before: String? = nil,
        after: String? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<[Gateway.MessageCreate]> {
        try checkMutuallyExclusive(queries: [
            ("around", around),
            ("before", before),
            ("after", after)
        ])
        let endpoint = Endpoint.getChannelMessages(channelId: channelId)
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
    
    /// https://discord.com/developers/docs/resources/channel#get-channel-message
    @inlinable
    func getChannelMessage(
        channelId: String,
        messageId: String
    ) async throws -> DiscordClientResponse<Gateway.MessageCreate> {
        let endpoint = Endpoint.getChannelMessage(channelId: channelId, messageId: messageId)
        return try await self.send(to: endpoint, queries: [])
    }
}
