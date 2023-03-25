// MARK: - DO NOT EDIT. Auto-generated endpoints using the GenerateAPIEndpoints command plugin.

import NIOHTTP1

public enum APIEndpoint: Endpoint {

    // MARK: AutoMod
    /// https://discord.com/developers/docs/resources/auto-moderation
    
    case getAutoModerationRule(guildId: String, ruleId: String)
    case listAutoModerationRules(guildId: String)
    case createAutoModerationRule(guildId: String)
    case updateAutoModerationRule(guildId: String, ruleId: String)
    case deleteAutoModerationRule(guildId: String, ruleId: String)
    
    // MARK: Audit Log
    /// https://discord.com/developers/docs/resources/audit-log
    
    case listGuildAuditLogEntries(guildId: String)
    
    // MARK: Channels
    /// https://discord.com/developers/docs/resources/channel
    
    case getChannel(channelId: String)
    case listGuildChannels(guildId: String)
    case listPinnedMessages(channelId: String)
    case addGroupDmUser(channelId: String, userId: String)
    case pinMessage(channelId: String, messageId: String)
    case setChannelPermissionOverwrite(channelId: String, overwriteId: String)
    case createDm
    case createGuildChannel(guildId: String)
    case followChannel(channelId: String)
    case triggerTypingIndicator(channelId: String)
    case bulkUpdateGuildChannels(guildId: String)
    case updateChannel(channelId: String)
    case deleteChannel(channelId: String)
    case deleteChannelPermissionOverwrite(channelId: String, overwriteId: String)
    case deleteGroupDmUser(channelId: String, userId: String)
    case unpinMessage(channelId: String, messageId: String)
    
    // MARK: Commands
    /// https://discord.com/developers/docs/interactions/application-commands
    
    case getApplicationCommand(applicationId: String, commandId: String)
    case getGuildApplicationCommand(applicationId: String, guildId: String, commandId: String)
    case getGuildApplicationCommandPermissions(applicationId: String, guildId: String, commandId: String)
    case listApplicationCommands(applicationId: String)
    case listGuildApplicationCommandPermissions(applicationId: String, guildId: String)
    case listGuildApplicationCommands(applicationId: String, guildId: String)
    case bulkSetApplicationCommands(applicationId: String)
    case bulkSetGuildApplicationCommands(applicationId: String, guildId: String)
    case setGuildApplicationCommandPermissions(applicationId: String, guildId: String, commandId: String)
    case createApplicationCommand(applicationId: String)
    case createGuildApplicationCommand(applicationId: String, guildId: String)
    case updateApplicationCommand(applicationId: String, commandId: String)
    case updateGuildApplicationCommand(applicationId: String, guildId: String, commandId: String)
    case deleteApplicationCommand(applicationId: String, commandId: String)
    case deleteGuildApplicationCommand(applicationId: String, guildId: String, commandId: String)
    
    // MARK: Emoji
    /// https://discord.com/developers/docs/resources/emoji
    
    case getGuildEmoji(guildId: String, emojiId: String)
    case listGuildEmojis(guildId: String)
    case createGuildEmoji(guildId: String)
    case updateGuildEmoji(guildId: String, emojiId: String)
    case deleteGuildEmoji(guildId: String, emojiId: String)
    
    // MARK: Gateway
    /// https://discord.com/developers/docs/topics/gateway
    
    case getBotGateway
    case getGateway
    
    // MARK: Guilds
    /// https://discord.com/developers/docs/resources/guild
    
    case getGuild(guildId: String)
    case getGuildBan(guildId: String, userId: String)
    case getGuildPreview(guildId: String)
    case getGuildVanityUrl(guildId: String)
    case getGuildWelcomeScreen(guildId: String)
    case getGuildWidget(guildId: String)
    case getGuildWidgetPng(guildId: String)
    case getGuildWidgetSettings(guildId: String)
    case listGuildBans(guildId: String)
    case listGuildIntegrations(guildId: String)
    case listMyGuilds
    case previewPruneGuild(guildId: String)
    case banUserFromGuild(guildId: String, userId: String)
    case createGuild
    case pruneGuild(guildId: String)
    case setGuildMfaLevel(guildId: String)
    case updateGuild(guildId: String)
    case updateGuildWelcomeScreen(guildId: String)
    case updateGuildWidgetSettings(guildId: String)
    case deleteGuild(guildId: String)
    case deleteGuildIntegration(guildId: String, integrationId: String)
    case leaveGuild(guildId: String)
    case unbanUserFromGuild(guildId: String, userId: String)
    
    // MARK: Guild Templates
    /// https://discord.com/developers/docs/resources/guild-template
    
    case getGuildTemplate(code: String)
    case listGuildTemplates(guildId: String)
    case syncGuildTemplate(guildId: String, code: String)
    case createGuildFromTemplate(code: String)
    case createGuildTemplate(guildId: String)
    case updateGuildTemplate(guildId: String, code: String)
    case deleteGuildTemplate(guildId: String, code: String)
    
    // MARK: Interactions
    /// https://discord.com/developers/docs/interactions/receiving-and-responding
    
    case getFollowupMessage(applicationId: String, interactionToken: String, messageId: String)
    case getOriginalInteractionResponse(applicationId: String, interactionToken: String)
    case createFollowupMessage(applicationId: String, interactionToken: String)
    case createInteractionResponse(interactionId: String, interactionToken: String)
    case updateFollowupMessage(applicationId: String, interactionToken: String, messageId: String)
    case updateOriginalInteractionResponse(applicationId: String, interactionToken: String)
    case deleteFollowupMessage(applicationId: String, interactionToken: String, messageId: String)
    case deleteOriginalInteractionResponse(applicationId: String, interactionToken: String)
    
    // MARK: Invites
    /// https://discord.com/developers/docs/resources/invite
    
    case inviteResolve(code: String)
    case listChannelInvites(channelId: String)
    case listGuildInvites(guildId: String)
    case createChannelInvite(channelId: String)
    case inviteRevoke(code: String)
    
    // MARK: Members
    /// https://discord.com/developers/docs/resources/guild
    
    case getGuildMember(guildId: String, userId: String)
    case getMyGuildMember(guildId: String)
    case listGuildMembers(guildId: String)
    case searchGuildMembers(guildId: String)
    case addGuildMember(guildId: String, userId: String)
    case updateGuildMember(guildId: String, userId: String)
    case updateMyGuildMember(guildId: String)
    case deleteGuildMember(guildId: String, userId: String)
    
    // MARK: Messages
    /// https://discord.com/developers/docs/resources/channel
    
    case getMessage(channelId: String, messageId: String)
    case listMessageReactionsByEmoji(channelId: String, messageId: String, emojiName: String)
    case listMessages(channelId: String)
    case addMyMessageReaction(channelId: String, messageId: String, emojiName: String)
    case bulkDeleteMessages(channelId: String)
    case createMessage(channelId: String)
    case crosspostMessage(channelId: String, messageId: String)
    case updateMessage(channelId: String, messageId: String)
    case deleteAllMessageReactions(channelId: String, messageId: String)
    case deleteAllMessageReactionsByEmoji(channelId: String, messageId: String, emojiName: String)
    case deleteMessage(channelId: String, messageId: String)
    case deleteMyMessageReaction(channelId: String, messageId: String, emojiName: String)
    case deleteUserMessageReaction(channelId: String, messageId: String, emojiName: String, userId: String)
    
    // MARK: OAuth
    /// https://discord.com/developers/docs/topics/oauth2
    
    case getMyOauth2Application
    
    // MARK: Roles
    /// https://discord.com/developers/docs/resources/guild
    
    case listGuildRoles(guildId: String)
    case addGuildMemberRole(guildId: String, userId: String, roleId: String)
    case createGuildRole(guildId: String)
    case bulkUpdateGuildRoles(guildId: String)
    case updateGuildRole(guildId: String, roleId: String)
    case deleteGuildMemberRole(guildId: String, userId: String, roleId: String)
    case deleteGuildRole(guildId: String, roleId: String)
    
    // MARK: Role Connections
    /// https://discord.com/developers/docs/resources/user
    
    case getApplicationRoleConnectionsMetadata(applicationId: String)
    case getApplicationUserRoleConnection(applicationId: String)
    case updateApplicationRoleConnectionsMetadata(applicationId: String)
    case updateApplicationUserRoleConnection(applicationId: String)
    
    // MARK: Scheduled Events
    /// https://discord.com/developers/docs/resources/guild-scheduled-event
    
    case getGuildScheduledEvent(guildId: String, guildScheduledEventId: String)
    case listGuildScheduledEventUsers(guildId: String, guildScheduledEventId: String)
    case listGuildScheduledEvents(guildId: String)
    case createGuildScheduledEvent(guildId: String)
    case updateGuildScheduledEvent(guildId: String, guildScheduledEventId: String)
    case deleteGuildScheduledEvent(guildId: String, guildScheduledEventId: String)
    
    // MARK: Stages
    /// https://discord.com/developers/docs/resources/stage-instance
    
    case getStageInstance(channelId: String)
    case createStageInstance
    case updateStageInstance(channelId: String)
    case deleteStageInstance(channelId: String)
    
    // MARK: Stickers
    /// https://discord.com/developers/docs/resources/sticker
    
    case getGuildSticker(guildId: String, stickerId: String)
    case getSticker(stickerId: String)
    case listGuildStickers(guildId: String)
    case listStickerPacks
    case createGuildSticker(guildId: String)
    case updateGuildSticker(guildId: String, stickerId: String)
    case deleteGuildSticker(guildId: String, stickerId: String)
    
    // MARK: Threads
    /// https://discord.com/developers/docs/resources/channel
    
    case getActiveGuildThreads(guildId: String)
    case getThreadMember(channelId: String, userId: String)
    case listMyPrivateArchivedThreads(channelId: String)
    case listPrivateArchivedThreads(channelId: String)
    case listPublicArchivedThreads(channelId: String)
    case listThreadMembers(channelId: String)
    case addThreadMember(channelId: String, userId: String)
    case joinThread(channelId: String)
    case createThread(channelId: String)
    case createThreadFromMessage(channelId: String, messageId: String)
    case deleteThreadMember(channelId: String, userId: String)
    case leaveThread(channelId: String)
    
