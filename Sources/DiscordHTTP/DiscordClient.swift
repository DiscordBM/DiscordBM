import DiscordModels
import NIOHTTP1
import NIOCore
import Foundation

public protocol DiscordClient: Sendable {
    var appId: String? { get }
    
    func send(request: DiscordHTTPRequest) async throws -> DiscordHTTPResponse
    
    func send<E: Encodable & ValidatablePayload>(
        request: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordHTTPResponse
    
    func sendMultipart<E: MultipartEncodable & ValidatablePayload>(
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
    func send(
        request: DiscordHTTPRequest,
        fallbackFileName: String
    ) async throws -> DiscordCDNResponse {
        let response = try await self.send(request: request)
        return DiscordCDNResponse(httpResponse: response, fallbackFileName: fallbackFileName)
    }
    
    @inlinable
    func send<E: Encodable & ValidatablePayload, C: Codable>(
        request: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordClientResponse<C> {
        let response = try await self.send(request: request, payload: payload)
        return DiscordClientResponse(httpResponse: response)
    }
    
    @inlinable
    func sendMultipart<E: MultipartEncodable & ValidatablePayload, C: Codable>(
        request: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordClientResponse<C> {
        let response = try await self.sendMultipart(request: request, payload: payload)
        return DiscordClientResponse(httpResponse: response)
    }
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
            throw HTTPError.appIdParameterRequired
        }
    }
    
    @usableFromInline
    func checkMutuallyExclusive(queries: [(String, String?)]) throws {
        let notNil = queries.filter { $0.1 != nil }
        guard notNil.count < 2 else {
            throw HTTPError.queryParametersMutuallyExclusive(
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
            throw HTTPError.queryParameterOutOfBounds(
                name: name,
                value: value?.description,
                lowerBound: 1,
                upperBound: 1_000
            )
        }
    }
}

//MARK: - Public +DiscordClient

private let iso8601DateFormatter = ISO8601DateFormatter()

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
    
    /// The `channelId` could be a thread-id as well.
    /// https://discord.com/developers/docs/resources/channel#create-message
    @inlinable
    func createMessage(
        channelId: String,
        payload: RequestBody.CreateMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = Endpoint.createMessage(channelId: channelId)
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }
    
    /// The `channelId` could be a thread-id as well.
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
    
    /// The `channelId` could be a thread-id as well.
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
        payload: RequestBody.ApplicationCommandCreate
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
        return try await self.send(request: .init(
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
    func createReaction(
        channelId: String,
        messageId: String,
        emoji: Reaction
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.createReaction(
            channelId: channelId,
            messageId: messageId,
            emoji: emoji.urlPathDescription
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#delete-own-reaction
    @inlinable
    func deleteOwnReaction(
        channelId: String,
        messageId: String,
        emoji: Reaction
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteOwnReaction(
            channelId: channelId,
            messageId: messageId,
            emoji: emoji.urlPathDescription
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#delete-user-reaction
    @inlinable
    func deleteUserReaction(
        channelId: String,
        messageId: String,
        emoji: Reaction,
        userId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteUserReaction(
            channelId: channelId,
            messageId: messageId,
            emoji: emoji.urlPathDescription,
            userId: userId
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-reactions
    @inlinable
    func getReactions(
        channelId: String,
        messageId: String,
        emoji: Reaction,
        after: String? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<[DiscordUser]> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 1_000)
        let endpoint = Endpoint.getReactions(
            channelId: channelId,
            messageId: messageId,
            emoji: emoji.urlPathDescription
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#delete-all-reactions
    @inlinable
    func deleteAllReactions(
        channelId: String,
        messageId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteAllReactions(
            channelId: channelId,
            messageId: messageId
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#delete-all-reactions-for-emoji
    @inlinable
    func deleteAllReactionsForEmoji(
        channelId: String,
        messageId: String,
        emoji: Reaction
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteAllReactionsForEmoji(
            channelId: channelId,
            messageId: messageId,
            emoji: emoji.urlPathDescription
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
    
    /// https://discord.com/developers/docs/resources/channel#start-thread-from-message
    @inlinable
    func startThreadFromMessage(
        channelId: String,
        messageId: String,
        reason: String? = nil,
        payload: RequestBody.CreateThreadFromMessage
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = Endpoint.startThreadFromMessage(channelId: channelId, messageId: messageId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }
    
    /// https://discord.com/developers/docs/resources/channel#start-thread-without-message
    @inlinable
    func startThreadWithoutMessage(
        channelId: String,
        reason: String? = nil,
        payload: RequestBody.CreateThreadWithoutMessage
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = Endpoint.startThreadWithoutMessage(channelId: channelId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }
    
    /// https://discord.com/developers/docs/resources/channel#start-thread-in-forum-channel
    @inlinable
    func startThreadInForumChannel(
        channelId: String,
        reason: String? = nil,
        payload: RequestBody.CreateThreadInForumChannel
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = Endpoint.startThreadInForumChannel(channelId: channelId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }
    
    /// https://discord.com/developers/docs/resources/channel#join-thread
    @inlinable
    func joinThread(id: String) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.joinThread(id: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#add-thread-member
    @inlinable
    func addThreadMember(
        threadId: String,
        userId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.addThreadMember(threadId: threadId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#leave-thread
    @inlinable
    func leaveThread(id: String) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.leaveThread(id: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#remove-thread-member
    @inlinable
    func removeThreadMember(
        threadId: String,
        userId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.removeThreadMember(threadId: threadId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-thread-member
    @inlinable
    func getThreadMember(
        threadId: String,
        userId: String
    ) async throws -> DiscordClientResponse<ThreadMember> {
        let endpoint = Endpoint.getThreadMember(threadId: threadId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-thread-member
    @inlinable
    func getThreadMemberWithMember(
        threadId: String,
        userId: String
    ) async throws -> DiscordClientResponse<ThreadMemberWithMember> {
        let endpoint = Endpoint.getThreadMember(threadId: threadId, userId: userId)
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("with_member", "true")]
        ))
    }
    
    /// https://discord.com/developers/docs/resources/channel#list-thread-members
    @inlinable
    func listThreadMembers(
        threadId: String
    ) async throws -> DiscordClientResponse<[ThreadMember]> {
        let endpoint = Endpoint.listThreadMembers(threadId: threadId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#list-thread-members
    @inlinable
    func listThreadMembersWithMember(
        threadId: String,
        after: String? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<[ThreadMemberWithMember]> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 100)
        let endpoint = Endpoint.listThreadMembers(threadId: threadId)
        return try await self.send(request: .init(
            to: endpoint,
            queries: [
                ("with_member", "true"),
                ("after", after.map({ "\($0)" })),
                ("limit", limit.map({ "\($0)" })),
            ]
        ))
    }
    
    /// https://discord.com/developers/docs/resources/channel#list-public-archived-threads
    func listPublicArchivedThreads(
        channelId: String,
        before: Date? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<RequestResponse.ArchivedThread> {
        /// Not documented, but correct, at least at the time of writing the code.
        try checkInBounds(name: "limit", value: limit, lowerBound: 2, upperBound: 100)
        let endpoint = Endpoint.listPublicArchivedThreads(channelId: channelId)
        return try await self.send(request: .init(
            to: endpoint,
            queries: [
                ("before", before.map(iso8601DateFormatter.string(from:))),
                ("limit", limit.map({ "\($0)" }))
            ]
        ))
    }
    
    /// https://discord.com/developers/docs/resources/channel#list-private-archived-threads
    func listPrivateArchivedThreads(
        channelId: String,
        before: Date? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<RequestResponse.ArchivedThread> {
        /// Not documented, but correct, at least at the time of writing the code.
        try checkInBounds(name: "limit", value: limit, lowerBound: 2, upperBound: 100)
        let endpoint = Endpoint.listPrivateArchivedThreads(channelId: channelId)
        return try await self.send(request: .init(
            to: endpoint,
            queries: [
                ("before", before.map(iso8601DateFormatter.string(from:))),
                ("limit", limit.map({ "\($0)" }))
            ]
        ))
    }
    
    /// https://discord.com/developers/docs/resources/channel#list-joined-private-archived-threads
    @inlinable
    func listJoinedPrivateArchivedThreads(
        channelId: String,
        before: String? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<RequestResponse.ArchivedThread> {
        /// Not documented, but correct, at least at the time of writing the code.
        try checkInBounds(name: "limit", value: limit, lowerBound: 2, upperBound: 100)
        let endpoint = Endpoint.listJoinedPrivateArchivedThreads(channelId: channelId)
        return try await self.send(request: .init(
            to: endpoint,
            queries: [
                ("before", before),
                ("limit", limit.map({ "\($0)" }))
            ]
        ))
    }
    
    /// https://discord.com/developers/docs/resources/webhook#create-webhook
    @inlinable
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
    @inlinable
    func getChannelWebhooks(channelId: String) async throws -> DiscordClientResponse<[Webhook]> {
        let endpoint = Endpoint.getChannelWebhooks(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/webhook#get-guild-webhooks
    @inlinable
    func getGuildWebhooks(guildId: String) async throws -> DiscordClientResponse<[Webhook]> {
        let endpoint = Endpoint.getGuildWebhooks(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// Requires authentication using an authorized bot-token.
    /// https://discord.com/developers/docs/resources/webhook#get-webhook
    @inlinable
    func getWebhook(id: String) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = Endpoint.getWebhook1(id: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// Doesn't require authentication using bot-token.
    /// https://discord.com/developers/docs/resources/webhook#get-webhook-with-token
    @inlinable
    func getWebhook(address: WebhookAddress) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = Endpoint.getWebhook2(id: address.id, token: address.token)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// Requires authentication using an authorized bot-token.
    /// https://discord.com/developers/docs/resources/webhook#modify-webhook
    @inlinable
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
    @inlinable
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
    @inlinable
    func deleteWebhook(id: String, reason: String? = nil) async throws -> DiscordHTTPResponse {
        let endpoint = Endpoint.deleteWebhook1(id: id)
        return try await self.send(request: .init(
            to: endpoint,
            headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
        ))
    }
    
    /// Doesn't require authentication using bot-token.
    /// https://discord.com/developers/docs/resources/webhook#delete-webhook-with-token
    @inlinable
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
    @inlinable
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
    @inlinable
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
    @inlinable
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
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNCustomEmoji(emojiId: String) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNCustomEmoji(emojiId: emojiId)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: emojiId)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildIcon(guildId: String, icon: String) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNGuildIcon(guildId: guildId, icon: icon)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildSplash(guildId: String, splash: String) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNGuildSplash(guildId: guildId, splash: splash)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: splash)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildDiscoverySplash(
        guildId: String,
        splash: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNGuildDiscoverySplash(guildId: guildId, splash: splash)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: splash)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildBanner(guildId: String, banner: String) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNGuildBanner(guildId: guildId, banner: banner)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: banner)
    }
    
    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `banner`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNUserBanner(userId: String, banner: String) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNUserBanner(userId: userId, banner: banner)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: banner)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNDefaultUserAvatar(discriminator: Int) async throws -> DiscordCDNResponse {
        /// `discriminator % 5` is what Discord says.
        let modulo = "\(discriminator % 5)"
        let endpoint = Endpoint.CDNDefaultUserAvatar(discriminator: modulo)
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: "\(discriminator)"
        )
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNUserAvatar(userId: String, avatar: String) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNUserAvatar(userId: userId, avatar: avatar)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: avatar)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildMemberAvatar(
        guildId: String,
        userId: String,
        avatar: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNGuildMemberAvatar(
            guildId: guildId,
            userId: userId,
            avatar: avatar
        )
        return try await self.send(request: .init(to: endpoint), fallbackFileName: avatar)
    }
    
    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `icon`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNApplicationIcon(appId: String, icon: String) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNApplicationIcon(appId: appId, icon: icon)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }
    
    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `cover`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNApplicationCover(appId: String, cover: String) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNApplicationCover(appId: appId, cover: cover)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: cover)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNApplicationAsset(appId: String, assetId: String) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNApplicationAsset(appId: appId, assetId: assetId)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: assetId)
    }
    
    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `icon`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNAchievementIcon(
        appId: String,
        achievementId: String,
        icon: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNAchievementIcon(
            appId: appId,
            achievementId: achievementId,
            icon: icon
        )
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }
    
    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `assetId`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNStickerPackBanner(assetId: String) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNStickerPackBanner(assetId: assetId)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: assetId)
    }
    
    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `icon`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNTeamIcon(teamId: String, icon: String) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNTeamIcon(teamId: teamId, icon: icon)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNSticker(stickerId: String) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNSticker(stickerId: stickerId)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: stickerId)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNRoleIcon(roleId: String, icon: String) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNRoleIcon(roleId: roleId, icon: icon)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }
    
    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `cover`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildScheduledEventCover(
        eventId: String,
        cover: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNGuildScheduledEventCover(eventId: eventId, cover: cover)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: cover)
    }
    
    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `banner`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildMemberBanner(
        guildId: String,
        userId: String,
        banner: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = Endpoint.CDNGuildMemberBanner(
            guildId: guildId,
            userId: userId,
            banner: banner
        )
        return try await self.send(request: .init(to: endpoint), fallbackFileName: banner)
    }
}
