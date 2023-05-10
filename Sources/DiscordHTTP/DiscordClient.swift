import DiscordModels
import NIOHTTP1
import NIOCore
import Foundation

public protocol DiscordClient: Sendable {
    var appId: ApplicationSnowflake? { get }
    
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
    func requireAppId(
        _ providedAppId: ApplicationSnowflake?
    ) throws -> ApplicationSnowflake {
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
    func requireAppId(_ appId: String) throws -> String {
        return appId
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
        id: InteractionSnowflake,
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
        appId: ApplicationSnowflake? = nil,
        token: String,
        threadId: ChannelSnowflake? = nil
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.getOriginalInteractionResponse(
            applicationId: try requireAppId(appId),
            interactionToken: token
        )
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("thread_id", threadId?.value)]
        ))
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#edit-original-interaction-response
    @inlinable
    func updateOriginalInteractionResponse(
        appId: ApplicationSnowflake? = nil,
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
        appId: ApplicationSnowflake? = nil,
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
        appId: ApplicationSnowflake? = nil,
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
        appId: ApplicationSnowflake? = nil,
        token: String,
        messageId: MessageSnowflake,
        threadId: ChannelSnowflake? = nil
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.getFollowupMessage(
            applicationId: try requireAppId(appId),
            interactionToken: token,
            messageId: messageId
        )
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("thread_id", threadId?.value)]
        ))
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#edit-followup-message
    @inlinable
    func updateFollowupMessage(
        appId: ApplicationSnowflake? = nil,
        token: String,
        messageId: MessageSnowflake,
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
        appId: ApplicationSnowflake? = nil,
        token: String,
        messageId: MessageSnowflake
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
        channelId: ChannelSnowflake,
        payload: Payloads.CreateMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.createMessage(channelId: channelId)
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/resources/channel#edit-message
    @inlinable
    func updateMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        payload: Payloads.EditMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.updateMessage(channelId: channelId, messageId: messageId)
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/resources/channel#delete-message
    @inlinable
    func deleteMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
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
        appId: ApplicationSnowflake? = nil,
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
        appId: ApplicationSnowflake? = nil,
        payload: Payloads.ApplicationCommandCreate
    ) async throws -> DiscordClientResponse<ApplicationCommand> {
        let endpoint = APIEndpoint.createApplicationCommand(applicationId: try requireAppId(appId))
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#get-global-application-command
    @inlinable
    func getApplicationCommand(
        appId: ApplicationSnowflake? = nil,
        commandId: CommandSnowflake
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
        appId: ApplicationSnowflake? = nil,
        commandId: CommandSnowflake,
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
        appId: ApplicationSnowflake? = nil,
        commandId: CommandSnowflake
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
        appId: ApplicationSnowflake? = nil,
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
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
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
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
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
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
        commandId: CommandSnowflake
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
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
        commandId: CommandSnowflake,
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
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
        commandId: CommandSnowflake
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
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
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
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake
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
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
        commandId: CommandSnowflake
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
        appId: ApplicationSnowflake? = nil,
        guildId: GuildSnowflake,
        commandId: CommandSnowflake,
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
        id: GuildSnowflake,
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
        id: GuildSnowflake,
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
    func deleteGuild(id: GuildSnowflake) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuild(guildId: id)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-roles
    @inlinable
    func listGuildRoles(id: GuildSnowflake) async throws -> DiscordClientResponse<[Role]> {
        let endpoint = APIEndpoint.listGuildRoles(guildId: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-channel
    @inlinable
    func getChannel(
        id: ChannelSnowflake
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.getChannel(channelId: id)
        return try await self.send(request: .init(to: endpoint))
    }

    /// This endpoint doesn't have a test since we can't create group DMs easily,
    /// but still should work fine if you actually needed it, because there are two similar
    /// functions down below for updating other types of channels, and those do have tests.
    /// https://discord.com/developers/docs/resources/channel#modify-channel
    @inlinable
    func updateGroupDMChannel(
        id: ChannelSnowflake,
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
        id: ChannelSnowflake,
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
        id: ChannelSnowflake,
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
        id: ChannelSnowflake,
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
        guildId: GuildSnowflake,
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
    func leaveGuild(id: GuildSnowflake) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.leaveGuild(guildId: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/guild#create-guild-role
    @inlinable
    func createGuildRole(
        guildId: GuildSnowflake,
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
        guildId: GuildSnowflake,
        roleId: RoleSnowflake,
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
        guildId: GuildSnowflake,
        userId: UserSnowflake,
        roleId: RoleSnowflake,
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
        guildId: GuildSnowflake,
        userId: UserSnowflake,
        roleId: RoleSnowflake,
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
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
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
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
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
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        emoji: Reaction,
        userId: UserSnowflake
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
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        emoji: Reaction,
        after: UserSnowflake? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<[DiscordUser]> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 100)
        let endpoint = APIEndpoint.listMessageReactionsByEmoji(
            channelId: channelId,
            messageId: messageId,
            emojiName: emoji.urlPathDescription
        )
        return try await self.send(request: .init(
            to: endpoint,
            queries: [
                ("after", after?.value),
                ("limit", limit.map({ "\($0)" }))
            ]
        ))
    }
    
    /// https://discord.com/developers/docs/resources/channel#delete-all-reactions
    @inlinable
    func deleteAllMessageReactions(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake
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
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
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
        guildId: GuildSnowflake,
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
        guildId: GuildSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordClientResponse<Guild.Member> {
        let endpoint = APIEndpoint.getGuildMember(guildId: guildId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// NOTE: `around`, `before` and `after` are mutually exclusive.
    /// https://discord.com/developers/docs/resources/channel#get-channel-messages
    @inlinable
    func listMessages(
        channelId: ChannelSnowflake,
        around: MessageSnowflake? = nil,
        before: MessageSnowflake? = nil,
        after: MessageSnowflake? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<[DiscordChannel.Message]> {
        try checkMutuallyExclusive(queries: [
            ("around", around?.value),
            ("before", before?.value),
            ("after", after?.value)
        ])
        let endpoint = APIEndpoint.listMessages(channelId: channelId)
        return try await self.send(request: .init(
            to: endpoint,
            queries: [
                ("around", around?.value),
                ("before", before?.value),
                ("after", after?.value),
                ("limit", limit.map({ "\($0)" }))
            ]
        ))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-channel-message
    @inlinable
    func getMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.getMessage(
            channelId: channelId,
            messageId: messageId
        )
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// NOTE: `limit`, if provided, must be between `1` and `1_000`.
    /// https://discord.com/developers/docs/resources/audit-log#get-guild-audit-log
    @inlinable
    func listGuildAuditLogEntries(
        guildId: GuildSnowflake,
        userId: UserSnowflake? = nil,
        action_type: AuditLog.Entry.ActionKind? = nil,
        before: AuditLogEntrySnowflake? = nil,
        after: AuditLogEntrySnowflake? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<AuditLog> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 1_000)
        let endpoint = APIEndpoint.listGuildAuditLogEntries(guildId: guildId)
        return try await self.send(request: .init(
            to: endpoint,
            queries: [
                ("user_id", userId?.value),
                ("action_type", action_type.map { "\($0.rawValue)" }),
                ("before", before?.value),
                ("after", after?.value),
                ("limit", limit.map { "\($0)" })
            ]
        ))
    }
    
    /// You can use this function to create a new **or** retrieve an existing DM channel.
    /// https://discord.com/developers/docs/resources/user#create-dm
    @inlinable
    func createDm(
        recipientId: UserSnowflake
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.createDm
        return try await self.send(
            request: .init(to: endpoint),
            payload: Payloads.CreateDM(recipient_id: recipientId)
        )
    }

    /// https://discord.com/developers/docs/resources/channel#trigger-typing-indicator
    @inlinable
    func triggerTypingIndicator(channelId: ChannelSnowflake) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.triggerTypingIndicator(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#start-thread-from-message
    @inlinable
    func createThreadFromMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
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
        channelId: ChannelSnowflake,
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
        channelId: ChannelSnowflake,
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
    func joinThread(id: ChannelSnowflake) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.joinThread(channelId: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#add-thread-member
    @inlinable
    func addThreadMember(
        threadId: ChannelSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.addThreadMember(channelId: threadId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#leave-thread
    @inlinable
    func leaveThread(id: ChannelSnowflake) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.leaveThread(channelId: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#remove-thread-member
    @inlinable
    func deleteThreadMember(
        threadId: ChannelSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteThreadMember(channelId: threadId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-thread-member
    @inlinable
    func getThreadMember(
        threadId: ChannelSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordClientResponse<ThreadMember> {
        let endpoint = APIEndpoint.getThreadMember(channelId: threadId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-thread-member
    @inlinable
    func getThreadMemberWithMember(
        threadId: ChannelSnowflake,
        userId: UserSnowflake
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
        threadId: ChannelSnowflake
    ) async throws -> DiscordClientResponse<[ThreadMember]> {
        let endpoint = APIEndpoint.listThreadMembers(channelId: threadId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#list-thread-members
    @inlinable
    func listThreadMembersWithMember(
        threadId: ChannelSnowflake,
        after: UserSnowflake? = nil,
        limit: Int? = nil
    ) async throws -> DiscordClientResponse<[ThreadMemberWithMember]> {
        try checkInBounds(name: "limit", value: limit, lowerBound: 1, upperBound: 100)
        let endpoint = APIEndpoint.listThreadMembers(channelId: threadId)
        return try await self.send(request: .init(
            to: endpoint,
            queries: [
                ("with_member", "true"),
                ("after", after?.value),
                ("limit", limit.map({ "\($0)" })),
            ]
        ))
    }
    
    /// https://discord.com/developers/docs/resources/channel#list-public-archived-threads
    func listPublicArchivedThreads(
        channelId: ChannelSnowflake,
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
        channelId: ChannelSnowflake,
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
        channelId: ChannelSnowflake,
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
        channelId: ChannelSnowflake,
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
    func listChannelWebhooks(channelId: ChannelSnowflake) async throws -> DiscordClientResponse<[Webhook]> {
        let endpoint = APIEndpoint.listChannelWebhooks(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/webhook#get-guild-webhooks
    @inlinable
    func getGuildWebhooks(guildId: GuildSnowflake) async throws -> DiscordClientResponse<[Webhook]> {
        let endpoint = APIEndpoint.getGuildWebhooks(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// Requires authentication using an authorized bot-token.
    /// https://discord.com/developers/docs/resources/webhook#get-webhook
    @inlinable
    func getWebhook(id: WebhookSnowflake) async throws -> DiscordClientResponse<Webhook> {
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
        id: WebhookSnowflake,
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
    func deleteWebhook(
        id: WebhookSnowflake,
        reason: String? = nil
    ) async throws -> DiscordHTTPResponse {
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
        threadId: ChannelSnowflake? = nil,
        payload: Payloads.ExecuteWebhook
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.executeWebhook(
            webhookId: address.id,
            webhookToken: address.token
        )
        return try await self.sendMultipart(
            request: .init(
                to: endpoint,
                queries: [("thread_id", threadId?.value)]
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
        threadId: ChannelSnowflake? = nil,
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
                    ("thread_id", threadId?.value)
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
        messageId: MessageSnowflake,
        threadId: ChannelSnowflake? = nil
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.getWebhookMessage(
            webhookId: address.id,
            webhookToken: address.token,
            messageId: messageId
        )
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("thread_id", threadId?.value)]
        ))
    }
    
    /// - Parameters:
    ///   - threadId: Required if the message is in a thread.
    /// https://discord.com/developers/docs/resources/webhook#edit-webhook-message
    @inlinable
    func updateWebhookMessage(
        address: WebhookAddress,
        messageId: MessageSnowflake,
        threadId: ChannelSnowflake? = nil,
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
                queries: [("thread_id", threadId?.value)]
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
        messageId: MessageSnowflake,
        threadId: ChannelSnowflake? = nil
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteWebhookMessage(
            webhookId: address.id,
            webhookToken: address.token,
            messageId: messageId
        )
        return try await self.send(request: .init(
            to: endpoint,
            queries: [("thread_id", threadId?.value)]
        ))
    }
}

/// MARK: - `CDNEndpoint` functions
public extension DiscordClient {
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNCustomEmoji(emojiId: EmojiSnowflake) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.customEmoji(emojiId: emojiId)
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: emojiId.value
        )
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildIcon(
        guildId: GuildSnowflake,
        icon: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildIcon(guildId: guildId, icon: icon)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildSplash(
        guildId: GuildSnowflake,
        splash: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildSplash(guildId: guildId, splash: splash)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: splash)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildDiscoverySplash(
        guildId: GuildSnowflake,
        splash: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildDiscoverySplash(guildId: guildId, splash: splash)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: splash)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildBanner(guildId: GuildSnowflake, banner: String) async throws -> DiscordCDNResponse {
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
    func getCDNUserBanner(userId: UserSnowflake, banner: String) async throws -> DiscordCDNResponse {
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
    func getCDNUserAvatar(userId: UserSnowflake, avatar: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.userAvatar(userId: userId, avatar: avatar)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: avatar)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildMemberAvatar(
        guildId: GuildSnowflake,
        userId: UserSnowflake,
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
    func getCDNApplicationIcon(appId: ApplicationSnowflake, icon: String) async throws -> DiscordCDNResponse {
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
    func getCDNApplicationCover(appId: ApplicationSnowflake, cover: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.applicationCover(appId: appId, cover: cover)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: cover)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNApplicationAsset(
        appId: ApplicationSnowflake,
        assetId: AssetsSnowflake
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.applicationAsset(appId: appId, assetId: assetId)
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: assetId.value
        )
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
        appId: ApplicationSnowflake,
        achievementId: AnySnowflake,
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
    func getCDNStorePageAsset(
        appId: ApplicationSnowflake,
        assetId: AssetsSnowflake
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.storePageAsset(appId: appId, assetId: assetId)
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: assetId.value
        )
    }
    
    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `assetId`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNStickerPackBanner(
        assetId: AssetsSnowflake
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.stickerPackBanner(assetId: assetId)
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: assetId.value
        )
    }
    
    /// Untested function.
    /// If it didn't work, try to append `.png` to the end of `icon`.
    /// If you are using this endpoint successfully, please open an issue and let me know what
    /// info you pass to the function, so I can fix the function and add it to the tests.
    /// (CDN data are _mostly_ public)
    ///
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNTeamIcon(teamId: TeamSnowflake, icon: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.teamIcon(teamId: teamId, icon: icon)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNSticker(stickerId: StickerSnowflake) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.sticker(stickerId: stickerId)
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: stickerId.value
        )
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNRoleIcon(roleId: RoleSnowflake, icon: String) async throws -> DiscordCDNResponse {
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
        eventId: GuildScheduledEventSnowflake,
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
        guildId: GuildSnowflake,
        userId: UserSnowflake,
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

//MARK: - Unused Functions (not ready for the public)

/// These endpoints possibly don't have one of these:
/// * a Test
/// * Link-comment
/// * Correct `DiscordClientResponse` type
/// * Support for payload/queries/headers
/// * Or I just haven't taken a look at them yet
/// * Or maybe the endpoint already has a function and the function below is redundant
///
/// These functions are supposed to slowly be rolled out. Please shout if you need any of them.
internal extension DiscordClient {
    @inlinable
    func getAutoModerationRule(
        guildId: GuildSnowflake,
        ruleId: RuleSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getAutoModerationRule(guildId: guildId, ruleId: ruleId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listAutoModerationRules(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listAutoModerationRules(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createAutoModerationRule(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createAutoModerationRule(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateAutoModerationRule(
        guildId: GuildSnowflake,
        ruleId: RuleSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateAutoModerationRule(guildId: guildId, ruleId: ruleId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteAutoModerationRule(
        guildId: GuildSnowflake,
        ruleId: RuleSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteAutoModerationRule(guildId: guildId, ruleId: ruleId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listGuildAuditLogEntries(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listGuildAuditLogEntries(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getChannel(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getChannel(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listPinnedMessages(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listPinnedMessages(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func addGroupDmUser(
        channelId: ChannelSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.addGroupDmUser(channelId: channelId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func pinMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.pinMessage(channelId: channelId, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func setChannelPermissionOverwrite(
        channelId: ChannelSnowflake,
        overwriteId: AnySnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.setChannelPermissionOverwrite(channelId: channelId, overwriteId: overwriteId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createDm() async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createDm
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func followChannel(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.followChannel(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateChannel(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateChannel(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteChannel(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteChannel(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteChannelPermissionOverwrite(
        channelId: ChannelSnowflake,
        overwriteId: AnySnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteChannelPermissionOverwrite(channelId: channelId, overwriteId: overwriteId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteGroupDmUser(
        channelId: ChannelSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGroupDmUser(channelId: channelId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func unpinMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.unpinMessage(channelId: channelId, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getApplicationCommand(
        applicationId: ApplicationSnowflake,
        commandId: CommandSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getApplicationCommand(applicationId: applicationId, commandId: commandId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildApplicationCommand(
        applicationId: ApplicationSnowflake,
        guildId: GuildSnowflake,
        commandId: CommandSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildApplicationCommand(applicationId: applicationId, guildId: guildId, commandId: commandId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildApplicationCommandPermissions(
        applicationId: ApplicationSnowflake,
        guildId: GuildSnowflake,
        commandId: CommandSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildApplicationCommandPermissions(applicationId: applicationId, guildId: guildId, commandId: commandId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listApplicationCommands(
        applicationId: ApplicationSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listApplicationCommands(applicationId: applicationId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listGuildApplicationCommandPermissions(
        applicationId: ApplicationSnowflake,
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listGuildApplicationCommandPermissions(applicationId: applicationId, guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listGuildApplicationCommands(
        applicationId: ApplicationSnowflake,
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listGuildApplicationCommands(applicationId: applicationId, guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func bulkSetApplicationCommands(
        applicationId: ApplicationSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.bulkSetApplicationCommands(applicationId: applicationId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func bulkSetGuildApplicationCommands(
        applicationId: ApplicationSnowflake,
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.bulkSetGuildApplicationCommands(applicationId: applicationId, guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func setGuildApplicationCommandPermissions(
        applicationId: ApplicationSnowflake,
        guildId: GuildSnowflake,
        commandId: CommandSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.setGuildApplicationCommandPermissions(applicationId: applicationId, guildId: guildId, commandId: commandId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createApplicationCommand(
        applicationId: ApplicationSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createApplicationCommand(applicationId: applicationId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createGuildApplicationCommand(
        applicationId: ApplicationSnowflake,
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createGuildApplicationCommand(applicationId: applicationId, guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateApplicationCommand(
        applicationId: ApplicationSnowflake,
        commandId: CommandSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateApplicationCommand(applicationId: applicationId, commandId: commandId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateGuildApplicationCommand(
        applicationId: ApplicationSnowflake,
        guildId: GuildSnowflake,
        commandId: CommandSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateGuildApplicationCommand(applicationId: applicationId, guildId: guildId, commandId: commandId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteApplicationCommand(
        applicationId: ApplicationSnowflake,
        commandId: CommandSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteApplicationCommand(applicationId: applicationId, commandId: commandId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteGuildApplicationCommand(
        applicationId: ApplicationSnowflake,
        guildId: GuildSnowflake,
        commandId: CommandSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildApplicationCommand(applicationId: applicationId, guildId: guildId, commandId: commandId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildEmoji(
        guildId: GuildSnowflake,
        emojiId: EmojiSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildEmoji(guildId: guildId, emojiId: emojiId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listGuildEmojis(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listGuildEmojis(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createGuildEmoji(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createGuildEmoji(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateGuildEmoji(
        guildId: GuildSnowflake,
        emojiId: EmojiSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateGuildEmoji(guildId: guildId, emojiId: emojiId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteGuildEmoji(
        guildId: GuildSnowflake,
        emojiId: EmojiSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildEmoji(guildId: guildId, emojiId: emojiId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getBotGateway() async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getBotGateway
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGateway() async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGateway
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuild(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuild(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildBan(
        guildId: GuildSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildBan(guildId: guildId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildOnboarding(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildOnboarding(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildPreview(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildPreview(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildVanityUrl(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildVanityUrl(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildWelcomeScreen(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildWelcomeScreen(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildWidget(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildWidget(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildWidgetPng(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildWidgetPng(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildWidgetSettings(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildWidgetSettings(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listGuildBans(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listGuildBans(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listGuildChannels(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listGuildChannels(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listGuildIntegrations(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listGuildIntegrations(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listOwnGuilds() async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listOwnGuilds
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func previewPruneGuild(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.previewPruneGuild(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func banUserFromGuild(
        guildId: GuildSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.banUserFromGuild(guildId: guildId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createGuild() async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createGuild
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createGuildChannel(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createGuildChannel(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func pruneGuild(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.pruneGuild(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func setGuildMfaLevel(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.setGuildMfaLevel(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func bulkUpdateGuildChannels(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.bulkUpdateGuildChannels(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateGuild(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateGuild(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateGuildWelcomeScreen(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateGuildWelcomeScreen(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateGuildWidgetSettings(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateGuildWidgetSettings(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteGuild(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuild(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteGuildIntegration(
        guildId: GuildSnowflake,
        integrationId: IntegrationSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildIntegration(guildId: guildId, integrationId: integrationId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func leaveGuild(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.leaveGuild(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func unbanUserFromGuild(
        guildId: GuildSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.unbanUserFromGuild(guildId: guildId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildTemplate(
        code: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildTemplate(code: code)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listGuildTemplates(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listGuildTemplates(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func syncGuildTemplate(
        guildId: GuildSnowflake,
        code: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.syncGuildTemplate(guildId: guildId, code: code)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createGuildFromTemplate(
        code: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createGuildFromTemplate(code: code)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createGuildTemplate(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createGuildTemplate(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateGuildTemplate(
        guildId: GuildSnowflake,
        code: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateGuildTemplate(guildId: guildId, code: code)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteGuildTemplate(
        guildId: GuildSnowflake,
        code: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildTemplate(guildId: guildId, code: code)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getFollowupMessage(
        applicationId: ApplicationSnowflake,
        interactionToken: String,
        messageId: MessageSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getFollowupMessage(applicationId: applicationId, interactionToken: interactionToken, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getOriginalInteractionResponse(
        applicationId: ApplicationSnowflake,
        interactionToken: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getOriginalInteractionResponse(applicationId: applicationId, interactionToken: interactionToken)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createFollowupMessage(
        applicationId: ApplicationSnowflake,
        interactionToken: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createFollowupMessage(applicationId: applicationId, interactionToken: interactionToken)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createInteractionResponse(
        interactionId: InteractionSnowflake,
        interactionToken: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createInteractionResponse(interactionId: interactionId, interactionToken: interactionToken)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateFollowupMessage(
        applicationId: ApplicationSnowflake,
        interactionToken: String,
        messageId: MessageSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateFollowupMessage(applicationId: applicationId, interactionToken: interactionToken, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateOriginalInteractionResponse(
        applicationId: ApplicationSnowflake,
        interactionToken: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateOriginalInteractionResponse(applicationId: applicationId, interactionToken: interactionToken)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteFollowupMessage(
        applicationId: ApplicationSnowflake,
        interactionToken: String,
        messageId: MessageSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteFollowupMessage(applicationId: applicationId, interactionToken: interactionToken, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteOriginalInteractionResponse(
        applicationId: ApplicationSnowflake,
        interactionToken: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteOriginalInteractionResponse(applicationId: applicationId, interactionToken: interactionToken)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func inviteResolve(
        code: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.inviteResolve(code: code)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listChannelInvites(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listChannelInvites(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listGuildInvites(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listGuildInvites(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createChannelInvite(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createChannelInvite(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func inviteRevoke(
        code: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.inviteRevoke(code: code)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildMember(
        guildId: GuildSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildMember(guildId: guildId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getOwnGuildMember(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getOwnGuildMember(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listGuildMembers(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listGuildMembers(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func searchGuildMembers(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.searchGuildMembers(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func addGuildMember(
        guildId: GuildSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.addGuildMember(guildId: guildId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateGuildMember(
        guildId: GuildSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateGuildMember(guildId: guildId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateOwnGuildMember(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateOwnGuildMember(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteGuildMember(
        guildId: GuildSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildMember(guildId: guildId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getMessage(channelId: channelId, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listMessageReactionsByEmoji(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        emojiName: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listMessageReactionsByEmoji(channelId: channelId, messageId: messageId, emojiName: emojiName)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listMessages(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listMessages(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func addOwnMessageReaction(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        emojiName: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.addOwnMessageReaction(channelId: channelId, messageId: messageId, emojiName: emojiName)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func bulkDeleteMessages(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.bulkDeleteMessages(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createMessage(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createMessage(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func crosspostMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.crosspostMessage(channelId: channelId, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateMessage(channelId: channelId, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteAllMessageReactionsByEmoji(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        emojiName: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteAllMessageReactionsByEmoji(channelId: channelId, messageId: messageId, emojiName: emojiName)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteMessage(channelId: channelId, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteOwnMessageReaction(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        emojiName: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteOwnMessageReaction(channelId: channelId, messageId: messageId, emojiName: emojiName)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteUserMessageReaction(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        emojiName: String,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteUserMessageReaction(channelId: channelId, messageId: messageId, emojiName: emojiName, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getOwnOauth2Application() async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getOwnOauth2Application
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listGuildRoles(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listGuildRoles(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func addGuildMemberRole(
        guildId: GuildSnowflake,
        userId: UserSnowflake,
        roleId: RoleSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.addGuildMemberRole(guildId: guildId, userId: userId, roleId: roleId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createGuildRole(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createGuildRole(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func bulkUpdateGuildRoles(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.bulkUpdateGuildRoles(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateGuildRole(
        guildId: GuildSnowflake,
        roleId: RoleSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateGuildRole(guildId: guildId, roleId: roleId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteGuildMemberRole(
        guildId: GuildSnowflake,
        userId: UserSnowflake,
        roleId: RoleSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildMemberRole(guildId: guildId, userId: userId, roleId: roleId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteGuildRole(
        guildId: GuildSnowflake,
        roleId: RoleSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildRole(guildId: guildId, roleId: roleId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getApplicationRoleConnectionsMetadata(
        applicationId: ApplicationSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getApplicationRoleConnectionsMetadata(applicationId: applicationId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getApplicationUserRoleConnection(
        applicationId: ApplicationSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getApplicationUserRoleConnection(applicationId: applicationId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateApplicationRoleConnectionsMetadata(
        applicationId: ApplicationSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateApplicationRoleConnectionsMetadata(applicationId: applicationId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateApplicationUserRoleConnection(
        applicationId: ApplicationSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateApplicationUserRoleConnection(applicationId: applicationId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildScheduledEvent(
        guildId: GuildSnowflake,
        guildScheduledEventId: GuildScheduledEventSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildScheduledEvent(guildId: guildId, guildScheduledEventId: guildScheduledEventId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listGuildScheduledEventUsers(
        guildId: GuildSnowflake,
        guildScheduledEventId: GuildScheduledEventSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listGuildScheduledEventUsers(guildId: guildId, guildScheduledEventId: guildScheduledEventId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listGuildScheduledEvents(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listGuildScheduledEvents(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createGuildScheduledEvent(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createGuildScheduledEvent(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateGuildScheduledEvent(
        guildId: GuildSnowflake,
        guildScheduledEventId: GuildScheduledEventSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateGuildScheduledEvent(guildId: guildId, guildScheduledEventId: guildScheduledEventId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteGuildScheduledEvent(
        guildId: GuildSnowflake,
        guildScheduledEventId: GuildScheduledEventSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildScheduledEvent(guildId: guildId, guildScheduledEventId: guildScheduledEventId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getStageInstance(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getStageInstance(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createStageInstance() async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createStageInstance
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateStageInstance(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateStageInstance(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteStageInstance(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteStageInstance(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildSticker(
        guildId: GuildSnowflake,
        stickerId: StickerSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildSticker(guildId: guildId, stickerId: stickerId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getSticker(
        stickerId: StickerSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getSticker(stickerId: stickerId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listGuildStickers(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listGuildStickers(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listStickerPacks() async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listStickerPacks
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createGuildSticker(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createGuildSticker(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateGuildSticker(
        guildId: GuildSnowflake,
        stickerId: StickerSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateGuildSticker(guildId: guildId, stickerId: stickerId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteGuildSticker(
        guildId: GuildSnowflake,
        stickerId: StickerSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuildSticker(guildId: guildId, stickerId: stickerId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getActiveGuildThreads(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getActiveGuildThreads(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getThreadMember(
        channelId: ChannelSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getThreadMember(channelId: channelId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listOwnPrivateArchivedThreads(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listOwnPrivateArchivedThreads(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listPrivateArchivedThreads(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listPrivateArchivedThreads(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listPublicArchivedThreads(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listPublicArchivedThreads(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listThreadMembers(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listThreadMembers(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func addThreadMember(
        channelId: ChannelSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.addThreadMember(channelId: channelId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func joinThread(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.joinThread(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createThread(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createThread(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createThreadFromMessage(
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createThreadFromMessage(channelId: channelId, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createThreadInForumChannel(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createThreadInForumChannel(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteThreadMember(
        channelId: ChannelSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteThreadMember(channelId: channelId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func leaveThread(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.leaveThread(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getOwnUser() async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getOwnUser
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getUser(
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getUser(userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listOwnConnections() async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listOwnConnections
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateOwnUser() async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateOwnUser
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listGuildVoiceRegions(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listGuildVoiceRegions(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listVoiceRegions() async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listVoiceRegions
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateSelfVoiceState(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateSelfVoiceState(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateVoiceState(
        guildId: GuildSnowflake,
        userId: UserSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateVoiceState(guildId: guildId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getGuildWebhooks(
        guildId: GuildSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getGuildWebhooks(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getWebhook(
        webhookId: WebhookSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getWebhook(webhookId: webhookId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getWebhookByToken(
        webhookId: WebhookSnowflake,
        webhookToken: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getWebhookByToken(webhookId: webhookId, webhookToken: webhookToken)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getWebhookMessage(
        webhookId: WebhookSnowflake,
        webhookToken: String,
        messageId: MessageSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getWebhookMessage(webhookId: webhookId, webhookToken: webhookToken, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func getWebhooksMessagesOriginal(
        webhookId: WebhookSnowflake,
        webhookToken: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.getWebhooksMessagesOriginal(webhookId: webhookId, webhookToken: webhookToken)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func listChannelWebhooks(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.listChannelWebhooks(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func createWebhook(
        channelId: ChannelSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.createWebhook(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func executeWebhook(
        webhookId: WebhookSnowflake,
        webhookToken: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.executeWebhook(webhookId: webhookId, webhookToken: webhookToken)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func patchWebhooksMessagesOriginal(
        webhookId: WebhookSnowflake,
        webhookToken: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.patchWebhooksMessagesOriginal(webhookId: webhookId, webhookToken: webhookToken)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateWebhook(
        webhookId: WebhookSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateWebhook(webhookId: webhookId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateWebhookByToken(
        webhookId: WebhookSnowflake,
        webhookToken: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateWebhookByToken(webhookId: webhookId, webhookToken: webhookToken)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func updateWebhookMessage(
        webhookId: WebhookSnowflake,
        webhookToken: String,
        messageId: MessageSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.updateWebhookMessage(webhookId: webhookId, webhookToken: webhookToken, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteWebhook(
        webhookId: WebhookSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteWebhook(webhookId: webhookId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteWebhookByToken(
        webhookId: WebhookSnowflake,
        webhookToken: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteWebhookByToken(webhookId: webhookId, webhookToken: webhookToken)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteWebhookMessage(
        webhookId: WebhookSnowflake,
        webhookToken: String,
        messageId: MessageSnowflake
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteWebhookMessage(webhookId: webhookId, webhookToken: webhookToken, messageId: messageId)
        return try await self.send(request: .init(to: endpoint))
    }

    @inlinable
    func deleteWebhooksMessagesOriginal(
        webhookId: WebhookSnowflake,
        webhookToken: String
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteWebhooksMessagesOriginal(webhookId: webhookId, webhookToken: webhookToken)
        return try await self.send(request: .init(to: endpoint))
    }
}