    // MARK: Users
    /// https://discord.com/developers/docs/resources/user
    
    case getMyUser
    case getUser(userId: String)
    case listMyConnections
    case updateMyUser
    
    // MARK: Voice
    /// https://discord.com/developers/docs/resources/voice#list-voice-regions
    
    case listGuildVoiceRegions(guildId: String)
    case listVoiceRegions
    case updateSelfVoiceState(guildId: String)
    case updateVoiceState(guildId: String, userId: String)
    
    // MARK: Webhooks
    /// https://discord.com/developers/docs/resources/webhook
    
    case getGuildWebhooks(guildId: String)
    case getWebhook(webhookId: String)
    case getWebhookByToken(webhookId: String, webhookToken: String)
    case getWebhookMessage(webhookId: String, webhookToken: String, messageId: String)
    case getWebhooksMessagesOriginal(webhookId: String, webhookToken: String)
    case listChannelWebhooks(channelId: String)
    case createWebhook(channelId: String)
    case executeWebhook(webhookId: String, webhookToken: String)
    case patchWebhooksMessagesOriginal(webhookId: String, webhookToken: String)
    case updateWebhook(webhookId: String)
    case updateWebhookByToken(webhookId: String, webhookToken: String)
    case updateWebhookMessage(webhookId: String, webhookToken: String, messageId: String)
    case deleteWebhook(webhookId: String)
    case deleteWebhookByToken(webhookId: String, webhookToken: String)
    case deleteWebhookMessage(webhookId: String, webhookToken: String, messageId: String)
    case deleteWebhooksMessagesOriginal(webhookId: String, webhookToken: String)

    var urlPrefix: String {
        "https://discord.com/api/v\(DiscordGlobalConfiguration.apiVersion)/"
    }

