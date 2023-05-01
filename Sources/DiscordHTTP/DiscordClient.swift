import DiscordModels
import NIOHTTP1
import NIOCore
import Foundation

public protocol DiscordClient: Sendable {
    var appId: Snowflake<PartialApplication>? { get }
    
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
        _ providedAppId: Snowflake<PartialApplication>?
    ) throws -> Snowflake<PartialApplication> {
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
        id: Snowflake<Interaction>,
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
        appId: Snowflake<PartialApplication>? = nil,
        token: String,
        threadId: Snowflake<DiscordChannel>? = nil
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
        appId: Snowflake<PartialApplication>? = nil,
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
        appId: Snowflake<PartialApplication>? = nil,
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
        appId: Snowflake<PartialApplication>? = nil,
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
        appId: Snowflake<PartialApplication>? = nil,
        token: String,
        messageId: Snowflake<DiscordChannel.Message>,
        threadId: Snowflake<DiscordChannel>? = nil
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
        appId: Snowflake<PartialApplication>? = nil,
        token: String,
        messageId: Snowflake<DiscordChannel.Message>,
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
        appId: Snowflake<PartialApplication>? = nil,
        token: String,
        messageId: Snowflake<DiscordChannel.Message>
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
        channelId: Snowflake<DiscordChannel>,
        payload: Payloads.CreateMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.createMessage(channelId: channelId)
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/resources/channel#edit-message
    @inlinable
    func updateMessage(
        channelId: Snowflake<DiscordChannel>,
        messageId: Snowflake<DiscordChannel.Message>,
        payload: Payloads.EditMessage
    ) async throws -> DiscordClientResponse<DiscordChannel.Message> {
        let endpoint = APIEndpoint.updateMessage(channelId: channelId, messageId: messageId)
        return try await self.sendMultipart(request: .init(to: endpoint), payload: payload)
    }

    /// https://discord.com/developers/docs/resources/channel#delete-message
    @inlinable
    func deleteMessage(
        channelId: Snowflake<DiscordChannel>,
        messageId: Snowflake<DiscordChannel.Message>,
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
        appId: Snowflake<PartialApplication>? = nil,
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
        appId: Snowflake<PartialApplication>? = nil,
        payload: Payloads.ApplicationCommandCreate
    ) async throws -> DiscordClientResponse<ApplicationCommand> {
        let endpoint = APIEndpoint.createApplicationCommand(applicationId: try requireAppId(appId))
        return try await self.send(request: .init(to: endpoint), payload: payload)
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#get-global-application-command
    @inlinable
    func getApplicationCommand(
        appId: Snowflake<PartialApplication>? = nil,
        commandId: Snowflake<ApplicationCommand>
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
        appId: Snowflake<PartialApplication>? = nil,
        commandId: Snowflake<ApplicationCommand>,
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
        appId: Snowflake<PartialApplication>? = nil,
        commandId: Snowflake<ApplicationCommand>
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
        appId: Snowflake<PartialApplication>? = nil,
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
        appId: Snowflake<PartialApplication>? = nil,
        guildId: Snowflake<Guild>,
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
        appId: Snowflake<PartialApplication>? = nil,
        guildId: Snowflake<Guild>,
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
        appId: Snowflake<PartialApplication>? = nil,
        guildId: Snowflake<Guild>,
        commandId: Snowflake<ApplicationCommand>
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
        appId: Snowflake<PartialApplication>? = nil,
        guildId: Snowflake<Guild>,
        commandId: Snowflake<ApplicationCommand>,
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
        appId: Snowflake<PartialApplication>? = nil,
        guildId: Snowflake<Guild>,
        commandId: Snowflake<ApplicationCommand>
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
        appId: Snowflake<PartialApplication>? = nil,
        guildId: Snowflake<Guild>,
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
        appId: Snowflake<PartialApplication>? = nil,
        guildId: Snowflake<Guild>
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
        appId: Snowflake<PartialApplication>? = nil,
        guildId: Snowflake<Guild>,
        commandId: Snowflake<ApplicationCommand>
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
        appId: Snowflake<PartialApplication>? = nil,
        guildId: Snowflake<Guild>,
        commandId: Snowflake<ApplicationCommand>,
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
        id: Snowflake<Guild>,
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
        id: Snowflake<Guild>,
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
    func deleteGuild(id: Snowflake<Guild>) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteGuild(guildId: id)
        return try await self.send(request: .init(to: endpoint))
    }

    /// https://discord.com/developers/docs/resources/guild#get-guild-roles
    @inlinable
    func listGuildRoles(id: Snowflake<Guild>) async throws -> DiscordClientResponse<[Role]> {
        let endpoint = APIEndpoint.listGuildRoles(guildId: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-channel
    @inlinable
    func getChannel(
        id: Snowflake<DiscordChannel>
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
        id: Snowflake<DiscordChannel>,
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
        id: Snowflake<DiscordChannel>,
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
        id: Snowflake<DiscordChannel>,
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
        id: Snowflake<DiscordChannel>,
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
        guildId: Snowflake<Guild>,
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
    func leaveGuild(id: Snowflake<Guild>) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.leaveGuild(guildId: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/guild#create-guild-role
    @inlinable
    func createGuildRole(
        guildId: Snowflake<Guild>,
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
        guildId: Snowflake<Guild>,
        roleId: Snowflake<Role>,
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
        guildId: Snowflake<Guild>,
        userId: Snowflake<DiscordUser>,
        roleId: Snowflake<Role>,
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
        guildId: Snowflake<Guild>,
        userId: Snowflake<DiscordUser>,
        roleId: Snowflake<Role>,
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
        channelId: Snowflake<DiscordChannel>,
        messageId: Snowflake<DiscordChannel.Message>,
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
        channelId: Snowflake<DiscordChannel>,
        messageId: Snowflake<DiscordChannel.Message>,
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
        channelId: Snowflake<DiscordChannel>,
        messageId: Snowflake<DiscordChannel.Message>,
        emoji: Reaction,
        userId: Snowflake<DiscordUser>
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
        channelId: Snowflake<DiscordChannel>,
        messageId: Snowflake<DiscordChannel.Message>,
        emoji: Reaction,
        after: Snowflake<DiscordUser>? = nil,
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
        channelId: Snowflake<DiscordChannel>,
        messageId: Snowflake<DiscordChannel.Message>
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
        channelId: Snowflake<DiscordChannel>,
        messageId: Snowflake<DiscordChannel.Message>,
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
        guildId: Snowflake<Guild>,
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
        guildId: Snowflake<Guild>,
        userId: Snowflake<DiscordUser>
    ) async throws -> DiscordClientResponse<Guild.Member> {
        let endpoint = APIEndpoint.getGuildMember(guildId: guildId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// NOTE: `around`, `before` and `after` are mutually exclusive.
    /// https://discord.com/developers/docs/resources/channel#get-channel-messages
    @inlinable
    func listMessages(
        channelId: Snowflake<DiscordChannel>,
        around: Snowflake<DiscordChannel.Message>? = nil,
        before: Snowflake<DiscordChannel.Message>? = nil,
        after: Snowflake<DiscordChannel.Message>? = nil,
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
        channelId: Snowflake<DiscordChannel>,
        messageId: Snowflake<DiscordChannel.Message>
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
        guildId: Snowflake<Guild>,
        userId: Snowflake<DiscordUser>? = nil,
        action_type: AuditLog.Entry.ActionKind? = nil,
        before: Snowflake<AuditLog.Entry>? = nil,
        after: Snowflake<AuditLog.Entry>? = nil,
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
        recipientId: Snowflake<DiscordUser>
    ) async throws -> DiscordClientResponse<DiscordChannel> {
        let endpoint = APIEndpoint.createDm
        return try await self.send(
            request: .init(to: endpoint),
            payload: Payloads.CreateDM(recipient_id: recipientId)
        )
    }

    /// https://discord.com/developers/docs/resources/channel#trigger-typing-indicator
    @inlinable
    func triggerTypingIndicator(channelId: Snowflake<DiscordChannel>) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.triggerTypingIndicator(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#start-thread-from-message
    @inlinable
    func createThreadFromMessage(
        channelId: Snowflake<DiscordChannel>,
        messageId: Snowflake<DiscordChannel.Message>,
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
        channelId: Snowflake<DiscordChannel>,
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
        channelId: Snowflake<DiscordChannel>,
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
    func joinThread(id: Snowflake<DiscordChannel>) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.joinThread(channelId: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#add-thread-member
    @inlinable
    func addThreadMember(
        threadId: Snowflake<DiscordChannel>,
        userId: Snowflake<DiscordUser>
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.addThreadMember(channelId: threadId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#leave-thread
    @inlinable
    func leaveThread(id: Snowflake<DiscordChannel>) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.leaveThread(channelId: id)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#remove-thread-member
    @inlinable
    func deleteThreadMember(
        threadId: Snowflake<DiscordChannel>,
        userId: Snowflake<DiscordUser>
    ) async throws -> DiscordHTTPResponse {
        let endpoint = APIEndpoint.deleteThreadMember(channelId: threadId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-thread-member
    @inlinable
    func getThreadMember(
        threadId: Snowflake<DiscordChannel>,
        userId: Snowflake<DiscordUser>
    ) async throws -> DiscordClientResponse<ThreadMember> {
        let endpoint = APIEndpoint.getThreadMember(channelId: threadId, userId: userId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#get-thread-member
    @inlinable
    func getThreadMemberWithMember(
        threadId: Snowflake<DiscordChannel>,
        userId: Snowflake<DiscordUser>
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
        threadId: Snowflake<DiscordChannel>
    ) async throws -> DiscordClientResponse<[ThreadMember]> {
        let endpoint = APIEndpoint.listThreadMembers(channelId: threadId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/channel#list-thread-members
    @inlinable
    func listThreadMembersWithMember(
        threadId: Snowflake<DiscordChannel>,
        after: Snowflake<DiscordUser>? = nil,
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
        channelId: Snowflake<DiscordChannel>,
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
        channelId: Snowflake<DiscordChannel>,
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
        channelId: Snowflake<DiscordChannel>,
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
        channelId: Snowflake<DiscordChannel>,
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
    func listChannelWebhooks(channelId: Snowflake<DiscordChannel>) async throws -> DiscordClientResponse<[Webhook]> {
        let endpoint = APIEndpoint.listChannelWebhooks(channelId: channelId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// https://discord.com/developers/docs/resources/webhook#get-guild-webhooks
    @inlinable
    func getGuildWebhooks(guildId: Snowflake<Guild>) async throws -> DiscordClientResponse<[Webhook]> {
        let endpoint = APIEndpoint.getGuildWebhooks(guildId: guildId)
        return try await self.send(request: .init(to: endpoint))
    }
    
    /// Requires authentication using an authorized bot-token.
    /// https://discord.com/developers/docs/resources/webhook#get-webhook
    @inlinable
    func getWebhook(id: Snowflake<Webhook>) async throws -> DiscordClientResponse<Webhook> {
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
        id: Snowflake<Webhook>,
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
        id: Snowflake<Webhook>,
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
        threadId: Snowflake<DiscordChannel>? = nil,
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
        threadId: Snowflake<DiscordChannel>? = nil,
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
        messageId: Snowflake<DiscordChannel.Message>,
        threadId: Snowflake<DiscordChannel>? = nil
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
        messageId: Snowflake<DiscordChannel.Message>,
        threadId: Snowflake<DiscordChannel>? = nil,
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
        messageId: Snowflake<DiscordChannel.Message>,
        threadId: Snowflake<DiscordChannel>? = nil
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
    func getCDNCustomEmoji(emojiId: Snowflake<PartialEmoji>) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.customEmoji(emojiId: emojiId)
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: emojiId.value
        )
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildIcon(guildId: Snowflake<Guild>, icon: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildIcon(guildId: guildId, icon: icon)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildSplash(guildId: Snowflake<Guild>, splash: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildSplash(guildId: guildId, splash: splash)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: splash)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildDiscoverySplash(
        guildId: Snowflake<Guild>,
        splash: String
    ) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.guildDiscoverySplash(guildId: guildId, splash: splash)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: splash)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildBanner(guildId: Snowflake<Guild>, banner: String) async throws -> DiscordCDNResponse {
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
    func getCDNUserBanner(userId: Snowflake<DiscordUser>, banner: String) async throws -> DiscordCDNResponse {
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
    func getCDNUserAvatar(userId: Snowflake<DiscordUser>, avatar: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.userAvatar(userId: userId, avatar: avatar)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: avatar)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNGuildMemberAvatar(
        guildId: Snowflake<Guild>,
        userId: Snowflake<DiscordUser>,
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
    func getCDNApplicationIcon(appId: Snowflake<PartialApplication>, icon: String) async throws -> DiscordCDNResponse {
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
    func getCDNApplicationCover(appId: Snowflake<PartialApplication>, cover: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.applicationCover(appId: appId, cover: cover)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: cover)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNApplicationAsset(
        appId: Snowflake<PartialApplication>,
        assetId: Snowflake<Gateway.Activity.Assets>
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
        appId: Snowflake<PartialApplication>,
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
    func getCDNStorePageAsset(appId: Snowflake<PartialApplication>, assetId: String) async throws -> DiscordCDNResponse {
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
    func getCDNTeamIcon(teamId: Snowflake<Team>, icon: String) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.teamIcon(teamId: teamId, icon: icon)
        return try await self.send(request: .init(to: endpoint), fallbackFileName: icon)
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNSticker(stickerId: Snowflake<Sticker>) async throws -> DiscordCDNResponse {
        let endpoint = CDNEndpoint.sticker(stickerId: stickerId)
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: stickerId.value
        )
    }
    
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getCDNRoleIcon(roleId: Snowflake<Role>, icon: String) async throws -> DiscordCDNResponse {
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
        eventId: Snowflake<GuildScheduledEvent>,
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
        guildId: Snowflake<Guild>,
        userId: Snowflake<DiscordUser>,
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
