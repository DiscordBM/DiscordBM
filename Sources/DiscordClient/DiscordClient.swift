import DiscordModels
import NIOHTTP1
import NIOCore
import Foundation

public protocol DiscordClient: Sendable {
    var appId: String? { get }
    
    func send(request: DiscordHTTPRequest) async throws -> DiscordHTTPResponse
    
    func send<E: Encodable & Validatable>(
        request: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordHTTPResponse
    
    func sendMultipart<E: MultipartEncodable & Validatable>(
        request: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordHTTPResponse
}

//MARK: - Default functions for DiscordClient
public extension DiscordClient {
    @inlinable
    func send<C: Codable>(request: DiscordHTTPRequest) async throws -> DiscordClientResponse<C> {
        let response = try await self.send(request: request)
        return DiscordClientResponse(httpResponse: response)
    }
    
    @inlinable
    func send<E: Encodable & Validatable, C: Codable>(
        request: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordClientResponse<C> {
        let response = try await self.send(request: request, payload: payload)
        return DiscordClientResponse(httpResponse: response)
    }
    
    @inlinable
    func sendMultipart<E: MultipartEncodable & Validatable, C: Codable>(
        request: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordClientResponse<C> {
        let response = try await self.sendMultipart(request: request, payload: payload)
        return DiscordClientResponse(httpResponse: response)
    }
}

public enum DiscordClientError: Error {
    /// You have exhausted your rate-limits.
    case rateLimited(url: String)
    /// Discord responded with a non-2xx status code.
    case badStatusCode(DiscordHTTPResponse)
    /// The body of the response was empty.
    case emptyBody(DiscordHTTPResponse)
    /// You need to provide an `appId`.
    /// Either via the function arguments or the DiscordClient initializer.
    case appIdParameterRequired
    /// Can only send one of these query parameters.
    case queryParametersMutuallyExclusive(queries: [(String, String)])
    /// Query parameter is out of the accepted bounds.
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
            /// You need to pass it in the function parameters at least.
            throw DiscordClientError.appIdParameterRequired
        }
    }
    
    @usableFromInline
    func checkMutuallyExclusive(queries: [(String, String?)]) throws {
        let notNil = queries.filter { $0.1 != nil }
        guard notNil.count < 2 else {
            throw DiscordClientError.queryParametersMutuallyExclusive(
                /// Force-unwrap is safe.
                queries: notNil.map { ($0, $1!) }
            )
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
    func getGateway() async throws -> DiscordClientResponse<Gateway.URL> {
        let endpoint = Endpoint.getGateway
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/topics/gateway#get-gateway-bot
    @inlinable
    func getGatewayBot() async throws -> DiscordClientResponse<Gateway.BotConnectionInfo> {
        let endpoint = Endpoint.getGatewayBot
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#create-interaction-response
    @inlinable
    func createInteractionResponse(
        id: String,
        token: String,
        payload: RequestBody.InteractionResponse
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.createInteractionResponse(id: id, token: token)
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#get-original-interaction-response
    @inlinable
    func getInteractionResponse(
        appId: String? = nil,
        token: String,
        thread_id: String? = nil
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = Endpoint.getInteractionResponse(
            appId: try requireAppId(appId),
            token: token
        )
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("thread_id", thread_id)]
        ))
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#edit-original-interaction-response
    @inlinable
    func editInteractionResponse(
        appId: String? = nil,
        token: String,
        payload: RequestBody.InteractionResponse.CallbackData
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.editInteractionResponse(
            appId: try requireAppId(appId),
            token: token
        )
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
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
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#create-followup-message
    @inlinable
    func createFollowupInteractionResponse(
        appId: String? = nil,
        token: String,
        payload: RequestBody.InteractionResponse
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.postFollowupInteractionResponse(
            appId: try requireAppId(appId),
            token: token
        )
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#get-followup-message
    @inlinable
    func getFollowupInteractionResponse(
        appId: String? = nil,
        token: String,
        messageId: String,
        thread_id: String? = nil
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = Endpoint.getFollowupInteractionResponse(
            appId: try requireAppId(appId),
            token: token,
            messageId: messageId
        )
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("thread_id", thread_id)]
        ))
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#edit-followup-message
    @inlinable
    func editFollowupInteractionResponse(
        appId: String? = nil,
        token: String,
        messageId: String,
        payload: RequestBody.InteractionResponse
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.editFollowupInteractionResponse(
            appId: try requireAppId(appId),
            token: token,
            messageId: messageId
        )
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#delete-followup-message
    @inlinable
    func deleteFollowupInteractionResponse(
        appId: String? = nil,
        token: String,
        messageId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteFollowupInteractionResponse(
            appId: try requireAppId(appId),
            token: token,
            messageId: messageId
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#create-message
    @inlinable
    func createMessage(
        channelId: String,
        payload: RequestBody.CreateMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = Endpoint.createMessage(channelId: channelId)
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/resources/channel#edit-message
    @inlinable
    func editMessage(
        channelId: String,
        messageId: String,
        payload: RequestBody.EditMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = Endpoint.editMessage(channelId: channelId, messageId: messageId)
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/resources/channel#delete-message
    @inlinable
    func deleteMessage(
        channelId: String,
        messageId: String,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteMessage(channelId: channelId, messageId: messageId)
        return try await self.send(request: .init(
            to: endpoint,
            headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
        ))
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#create-global-application-command
    @inlinable
    func createApplicationGlobalCommand(
        appId: String? = nil,
        payload: ApplicationCommand
    ) async throws -> DiscordClientResponse<ApplicationCommand> {
        let endpoint = Endpoint.createApplicationGlobalCommand(appId: try requireAppId(appId))
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#get-global-application-commands
    @inlinable
    func getApplicationGlobalCommands(
        appId: String? = nil,
        with_localizations: Bool? = nil
    ) async throws -> DiscordClientResponse<[ApplicationCommand]> {
        let endpoint = Endpoint.getApplicationGlobalCommands(appId: try requireAppId(appId))
        return try await send(request: .init(
            to: endpoint,
            queries: [("with_localizations", with_localizations.map { "\($0)" })]
        ))
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
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/guild#get-guild
    @inlinable
    func getGuild(
        id: String,
        withCounts: Bool? = nil
    ) async throws -> DiscordClientResponse<Guild> {
        let endpoint = Endpoint.getGuild(id: id)
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("with_counts", withCounts?.description)]
        ))
    }
    
    /// https://discord.com/developers/docs/resources/guild#get-guild-roles
    @inlinable
    func getGuildRoles(id: String) async throws -> DiscordClientResponse<[Role]> {
        let endpoint = Endpoint.getGuildRoles(id: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-channel
    @inlinable
    func getChannel(id: String) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = Endpoint.getChannel(id: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/user#leave-guild
    @inlinable
    func leaveGuild(id: String) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.leaveGuild(id: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/guild#create-guild-role
    @inlinable
    func createGuildRole(
        guildId: String,
        reason: String? = nil,
        payload: RequestBody.CreateGuildRole
    ) async throws -> DiscordClientResponse<Role> {
        let endpoint = Endpoint.createGuildRole(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }
    
    /// https://discord.com/developers/docs/resources/guild#delete-guild-role
    @inlinable
    func deleteGuildRole(
        guildId: String,
        roleId: String,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteGuildRole(guildId: guildId, roleId: roleId)
        return try await self.send(request: .init(
            to: endpoint,
            headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
        ))
    }
    
    /// https://discord.com/developers/docs/resources/guild#add-guild-member-role
    @inlinable
    func addGuildMemberRole(
        guildId: String,
        userId: String,
        roleId: String,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.addGuildMemberRole(
            guildId: guildId,
            userId: userId,
            roleId: roleId
        )
        return try await self.send(request: .init(
            to: endpoint,
            headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
        ))
    }
    
    /// https://discord.com/developers/docs/resources/guild#remove-guild-member-role
    @inlinable
    func removeGuildMemberRole(
        guildId: String,
        userId: String,
        roleId: String,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.removeGuildMemberRole(
            guildId: guildId,
            userId: userId,
            roleId: roleId
        )
        return try await self.send(request: .init(
            to: endpoint,
            headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
        ))
    }
    
    /// https://discord.com/developers/docs/resources/channel#create-reaction
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
        return try await self.send(request: .init(to: endpoint))
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
        return try await self.send(request: .init(
            to: endpoint,
            queries: [
                ("query", query),
                ("limit", limit?.description)
            ]
        ))
    }
    
    /// https://discord.com/developers/docs/resources/guild#get-guild-member
    @inlinable
    func getGuildMember(
        guildId: String,
        userId: String
    ) async throws -> DiscordClientResponse<Guild.Member> {
        let endpoint = Endpoint.getGuildMember(id: guildId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
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
        return try await self.send(request: .init(
            to: endpoint,
            queries: [
                ("around", around),
                ("before", before),
                ("after", after),
                ("limit", limit.map({ "\($0)" }))
            ]
        ))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-channel-message
    @inlinable
    func getChannelMessage(
        channelId: String,
        messageId: String
    ) async throws -> DiscordClientResponse<Gateway.MessageCreate> {
        let endpoint = Endpoint.getChannelMessage(channelId: channelId, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// NOTE: `limit`, if provided, must be between `1` and `1_000`.
    /// https://discord.com/developers/docs/resources/audit-log#get-guild-audit-log
    @inlinable
    func getGuildAuditLogs(
        guildId: String,
        user_id: String? = nil,
        action_type: AuditLog.Entry.ActionKind? = nil,
        before: String? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<AuditLog> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 1_000)
        let endpoint = Endpoint.getGuildAuditLogs(guildId: guildId)
        return try await self.send(request: .init(
            to: endpoint,
            queries: [
                ("user_id", user_id),
                ("action_type", action_type.map { "\($0.rawValue)" }),
                ("before", before),
                ("limit", limit.map { "\($0)" })
            ]
        ))
    }
    
    /// You can use this function to create a new **or** retrieve an existing DM channel.
    /// https://discord.com/developers/docs/resources/user#create-dm
    @inlinable
    func createDM(recipient_id: String) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = Endpoint.createDM
        return try await self.send(
            request: .init(to: endpoint),
            payload: RequestBody.CreateDM(recipient_id: recipient_id)
        )
    }
    
    /// https://discord.com/developers/docs/resources/webhook#create-webhook
    func createWebhook(
        channelId: String,
        reason: String? = nil,
        payload: RequestBody.CreateWebhook
    ) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = Endpoint.createWebhook(channelId: channelId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }
    
    /// https://discord.com/developers/docs/resources/webhook#get-channel-webhooks
    func getChannelWebhooks(channelId: String) async throws -> DiscordClientResponse<[Webhook]> {
        let endpoint = Endpoint.getChannelWebhooks(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/webhook#get-guild-webhooks
    func getGuildWebhooks(guildId: String) async throws -> DiscordClientResponse<[Webhook]> {
        let endpoint = Endpoint.getGuildWebhooks(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// Requires authentication using an authorized bot-token.
    /// https://discord.com/developers/docs/resources/webhook#get-webhook
    func getWebhook(id: String) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = Endpoint.getWebhook1(id: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// Doesn't require authentication using bot-token.
    /// https://discord.com/developers/docs/resources/webhook#get-webhook-with-token
    func getWebhook(address: WebhookAddress) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = Endpoint.getWebhook2(id: address.id, token: address.token)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// Requires authentication using an authorized bot-token.
    /// https://discord.com/developers/docs/resources/webhook#modify-webhook
    func modifyWebhook(
        id: String,
        reason: String? = nil,
        payload: RequestBody.ModifyGuildWebhook
    ) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = Endpoint.modifyWebhook1(id: id)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }
    
    /// Doesn't require authentication using bot-token.
    /// https://discord.com/developers/docs/resources/webhook#modify-webhook-with-token
    func modifyWebhook(
        address: WebhookAddress,
        reason: String? = nil,
        payload: RequestBody.ModifyWebhook
    ) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = Endpoint.modifyWebhook2(id: address.id, token: address.token)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }
    
    /// Requires authentication using an authorized bot-token.
    /// https://discord.com/developers/docs/resources/webhook#delete-webhook
    func deleteWebhook(id: String, reason: String? = nil) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteWebhook1(id: id)
        return try await self.send(request: .init(
            to: endpoint,
            headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
        ))
    }
    
    /// Doesn't require authentication using bot-token.
    /// https://discord.com/developers/docs/resources/webhook#delete-webhook-with-token
    func deleteWebhook(
        address: WebhookAddress,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteWebhook2(id: address.id, token: address.token)
        return try await self.send(request: .init(
            to: endpoint,
            headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
        ))
    }
    
    /// - Parameters:
    ///   - threadId: Required if the message is in a thread.
    /// https://discord.com/developers/docs/resources/webhook#execute-webhook
    @inlinable
    func executeWebhook(
        address: WebhookAddress,
        threadId: String? = nil,
        payload: RequestBody.ExecuteWebhook
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.executeWebhook(id: address.id, token: address.token)
        return try await self.sendMultipart(
            request: .init(
                to: endpoint,
                queries: [("thread_id", threadId)]
            ),
            payload: payload
        )
    }
    
    /// - Parameters:
    ///   - threadId: Required if the message is in a thread.
    /// https://discord.com/developers/docs/resources/webhook#execute-webhook
    @inlinable
    func executeWebhookWithResponse(
        address: WebhookAddress,
        threadId: String? = nil,
        payload: RequestBody.ExecuteWebhook
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = Endpoint.executeWebhook(id: address.id, token: address.token)
        return try await self.sendMultipart(
            request: .init(
                to: endpoint,
                queries: [
                    ("wait", "true"),
                    ("thread_id", threadId)
                ]
            ),
            payload: payload
        )
    }
    
    /// - Parameters:
    ///   - threadId: Required if the message is in a thread.
    /// https://discord.com/developers/docs/resources/webhook#get-webhook-message
    func getWebhookMessage(
        address: WebhookAddress,
        messageId: String,
        threadId: String? = nil
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = Endpoint.getWebhookMessage(
            id: address.id,
            token: address.token,
            messageId: messageId
        )
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("thread_id", threadId)]
        ))
    }
    
    /// - Parameters:
    ///   - threadId: Required if the message is in a thread.
    /// https://discord.com/developers/docs/resources/webhook#edit-webhook-message
    func editWebhookMessage(
        address: WebhookAddress,
        messageId: String,
        threadId: String? = nil,
        payload: RequestBody.EditWebhookMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = Endpoint.editWebhookMessage(
            id: address.id,
            token: address.token,
            messageId: messageId
        )
        return try await self.sendMultipart(
            request: .init(
                to: endpoint,
                queries: [("thread_id", threadId)]
            ),
            payload: payload
        )
    }
    
    
    /// - Parameters:
    ///   - threadId: Required if the message is in a thread.
    /// https://discord.com/developers/docs/resources/webhook#delete-webhook-message
    func deleteWebhookMessage(
        address: WebhookAddress,
        messageId: String,
        threadId: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteWebhookMessage(
            id: address.id,
            token: address.token,
            messageId: messageId
        )
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("thread_id", threadId)]
        ))
    }
}