    public var url: String {
        func encoded(_ string: String) -> String {
            string.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? string
        }
        let suffix: String
        switch self {
        case let .getAutoModerationRule(guildId, ruleId):
            let guildId = encoded(guildId)
            let ruleId = encoded(ruleId)
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .listAutoModerationRules(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/auto-moderation/rules"
        case let .createAutoModerationRule(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/auto-moderation/rules"
        case let .updateAutoModerationRule(guildId, ruleId):
            let guildId = encoded(guildId)
            let ruleId = encoded(ruleId)
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .deleteAutoModerationRule(guildId, ruleId):
            let guildId = encoded(guildId)
            let ruleId = encoded(ruleId)
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .listGuildAuditLogEntries(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/audit-logs"
        case let .getChannel(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)"
        case let .listGuildChannels(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/channels"
        case let .listPinnedMessages(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/pins"
        case let .addGroupDmUser(channelId, userId):
            let channelId = encoded(channelId)
            let userId = encoded(userId)
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .pinMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .setChannelPermissionOverwrite(channelId, overwriteId):
            let channelId = encoded(channelId)
            let overwriteId = encoded(overwriteId)
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case .createDm:
            suffix = "users/@me/channels"
        case let .createGuildChannel(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/channels"
        case let .followChannel(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/followers"
        case let .triggerTypingIndicator(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/typing"
        case let .bulkUpdateGuildChannels(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/channels"
        case let .updateChannel(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)"
        case let .deleteChannel(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)"
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            let channelId = encoded(channelId)
            let overwriteId = encoded(overwriteId)
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case let .deleteGroupDmUser(channelId, userId):
            let channelId = encoded(channelId)
            let userId = encoded(userId)
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .unpinMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .getApplicationCommand(applicationId, commandId):
            let applicationId = encoded(applicationId)
            let commandId = encoded(commandId)
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            let commandId = encoded(commandId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            let commandId = encoded(commandId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .listApplicationCommands(applicationId):
            let applicationId = encoded(applicationId)
            suffix = "applications/\(applicationId)/commands"
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
        case let .listGuildApplicationCommands(applicationId, guildId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .bulkSetApplicationCommands(applicationId):
            let applicationId = encoded(applicationId)
            suffix = "applications/\(applicationId)/commands"
        case let .bulkSetGuildApplicationCommands(applicationId, guildId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .setGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            let commandId = encoded(commandId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .createApplicationCommand(applicationId):
            let applicationId = encoded(applicationId)
            suffix = "applications/\(applicationId)/commands"
        case let .createGuildApplicationCommand(applicationId, guildId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .updateApplicationCommand(applicationId, commandId):
            let applicationId = encoded(applicationId)
            let commandId = encoded(commandId)
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .updateGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            let commandId = encoded(commandId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .deleteApplicationCommand(applicationId, commandId):
            let applicationId = encoded(applicationId)
            let commandId = encoded(commandId)
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .deleteGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            let commandId = encoded(commandId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .getGuildEmoji(guildId, emojiId):
            let guildId = encoded(guildId)
            let emojiId = encoded(emojiId)
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case let .listGuildEmojis(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/emojis"
        case let .createGuildEmoji(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/emojis"
        case let .updateGuildEmoji(guildId, emojiId):
            let guildId = encoded(guildId)
            let emojiId = encoded(emojiId)
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case let .deleteGuildEmoji(guildId, emojiId):
            let guildId = encoded(guildId)
            let emojiId = encoded(emojiId)
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case .getBotGateway:
            suffix = "gateway/bot"
        case .getGateway:
            suffix = "gateway"
        case let .getGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)"
        case let .getGuildBan(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildPreview(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/preview"
        case let .getGuildVanityUrl(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/vanity-url"
        case let .getGuildWelcomeScreen(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .getGuildWidget(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/widget.json"
        case let .getGuildWidgetPng(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/widget.png"
        case let .getGuildWidgetSettings(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/widget"
        case let .listGuildBans(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/bans"
        case let .listGuildIntegrations(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/integrations"
        case .listMyGuilds:
            suffix = "users/@me/guilds"
        case let .previewPruneGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/prune"
        case let .banUserFromGuild(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case .createGuild:
            suffix = "guilds"
        case let .pruneGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/prune"
        case let .setGuildMfaLevel(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/mfa"
        case let .updateGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)"
        case let .updateGuildWelcomeScreen(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .updateGuildWidgetSettings(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/widget"
        case let .deleteGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)"
        case let .deleteGuildIntegration(guildId, integrationId):
            let guildId = encoded(guildId)
            let integrationId = encoded(integrationId)
            suffix = "guilds/\(guildId)/integrations/\(integrationId)"
        case let .leaveGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "users/@me/guilds/\(guildId)"
        case let .unbanUserFromGuild(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildTemplate(code):
            let code = encoded(code)
            suffix = "guilds/templates/\(code)"
        case let .listGuildTemplates(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/templates"
        case let .syncGuildTemplate(guildId, code):
            let guildId = encoded(guildId)
            let code = encoded(code)
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .createGuildFromTemplate(code):
            let code = encoded(code)
            suffix = "guilds/templates/\(code)"
        case let .createGuildTemplate(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/templates"
        case let .updateGuildTemplate(guildId, code):
            let guildId = encoded(guildId)
            let code = encoded(code)
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .deleteGuildTemplate(guildId, code):
            let guildId = encoded(guildId)
            let code = encoded(code)
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .getFollowupMessage(applicationId, interactionToken, messageId):
            let applicationId = encoded(applicationId)
            let interactionToken = encoded(interactionToken)
            let messageId = encoded(messageId)
            suffix = "webhooks/application.id/interaction.token/messages/message.id"
        case let .getOriginalInteractionResponse(applicationId, interactionToken):
            let applicationId = encoded(applicationId)
            let interactionToken = encoded(interactionToken)
            suffix = "webhooks/application.id/interaction.token/messages/@original"
        case let .createFollowupMessage(applicationId, interactionToken):
            let applicationId = encoded(applicationId)
            let interactionToken = encoded(interactionToken)
            suffix = "webhooks/application.id/interaction.token"
        case let .createInteractionResponse(interactionId, interactionToken):
            let interactionId = encoded(interactionId)
            let interactionToken = encoded(interactionToken)
            suffix = "interactions/\(interactionId)/\(interactionToken)/callback"
        case let .updateFollowupMessage(applicationId, interactionToken, messageId):
            let applicationId = encoded(applicationId)
            let interactionToken = encoded(interactionToken)
            let messageId = encoded(messageId)
            suffix = "webhooks/application.id/interaction.token/messages/message.id"
        case let .updateOriginalInteractionResponse(applicationId, interactionToken):
            let applicationId = encoded(applicationId)
            let interactionToken = encoded(interactionToken)
            suffix = "webhooks/application.id/interaction.token/messages/@original"
        case let .deleteFollowupMessage(applicationId, interactionToken, messageId):
            let applicationId = encoded(applicationId)
            let interactionToken = encoded(interactionToken)
            let messageId = encoded(messageId)
            suffix = "webhooks/application.id/interaction.token/messages/message.id"
        case let .deleteOriginalInteractionResponse(applicationId, interactionToken):
            let applicationId = encoded(applicationId)
            let interactionToken = encoded(interactionToken)
            suffix = "webhooks/application.id/interaction.token/messages/@original"
        case let .inviteResolve(code):
            let code = encoded(code)
            suffix = "invites/\(code)"
        case let .listChannelInvites(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/invites"
        case let .listGuildInvites(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/invites"
        case let .createChannelInvite(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/invites"
        case let .inviteRevoke(code):
            let code = encoded(code)
            suffix = "invites/\(code)"
        case let .getGuildMember(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .getMyGuildMember(guildId):
            let guildId = encoded(guildId)
            suffix = "users/@me/guilds/\(guildId)/member"
        case let .listGuildMembers(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/members"
        case let .searchGuildMembers(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/members/search"
        case let .addGuildMember(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .updateGuildMember(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .updateMyGuildMember(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/members/@me"
        case let .deleteGuildMember(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .getMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            let emojiName = encoded(emojiName)
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .listMessages(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/messages"
        case let .addMyMessageReaction(channelId, messageId, emojiName):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            let emojiName = encoded(emojiName)
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .bulkDeleteMessages(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/messages/bulk-delete"
        case let .createMessage(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/messages"
        case let .crosspostMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)/crosspost"
        case let .updateMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteAllMessageReactions(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions"
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            let emojiName = encoded(emojiName)
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .deleteMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteMyMessageReaction(channelId, messageId, emojiName):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            let emojiName = encoded(emojiName)
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            let emojiName = encoded(emojiName)
            let userId = encoded(userId)
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/\(userId)"
        case .getMyOauth2Application:
            suffix = "oauth2/applications/@me"
        case let .listGuildRoles(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/roles"
        case let .addGuildMemberRole(guildId, userId, roleId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            let roleId = encoded(roleId)
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .createGuildRole(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/roles"
        case let .bulkUpdateGuildRoles(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/roles"
        case let .updateGuildRole(guildId, roleId):
            let guildId = encoded(guildId)
            let roleId = encoded(roleId)
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .deleteGuildMemberRole(guildId, userId, roleId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            let roleId = encoded(roleId)
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .deleteGuildRole(guildId, roleId):
            let guildId = encoded(guildId)
            let roleId = encoded(roleId)
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .getApplicationRoleConnectionsMetadata(applicationId):
            let applicationId = encoded(applicationId)
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .getApplicationUserRoleConnection(applicationId):
            let applicationId = encoded(applicationId)
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .updateApplicationRoleConnectionsMetadata(applicationId):
            let applicationId = encoded(applicationId)
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .updateApplicationUserRoleConnection(applicationId):
            let applicationId = encoded(applicationId)
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
            let guildId = encoded(guildId)
            let guildScheduledEventId = encoded(guildScheduledEventId)
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            let guildId = encoded(guildId)
            let guildScheduledEventId = encoded(guildScheduledEventId)
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)/users"
        case let .listGuildScheduledEvents(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .createGuildScheduledEvent(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .updateGuildScheduledEvent(guildId, guildScheduledEventId):
            let guildId = encoded(guildId)
            let guildScheduledEventId = encoded(guildScheduledEventId)
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .deleteGuildScheduledEvent(guildId, guildScheduledEventId):
            let guildId = encoded(guildId)
            let guildScheduledEventId = encoded(guildScheduledEventId)
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .getStageInstance(channelId):
            let channelId = encoded(channelId)
            suffix = "stage-instances/\(channelId)"
        case .createStageInstance:
            suffix = "stage-instances"
        case let .updateStageInstance(channelId):
            let channelId = encoded(channelId)
            suffix = "stage-instances/\(channelId)"
        case let .deleteStageInstance(channelId):
            let channelId = encoded(channelId)
            suffix = "stage-instances/\(channelId)"
        case let .getGuildSticker(guildId, stickerId):
            let guildId = encoded(guildId)
            let stickerId = encoded(stickerId)
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .getSticker(stickerId):
            let stickerId = encoded(stickerId)
            suffix = "stickers/\(stickerId)"
        case let .listGuildStickers(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/stickers"
        case .listStickerPacks:
            suffix = "sticker-packs"
        case let .createGuildSticker(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/stickers"
        case let .updateGuildSticker(guildId, stickerId):
            let guildId = encoded(guildId)
            let stickerId = encoded(stickerId)
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .deleteGuildSticker(guildId, stickerId):
            let guildId = encoded(guildId)
            let stickerId = encoded(stickerId)
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .getActiveGuildThreads(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/threads/active"
        case let .getThreadMember(channelId, userId):
            let channelId = encoded(channelId)
            let userId = encoded(userId)
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .listMyPrivateArchivedThreads(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/users/@me/threads/archived/private"
        case let .listPrivateArchivedThreads(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/threads/archived/private"
        case let .listPublicArchivedThreads(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/threads/archived/public"
        case let .listThreadMembers(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/thread-members"
        case let .addThreadMember(channelId, userId):
            let channelId = encoded(channelId)
            let userId = encoded(userId)
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .joinThread(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/thread-members/@me"
        case let .createThread(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/threads"
        case let .createThreadFromMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)/threads"
        case let .deleteThreadMember(channelId, userId):
            let channelId = encoded(channelId)
            let userId = encoded(userId)
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .leaveThread(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/thread-members/@me"
        case .getMyUser:
            suffix = "users/@me"
        case let .getUser(userId):
            let userId = encoded(userId)
            suffix = "users/\(userId)"
        case .listMyConnections:
            suffix = "users/@me/connections"
        case .updateMyUser:
            suffix = "users/@me"
        case let .listGuildVoiceRegions(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/regions"
        case .listVoiceRegions:
            suffix = "voice/regions"
        case let .updateSelfVoiceState(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/voice-states/@me"
        case let .updateVoiceState(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/voice-states/\(userId)"
        case let .getGuildWebhooks(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/webhooks"
        case let .getWebhook(webhookId):
            let webhookId = encoded(webhookId)
            suffix = "webhooks/\(webhookId)"
        case let .getWebhookByToken(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            let messageId = encoded(messageId)
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .listChannelWebhooks(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/webhooks"
        case let .createWebhook(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/webhooks"
        case let .executeWebhook(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .updateWebhook(webhookId):
            let webhookId = encoded(webhookId)
            suffix = "webhooks/\(webhookId)"
        case let .updateWebhookByToken(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .updateWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            let messageId = encoded(messageId)
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .deleteWebhook(webhookId):
            let webhookId = encoded(webhookId)
            suffix = "webhooks/\(webhookId)"
        case let .deleteWebhookByToken(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            let messageId = encoded(messageId)
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .deleteWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        }
        return urlPrefix + suffix
    }

    public var urlDescription: String {
        let suffix: String
        switch self {
        case let .getAutoModerationRule(guildId, ruleId):
            let guildId = guildId.urlPathEncoded()
            let ruleId = ruleId.urlPathEncoded()
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .listAutoModerationRules(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/auto-moderation/rules"
        case let .createAutoModerationRule(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/auto-moderation/rules"
        case let .updateAutoModerationRule(guildId, ruleId):
            let guildId = guildId.urlPathEncoded()
            let ruleId = ruleId.urlPathEncoded()
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .deleteAutoModerationRule(guildId, ruleId):
            let guildId = guildId.urlPathEncoded()
            let ruleId = ruleId.urlPathEncoded()
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .listGuildAuditLogEntries(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/audit-logs"
        case let .getChannel(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)"
        case let .listGuildChannels(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/channels"
        case let .listPinnedMessages(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/pins"
        case let .addGroupDmUser(channelId, userId):
            let channelId = channelId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .pinMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .setChannelPermissionOverwrite(channelId, overwriteId):
            let channelId = channelId.urlPathEncoded()
            let overwriteId = overwriteId.urlPathEncoded()
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case .createDm:
            suffix = "users/@me/channels"
        case let .createGuildChannel(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/channels"
        case let .followChannel(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/followers"
        case let .triggerTypingIndicator(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/typing"
        case let .bulkUpdateGuildChannels(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/channels"
        case let .updateChannel(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)"
        case let .deleteChannel(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)"
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            let channelId = channelId.urlPathEncoded()
            let overwriteId = overwriteId.urlPathEncoded()
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case let .deleteGroupDmUser(channelId, userId):
            let channelId = channelId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .unpinMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .getApplicationCommand(applicationId, commandId):
            let applicationId = applicationId.urlPathEncoded()
            let commandId = commandId.urlPathEncoded()
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            let commandId = commandId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            let commandId = commandId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .listApplicationCommands(applicationId):
            let applicationId = applicationId.urlPathEncoded()
            suffix = "applications/\(applicationId)/commands"
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
        case let .listGuildApplicationCommands(applicationId, guildId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .bulkSetApplicationCommands(applicationId):
            let applicationId = applicationId.urlPathEncoded()
            suffix = "applications/\(applicationId)/commands"
        case let .bulkSetGuildApplicationCommands(applicationId, guildId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .setGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            let commandId = commandId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .createApplicationCommand(applicationId):
            let applicationId = applicationId.urlPathEncoded()
            suffix = "applications/\(applicationId)/commands"
        case let .createGuildApplicationCommand(applicationId, guildId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .updateApplicationCommand(applicationId, commandId):
            let applicationId = applicationId.urlPathEncoded()
            let commandId = commandId.urlPathEncoded()
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .updateGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            let commandId = commandId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .deleteApplicationCommand(applicationId, commandId):
            let applicationId = applicationId.urlPathEncoded()
            let commandId = commandId.urlPathEncoded()
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .deleteGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            let commandId = commandId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .getGuildEmoji(guildId, emojiId):
            let guildId = guildId.urlPathEncoded()
            let emojiId = emojiId.urlPathEncoded()
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case let .listGuildEmojis(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/emojis"
        case let .createGuildEmoji(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/emojis"
        case let .updateGuildEmoji(guildId, emojiId):
            let guildId = guildId.urlPathEncoded()
            let emojiId = emojiId.urlPathEncoded()
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case let .deleteGuildEmoji(guildId, emojiId):
            let guildId = guildId.urlPathEncoded()
            let emojiId = emojiId.urlPathEncoded()
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case .getBotGateway:
            suffix = "gateway/bot"
        case .getGateway:
            suffix = "gateway"
        case let .getGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)"
        case let .getGuildBan(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildPreview(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/preview"
        case let .getGuildVanityUrl(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/vanity-url"
        case let .getGuildWelcomeScreen(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .getGuildWidget(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/widget.json"
        case let .getGuildWidgetPng(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/widget.png"
        case let .getGuildWidgetSettings(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/widget"
        case let .listGuildBans(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/bans"
        case let .listGuildIntegrations(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/integrations"
        case .listMyGuilds:
            suffix = "users/@me/guilds"
        case let .previewPruneGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/prune"
        case let .banUserFromGuild(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case .createGuild:
            suffix = "guilds"
        case let .pruneGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/prune"
        case let .setGuildMfaLevel(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/mfa"
        case let .updateGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)"
        case let .updateGuildWelcomeScreen(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .updateGuildWidgetSettings(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/widget"
        case let .deleteGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)"
        case let .deleteGuildIntegration(guildId, integrationId):
            let guildId = guildId.urlPathEncoded()
            let integrationId = integrationId.urlPathEncoded()
            suffix = "guilds/\(guildId)/integrations/\(integrationId)"
        case let .leaveGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "users/@me/guilds/\(guildId)"
        case let .unbanUserFromGuild(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildTemplate(code):
            let code = code.urlPathEncoded()
            suffix = "guilds/templates/\(code)"
        case let .listGuildTemplates(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/templates"
        case let .syncGuildTemplate(guildId, code):
            let guildId = guildId.urlPathEncoded()
            let code = code.urlPathEncoded()
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .createGuildFromTemplate(code):
            let code = code.urlPathEncoded()
            suffix = "guilds/templates/\(code)"
        case let .createGuildTemplate(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/templates"
        case let .updateGuildTemplate(guildId, code):
            let guildId = guildId.urlPathEncoded()
            let code = code.urlPathEncoded()
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .deleteGuildTemplate(guildId, code):
            let guildId = guildId.urlPathEncoded()
            let code = code.urlPathEncoded()
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .getFollowupMessage(applicationId, interactionToken, messageId):
            let applicationId = applicationId.urlPathEncoded()
            let interactionToken = interactionToken.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "webhooks/application.id/interaction.token/messages/message.id"
        case let .getOriginalInteractionResponse(applicationId, interactionToken):
            let applicationId = applicationId.urlPathEncoded()
            let interactionToken = interactionToken.urlPathEncoded()
            suffix = "webhooks/application.id/interaction.token/messages/@original"
        case let .createFollowupMessage(applicationId, interactionToken):
            let applicationId = applicationId.urlPathEncoded()
            let interactionToken = interactionToken.urlPathEncoded()
            suffix = "webhooks/application.id/interaction.token"
        case let .createInteractionResponse(interactionId, interactionToken):
            let interactionId = interactionId.urlPathEncoded()
            let interactionToken = interactionToken.urlPathEncoded()
            suffix = "interactions/\(interactionId)/\(interactionToken)/callback"
        case let .updateFollowupMessage(applicationId, interactionToken, messageId):
            let applicationId = applicationId.urlPathEncoded()
            let interactionToken = interactionToken.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "webhooks/application.id/interaction.token/messages/message.id"
        case let .updateOriginalInteractionResponse(applicationId, interactionToken):
            let applicationId = applicationId.urlPathEncoded()
            let interactionToken = interactionToken.urlPathEncoded()
            suffix = "webhooks/application.id/interaction.token/messages/@original"
        case let .deleteFollowupMessage(applicationId, interactionToken, messageId):
            let applicationId = applicationId.urlPathEncoded()
            let interactionToken = interactionToken.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "webhooks/application.id/interaction.token/messages/message.id"
        case let .deleteOriginalInteractionResponse(applicationId, interactionToken):
            let applicationId = applicationId.urlPathEncoded()
            let interactionToken = interactionToken.urlPathEncoded()
            suffix = "webhooks/application.id/interaction.token/messages/@original"
        case let .inviteResolve(code):
            let code = code.urlPathEncoded()
            suffix = "invites/\(code)"
        case let .listChannelInvites(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/invites"
        case let .listGuildInvites(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/invites"
        case let .createChannelInvite(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/invites"
        case let .inviteRevoke(code):
            let code = code.urlPathEncoded()
            suffix = "invites/\(code)"
        case let .getGuildMember(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .getMyGuildMember(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "users/@me/guilds/\(guildId)/member"
        case let .listGuildMembers(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members"
        case let .searchGuildMembers(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members/search"
        case let .addGuildMember(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .updateGuildMember(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .updateMyGuildMember(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members/@me"
        case let .deleteGuildMember(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .getMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .listMessages(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages"
        case let .addMyMessageReaction(channelId, messageId, emojiName):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .bulkDeleteMessages(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/bulk-delete"
        case let .createMessage(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages"
        case let .crosspostMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/crosspost"
        case let .updateMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteAllMessageReactions(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions"
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .deleteMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteMyMessageReaction(channelId, messageId, emojiName):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            let emojiName = emojiName.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/\(userId)"
        case .getMyOauth2Application:
            suffix = "oauth2/applications/@me"
        case let .listGuildRoles(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/roles"
        case let .addGuildMemberRole(guildId, userId, roleId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            let roleId = roleId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .createGuildRole(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/roles"
        case let .bulkUpdateGuildRoles(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/roles"
        case let .updateGuildRole(guildId, roleId):
            let guildId = guildId.urlPathEncoded()
            let roleId = roleId.urlPathEncoded()
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .deleteGuildMemberRole(guildId, userId, roleId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            let roleId = roleId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .deleteGuildRole(guildId, roleId):
            let guildId = guildId.urlPathEncoded()
            let roleId = roleId.urlPathEncoded()
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .getApplicationRoleConnectionsMetadata(applicationId):
            let applicationId = applicationId.urlPathEncoded()
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .getApplicationUserRoleConnection(applicationId):
            let applicationId = applicationId.urlPathEncoded()
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .updateApplicationRoleConnectionsMetadata(applicationId):
            let applicationId = applicationId.urlPathEncoded()
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .updateApplicationUserRoleConnection(applicationId):
            let applicationId = applicationId.urlPathEncoded()
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
            let guildId = guildId.urlPathEncoded()
            let guildScheduledEventId = guildScheduledEventId.urlPathEncoded()
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            let guildId = guildId.urlPathEncoded()
            let guildScheduledEventId = guildScheduledEventId.urlPathEncoded()
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)/users"
        case let .listGuildScheduledEvents(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .createGuildScheduledEvent(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .updateGuildScheduledEvent(guildId, guildScheduledEventId):
            let guildId = guildId.urlPathEncoded()
            let guildScheduledEventId = guildScheduledEventId.urlPathEncoded()
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .deleteGuildScheduledEvent(guildId, guildScheduledEventId):
            let guildId = guildId.urlPathEncoded()
            let guildScheduledEventId = guildScheduledEventId.urlPathEncoded()
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .getStageInstance(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "stage-instances/\(channelId)"
        case .createStageInstance:
            suffix = "stage-instances"
        case let .updateStageInstance(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "stage-instances/\(channelId)"
        case let .deleteStageInstance(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "stage-instances/\(channelId)"
        case let .getGuildSticker(guildId, stickerId):
            let guildId = guildId.urlPathEncoded()
            let stickerId = stickerId.urlPathEncoded()
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .getSticker(stickerId):
            let stickerId = stickerId.urlPathEncoded()
            suffix = "stickers/\(stickerId)"
        case let .listGuildStickers(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/stickers"
        case .listStickerPacks:
            suffix = "sticker-packs"
        case let .createGuildSticker(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/stickers"
        case let .updateGuildSticker(guildId, stickerId):
            let guildId = guildId.urlPathEncoded()
            let stickerId = stickerId.urlPathEncoded()
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .deleteGuildSticker(guildId, stickerId):
            let guildId = guildId.urlPathEncoded()
            let stickerId = stickerId.urlPathEncoded()
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .getActiveGuildThreads(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/threads/active"
        case let .getThreadMember(channelId, userId):
            let channelId = channelId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .listMyPrivateArchivedThreads(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/users/@me/threads/archived/private"
        case let .listPrivateArchivedThreads(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/threads/archived/private"
        case let .listPublicArchivedThreads(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/threads/archived/public"
        case let .listThreadMembers(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/thread-members"
        case let .addThreadMember(channelId, userId):
            let channelId = channelId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .joinThread(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/thread-members/@me"
        case let .createThread(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/threads"
        case let .createThreadFromMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/threads"
        case let .deleteThreadMember(channelId, userId):
            let channelId = channelId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .leaveThread(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/thread-members/@me"
        case .getMyUser:
            suffix = "users/@me"
        case let .getUser(userId):
            let userId = userId.urlPathEncoded()
            suffix = "users/\(userId)"
        case .listMyConnections:
            suffix = "users/@me/connections"
        case .updateMyUser:
            suffix = "users/@me"
        case let .listGuildVoiceRegions(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/regions"
        case .listVoiceRegions:
            suffix = "voice/regions"
        case let .updateSelfVoiceState(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/voice-states/@me"
        case let .updateVoiceState(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/voice-states/\(userId)"
        case let .getGuildWebhooks(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/webhooks"
        case let .getWebhook(webhookId):
            let webhookId = webhookId.urlPathEncoded()
            suffix = "webhooks/\(webhookId)"
        case let .getWebhookByToken(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            let messageId = messageId.urlPathEncoded()
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .listChannelWebhooks(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/webhooks"
        case let .createWebhook(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/webhooks"
        case let .executeWebhook(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .updateWebhook(webhookId):
            let webhookId = webhookId.urlPathEncoded()
            suffix = "webhooks/\(webhookId)"
        case let .updateWebhookByToken(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .updateWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            let messageId = messageId.urlPathEncoded()
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .deleteWebhook(webhookId):
            let webhookId = webhookId.urlPathEncoded()
            suffix = "webhooks/\(webhookId)"
        case let .deleteWebhookByToken(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            let messageId = messageId.urlPathEncoded()
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .deleteWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        }
        return urlPrefix + suffix
    }

    public var httpMethod: HTTPMethod {
        switch self {
        case .getAutoModerationRule: return .GET
        case .listAutoModerationRules: return .GET
        case .createAutoModerationRule: return .POST
        case .updateAutoModerationRule: return .PATCH
        case .deleteAutoModerationRule: return .DELETE
        case .listGuildAuditLogEntries: return .GET
        case .getChannel: return .GET
        case .listGuildChannels: return .GET
        case .listPinnedMessages: return .GET
        case .addGroupDmUser: return .PUT
        case .pinMessage: return .PUT
        case .setChannelPermissionOverwrite: return .PUT
        case .createDm: return .POST
        case .createGuildChannel: return .POST
        case .followChannel: return .POST
        case .triggerTypingIndicator: return .POST
        case .bulkUpdateGuildChannels: return .PATCH
        case .updateChannel: return .PATCH
        case .deleteChannel: return .DELETE
        case .deleteChannelPermissionOverwrite: return .DELETE
        case .deleteGroupDmUser: return .DELETE
        case .unpinMessage: return .DELETE
        case .getApplicationCommand: return .GET
        case .getGuildApplicationCommand: return .GET
        case .getGuildApplicationCommandPermissions: return .GET
        case .listApplicationCommands: return .GET
        case .listGuildApplicationCommandPermissions: return .GET
        case .listGuildApplicationCommands: return .GET
        case .bulkSetApplicationCommands: return .PUT
        case .bulkSetGuildApplicationCommands: return .PUT
        case .setGuildApplicationCommandPermissions: return .PUT
        case .createApplicationCommand: return .POST
        case .createGuildApplicationCommand: return .POST
        case .updateApplicationCommand: return .PATCH
        case .updateGuildApplicationCommand: return .PATCH
        case .deleteApplicationCommand: return .DELETE
        case .deleteGuildApplicationCommand: return .DELETE
        case .getGuildEmoji: return .GET
        case .listGuildEmojis: return .GET
        case .createGuildEmoji: return .POST
        case .updateGuildEmoji: return .PATCH
        case .deleteGuildEmoji: return .DELETE
        case .getBotGateway: return .GET
        case .getGateway: return .GET
        case .getGuild: return .GET
        case .getGuildBan: return .GET
        case .getGuildPreview: return .GET
        case .getGuildVanityUrl: return .GET
        case .getGuildWelcomeScreen: return .GET
        case .getGuildWidget: return .GET
        case .getGuildWidgetPng: return .GET
        case .getGuildWidgetSettings: return .GET
        case .listGuildBans: return .GET
        case .listGuildIntegrations: return .GET
        case .listMyGuilds: return .GET
        case .previewPruneGuild: return .GET
        case .banUserFromGuild: return .PUT
        case .createGuild: return .POST
        case .pruneGuild: return .POST
        case .setGuildMfaLevel: return .POST
        case .updateGuild: return .PATCH
        case .updateGuildWelcomeScreen: return .PATCH
        case .updateGuildWidgetSettings: return .PATCH
        case .deleteGuild: return .DELETE
        case .deleteGuildIntegration: return .DELETE
        case .leaveGuild: return .DELETE
        case .unbanUserFromGuild: return .DELETE
        case .getGuildTemplate: return .GET
        case .listGuildTemplates: return .GET
        case .syncGuildTemplate: return .PUT
        case .createGuildFromTemplate: return .POST
        case .createGuildTemplate: return .POST
        case .updateGuildTemplate: return .PATCH
        case .deleteGuildTemplate: return .DELETE
        case .getFollowupMessage: return .GET
        case .getOriginalInteractionResponse: return .GET
        case .createFollowupMessage: return .POST
        case .createInteractionResponse: return .POST
        case .updateFollowupMessage: return .PATCH
        case .updateOriginalInteractionResponse: return .PATCH
        case .deleteFollowupMessage: return .DELETE
        case .deleteOriginalInteractionResponse: return .DELETE
        case .inviteResolve: return .GET
        case .listChannelInvites: return .GET
        case .listGuildInvites: return .GET
        case .createChannelInvite: return .POST
        case .inviteRevoke: return .DELETE
        case .getGuildMember: return .GET
        case .getMyGuildMember: return .GET
        case .listGuildMembers: return .GET
        case .searchGuildMembers: return .GET
        case .addGuildMember: return .PUT
        case .updateGuildMember: return .PATCH
        case .updateMyGuildMember: return .PATCH
        case .deleteGuildMember: return .DELETE
        case .getMessage: return .GET
        case .listMessageReactionsByEmoji: return .GET
        case .listMessages: return .GET
        case .addMyMessageReaction: return .PUT
        case .bulkDeleteMessages: return .POST
        case .createMessage: return .POST
        case .crosspostMessage: return .POST
        case .updateMessage: return .PATCH
        case .deleteAllMessageReactions: return .DELETE
        case .deleteAllMessageReactionsByEmoji: return .DELETE
        case .deleteMessage: return .DELETE
        case .deleteMyMessageReaction: return .DELETE
        case .deleteUserMessageReaction: return .DELETE
        case .getMyOauth2Application: return .GET
        case .listGuildRoles: return .GET
        case .addGuildMemberRole: return .PUT
        case .createGuildRole: return .POST
        case .bulkUpdateGuildRoles: return .PATCH
        case .updateGuildRole: return .PATCH
        case .deleteGuildMemberRole: return .DELETE
        case .deleteGuildRole: return .DELETE
        case .getApplicationRoleConnectionsMetadata: return .GET
        case .getApplicationUserRoleConnection: return .GET
        case .updateApplicationRoleConnectionsMetadata: return .PUT
        case .updateApplicationUserRoleConnection: return .PUT
        case .getGuildScheduledEvent: return .GET
        case .listGuildScheduledEventUsers: return .GET
        case .listGuildScheduledEvents: return .GET
        case .createGuildScheduledEvent: return .POST
        case .updateGuildScheduledEvent: return .PATCH
        case .deleteGuildScheduledEvent: return .DELETE
        case .getStageInstance: return .GET
        case .createStageInstance: return .POST
        case .updateStageInstance: return .PATCH
        case .deleteStageInstance: return .DELETE
        case .getGuildSticker: return .GET
        case .getSticker: return .GET
        case .listGuildStickers: return .GET
        case .listStickerPacks: return .GET
        case .createGuildSticker: return .POST
        case .updateGuildSticker: return .PATCH
        case .deleteGuildSticker: return .DELETE
        case .getActiveGuildThreads: return .GET
        case .getThreadMember: return .GET
        case .listMyPrivateArchivedThreads: return .GET
        case .listPrivateArchivedThreads: return .GET
        case .listPublicArchivedThreads: return .GET
        case .listThreadMembers: return .GET
        case .addThreadMember: return .PUT
        case .joinThread: return .PUT
        case .createThread: return .POST
        case .createThreadFromMessage: return .POST
        case .deleteThreadMember: return .DELETE
        case .leaveThread: return .DELETE
        case .getMyUser: return .GET
        case .getUser: return .GET
        case .listMyConnections: return .GET
        case .updateMyUser: return .PATCH
        case .listGuildVoiceRegions: return .GET
        case .listVoiceRegions: return .GET
        case .updateSelfVoiceState: return .PATCH
        case .updateVoiceState: return .PATCH
        case .getGuildWebhooks: return .GET
        case .getWebhook: return .GET
        case .getWebhookByToken: return .GET
        case .getWebhookMessage: return .GET
        case .getWebhooksMessagesOriginal: return .GET
        case .listChannelWebhooks: return .GET
        case .createWebhook: return .POST
        case .executeWebhook: return .POST
        case .patchWebhooksMessagesOriginal: return .PATCH
        case .updateWebhook: return .PATCH
        case .updateWebhookByToken: return .PATCH
        case .updateWebhookMessage: return .PATCH
        case .deleteWebhook: return .DELETE
        case .deleteWebhookByToken: return .DELETE
        case .deleteWebhookMessage: return .DELETE
        case .deleteWebhooksMessagesOriginal: return .DELETE
        }
    }

    public var countsAgainstGlobalRateLimit: Bool {
        switch self {
        case .getAutoModerationRule: return false
        case .listAutoModerationRules: return false
        case .createAutoModerationRule: return false
        case .updateAutoModerationRule: return false
        case .deleteAutoModerationRule: return false
        case .listGuildAuditLogEntries: return false
        case .getChannel: return false
        case .listGuildChannels: return false
        case .listPinnedMessages: return false
        case .addGroupDmUser: return false
        case .pinMessage: return false
        case .setChannelPermissionOverwrite: return false
        case .createDm: return false
        case .createGuildChannel: return false
        case .followChannel: return false
        case .triggerTypingIndicator: return false
        case .bulkUpdateGuildChannels: return false
        case .updateChannel: return false
        case .deleteChannel: return false
        case .deleteChannelPermissionOverwrite: return false
        case .deleteGroupDmUser: return false
        case .unpinMessage: return false
        case .getApplicationCommand: return false
        case .getGuildApplicationCommand: return false
        case .getGuildApplicationCommandPermissions: return false
        case .listApplicationCommands: return false
        case .listGuildApplicationCommandPermissions: return false
        case .listGuildApplicationCommands: return false
        case .bulkSetApplicationCommands: return false
        case .bulkSetGuildApplicationCommands: return false
        case .setGuildApplicationCommandPermissions: return false
        case .createApplicationCommand: return false
        case .createGuildApplicationCommand: return false
        case .updateApplicationCommand: return false
        case .updateGuildApplicationCommand: return false
        case .deleteApplicationCommand: return false
        case .deleteGuildApplicationCommand: return false
        case .getGuildEmoji: return false
        case .listGuildEmojis: return false
        case .createGuildEmoji: return false
        case .updateGuildEmoji: return false
        case .deleteGuildEmoji: return false
        case .getBotGateway: return false
        case .getGateway: return false
        case .getGuild: return false
        case .getGuildBan: return false
        case .getGuildPreview: return false
        case .getGuildVanityUrl: return false
        case .getGuildWelcomeScreen: return false
        case .getGuildWidget: return false
        case .getGuildWidgetPng: return false
        case .getGuildWidgetSettings: return false
        case .listGuildBans: return false
        case .listGuildIntegrations: return false
        case .listMyGuilds: return false
        case .previewPruneGuild: return false
        case .banUserFromGuild: return false
        case .createGuild: return false
        case .pruneGuild: return false
        case .setGuildMfaLevel: return false
        case .updateGuild: return false
        case .updateGuildWelcomeScreen: return false
        case .updateGuildWidgetSettings: return false
        case .deleteGuild: return false
        case .deleteGuildIntegration: return false
        case .leaveGuild: return false
        case .unbanUserFromGuild: return false
        case .getGuildTemplate: return false
        case .listGuildTemplates: return false
        case .syncGuildTemplate: return false
        case .createGuildFromTemplate: return false
        case .createGuildTemplate: return false
        case .updateGuildTemplate: return false
        case .deleteGuildTemplate: return false
        case .getFollowupMessage: return true
        case .getOriginalInteractionResponse: return true
        case .createFollowupMessage: return true
        case .createInteractionResponse: return true
        case .updateFollowupMessage: return true
        case .updateOriginalInteractionResponse: return true
        case .deleteFollowupMessage: return true
        case .deleteOriginalInteractionResponse: return true
        case .inviteResolve: return false
        case .listChannelInvites: return false
        case .listGuildInvites: return false
        case .createChannelInvite: return false
        case .inviteRevoke: return false
        case .getGuildMember: return false
        case .getMyGuildMember: return false
        case .listGuildMembers: return false
        case .searchGuildMembers: return false
        case .addGuildMember: return false
        case .updateGuildMember: return false
        case .updateMyGuildMember: return false
        case .deleteGuildMember: return false
        case .getMessage: return false
        case .listMessageReactionsByEmoji: return false
        case .listMessages: return false
        case .addMyMessageReaction: return false
        case .bulkDeleteMessages: return false
        case .createMessage: return false
        case .crosspostMessage: return false
        case .updateMessage: return false
        case .deleteAllMessageReactions: return false
        case .deleteAllMessageReactionsByEmoji: return false
        case .deleteMessage: return false
        case .deleteMyMessageReaction: return false
        case .deleteUserMessageReaction: return false
        case .getMyOauth2Application: return false
        case .listGuildRoles: return false
        case .addGuildMemberRole: return false
        case .createGuildRole: return false
        case .bulkUpdateGuildRoles: return false
        case .updateGuildRole: return false
        case .deleteGuildMemberRole: return false
        case .deleteGuildRole: return false
        case .getApplicationRoleConnectionsMetadata: return false
        case .getApplicationUserRoleConnection: return false
        case .updateApplicationRoleConnectionsMetadata: return false
        case .updateApplicationUserRoleConnection: return false
        case .getGuildScheduledEvent: return false
        case .listGuildScheduledEventUsers: return false
        case .listGuildScheduledEvents: return false
        case .createGuildScheduledEvent: return false
        case .updateGuildScheduledEvent: return false
        case .deleteGuildScheduledEvent: return false
        case .getStageInstance: return false
        case .createStageInstance: return false
        case .updateStageInstance: return false
        case .deleteStageInstance: return false
        case .getGuildSticker: return false
        case .getSticker: return false
        case .listGuildStickers: return false
        case .listStickerPacks: return false
        case .createGuildSticker: return false
        case .updateGuildSticker: return false
        case .deleteGuildSticker: return false
        case .getActiveGuildThreads: return false
        case .getThreadMember: return false
        case .listMyPrivateArchivedThreads: return false
        case .listPrivateArchivedThreads: return false
        case .listPublicArchivedThreads: return false
        case .listThreadMembers: return false
        case .addThreadMember: return false
        case .joinThread: return false
        case .createThread: return false
        case .createThreadFromMessage: return false
        case .deleteThreadMember: return false
        case .leaveThread: return false
        case .getMyUser: return false
        case .getUser: return false
        case .listMyConnections: return false
        case .updateMyUser: return false
        case .listGuildVoiceRegions: return false
        case .listVoiceRegions: return false
        case .updateSelfVoiceState: return false
        case .updateVoiceState: return false
        case .getGuildWebhooks: return false
        case .getWebhook: return false
        case .getWebhookByToken: return false
        case .getWebhookMessage: return false
        case .getWebhooksMessagesOriginal: return false
        case .listChannelWebhooks: return false
        case .createWebhook: return false
        case .executeWebhook: return false
        case .patchWebhooksMessagesOriginal: return false
        case .updateWebhook: return false
        case .updateWebhookByToken: return false
        case .updateWebhookMessage: return false
        case .deleteWebhook: return false
        case .deleteWebhookByToken: return false
        case .deleteWebhookMessage: return false
        case .deleteWebhooksMessagesOriginal: return false
        }
    }

    public var requiresAuthorizationHeader: Bool {
        switch self {
        case .getAutoModerationRule: return false
        case .listAutoModerationRules: return false
        case .createAutoModerationRule: return false
        case .updateAutoModerationRule: return false
        case .deleteAutoModerationRule: return false
        case .listGuildAuditLogEntries: return false
        case .getChannel: return false
        case .listGuildChannels: return false
        case .listPinnedMessages: return false
        case .addGroupDmUser: return false
        case .pinMessage: return false
        case .setChannelPermissionOverwrite: return false
        case .createDm: return false
        case .createGuildChannel: return false
        case .followChannel: return false
        case .triggerTypingIndicator: return false
        case .bulkUpdateGuildChannels: return false
        case .updateChannel: return false
        case .deleteChannel: return false
        case .deleteChannelPermissionOverwrite: return false
        case .deleteGroupDmUser: return false
        case .unpinMessage: return false
        case .getApplicationCommand: return false
        case .getGuildApplicationCommand: return false
        case .getGuildApplicationCommandPermissions: return false
        case .listApplicationCommands: return false
        case .listGuildApplicationCommandPermissions: return false
        case .listGuildApplicationCommands: return false
        case .bulkSetApplicationCommands: return false
        case .bulkSetGuildApplicationCommands: return false
        case .setGuildApplicationCommandPermissions: return false
        case .createApplicationCommand: return false
        case .createGuildApplicationCommand: return false
        case .updateApplicationCommand: return false
        case .updateGuildApplicationCommand: return false
        case .deleteApplicationCommand: return false
        case .deleteGuildApplicationCommand: return false
        case .getGuildEmoji: return false
        case .listGuildEmojis: return false
        case .createGuildEmoji: return false
        case .updateGuildEmoji: return false
        case .deleteGuildEmoji: return false
        case .getBotGateway: return false
        case .getGateway: return false
        case .getGuild: return false
        case .getGuildBan: return false
        case .getGuildPreview: return false
        case .getGuildVanityUrl: return false
        case .getGuildWelcomeScreen: return false
        case .getGuildWidget: return false
        case .getGuildWidgetPng: return false
        case .getGuildWidgetSettings: return false
        case .listGuildBans: return false
        case .listGuildIntegrations: return false
        case .listMyGuilds: return false
        case .previewPruneGuild: return false
        case .banUserFromGuild: return false
        case .createGuild: return false
        case .pruneGuild: return false
        case .setGuildMfaLevel: return false
        case .updateGuild: return false
        case .updateGuildWelcomeScreen: return false
        case .updateGuildWidgetSettings: return false
        case .deleteGuild: return false
        case .deleteGuildIntegration: return false
        case .leaveGuild: return false
        case .unbanUserFromGuild: return false
        case .getGuildTemplate: return false
        case .listGuildTemplates: return false
        case .syncGuildTemplate: return false
        case .createGuildFromTemplate: return false
        case .createGuildTemplate: return false
        case .updateGuildTemplate: return false
        case .deleteGuildTemplate: return false
        case .getFollowupMessage: return false
        case .getOriginalInteractionResponse: return false
        case .createFollowupMessage: return false
        case .createInteractionResponse: return false
        case .updateFollowupMessage: return false
        case .updateOriginalInteractionResponse: return false
        case .deleteFollowupMessage: return false
        case .deleteOriginalInteractionResponse: return false
        case .inviteResolve: return false
        case .listChannelInvites: return false
        case .listGuildInvites: return false
        case .createChannelInvite: return false
        case .inviteRevoke: return false
        case .getGuildMember: return false
        case .getMyGuildMember: return false
        case .listGuildMembers: return false
        case .searchGuildMembers: return false
        case .addGuildMember: return false
        case .updateGuildMember: return false
        case .updateMyGuildMember: return false
        case .deleteGuildMember: return false
        case .getMessage: return false
        case .listMessageReactionsByEmoji: return false
        case .listMessages: return false
        case .addMyMessageReaction: return false
        case .bulkDeleteMessages: return false
        case .createMessage: return false
        case .crosspostMessage: return false
        case .updateMessage: return false
        case .deleteAllMessageReactions: return false
        case .deleteAllMessageReactionsByEmoji: return false
        case .deleteMessage: return false
        case .deleteMyMessageReaction: return false
        case .deleteUserMessageReaction: return false
        case .getMyOauth2Application: return false
        case .listGuildRoles: return false
        case .addGuildMemberRole: return false
        case .createGuildRole: return false
        case .bulkUpdateGuildRoles: return false
        case .updateGuildRole: return false
        case .deleteGuildMemberRole: return false
        case .deleteGuildRole: return false
        case .getApplicationRoleConnectionsMetadata: return false
        case .getApplicationUserRoleConnection: return false
        case .updateApplicationRoleConnectionsMetadata: return false
        case .updateApplicationUserRoleConnection: return false
        case .getGuildScheduledEvent: return false
        case .listGuildScheduledEventUsers: return false
        case .listGuildScheduledEvents: return false
        case .createGuildScheduledEvent: return false
        case .updateGuildScheduledEvent: return false
        case .deleteGuildScheduledEvent: return false
        case .getStageInstance: return false
        case .createStageInstance: return false
        case .updateStageInstance: return false
        case .deleteStageInstance: return false
        case .getGuildSticker: return false
        case .getSticker: return false
        case .listGuildStickers: return false
        case .listStickerPacks: return false
        case .createGuildSticker: return false
        case .updateGuildSticker: return false
        case .deleteGuildSticker: return false
        case .getActiveGuildThreads: return false
        case .getThreadMember: return false
        case .listMyPrivateArchivedThreads: return false
        case .listPrivateArchivedThreads: return false
        case .listPublicArchivedThreads: return false
        case .listThreadMembers: return false
        case .addThreadMember: return false
        case .joinThread: return false
        case .createThread: return false
        case .createThreadFromMessage: return false
        case .deleteThreadMember: return false
        case .leaveThread: return false
        case .getMyUser: return false
        case .getUser: return false
        case .listMyConnections: return false
        case .updateMyUser: return false
        case .listGuildVoiceRegions: return false
        case .listVoiceRegions: return false
        case .updateSelfVoiceState: return false
        case .updateVoiceState: return false
        case .getGuildWebhooks: return false
        case .getWebhook: return false
        case .getWebhookByToken: return true
        case .getWebhookMessage: return true
        case .getWebhooksMessagesOriginal: return true
        case .listChannelWebhooks: return false
        case .createWebhook: return false
        case .executeWebhook: return true
        case .patchWebhooksMessagesOriginal: return true
        case .updateWebhook: return false
        case .updateWebhookByToken: return true
        case .updateWebhookMessage: return true
        case .deleteWebhook: return false
        case .deleteWebhookByToken: return true
        case .deleteWebhookMessage: return true
        case .deleteWebhooksMessagesOriginal: return true
        }
    }

    public var parameters: [String] {
        switch self {
        case let .getAutoModerationRule(guildId, ruleId):
            return [guildId, ruleId]
        case let .listAutoModerationRules(guildId):
            return [guildId]
        case let .createAutoModerationRule(guildId):
            return [guildId]
        case let .updateAutoModerationRule(guildId, ruleId):
            return [guildId, ruleId]
        case let .deleteAutoModerationRule(guildId, ruleId):
            return [guildId, ruleId]
        case let .listGuildAuditLogEntries(guildId):
            return [guildId]
        case let .getChannel(channelId):
            return [channelId]
        case let .listGuildChannels(guildId):
            return [guildId]
        case let .listPinnedMessages(channelId):
            return [channelId]
        case let .addGroupDmUser(channelId, userId):
            return [channelId, userId]
        case let .pinMessage(channelId, messageId):
            return [channelId, messageId]
        case let .setChannelPermissionOverwrite(channelId, overwriteId):
            return [channelId, overwriteId]
        case .createDm:
            return []
        case let .createGuildChannel(guildId):
            return [guildId]
        case let .followChannel(channelId):
            return [channelId]
        case let .triggerTypingIndicator(channelId):
            return [channelId]
        case let .bulkUpdateGuildChannels(guildId):
            return [guildId]
        case let .updateChannel(channelId):
            return [channelId]
        case let .deleteChannel(channelId):
            return [channelId]
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            return [channelId, overwriteId]
        case let .deleteGroupDmUser(channelId, userId):
            return [channelId, userId]
        case let .unpinMessage(channelId, messageId):
            return [channelId, messageId]
        case let .getApplicationCommand(applicationId, commandId):
            return [applicationId, commandId]
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            return [applicationId, guildId, commandId]
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            return [applicationId, guildId, commandId]
        case let .listApplicationCommands(applicationId):
            return [applicationId]
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            return [applicationId, guildId]
        case let .listGuildApplicationCommands(applicationId, guildId):
            return [applicationId, guildId]
        case let .bulkSetApplicationCommands(applicationId):
            return [applicationId]
        case let .bulkSetGuildApplicationCommands(applicationId, guildId):
            return [applicationId, guildId]
        case let .setGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            return [applicationId, guildId, commandId]
        case let .createApplicationCommand(applicationId):
            return [applicationId]
        case let .createGuildApplicationCommand(applicationId, guildId):
            return [applicationId, guildId]
        case let .updateApplicationCommand(applicationId, commandId):
            return [applicationId, commandId]
        case let .updateGuildApplicationCommand(applicationId, guildId, commandId):
            return [applicationId, guildId, commandId]
        case let .deleteApplicationCommand(applicationId, commandId):
            return [applicationId, commandId]
        case let .deleteGuildApplicationCommand(applicationId, guildId, commandId):
            return [applicationId, guildId, commandId]
        case let .getGuildEmoji(guildId, emojiId):
            return [guildId, emojiId]
        case let .listGuildEmojis(guildId):
            return [guildId]
        case let .createGuildEmoji(guildId):
            return [guildId]
        case let .updateGuildEmoji(guildId, emojiId):
            return [guildId, emojiId]
        case let .deleteGuildEmoji(guildId, emojiId):
            return [guildId, emojiId]
        case .getBotGateway:
            return []
        case .getGateway:
            return []
        case let .getGuild(guildId):
            return [guildId]
        case let .getGuildBan(guildId, userId):
            return [guildId, userId]
        case let .getGuildPreview(guildId):
            return [guildId]
        case let .getGuildVanityUrl(guildId):
            return [guildId]
        case let .getGuildWelcomeScreen(guildId):
            return [guildId]
        case let .getGuildWidget(guildId):
            return [guildId]
        case let .getGuildWidgetPng(guildId):
            return [guildId]
        case let .getGuildWidgetSettings(guildId):
            return [guildId]
        case let .listGuildBans(guildId):
            return [guildId]
        case let .listGuildIntegrations(guildId):
            return [guildId]
        case .listMyGuilds:
            return []
        case let .previewPruneGuild(guildId):
            return [guildId]
        case let .banUserFromGuild(guildId, userId):
            return [guildId, userId]
        case .createGuild:
            return []
        case let .pruneGuild(guildId):
            return [guildId]
        case let .setGuildMfaLevel(guildId):
            return [guildId]
        case let .updateGuild(guildId):
            return [guildId]
        case let .updateGuildWelcomeScreen(guildId):
            return [guildId]
        case let .updateGuildWidgetSettings(guildId):
            return [guildId]
        case let .deleteGuild(guildId):
            return [guildId]
        case let .deleteGuildIntegration(guildId, integrationId):
            return [guildId, integrationId]
        case let .leaveGuild(guildId):
            return [guildId]
        case let .unbanUserFromGuild(guildId, userId):
            return [guildId, userId]
        case let .getGuildTemplate(code):
            return [code]
        case let .listGuildTemplates(guildId):
            return [guildId]
        case let .syncGuildTemplate(guildId, code):
            return [guildId, code]
        case let .createGuildFromTemplate(code):
            return [code]
        case let .createGuildTemplate(guildId):
            return [guildId]
        case let .updateGuildTemplate(guildId, code):
            return [guildId, code]
        case let .deleteGuildTemplate(guildId, code):
            return [guildId, code]
        case let .getFollowupMessage(applicationId, interactionToken, messageId):
            return [applicationId, interactionToken, messageId]
        case let .getOriginalInteractionResponse(applicationId, interactionToken):
            return [applicationId, interactionToken]
        case let .createFollowupMessage(applicationId, interactionToken):
            return [applicationId, interactionToken]
        case let .createInteractionResponse(interactionId, interactionToken):
            return [interactionId, interactionToken]
        case let .updateFollowupMessage(applicationId, interactionToken, messageId):
            return [applicationId, interactionToken, messageId]
        case let .updateOriginalInteractionResponse(applicationId, interactionToken):
            return [applicationId, interactionToken]
        case let .deleteFollowupMessage(applicationId, interactionToken, messageId):
            return [applicationId, interactionToken, messageId]
        case let .deleteOriginalInteractionResponse(applicationId, interactionToken):
            return [applicationId, interactionToken]
        case let .inviteResolve(code):
            return [code]
        case let .listChannelInvites(channelId):
            return [channelId]
        case let .listGuildInvites(guildId):
            return [guildId]
        case let .createChannelInvite(channelId):
            return [channelId]
        case let .inviteRevoke(code):
            return [code]
        case let .getGuildMember(guildId, userId):
            return [guildId, userId]
        case let .getMyGuildMember(guildId):
            return [guildId]
        case let .listGuildMembers(guildId):
            return [guildId]
        case let .searchGuildMembers(guildId):
            return [guildId]
        case let .addGuildMember(guildId, userId):
            return [guildId, userId]
        case let .updateGuildMember(guildId, userId):
            return [guildId, userId]
        case let .updateMyGuildMember(guildId):
            return [guildId]
        case let .deleteGuildMember(guildId, userId):
            return [guildId, userId]
        case let .getMessage(channelId, messageId):
            return [channelId, messageId]
        case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
            return [channelId, messageId, emojiName]
        case let .listMessages(channelId):
            return [channelId]
        case let .addMyMessageReaction(channelId, messageId, emojiName):
            return [channelId, messageId, emojiName]
        case let .bulkDeleteMessages(channelId):
            return [channelId]
        case let .createMessage(channelId):
            return [channelId]
        case let .crosspostMessage(channelId, messageId):
            return [channelId, messageId]
        case let .updateMessage(channelId, messageId):
            return [channelId, messageId]
        case let .deleteAllMessageReactions(channelId, messageId):
            return [channelId, messageId]
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            return [channelId, messageId, emojiName]
        case let .deleteMessage(channelId, messageId):
            return [channelId, messageId]
        case let .deleteMyMessageReaction(channelId, messageId, emojiName):
            return [channelId, messageId, emojiName]
        case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
            return [channelId, messageId, emojiName, userId]
        case .getMyOauth2Application:
            return []
        case let .listGuildRoles(guildId):
            return [guildId]
        case let .addGuildMemberRole(guildId, userId, roleId):
            return [guildId, userId, roleId]
        case let .createGuildRole(guildId):
            return [guildId]
        case let .bulkUpdateGuildRoles(guildId):
            return [guildId]
        case let .updateGuildRole(guildId, roleId):
            return [guildId, roleId]
        case let .deleteGuildMemberRole(guildId, userId, roleId):
            return [guildId, userId, roleId]
        case let .deleteGuildRole(guildId, roleId):
            return [guildId, roleId]
        case let .getApplicationRoleConnectionsMetadata(applicationId):
            return [applicationId]
        case let .getApplicationUserRoleConnection(applicationId):
            return [applicationId]
        case let .updateApplicationRoleConnectionsMetadata(applicationId):
            return [applicationId]
        case let .updateApplicationUserRoleConnection(applicationId):
            return [applicationId]
        case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
            return [guildId, guildScheduledEventId]
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            return [guildId, guildScheduledEventId]
        case let .listGuildScheduledEvents(guildId):
            return [guildId]
        case let .createGuildScheduledEvent(guildId):
            return [guildId]
        case let .updateGuildScheduledEvent(guildId, guildScheduledEventId):
            return [guildId, guildScheduledEventId]
        case let .deleteGuildScheduledEvent(guildId, guildScheduledEventId):
            return [guildId, guildScheduledEventId]
        case let .getStageInstance(channelId):
            return [channelId]
        case .createStageInstance:
            return []
        case let .updateStageInstance(channelId):
            return [channelId]
        case let .deleteStageInstance(channelId):
            return [channelId]
        case let .getGuildSticker(guildId, stickerId):
            return [guildId, stickerId]
        case let .getSticker(stickerId):
            return [stickerId]
        case let .listGuildStickers(guildId):
            return [guildId]
        case .listStickerPacks:
            return []
        case let .createGuildSticker(guildId):
            return [guildId]
        case let .updateGuildSticker(guildId, stickerId):
            return [guildId, stickerId]
        case let .deleteGuildSticker(guildId, stickerId):
            return [guildId, stickerId]
        case let .getActiveGuildThreads(guildId):
            return [guildId]
        case let .getThreadMember(channelId, userId):
            return [channelId, userId]
        case let .listMyPrivateArchivedThreads(channelId):
            return [channelId]
        case let .listPrivateArchivedThreads(channelId):
            return [channelId]
        case let .listPublicArchivedThreads(channelId):
            return [channelId]
        case let .listThreadMembers(channelId):
            return [channelId]
        case let .addThreadMember(channelId, userId):
            return [channelId, userId]
        case let .joinThread(channelId):
            return [channelId]
        case let .createThread(channelId):
            return [channelId]
        case let .createThreadFromMessage(channelId, messageId):
            return [channelId, messageId]
        case let .deleteThreadMember(channelId, userId):
            return [channelId, userId]
        case let .leaveThread(channelId):
            return [channelId]
        case .getMyUser:
            return []
        case let .getUser(userId):
            return [userId]
        case .listMyConnections:
            return []
        case .updateMyUser:
            return []
        case let .listGuildVoiceRegions(guildId):
            return [guildId]
        case .listVoiceRegions:
            return []
        case let .updateSelfVoiceState(guildId):
            return [guildId]
        case let .updateVoiceState(guildId, userId):
            return [guildId, userId]
        case let .getGuildWebhooks(guildId):
            return [guildId]
        case let .getWebhook(webhookId):
            return [webhookId]
        case let .getWebhookByToken(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            return [webhookId, webhookToken, messageId]
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .listChannelWebhooks(channelId):
            return [channelId]
        case let .createWebhook(channelId):
            return [channelId]
        case let .executeWebhook(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .updateWebhook(webhookId):
            return [webhookId]
        case let .updateWebhookByToken(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .updateWebhookMessage(webhookId, webhookToken, messageId):
            return [webhookId, webhookToken, messageId]
        case let .deleteWebhook(webhookId):
            return [webhookId]
        case let .deleteWebhookByToken(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
            return [webhookId, webhookToken, messageId]
        case let .deleteWebhooksMessagesOriginal(webhookId, webhookToken):
            return [webhookId, webhookToken]
        }
    }

    public var id: Int {
        switch self {
        case .getAutoModerationRule: return 1
        case .listAutoModerationRules: return 2
        case .createAutoModerationRule: return 3
        case .updateAutoModerationRule: return 4
        case .deleteAutoModerationRule: return 5
        case .listGuildAuditLogEntries: return 6
        case .getChannel: return 7
        case .listGuildChannels: return 8
        case .listPinnedMessages: return 9
        case .addGroupDmUser: return 10
        case .pinMessage: return 11
        case .setChannelPermissionOverwrite: return 12
        case .createDm: return 13
        case .createGuildChannel: return 14
        case .followChannel: return 15
        case .triggerTypingIndicator: return 16
        case .bulkUpdateGuildChannels: return 17
        case .updateChannel: return 18
        case .deleteChannel: return 19
        case .deleteChannelPermissionOverwrite: return 20
        case .deleteGroupDmUser: return 21
        case .unpinMessage: return 22
        case .getApplicationCommand: return 23
        case .getGuildApplicationCommand: return 24
        case .getGuildApplicationCommandPermissions: return 25
        case .listApplicationCommands: return 26
        case .listGuildApplicationCommandPermissions: return 27
        case .listGuildApplicationCommands: return 28
        case .bulkSetApplicationCommands: return 29
        case .bulkSetGuildApplicationCommands: return 30
        case .setGuildApplicationCommandPermissions: return 31
        case .createApplicationCommand: return 32
        case .createGuildApplicationCommand: return 33
        case .updateApplicationCommand: return 34
        case .updateGuildApplicationCommand: return 35
        case .deleteApplicationCommand: return 36
        case .deleteGuildApplicationCommand: return 37
        case .getGuildEmoji: return 38
        case .listGuildEmojis: return 39
        case .createGuildEmoji: return 40
        case .updateGuildEmoji: return 41
        case .deleteGuildEmoji: return 42
        case .getBotGateway: return 43
        case .getGateway: return 44
        case .getGuild: return 45
        case .getGuildBan: return 46
        case .getGuildPreview: return 47
        case .getGuildVanityUrl: return 48
        case .getGuildWelcomeScreen: return 49
        case .getGuildWidget: return 50
        case .getGuildWidgetPng: return 51
        case .getGuildWidgetSettings: return 52
        case .listGuildBans: return 53
        case .listGuildIntegrations: return 54
        case .listMyGuilds: return 55
        case .previewPruneGuild: return 56
        case .banUserFromGuild: return 57
        case .createGuild: return 58
        case .pruneGuild: return 59
        case .setGuildMfaLevel: return 60
        case .updateGuild: return 61
        case .updateGuildWelcomeScreen: return 62
        case .updateGuildWidgetSettings: return 63
        case .deleteGuild: return 64
        case .deleteGuildIntegration: return 65
        case .leaveGuild: return 66
        case .unbanUserFromGuild: return 67
        case .getGuildTemplate: return 68
        case .listGuildTemplates: return 69
        case .syncGuildTemplate: return 70
        case .createGuildFromTemplate: return 71
        case .createGuildTemplate: return 72
        case .updateGuildTemplate: return 73
        case .deleteGuildTemplate: return 74
        case .getFollowupMessage: return 75
        case .getOriginalInteractionResponse: return 76
        case .createFollowupMessage: return 77
        case .createInteractionResponse: return 78
        case .updateFollowupMessage: return 79
        case .updateOriginalInteractionResponse: return 80
        case .deleteFollowupMessage: return 81
        case .deleteOriginalInteractionResponse: return 82
        case .inviteResolve: return 83
        case .listChannelInvites: return 84
        case .listGuildInvites: return 85
        case .createChannelInvite: return 86
        case .inviteRevoke: return 87
        case .getGuildMember: return 88
        case .getMyGuildMember: return 89
        case .listGuildMembers: return 90
        case .searchGuildMembers: return 91
        case .addGuildMember: return 92
        case .updateGuildMember: return 93
        case .updateMyGuildMember: return 94
        case .deleteGuildMember: return 95
        case .getMessage: return 96
        case .listMessageReactionsByEmoji: return 97
        case .listMessages: return 98
        case .addMyMessageReaction: return 99
        case .bulkDeleteMessages: return 100
        case .createMessage: return 101
        case .crosspostMessage: return 102
        case .updateMessage: return 103
        case .deleteAllMessageReactions: return 104
        case .deleteAllMessageReactionsByEmoji: return 105
        case .deleteMessage: return 106
        case .deleteMyMessageReaction: return 107
        case .deleteUserMessageReaction: return 108
        case .getMyOauth2Application: return 109
        case .listGuildRoles: return 110
        case .addGuildMemberRole: return 111
        case .createGuildRole: return 112
        case .bulkUpdateGuildRoles: return 113
        case .updateGuildRole: return 114
        case .deleteGuildMemberRole: return 115
        case .deleteGuildRole: return 116
        case .getApplicationRoleConnectionsMetadata: return 117
        case .getApplicationUserRoleConnection: return 118
        case .updateApplicationRoleConnectionsMetadata: return 119
        case .updateApplicationUserRoleConnection: return 120
        case .getGuildScheduledEvent: return 121
        case .listGuildScheduledEventUsers: return 122
        case .listGuildScheduledEvents: return 123
        case .createGuildScheduledEvent: return 124
        case .updateGuildScheduledEvent: return 125
        case .deleteGuildScheduledEvent: return 126
        case .getStageInstance: return 127
        case .createStageInstance: return 128
        case .updateStageInstance: return 129
        case .deleteStageInstance: return 130
        case .getGuildSticker: return 131
        case .getSticker: return 132
        case .listGuildStickers: return 133
        case .listStickerPacks: return 134
        case .createGuildSticker: return 135
        case .updateGuildSticker: return 136
        case .deleteGuildSticker: return 137
        case .getActiveGuildThreads: return 138
        case .getThreadMember: return 139
        case .listMyPrivateArchivedThreads: return 140
        case .listPrivateArchivedThreads: return 141
        case .listPublicArchivedThreads: return 142
        case .listThreadMembers: return 143
        case .addThreadMember: return 144
        case .joinThread: return 145
        case .createThread: return 146
        case .createThreadFromMessage: return 147
        case .deleteThreadMember: return 148
        case .leaveThread: return 149
        case .getMyUser: return 150
        case .getUser: return 151
        case .listMyConnections: return 152
        case .updateMyUser: return 153
        case .listGuildVoiceRegions: return 154
        case .listVoiceRegions: return 155
        case .updateSelfVoiceState: return 156
        case .updateVoiceState: return 157
        case .getGuildWebhooks: return 158
        case .getWebhook: return 159
        case .getWebhookByToken: return 160
        case .getWebhookMessage: return 161
        case .getWebhooksMessagesOriginal: return 162
        case .listChannelWebhooks: return 163
        case .createWebhook: return 164
        case .executeWebhook: return 165
        case .patchWebhooksMessagesOriginal: return 166
        case .updateWebhook: return 167
        case .updateWebhookByToken: return 168
        case .updateWebhookMessage: return 169
        case .deleteWebhook: return 170
        case .deleteWebhookByToken: return 171
        case .deleteWebhookMessage: return 172
        case .deleteWebhooksMessagesOriginal: return 173
        }
    }
}