import DiscordModels
import NIOHTTP1
import NIOCore
import Foundation

public protocol DiscordClient: Sendable {
    var appId: String? { get }
    
    func send(request: DiscordHTTPRequest) async throws -> DiscordHTTPResponse
    
    func send<E: Sendable & Encodable & ValidatablePayload>(
        request: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordHTTPResponse
    
    func sendMultipart<E: Sendable & MultipartEncodable & ValidatablePayload>(
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
    func send<E: Sendable & Encodable & ValidatablePayload, C: Codable>(
        request: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordClientResponse<C> {
        let response = try await self.send(request: request, payload: payload)
        return DiscordClientResponse(httpResponse: response)
    }
    
    @inlinable
    func sendMultipart<E: Sendable & MultipartEncodable & ValidatablePayload, C: Codable>(
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
            throw DiscordHTTPError.appIdParameterRequired
        }
    }
    
    /// For compiler warnings
    @available(*, deprecated, message: "App id must be optional otherwise there is no point")
    @usableFromInline
    func requireAppId(_ : String) throws -> String {
        fatalError()
    }
    
    @usableFromInline
    func checkMutuallyExclusive(queries: [(String, String?)]) throws {
        let notNil = queries.filter { $0.1 != nil }
        guard notNil.count < 2 else {
            throw DiscordHTTPError.queryParametersMutuallyExclusive(
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
            throw DiscordHTTPError.queryParameterOutOfBounds(
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

/// MARK: - `APIEndpoint` functions
public extension DiscordClient {
    
    /// https://discord.com/developers/docs/topics/gateway#get-gateway
    @inlinable
    func getGateway() async throws -> DiscordClientResponse<Gateway.URL> {
        let endpoint = APIEndpoint.getGateway
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/topics/gateway#get-gateway-bot
    @inlinable
    func getBotGateway() async throws -> DiscordClientResponse<Gateway.BotConnectionInfo> {
        let endpoint = APIEndpoint.getBotGateway
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#create-interaction-response
    @inlinable
    func createInteractionResponse(
        id: String,
        token: String,
        payload: Payloads.InteractionResponse
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createInteractionResponse(
            interactionId: id,
            interactionToken: token
        )
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#get-original-interaction-response
    @inlinable
    func getOriginalInteractionResponse(
        appId: String? = nil,
        token: String,
        thread_id: String? = nil
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.getOriginalInteractionResponse(
            applicationId: try requireAppId(appId),
            interactionToken: token
        )
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("thread_id", thread_id)]
        ))
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#edit-original-interaction-response
    @inlinable
    func updateOriginalInteractionResponse(
        appId: String? = nil,
        token: String,
        payload: Payloads.EditWebhookMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.updateOriginalInteractionResponse(
            applicationId: try requireAppId(appId),
            interactionToken: token
        )
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#delete-original-interaction-response
    @inlinable
    func deleteOriginalInteractionResponse(
        appId: String? = nil,
        token: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteOriginalInteractionResponse(
            applicationId: try requireAppId(appId),
            interactionToken: token
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#create-followup-message
    @inlinable
    func createFollowupMessage(
        appId: String? = nil,
        token: String,
        payload: Payloads.InteractionResponse
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createFollowupMessage(
            applicationId: try requireAppId(appId),
            interactionToken: token
        )
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#get-followup-message
    @inlinable
    func getFollowupMessage(
        appId: String? = nil,
        token: String,
        messageId: String,
        thread_id: String? = nil
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.getFollowupMessage(
            applicationId: try requireAppId(appId),
            interactionToken: token,
            messageId: messageId
        )
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("thread_id", thread_id)]
        ))
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#edit-followup-message
    @inlinable
    func updateFollowupMessage(
        appId: String? = nil,
        token: String,
        messageId: String,
        payload: Payloads.InteractionResponse
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateFollowupMessage(
            applicationId: try requireAppId(appId),
            interactionToken: token,
            messageId: messageId
        )
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#delete-followup-message
    @inlinable
    func deleteFollowupMessage(
        appId: String? = nil,
        token: String,
        messageId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteFollowupMessage(
            applicationId: try requireAppId(appId),
            interactionToken: token,
            messageId: messageId
        )
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/channel#create-message
    @inlinable
    func createMessage(
        channelId: String,
        payload: Payloads.CreateMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.createMessage(channelId: channelId)
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/resources/channel#edit-message
    @inlinable
    func updateMessage(
        channelId: String,
        messageId: String,
        payload: Payloads.EditMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.updateMessage(channelId: channelId, messageId: messageId)
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/resources/channel#delete-message
    @inlinable
    func deleteMessage(
        channelId: String,
        messageId: String,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteMessage(channelId: channelId, messageId: messageId)
        return try await self.send(request: .init(
            to: endpoint,
            headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
        ))
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#get-global-application-commands
    @inlinable
    func listApplicationCommands(
        appId: String? = nil,
        with_localizations: Bool? = nil
    ) async throws -> DiscordClientResponse<[ApplicationCommand]> {
        let endpoint = APIEndpoint.listApplicationCommands(applicationId: try requireAppId(appId))
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("with_localizations", with_localizations.map { "\($0)" })]
        ))
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#create-global-application-command
    @inlinable
    func createApplicationCommand(
        appId: String? = nil,
        payload: Payloads.ApplicationCommandCreate
    ) async throws -> DiscordClientResponse<ApplicationCommand> {
        let endpoint = APIEndpoint.createApplicationCommand(applicationId: try requireAppId(appId))
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#get-global-application-command
    @inlinable
    func getApplicationCommand(
        appId: String? = nil,
        commandId: String
    ) async throws -> DiscordClientResponse<ApplicationCommand> {
        let endpoint = APIEndpoint.getApplicationCommand(
            applicationId: try requireAppId(appId),
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#edit-global-application-command
    @inlinable
    func updateApplicationCommand(
        appId: String? = nil,
        commandId: String,
        payload: Payloads.ApplicationCommandEdit
    ) async throws -> DiscordClientResponse<ApplicationCommand> {
        let endpoint = APIEndpoint.updateApplicationCommand(
            applicationId: try requireAppId(appId),
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#delete-global-application-command
    @inlinable
    func deleteApplicationCommand(
        appId: String? = nil,
        commandId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteApplicationCommand(
            applicationId: try requireAppId(appId),
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#bulk-overwrite-global-application-commands
    @inlinable
    func bulkSetApplicationCommands(
        appId: String? = nil,
        payload: [Payloads.ApplicationCommandCreate]
    ) async throws -> DiscordClientResponse<[ApplicationCommand]> {
        let endpoint = APIEndpoint.bulkSetApplicationCommands(
            applicationId: try requireAppId(appId)
        )
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#get-guild-application-commands
    @inlinable
    func listGuildApplicationCommands(
        appId: String? = nil,
        guildId: String,
        with_localizations: Bool? = nil
    ) async throws -> DiscordClientResponse<[ApplicationCommand]> {
        let endpoint = APIEndpoint.listGuildApplicationCommands(
            applicationId: try requireAppId(appId),
            guildId: guildId
        )
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("with_localizations", with_localizations.map { "\($0)" })]
        ))
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#create-guild-application-command
    @inlinable
    func createGuildApplicationCommand(
        appId: String? = nil,
        guildId: String,
        payload: Payloads.ApplicationCommandCreate
    ) async throws -> DiscordClientResponse<ApplicationCommand> {
        let endpoint = APIEndpoint.createGuildApplicationCommand(
            applicationId: try requireAppId(appId),
            guildId: guildId
        )
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#get-guild-application-command
    @inlinable
    func getGuildApplicationCommand(
        appId: String? = nil,
        guildId: String,
        commandId: String
    ) async throws -> DiscordClientResponse<ApplicationCommand> {
        let endpoint = APIEndpoint.getGuildApplicationCommand(
            applicationId: try requireAppId(appId),
            guildId: guildId,
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#edit-guild-application-command
    @inlinable
    func updateGuildApplicationCommand(
        appId: String? = nil,
        guildId: String,
        commandId: String,
        payload: Payloads.ApplicationCommandEdit
    ) async throws -> DiscordClientResponse<ApplicationCommand> {
        let endpoint = APIEndpoint.updateGuildApplicationCommand(
            applicationId: try requireAppId(appId),
            guildId: guildId,
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#delete-guild-application-command
    @inlinable
    func deleteGuildApplicationCommand(
        appId: String? = nil,
        guildId: String,
        commandId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildApplicationCommand(
            applicationId: try requireAppId(appId),
            guildId: guildId,
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#bulk-overwrite-guild-application-commands
    @inlinable
    func bulkSetGuildApplicationCommands(
        appId: String? = nil,
        guildId: String,
        payload: [Payloads.ApplicationCommandCreate]
    ) async throws -> DiscordClientResponse<[ApplicationCommand]> {
        let endpoint = APIEndpoint.bulkSetGuildApplicationCommands(
            applicationId: try requireAppId(appId),
            guildId: guildId
        )
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#get-application-command-permissions
    @inlinable
    func listGuildApplicationCommandPermissions(
        appId: String? = nil,
        guildId: String
    ) async throws -> DiscordClientResponse<[GuildApplicationCommandPermissions]> {
        let endpoint = APIEndpoint.listGuildApplicationCommandPermissions(
            applicationId: try requireAppId(appId),
            guildId: guildId
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#edit-application-command-permissions
    @inlinable
    func getGuildApplicationCommandPermissions(
        appId: String? = nil,
        guildId: String,
        commandId: String
    ) async throws -> DiscordClientResponse<GuildApplicationCommandPermissions> {
        let endpoint = APIEndpoint.getGuildApplicationCommandPermissions(
            applicationId: try requireAppId(appId),
            guildId: guildId,
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    @available(*, unavailable, message: "Currently this endpoint can't be used with a bot token")
    /// https://discord.com/developers/docs/interactions/application-commands#batch-edit-application-command-permissions
    @inlinable
    func setGuildApplicationCommandPermissions(
        appId: String? = nil,
        guildId: String,
        commandId: String,
        payload: Payloads.EditApplicationCommandPermissions
    ) async throws -> DiscordClientResponse<GuildApplicationCommandPermissions> {
        let endpoint = APIEndpoint.setGuildApplicationCommandPermissions(
            applicationId: try requireAppId(appId),
            guildId: guildId,
            commandId: commandId
        )
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/resources/guild#get-guild
    @inlinable
    func getGuild(
        id: String,
        withCounts: Bool? = nil
    ) async throws -> DiscordClientResponse<Guild> {
        let endpoint = APIEndpoint.getGuild(guildId: id)
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("with_counts", withCounts?.description)]
        ))
    }

    /// https://discord.com/developers/docs/resources/guild#create-guild
    @inlinable
    func createGuild(
        payload: Payloads.CreateGuild
    ) async throws -> DiscordClientResponse<Guild> {
        let endpoint = APIEndpoint.createGuild
        return try await self.send(
            request: .init(to: endpoint),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#modify-guild
    @inlinable
    func updateGuild(
        id: String,
        reason: String? = nil,
        payload: Payloads.ModifyGuild
    ) async throws -> DiscordClientResponse<Guild> {
        let endpoint = APIEndpoint.updateGuild(guildId: id)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/guild#delete-guild
    @inlinable
    func deleteGuild(id: String) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuild(guildId: id)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-roles
    @inlinable
    func listGuildRoles(id: String) async throws -> DiscordClientResponse<[Role]> {
        let endpoint = APIEndpoint.listGuildRoles(guildId: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-channel
    @inlinable
    func getChannel(id: String) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.getChannel(channelId: id)
        return try await self.send(request: .init(to: endpoint))
    }

    /// This endpoint doesn't have a test since we can't create group DMs easily,
    /// but still should work fine if you actually needed it, because there are two similar
    /// functions down below for updating other types of channels, and those do have tests.
    /// https://discord.com/developers/docs/resources/channel#modify-channel
    @inlinable
    func updateGroupDMChannel(
        id: String,
        reason: String? = nil,
        payload: Payloads.ModifyGroupDMChannel
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.updateChannel(channelId: id)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/channel#modify-channel
    @inlinable
    func updateGuildChannel(
        id: String,
        reason: String? = nil,
        payload: Payloads.ModifyGuildChannel
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.updateChannel(channelId: id)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/channel#modify-channel
    @inlinable
    func updateThreadChannel(
        id: String,
        reason: String? = nil,
        payload: Payloads.ModifyThreadChannel
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.updateChannel(channelId: id)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }

    /// https://discord.com/developers/docs/resources/channel#deleteclose-channel
    @inlinable
    func deleteChannel(
        id: String,
        reason: String? = nil
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.deleteChannel(channelId: id)
        return try await self.send(request: .init(
            to: endpoint,
            headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
        ))
    }

    /// https://discord.com/developers/docs/resources/guild#create-guild-channel
    @inlinable
    func createGuildChannel(
        guildId: String,
        reason: String? = nil,
        payload: Payloads.CreateGuildChannel
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.createGuildChannel(guildId: guildId)
        return try await self.send(
            request: .init(
                to: endpoint,
                headers: reason.map { ["X-Audit-Log-Reason": $0] } ?? [:]
            ),
            payload: payload
        )
    }
    
    /// https://discord.com/developers/docs/resources/user#leave-guild
    @inlinable
    func leaveGuild(id: String) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.leaveGuild(guildId: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/guild#create-guild-role
    @inlinable
    func createGuildRole(
        guildId: String,
        reason: String? = nil,
        payload: Payloads.CreateGuildRole
    ) async throws -> DiscordClientResponse<Role> {
        let endpoint = APIEndpoint.createGuildRole(guildId: guildId)
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
        let endpoint = APIEndpoint.deleteGuildRole(guildId: guildId, roleId: roleId)
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
        let endpoint = APIEndpoint.addGuildMemberRole(
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
    func deleteGuildMemberRole(
        guildId: String,
        userId: String,
        roleId: String,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildMemberRole(
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
    func addOwnMessageReaction(
        channelId: String,
        messageId: String,
        emoji: Reaction
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.addOwnMessageReaction(
            channelId: channelId,
            messageId: messageId,
            emojiName: emoji.urlPathDescription
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#delete-own-reaction
    @inlinable
    func deleteOwnMessageReaction(
        channelId: String,
        messageId: String,
        emoji: Reaction
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteOwnMessageReaction(
            channelId: channelId,
            messageId: messageId,
            emojiName: emoji.urlPathDescription
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#delete-user-reaction
    @inlinable
    func deleteUserMessageReaction(
        channelId: String,
        messageId: String,
        emoji: Reaction,
        userId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteUserMessageReaction(
            channelId: channelId,
            messageId: messageId,
            emojiName: emoji.urlPathDescription,
            userId: userId
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-reactions
    @inlinable
    func listMessageReactionsByEmoji(
        channelId: String,
        messageId: String,
        emoji: Reaction,
        after: String? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<[DiscordUser]> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 1_000)
        let endpoint = APIEndpoint.listMessageReactionsByEmoji(
            channelId: channelId,
            messageId: messageId,
            emojiName: emoji.urlPathDescription
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#delete-all-reactions
    @inlinable
    func deleteAllMessageReactions(
        channelId: String,
        messageId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteAllMessageReactions(
            channelId: channelId,
            messageId: messageId
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#delete-all-reactions-for-emoji
    @inlinable
    func deleteAllMessageReactionsByEmoji(
        channelId: String,
        messageId: String,
        emoji: Reaction
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteAllMessageReactionsByEmoji(
            channelId: channelId,
            messageId: messageId,
            emojiName: emoji.urlPathDescription
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
        let endpoint = APIEndpoint.searchGuildMembers(guildId: guildId)
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
        let endpoint = APIEndpoint.getGuildMember(guildId: guildId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// NOTE: `around`, `before` and `after` are mutually exclusive.
    /// https://discord.com/developers/docs/resources/channel#get-channel-messages
    @inlinable
    func listMessages(
        channelId: String,
        around: String? = nil,
        before: String? = nil,
        after: String? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<[DiscordChannel.Message]> {
        try checkMutuallyExclusive(queries: [
            ("around", around),
            ("before", before),
            ("after", after)
        ])
        let endpoint = APIEndpoint.listMessages(channelId: channelId)
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
    func getMessage(
        channelId: String,
        messageId: String
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.getMessage(channelId: channelId, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// NOTE: `limit`, if provided, must be between `1` and `1_000`.
    /// https://discord.com/developers/docs/resources/audit-log#get-guild-audit-log
    @inlinable
    func listGuildAuditLogEntries(
        guildId: String,
        user_id: String? = nil,
        action_type: AuditLog.Entry.ActionKind? = nil,
        before: String? = nil,
        after: String? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<AuditLog> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 1_000)
        let endpoint = APIEndpoint.listGuildAuditLogEntries(guildId: guildId)
        return try await self.send(request: .init(
            to: endpoint,
            queries: [
                ("user_id", user_id),
                ("action_type", action_type.map { "\($0.rawValue)" }),
                ("before", before),
                ("after", after),
                ("limit", limit.map { "\($0)" })
            ]
        ))
    }
    
    /// You can use this function to create a new **or** retrieve an existing DM channel.
    /// https://discord.com/developers/docs/resources/user#create-dm
    @inlinable
    func createDm(recipientId: String) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.createDm
        return try await self.send(
            request: .init(to: endpoint),
            payload: Payloads.CreateDM(recipient_id: recipientId)
        )
    }

    /// https://discord.com/developers/docs/resources/channel#trigger-typing-indicator
    @inlinable
    func triggerTypingIndicator(channelId: String) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.triggerTypingIndicator(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#start-thread-from-message
    @inlinable
    func createThreadFromMessage(
        channelId: String,
        messageId: String,
        reason: String? = nil,
        payload: Payloads.CreateThreadFromMessage
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.createThreadFromMessage(channelId: channelId, messageId: messageId)
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
    func createThread(
        channelId: String,
        reason: String? = nil,
        payload: Payloads.CreateThreadWithoutMessage
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.createThread(channelId: channelId)
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
        payload: Payloads.CreateThreadInForumChannel
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.createThreadInForumChannel(channelId: channelId)
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
        let endpoint = APIEndpoint.joinThread(channelId: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#add-thread-member
    @inlinable
    func addThreadMember(
        threadId: String,
        userId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.addThreadMember(channelId: threadId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#leave-thread
    @inlinable
    func leaveThread(id: String) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.leaveThread(channelId: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#remove-thread-member
    @inlinable
    func deleteThreadMember(
        threadId: String,
        userId: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteThreadMember(channelId: threadId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-thread-member
    @inlinable
    func getThreadMember(
        threadId: String,
        userId: String
    ) async throws -> DiscordClientResponse<ThreadMember> {
        let endpoint = APIEndpoint.getThreadMember(channelId: threadId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-thread-member
    @inlinable
    func getThreadMemberWithMember(
        threadId: String,
        userId: String
    ) async throws -> DiscordClientResponse<ThreadMemberWithMember> {
        let endpoint = APIEndpoint.getThreadMember(channelId: threadId, userId: userId)
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
        let endpoint = APIEndpoint.listThreadMembers(channelId: threadId)
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
        let endpoint = APIEndpoint.listThreadMembers(channelId: threadId)
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
        let endpoint = APIEndpoint.listPublicArchivedThreads(channelId: channelId)
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
        let endpoint = APIEndpoint.listPrivateArchivedThreads(channelId: channelId)
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
    func listOwnPrivateArchivedThreads(
        channelId: String,
        before: String? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<RequestResponse.ArchivedThread> {
        /// Not documented, but correct, at least at the time of writing the code.
        try checkInBounds(name: "limit", value: limit, lowerBound: 2, upperBound: 100)
        let endpoint = APIEndpoint.listOwnPrivateArchivedThreads(channelId: channelId)
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
        payload: Payloads.CreateWebhook
    ) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = APIEndpoint.createWebhook(channelId: channelId)
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
    func listChannelWebhooks(channelId: String) async throws -> DiscordClientResponse<[Webhook]> {
        let endpoint = APIEndpoint.listChannelWebhooks(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/webhook#get-guild-webhooks
    @inlinable
    func getGuildWebhooks(guildId: String) async throws -> DiscordClientResponse<[Webhook]> {
        let endpoint = APIEndpoint.getGuildWebhooks(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// Requires authentication using an authorized bot-token.
    /// https://discord.com/developers/docs/resources/webhook#get-webhook
    @inlinable
    func getWebhook(id: String) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = APIEndpoint.getWebhook(webhookId: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// Doesn't require authentication using bot-token.
    /// https://discord.com/developers/docs/resources/webhook#get-webhook-with-token
    @inlinable
    func getWebhook(address: WebhookAddress) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = APIEndpoint.getWebhookByToken(
            webhookId: address.id,
            webhookToken: address.token
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// Requires authentication using an authorized bot-token.
    /// https://discord.com/developers/docs/resources/webhook#modify-webhook
    @inlinable
    func updateWebhook(
        id: String,
        reason: String? = nil,
        payload: Payloads.ModifyGuildWebhook
    ) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = APIEndpoint.updateWebhook(webhookId: id)
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
    func updateWebhook(
        address: WebhookAddress,
        reason: String? = nil,
        payload: Payloads.ModifyWebhook
    ) async throws -> DiscordClientResponse<Webhook> {
        let endpoint = APIEndpoint.updateWebhookByToken(
            webhookId: address.id,
            webhookToken: address.token
        )
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
        let endpoint = APIEndpoint.deleteWebhook(webhookId: id)
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
        let endpoint = APIEndpoint.deleteWebhookByToken(
            webhookId: address.id,
            webhookToken: address.token
        )
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
        payload: Payloads.ExecuteWebhook
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.executeWebhook(
            webhookId: address.id,
            webhookToken: address.token
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
    /// https://discord.com/developers/docs/resources/webhook#execute-webhook
    @inlinable
    func executeWebhookWithResponse(
        address: WebhookAddress,
        threadId: String? = nil,
        payload: Payloads.ExecuteWebhook
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.executeWebhook(
            webhookId: address.id,
            webhookToken: address.token
        )
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
        let endpoint = APIEndpoint.getWebhookMessage(
            webhookId: address.id,
            webhookToken: address.token,
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
    func updateWebhookMessage(
        address: WebhookAddress,
        messageId: String,
        threadId: String? = nil,
        payload: Payloads.EditWebhookMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.updateWebhookMessage(
            webhookId: address.id,
            webhookToken: address.token,
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
        let endpoint = APIEndpoint.deleteWebhookMessage(
            webhookId: address.id,
            webhookToken: address.token,
            messageId: messageId
        )
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("thread_id", threadId)]
        ))
    }
}

/// MARK: - `CDNEndpoint` functions
public extension DiscordClient {
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNCustomEmoji(emojiId: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.customEmoji(emojiId: emojiId)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: emojiId)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildIcon(guildId: String, icon: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildIcon(guildId: guildId, icon: icon)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildSplash(guildId: String, splash: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildSplash(guildId: guildId, splash: splash)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: splash)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildDiscoverySplash(
        guildId: String,
        splash: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildDiscoverySplash(guildId: guildId, splash: splash)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: splash)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildBanner(guildId: String, banner: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildBanner(guildId: guildId, banner: banner)
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
        let endpoint = CDNEndpoint.userBanner(userId: userId, banner: banner)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: banner)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNDefaultUserAvatar(discriminator: Int) async throws -> DiscordCDNResponse {
        /// `discriminator % 5` is what Discord says.
        let modulo = "\(discriminator % 5)"
        let endpoint = CDNEndpoint.defaultUserAvatar(discriminator: modulo)
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: "\(discriminator)"
        )
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNUserAvatar(userId: String, avatar: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.userAvatar(userId: userId, avatar: avatar)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: avatar)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildMemberAvatar(
        guildId: String,
        userId: String,
        avatar: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildMemberAvatar(
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
        let endpoint = CDNEndpoint.applicationIcon(appId: appId, icon: icon)
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
        let endpoint = CDNEndpoint.applicationCover(appId: appId, cover: cover)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: cover)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNApplicationAsset(appId: String, assetId: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.applicationAsset(appId: appId, assetId: assetId)
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
        let endpoint = CDNEndpoint.achievementIcon(
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
    func getCDNStorePageAsset(appId: String, assetId: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.storePageAsset(appId: appId, assetId: assetId)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: assetId)
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
        let endpoint = CDNEndpoint.stickerPackBanner(assetId: assetId)
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
        let endpoint = CDNEndpoint.teamIcon(teamId: teamId, icon: icon)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNSticker(stickerId: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.sticker(stickerId: stickerId)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: stickerId)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNRoleIcon(roleId: String, icon: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.roleIcon(roleId: roleId, icon: icon)
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
        let endpoint = CDNEndpoint.guildScheduledEventCover(eventId: eventId, cover: cover)
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
        let endpoint = CDNEndpoint.guildMemberBanner(
            guildId: guildId,
            userId: userId,
            banner: banner
        )
        return try await self.send(request: .init(to: endpoint), fallbackFileName: banner)
    }
}
