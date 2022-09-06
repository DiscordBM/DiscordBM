import Foundation
import AsyncHTTPClient
import NIOHTTP1

public enum DiscordClientError: Error {
    case rateLimited(endpoint: String)
    case cantAttemptToDecode(status: HTTPResponseStatus)
    case emptyBody
}

private let rateLimiter = HTTPRateLimiter(label: "DiscordClientRateLimiter")

public struct DiscordClient {
    
    public struct Response<C> where C: Codable {
        
        public let raw: HTTPClient.Response
        
        public func decode() throws -> C {
            if (200..<300).contains(raw.status.code) {
                if let body = raw.body {
                    let data = body.getData(at: 0, length: body.readableBytes) ?? Data()
                    return try DiscordGlobalConfiguration.decoder.decode(C.self, from: data)
                } else {
                    throw DiscordClientError.emptyBody
                }
            } else {
                throw DiscordClientError.cantAttemptToDecode(status: raw.status)
            }
        }
    }
    
    private let client: HTTPClient
    private let token: String
    private let appId: String
    private var authHeaders: HTTPHeaders {
        ["Authorization": "Bot \(token)"]
    }
    
    public init(
        httpClient: HTTPClient,
        token: String,
        appId: String
    ) {
        self.client = httpClient
        self.token = token
        self.appId = appId
    }
    
    private func checkRateLimitsAllowRequest(to endpoint: Endpoint) throws {
        if !rateLimiter.canRequest(to: "\(endpoint.id)") {
            throw DiscordClientError.rateLimited(endpoint: "\(endpoint)")
        }
    }
    
    private func includeInRateLimits(endpoint: Endpoint, headers: HTTPHeaders) {
        rateLimiter.include(endpointId: "\(endpoint.id)", headers: headers)
    }
    
    private func send(
        to endpoint: Endpoint,
        query: [(String, String)] = []
    ) async throws -> HTTPClient.Response {
        try self.checkRateLimitsAllowRequest(to: endpoint)
        let request = try HTTPClient.Request(
            url: endpoint.url + query.makeForURL(),
            method: endpoint.httpMethod,
            headers: self.authHeaders
        )
        let response = try await client.execute(request: request).get()
        self.includeInRateLimits(endpoint: endpoint, headers: response.headers)
        return response
    }
    
    private func send<C: Codable>(
        to endpoint: Endpoint,
        query: [(String, String)] = []
    ) async throws -> Response<C> {
        let response = try await self.send(to: endpoint, query: query)
        return Response(raw: response)
    }
    
    private func send<E: Encodable>(
        to endpoint: Endpoint,
        query: [(String, String)] = [],
        payload: E
    ) async throws -> HTTPClient.Response {
        try self.checkRateLimitsAllowRequest(to: endpoint)
        let data = try DiscordGlobalConfiguration.encoder.encode(payload)
        let request = try HTTPClient.Request(
            url: endpoint.url + query.makeForURL(),
            method: endpoint.httpMethod,
            headers: self.authHeaders,
            body: .bytes(data)
        )
        let response = try await client.execute(request: request).get()
        self.includeInRateLimits(endpoint: endpoint, headers: response.headers)
        return response
    }
    
    private func send<E: Encodable, C: Codable>(
        to endpoint: Endpoint,
        query: [(String, String)] = [],
        payload: E
    ) async throws -> Response<C> {
        let response = try await self.send(to: endpoint, query: query, payload: payload)
        return Response(raw: response)
    }
}

extension DiscordClient: CustomStringConvertible {
    public var description: String {
        "DiscordClient(client: \(type(of: client)))"
    }
}

//MARK: - API-call functions

extension DiscordClient {
    
    public func getGateway() async throws -> Response<Gateway.GatewayUrl> {
        let endpoint = Endpoint.getGateway
        return try await self.send(to: endpoint)
    }
    
    public func postGatewayInteractionResponse(
        id: String,
        token: String,
        payload: InteractionResponse
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.createInteractionResponse(id: id, token: token)
        return try await self.send(to: endpoint, payload: payload)
    }
    
    public func editGatewayInteractionResponse(
        token: String,
        payload: InteractionResponse.CallbackData
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.editOriginalInteractionResponse(appId: appId, token: token)
        return try await self.send(to: endpoint, payload: payload)
    }
    
    public func deleteGatewayInteractionResponse(token: String) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.deleteGatewayInteractionResponse(appId: appId, token: token)
        return try await self.send(to: endpoint)
    }
    
    public func postFollowupGatewayInteractionResponse(
        token: String,
        payload: InteractionResponse
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.postFollowupGatewayInteractionResponse(appId: appId, token: token)
        return try await self.send(to: endpoint, payload: payload)
    }
    
    public func editGatewayInteractionResponseFollowup(
        token: String,
        id: String,
        payload: InteractionResponse
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.editGatewayInteractionResponseFollowup(appId: appId, token: token, id: id)
        return try await self.send(to: endpoint, payload: payload)
    }
    
    public func postChannelCreateMessage(
        id: String,
        payload: ChannelCreateMessage
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.postChannelCreateMessage(channel: id)
        return try await self.send(to: endpoint, payload: payload)
    }
    
    public func patchChannelEditMessage(
        channel: String,
        messageId: String,
        payload: ChannelEditMessage
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.patchChannelEditMessage(channel: channel, messageId: messageId)
        return try await self.send(to: endpoint, payload: payload)
    }
    
    public func deleteChannelMessage(
        channel: String,
        messageId: String
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.deleteChannelMessage(channel: channel, messageId: messageId)
        return try await self.send(to: endpoint)
    }
    
    public func createApplicationGlobalCommand(
        payload: SlashCommand
    ) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.createApplicationGlobalCommand(appId: appId)
        return try await self.send(to: endpoint, payload: payload)
    }
    
    public func getApplicationGlobalCommands() async throws -> Response<[SlashCommand]> {
        let endpoint = Endpoint.getApplicationGlobalCommands(appId: appId)
        return try await send(to: endpoint)
    }
    
    public func deleteApplicationGlobalCommand(id: String) async throws -> HTTPClient.Response {
        let endpoint = Endpoint.deleteApplicationGlobalCommand(appId: appId, id: id)
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
            query: [
                ("query", query),
                ("limit", "\(limit)")
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

private extension Array where Element == (String, String) {
    func makeForURL() -> String {
        if self.isEmpty {
            return ""
        } else {
            return "?" + self.map({ "\($0)=\($1)" }).joined(separator: "&")
        }
    }
}
