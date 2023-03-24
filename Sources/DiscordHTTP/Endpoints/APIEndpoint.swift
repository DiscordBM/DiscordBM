// MARK: - DO NOT EDIT. Auto-generated endpoints using the GenerateAPIEndpoints command plugin.

import NIOHTTP1

public enum APIEndpoint: Endpoint {

    // MARK: AutoMod
    /// https://discord.com/developers/docs/resources/auto-moderation
    
    case listAutoModerationRules(guildId: String)
    case getAutoModerationRule(guildId: String, ruleId: String)
    case createAutoModerationRule(guildId: String)
    case updateAutoModerationRule(guildId: String, ruleId: String)
    case deleteAutoModerationRule(guildId: String, ruleId: String)
    
    // MARK: Audit Log
    /// https://discord.com/developers/docs/resources/audit-log
    
    case listGuildAuditLogEntries(guildId: String)
    
    // MARK: Channels
    /// https://discord.com/developers/docs/resources/channel
    
    case listPinnedMessages(channelId: String)
    case getChannel(channelId: String)
    case listGuildChannels(guildId: String)
    case addGroupDmUser(channelId: String, userId: String)
    case pinMessage(channelId: String, messageId: String)
    case setChannelPermissionOverwrite(channelId: String, overwriteId: String)
    case followChannel(channelId: String)
    case triggerTypingIndicator(channelId: String)
    case createDm
    case createGuildChannel(guildId: String)
    case updateChannel(channelId: String)
    case bulkUpdateGuildChannels(guildId: String)
    case deleteChannel(channelId: String)
    case deleteGroupDmUser(channelId: String, userId: String)
    case unpinMessage(channelId: String, messageId: String)
    case deleteChannelPermissionOverwrite(channelId: String, overwriteId: String)
    
    // MARK: Commands
    /// https://discord.com/developers/docs/interactions/application-commands
    
    case getGuildApplicationCommandPermissions(applicationId: String, guildId: String, commandId: String)
    case listGuildApplicationCommands(applicationId: String, guildId: String)
    case getApplicationCommand(applicationId: String, commandId: String)
    case listGuildApplicationCommandPermissions(applicationId: String, guildId: String)
    case listApplicationCommands(applicationId: String)
    case getGuildApplicationCommand(applicationId: String, guildId: String, commandId: String)
    case setGuildApplicationCommandPermissions(applicationId: String, guildId: String, commandId: String)
    case bulkSetGuildApplicationCommands(applicationId: String, guildId: String)
    case bulkSetApplicationCommands(applicationId: String)
    case createGuildApplicationCommand(applicationId: String, guildId: String)
    case createApplicationCommand(applicationId: String)
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
    
    case listGuildIntegrations(guildId: String)
    case getGuildWidgetPng(guildId: String)
    case getGuildPreview(guildId: String)
    case getGuildVanityUrl(guildId: String)
    case listMyGuilds
    case getGuildWidget(guildId: String)
    case getGuildBan(guildId: String, userId: String)
    case getGuildWelcomeScreen(guildId: String)
    case previewPruneGuild(guildId: String)
    case getGuild(guildId: String)
    case getGuildWidgetSettings(guildId: String)
    case listGuildBans(guildId: String)
    case banUserFromGuild(guildId: String, userId: String)
    case setGuildMfaLevel(guildId: String)
    case pruneGuild(guildId: String)
    case createGuild
    case updateGuildWelcomeScreen(guildId: String)
    case updateGuild(guildId: String)
    case updateGuildWidgetSettings(guildId: String)
    case leaveGuild(guildId: String)
    case deleteGuildIntegration(guildId: String, integrationId: String)
    case unbanUserFromGuild(guildId: String, userId: String)
    case deleteGuild(guildId: String)
    
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
    
    case createInteractionResponse(interactionId: String, interactionToken: String)
    
    // MARK: Invites
    /// https://discord.com/developers/docs/resources/invite
    
    case listGuildInvites(guildId: String)
    case inviteResolve(code: String)
    case listChannelInvites(channelId: String)
    case createChannelInvite(channelId: String)
    case inviteRevoke(code: String)
    
    // MARK: Members
    /// https://discord.com/developers/docs/resources/guild
    
    case getMyGuildMember(guildId: String)
    case getGuildMember(guildId: String, userId: String)
    case listGuildMembers(guildId: String)
    case searchGuildMembers(guildId: String)
    case addGuildMember(guildId: String, userId: String)
    case updateMyGuildMember(guildId: String)
    case updateGuildMember(guildId: String, userId: String)
    case deleteGuildMember(guildId: String, userId: String)
    
    // MARK: Messages
    /// https://discord.com/developers/docs/resources/channel
    
    case getMessage(channelId: String, messageId: String)
    case listMessageReactionsByEmoji(channelId: String, messageId: String, emojiName: String)
    case listMessages(channelId: String)
    case addMyMessageReaction(channelId: String, messageId: String, emojiName: String)
    case bulkDeleteMessages(channelId: String)
    case crosspostMessage(channelId: String, messageId: String)
    case createMessage(channelId: String)
    case updateMessage(channelId: String, messageId: String)
    case deleteMessage(channelId: String, messageId: String)
    case deleteAllMessageReactions(channelId: String, messageId: String)
    case deleteMyMessageReaction(channelId: String, messageId: String, emojiName: String)
    case deleteUserMessageReaction(channelId: String, messageId: String, emojiName: String, userId: String)
    case deleteAllMessageReactionsByEmoji(channelId: String, messageId: String, emojiName: String)
    
    // MARK: OAuth
    /// https://discord.com/developers/docs/topics/oauth2
    
    case getMyOauth2Application
    
    // MARK: Roles
    /// https://discord.com/developers/docs/resources/guild
    
    case listGuildRoles(guildId: String)
    case addGuildMemberRole(guildId: String, userId: String, roleId: String)
    case createGuildRole(guildId: String)
    case updateGuildRole(guildId: String, roleId: String)
    case bulkUpdateGuildRoles(guildId: String)
    case deleteGuildRole(guildId: String, roleId: String)
    case deleteGuildMemberRole(guildId: String, userId: String, roleId: String)
    
    // MARK: Role Connections
    /// https://discord.com/developers/docs/resources/user
    
    case getApplicationRoleConnectionsMetadata(applicationId: String)
    case getApplicationUserRoleConnection(applicationId: String)
    case updateApplicationRoleConnectionsMetadata(applicationId: String)
    case updateApplicationUserRoleConnection(applicationId: String)
    
    // MARK: Scheduled Events
    /// https://discord.com/developers/docs/resources/guild-scheduled-event
    
    case getGuildScheduledEvent(guildId: String, guildScheduledEventId: String)
    case listGuildScheduledEvents(guildId: String)
    case listGuildScheduledEventUsers(guildId: String, guildScheduledEventId: String)
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
    
    case listStickerPacks
    case getSticker(stickerId: String)
    case listGuildStickers(guildId: String)
    case getGuildSticker(guildId: String, stickerId: String)
    case createGuildSticker(guildId: String)
    case updateGuildSticker(guildId: String, stickerId: String)
    case deleteGuildSticker(guildId: String, stickerId: String)
    
    // MARK: Threads
    /// https://discord.com/developers/docs/resources/channel
    
    case getThreadMember(channelId: String, userId: String)
    case listThreadMembers(channelId: String)
    case getActiveGuildThreads(guildId: String)
    case listPublicArchivedThreads(channelId: String)
    case listMyPrivateArchivedThreads(channelId: String)
    case listPrivateArchivedThreads(channelId: String)
    case addThreadMember(channelId: String, userId: String)
    case joinThread(channelId: String)
    case createThreadFromMessage(channelId: String, messageId: String)
    case createThread(channelId: String)
    case deleteThreadMember(channelId: String, userId: String)
    case leaveThread(channelId: String)
    
    // MARK: Users
    /// https://discord.com/developers/docs/resources/user
    
    case listMyConnections
    case getMyUser
    case getUser(userId: String)
    case updateMyUser
    
    // MARK: Voice
    /// https://discord.com/developers/docs/resources/voice#list-voice-regions
    
    case listVoiceRegions
    case listGuildVoiceRegions(guildId: String)
    case updateSelfVoiceState(guildId: String)
    case updateVoiceState(guildId: String, userId: String)
    
    // MARK: Webhooks
    /// https://discord.com/developers/docs/resources/webhook
    
    case getWebhooksMessagesOriginal(webhookId: String, webhookToken: String)
    case getWebhookMessage(webhookId: String, webhookToken: String, messageId: String)
    case getWebhookByToken(webhookId: String, webhookToken: String)
    case listChannelWebhooks(channelId: String)
    case getWebhook(webhookId: String)
    case getGuildWebhooks(guildId: String)
    case executeWebhook(webhookId: String, webhookToken: String)
    case createWebhook(channelId: String)
    case patchWebhooksMessagesOriginal(webhookId: String, webhookToken: String)
    case updateWebhookMessage(webhookId: String, webhookToken: String, messageId: String)
    case updateWebhookByToken(webhookId: String, webhookToken: String)
    case updateWebhook(webhookId: String)
    case deleteWebhooksMessagesOriginal(webhookId: String, webhookToken: String)
    case deleteWebhookMessage(webhookId: String, webhookToken: String, messageId: String)
    case deleteWebhookByToken(webhookId: String, webhookToken: String)
    case deleteWebhook(webhookId: String)

    var urlPrefix: String {
        "https://discord.com/api/v\(DiscordGlobalConfiguration.apiVersion)/"
    }

    public var url: String {
        func encoded(_ string: String) -> String {
            string.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? string
        }
        let suffix: String
        switch self {
        case let .listAutoModerationRules(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/auto-moderation/rules"
        case let .getAutoModerationRule(guildId, ruleId):
            let guildId = encoded(guildId)
            let ruleId = encoded(ruleId)
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
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
        case let .listPinnedMessages(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/pins"
        case let .getChannel(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)"
        case let .listGuildChannels(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/channels"
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
        case let .followChannel(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/followers"
        case let .triggerTypingIndicator(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/typing"
        case .createDm:
            suffix = "users/@me/channels"
        case let .createGuildChannel(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/channels"
        case let .updateChannel(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)"
        case let .bulkUpdateGuildChannels(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/channels"
        case let .deleteChannel(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)"
        case let .deleteGroupDmUser(channelId, userId):
            let channelId = encoded(channelId)
            let userId = encoded(userId)
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .unpinMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            let channelId = encoded(channelId)
            let overwriteId = encoded(overwriteId)
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            let commandId = encoded(commandId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .listGuildApplicationCommands(applicationId, guildId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .getApplicationCommand(applicationId, commandId):
            let applicationId = encoded(applicationId)
            let commandId = encoded(commandId)
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
        case let .listApplicationCommands(applicationId):
            let applicationId = encoded(applicationId)
            suffix = "applications/\(applicationId)/commands"
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            let commandId = encoded(commandId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .setGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            let commandId = encoded(commandId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .bulkSetGuildApplicationCommands(applicationId, guildId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .bulkSetApplicationCommands(applicationId):
            let applicationId = encoded(applicationId)
            suffix = "applications/\(applicationId)/commands"
        case let .createGuildApplicationCommand(applicationId, guildId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .createApplicationCommand(applicationId):
            let applicationId = encoded(applicationId)
            suffix = "applications/\(applicationId)/commands"
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
        case let .listGuildIntegrations(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/integrations"
        case let .getGuildWidgetPng(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/widget.png"
        case let .getGuildPreview(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/preview"
        case let .getGuildVanityUrl(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/vanity-url"
        case .listMyGuilds:
            suffix = "users/@me/guilds"
        case let .getGuildWidget(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/widget.json"
        case let .getGuildBan(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildWelcomeScreen(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .previewPruneGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/prune"
        case let .getGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)"
        case let .getGuildWidgetSettings(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/widget"
        case let .listGuildBans(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/bans"
        case let .banUserFromGuild(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .setGuildMfaLevel(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/mfa"
        case let .pruneGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/prune"
        case .createGuild:
            suffix = "guilds"
        case let .updateGuildWelcomeScreen(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .updateGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)"
        case let .updateGuildWidgetSettings(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/widget"
        case let .leaveGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "users/@me/guilds/\(guildId)"
        case let .deleteGuildIntegration(guildId, integrationId):
            let guildId = encoded(guildId)
            let integrationId = encoded(integrationId)
            suffix = "guilds/\(guildId)/integrations/\(integrationId)"
        case let .unbanUserFromGuild(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .deleteGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)"
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
        case let .createInteractionResponse(interactionId, interactionToken):
            let interactionId = encoded(interactionId)
            let interactionToken = encoded(interactionToken)
            suffix = "interactions/\(interactionId)/\(interactionToken)/callback"
        case let .listGuildInvites(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/invites"
        case let .inviteResolve(code):
            let code = encoded(code)
            suffix = "invites/\(code)"
        case let .listChannelInvites(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/invites"
        case let .createChannelInvite(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/invites"
        case let .inviteRevoke(code):
            let code = encoded(code)
            suffix = "invites/\(code)"
        case let .getMyGuildMember(guildId):
            let guildId = encoded(guildId)
            suffix = "users/@me/guilds/\(guildId)/member"
        case let .getGuildMember(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/members/\(userId)"
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
        case let .updateMyGuildMember(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/members/@me"
        case let .updateGuildMember(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/members/\(userId)"
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
        case let .crosspostMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)/crosspost"
        case let .createMessage(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/messages"
        case let .updateMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteAllMessageReactions(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions"
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
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            let emojiName = encoded(emojiName)
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
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
        case let .updateGuildRole(guildId, roleId):
            let guildId = encoded(guildId)
            let roleId = encoded(roleId)
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .bulkUpdateGuildRoles(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/roles"
        case let .deleteGuildRole(guildId, roleId):
            let guildId = encoded(guildId)
            let roleId = encoded(roleId)
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .deleteGuildMemberRole(guildId, userId, roleId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            let roleId = encoded(roleId)
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
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
        case let .listGuildScheduledEvents(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            let guildId = encoded(guildId)
            let guildScheduledEventId = encoded(guildScheduledEventId)
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)/users"
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
        case .listStickerPacks:
            suffix = "sticker-packs"
        case let .getSticker(stickerId):
            let stickerId = encoded(stickerId)
            suffix = "stickers/\(stickerId)"
        case let .listGuildStickers(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/stickers"
        case let .getGuildSticker(guildId, stickerId):
            let guildId = encoded(guildId)
            let stickerId = encoded(stickerId)
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
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
        case let .getThreadMember(channelId, userId):
            let channelId = encoded(channelId)
            let userId = encoded(userId)
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .listThreadMembers(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/thread-members"
        case let .getActiveGuildThreads(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/threads/active"
        case let .listPublicArchivedThreads(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/threads/archived/public"
        case let .listMyPrivateArchivedThreads(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/users/@me/threads/archived/private"
        case let .listPrivateArchivedThreads(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/threads/archived/private"
        case let .addThreadMember(channelId, userId):
            let channelId = encoded(channelId)
            let userId = encoded(userId)
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .joinThread(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/thread-members/@me"
        case let .createThreadFromMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)/threads"
        case let .createThread(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/threads"
        case let .deleteThreadMember(channelId, userId):
            let channelId = encoded(channelId)
            let userId = encoded(userId)
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .leaveThread(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/thread-members/@me"
        case .listMyConnections:
            suffix = "users/@me/connections"
        case .getMyUser:
            suffix = "users/@me"
        case let .getUser(userId):
            let userId = encoded(userId)
            suffix = "users/\(userId)"
        case .updateMyUser:
            suffix = "users/@me"
        case .listVoiceRegions:
            suffix = "voice/regions"
        case let .listGuildVoiceRegions(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/regions"
        case let .updateSelfVoiceState(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/voice-states/@me"
        case let .updateVoiceState(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/voice-states/\(userId)"
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            let messageId = encoded(messageId)
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .getWebhookByToken(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .listChannelWebhooks(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/webhooks"
        case let .getWebhook(webhookId):
            let webhookId = encoded(webhookId)
            suffix = "webhooks/\(webhookId)"
        case let .getGuildWebhooks(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/webhooks"
        case let .executeWebhook(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .createWebhook(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/webhooks"
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .updateWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            let messageId = encoded(messageId)
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .updateWebhookByToken(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .updateWebhook(webhookId):
            let webhookId = encoded(webhookId)
            suffix = "webhooks/\(webhookId)"
        case let .deleteWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            let messageId = encoded(messageId)
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .deleteWebhookByToken(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .deleteWebhook(webhookId):
            let webhookId = encoded(webhookId)
            suffix = "webhooks/\(webhookId)"
        }
        return urlPrefix + suffix
    }

    public var urlDescription: String {
        let suffix: String
        switch self {
        case let .listAutoModerationRules(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/auto-moderation/rules"
        case let .getAutoModerationRule(guildId, ruleId):
            let guildId = guildId.urlPathEncoded()
            let ruleId = ruleId.urlPathEncoded()
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
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
        case let .listPinnedMessages(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/pins"
        case let .getChannel(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)"
        case let .listGuildChannels(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/channels"
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
        case let .followChannel(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/followers"
        case let .triggerTypingIndicator(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/typing"
        case .createDm:
            suffix = "users/@me/channels"
        case let .createGuildChannel(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/channels"
        case let .updateChannel(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)"
        case let .bulkUpdateGuildChannels(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/channels"
        case let .deleteChannel(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)"
        case let .deleteGroupDmUser(channelId, userId):
            let channelId = channelId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .unpinMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            let channelId = channelId.urlPathEncoded()
            let overwriteId = overwriteId.urlPathEncoded()
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            let commandId = commandId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .listGuildApplicationCommands(applicationId, guildId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .getApplicationCommand(applicationId, commandId):
            let applicationId = applicationId.urlPathEncoded()
            let commandId = commandId.urlPathEncoded()
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
        case let .listApplicationCommands(applicationId):
            let applicationId = applicationId.urlPathEncoded()
            suffix = "applications/\(applicationId)/commands"
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            let commandId = commandId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .setGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            let commandId = commandId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .bulkSetGuildApplicationCommands(applicationId, guildId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .bulkSetApplicationCommands(applicationId):
            let applicationId = applicationId.urlPathEncoded()
            suffix = "applications/\(applicationId)/commands"
        case let .createGuildApplicationCommand(applicationId, guildId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .createApplicationCommand(applicationId):
            let applicationId = applicationId.urlPathEncoded()
            suffix = "applications/\(applicationId)/commands"
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
        case let .listGuildIntegrations(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/integrations"
        case let .getGuildWidgetPng(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/widget.png"
        case let .getGuildPreview(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/preview"
        case let .getGuildVanityUrl(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/vanity-url"
        case .listMyGuilds:
            suffix = "users/@me/guilds"
        case let .getGuildWidget(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/widget.json"
        case let .getGuildBan(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildWelcomeScreen(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .previewPruneGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/prune"
        case let .getGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)"
        case let .getGuildWidgetSettings(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/widget"
        case let .listGuildBans(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/bans"
        case let .banUserFromGuild(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .setGuildMfaLevel(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/mfa"
        case let .pruneGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/prune"
        case .createGuild:
            suffix = "guilds"
        case let .updateGuildWelcomeScreen(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .updateGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)"
        case let .updateGuildWidgetSettings(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/widget"
        case let .leaveGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "users/@me/guilds/\(guildId)"
        case let .deleteGuildIntegration(guildId, integrationId):
            let guildId = guildId.urlPathEncoded()
            let integrationId = integrationId.urlPathEncoded()
            suffix = "guilds/\(guildId)/integrations/\(integrationId)"
        case let .unbanUserFromGuild(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .deleteGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)"
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
        case let .createInteractionResponse(interactionId, interactionToken):
            let interactionId = interactionId.urlPathEncoded()
            let interactionToken = interactionToken.urlPathEncoded()
            suffix = "interactions/\(interactionId)/\(interactionToken)/callback"
        case let .listGuildInvites(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/invites"
        case let .inviteResolve(code):
            let code = code.urlPathEncoded()
            suffix = "invites/\(code)"
        case let .listChannelInvites(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/invites"
        case let .createChannelInvite(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/invites"
        case let .inviteRevoke(code):
            let code = code.urlPathEncoded()
            suffix = "invites/\(code)"
        case let .getMyGuildMember(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "users/@me/guilds/\(guildId)/member"
        case let .getGuildMember(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members/\(userId)"
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
        case let .updateMyGuildMember(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members/@me"
        case let .updateGuildMember(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members/\(userId)"
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
        case let .crosspostMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/crosspost"
        case let .createMessage(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages"
        case let .updateMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteAllMessageReactions(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions"
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
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
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
        case let .updateGuildRole(guildId, roleId):
            let guildId = guildId.urlPathEncoded()
            let roleId = roleId.urlPathEncoded()
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .bulkUpdateGuildRoles(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/roles"
        case let .deleteGuildRole(guildId, roleId):
            let guildId = guildId.urlPathEncoded()
            let roleId = roleId.urlPathEncoded()
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .deleteGuildMemberRole(guildId, userId, roleId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            let roleId = roleId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
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
        case let .listGuildScheduledEvents(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            let guildId = guildId.urlPathEncoded()
            let guildScheduledEventId = guildScheduledEventId.urlPathEncoded()
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)/users"
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
        case .listStickerPacks:
            suffix = "sticker-packs"
        case let .getSticker(stickerId):
            let stickerId = stickerId.urlPathEncoded()
            suffix = "stickers/\(stickerId)"
        case let .listGuildStickers(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/stickers"
        case let .getGuildSticker(guildId, stickerId):
            let guildId = guildId.urlPathEncoded()
            let stickerId = stickerId.urlPathEncoded()
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
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
        case let .getThreadMember(channelId, userId):
            let channelId = channelId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .listThreadMembers(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/thread-members"
        case let .getActiveGuildThreads(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/threads/active"
        case let .listPublicArchivedThreads(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/threads/archived/public"
        case let .listMyPrivateArchivedThreads(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/users/@me/threads/archived/private"
        case let .listPrivateArchivedThreads(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/threads/archived/private"
        case let .addThreadMember(channelId, userId):
            let channelId = channelId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .joinThread(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/thread-members/@me"
        case let .createThreadFromMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/threads"
        case let .createThread(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/threads"
        case let .deleteThreadMember(channelId, userId):
            let channelId = channelId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .leaveThread(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/thread-members/@me"
        case .listMyConnections:
            suffix = "users/@me/connections"
        case .getMyUser:
            suffix = "users/@me"
        case let .getUser(userId):
            let userId = userId.urlPathEncoded()
            suffix = "users/\(userId)"
        case .updateMyUser:
            suffix = "users/@me"
        case .listVoiceRegions:
            suffix = "voice/regions"
        case let .listGuildVoiceRegions(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/regions"
        case let .updateSelfVoiceState(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/voice-states/@me"
        case let .updateVoiceState(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/voice-states/\(userId)"
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            let messageId = messageId.urlPathEncoded()
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .getWebhookByToken(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .listChannelWebhooks(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/webhooks"
        case let .getWebhook(webhookId):
            let webhookId = webhookId.urlPathEncoded()
            suffix = "webhooks/\(webhookId)"
        case let .getGuildWebhooks(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/webhooks"
        case let .executeWebhook(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .createWebhook(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/webhooks"
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .updateWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            let messageId = messageId.urlPathEncoded()
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .updateWebhookByToken(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .updateWebhook(webhookId):
            let webhookId = webhookId.urlPathEncoded()
            suffix = "webhooks/\(webhookId)"
        case let .deleteWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            let messageId = messageId.urlPathEncoded()
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .deleteWebhookByToken(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .deleteWebhook(webhookId):
            let webhookId = webhookId.urlPathEncoded()
            suffix = "webhooks/\(webhookId)"
        }
        return urlPrefix + suffix
    }

    public var httpMethod: HTTPMethod {
        switch self {
        case .listAutoModerationRules: return .GET
        case .getAutoModerationRule: return .GET
        case .createAutoModerationRule: return .POST
        case .updateAutoModerationRule: return .PATCH
        case .deleteAutoModerationRule: return .DELETE
        case .listGuildAuditLogEntries: return .GET
        case .listPinnedMessages: return .GET
        case .getChannel: return .GET
        case .listGuildChannels: return .GET
        case .addGroupDmUser: return .PUT
        case .pinMessage: return .PUT
        case .setChannelPermissionOverwrite: return .PUT
        case .followChannel: return .POST
        case .triggerTypingIndicator: return .POST
        case .createDm: return .POST
        case .createGuildChannel: return .POST
        case .updateChannel: return .PATCH
        case .bulkUpdateGuildChannels: return .PATCH
        case .deleteChannel: return .DELETE
        case .deleteGroupDmUser: return .DELETE
        case .unpinMessage: return .DELETE
        case .deleteChannelPermissionOverwrite: return .DELETE
        case .getGuildApplicationCommandPermissions: return .GET
        case .listGuildApplicationCommands: return .GET
        case .getApplicationCommand: return .GET
        case .listGuildApplicationCommandPermissions: return .GET
        case .listApplicationCommands: return .GET
        case .getGuildApplicationCommand: return .GET
        case .setGuildApplicationCommandPermissions: return .PUT
        case .bulkSetGuildApplicationCommands: return .PUT
        case .bulkSetApplicationCommands: return .PUT
        case .createGuildApplicationCommand: return .POST
        case .createApplicationCommand: return .POST
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
        case .listGuildIntegrations: return .GET
        case .getGuildWidgetPng: return .GET
        case .getGuildPreview: return .GET
        case .getGuildVanityUrl: return .GET
        case .listMyGuilds: return .GET
        case .getGuildWidget: return .GET
        case .getGuildBan: return .GET
        case .getGuildWelcomeScreen: return .GET
        case .previewPruneGuild: return .GET
        case .getGuild: return .GET
        case .getGuildWidgetSettings: return .GET
        case .listGuildBans: return .GET
        case .banUserFromGuild: return .PUT
        case .setGuildMfaLevel: return .POST
        case .pruneGuild: return .POST
        case .createGuild: return .POST
        case .updateGuildWelcomeScreen: return .PATCH
        case .updateGuild: return .PATCH
        case .updateGuildWidgetSettings: return .PATCH
        case .leaveGuild: return .DELETE
        case .deleteGuildIntegration: return .DELETE
        case .unbanUserFromGuild: return .DELETE
        case .deleteGuild: return .DELETE
        case .getGuildTemplate: return .GET
        case .listGuildTemplates: return .GET
        case .syncGuildTemplate: return .PUT
        case .createGuildFromTemplate: return .POST
        case .createGuildTemplate: return .POST
        case .updateGuildTemplate: return .PATCH
        case .deleteGuildTemplate: return .DELETE
        case .createInteractionResponse: return .POST
        case .listGuildInvites: return .GET
        case .inviteResolve: return .GET
        case .listChannelInvites: return .GET
        case .createChannelInvite: return .POST
        case .inviteRevoke: return .DELETE
        case .getMyGuildMember: return .GET
        case .getGuildMember: return .GET
        case .listGuildMembers: return .GET
        case .searchGuildMembers: return .GET
        case .addGuildMember: return .PUT
        case .updateMyGuildMember: return .PATCH
        case .updateGuildMember: return .PATCH
        case .deleteGuildMember: return .DELETE
        case .getMessage: return .GET
        case .listMessageReactionsByEmoji: return .GET
        case .listMessages: return .GET
        case .addMyMessageReaction: return .PUT
        case .bulkDeleteMessages: return .POST
        case .crosspostMessage: return .POST
        case .createMessage: return .POST
        case .updateMessage: return .PATCH
        case .deleteMessage: return .DELETE
        case .deleteAllMessageReactions: return .DELETE
        case .deleteMyMessageReaction: return .DELETE
        case .deleteUserMessageReaction: return .DELETE
        case .deleteAllMessageReactionsByEmoji: return .DELETE
        case .getMyOauth2Application: return .GET
        case .listGuildRoles: return .GET
        case .addGuildMemberRole: return .PUT
        case .createGuildRole: return .POST
        case .updateGuildRole: return .PATCH
        case .bulkUpdateGuildRoles: return .PATCH
        case .deleteGuildRole: return .DELETE
        case .deleteGuildMemberRole: return .DELETE
        case .getApplicationRoleConnectionsMetadata: return .GET
        case .getApplicationUserRoleConnection: return .GET
        case .updateApplicationRoleConnectionsMetadata: return .PUT
        case .updateApplicationUserRoleConnection: return .PUT
        case .getGuildScheduledEvent: return .GET
        case .listGuildScheduledEvents: return .GET
        case .listGuildScheduledEventUsers: return .GET
        case .createGuildScheduledEvent: return .POST
        case .updateGuildScheduledEvent: return .PATCH
        case .deleteGuildScheduledEvent: return .DELETE
        case .getStageInstance: return .GET
        case .createStageInstance: return .POST
        case .updateStageInstance: return .PATCH
        case .deleteStageInstance: return .DELETE
        case .listStickerPacks: return .GET
        case .getSticker: return .GET
        case .listGuildStickers: return .GET
        case .getGuildSticker: return .GET
        case .createGuildSticker: return .POST
        case .updateGuildSticker: return .PATCH
        case .deleteGuildSticker: return .DELETE
        case .getThreadMember: return .GET
        case .listThreadMembers: return .GET
        case .getActiveGuildThreads: return .GET
        case .listPublicArchivedThreads: return .GET
        case .listMyPrivateArchivedThreads: return .GET
        case .listPrivateArchivedThreads: return .GET
        case .addThreadMember: return .PUT
        case .joinThread: return .PUT
        case .createThreadFromMessage: return .POST
        case .createThread: return .POST
        case .deleteThreadMember: return .DELETE
        case .leaveThread: return .DELETE
        case .listMyConnections: return .GET
        case .getMyUser: return .GET
        case .getUser: return .GET
        case .updateMyUser: return .PATCH
        case .listVoiceRegions: return .GET
        case .listGuildVoiceRegions: return .GET
        case .updateSelfVoiceState: return .PATCH
        case .updateVoiceState: return .PATCH
        case .getWebhooksMessagesOriginal: return .GET
        case .getWebhookMessage: return .GET
        case .getWebhookByToken: return .GET
        case .listChannelWebhooks: return .GET
        case .getWebhook: return .GET
        case .getGuildWebhooks: return .GET
        case .executeWebhook: return .POST
        case .createWebhook: return .POST
        case .patchWebhooksMessagesOriginal: return .PATCH
        case .updateWebhookMessage: return .PATCH
        case .updateWebhookByToken: return .PATCH
        case .updateWebhook: return .PATCH
        case .deleteWebhooksMessagesOriginal: return .DELETE
        case .deleteWebhookMessage: return .DELETE
        case .deleteWebhookByToken: return .DELETE
        case .deleteWebhook: return .DELETE
        }
    }

    public var countsAgainstGlobalRateLimit: Bool {
        switch self {
        case .listAutoModerationRules: return false
        case .getAutoModerationRule: return false
        case .createAutoModerationRule: return false
        case .updateAutoModerationRule: return false
        case .deleteAutoModerationRule: return false
        case .listGuildAuditLogEntries: return false
        case .listPinnedMessages: return false
        case .getChannel: return false
        case .listGuildChannels: return false
        case .addGroupDmUser: return false
        case .pinMessage: return false
        case .setChannelPermissionOverwrite: return false
        case .followChannel: return false
        case .triggerTypingIndicator: return false
        case .createDm: return false
        case .createGuildChannel: return false
        case .updateChannel: return false
        case .bulkUpdateGuildChannels: return false
        case .deleteChannel: return false
        case .deleteGroupDmUser: return false
        case .unpinMessage: return false
        case .deleteChannelPermissionOverwrite: return false
        case .getGuildApplicationCommandPermissions: return false
        case .listGuildApplicationCommands: return false
        case .getApplicationCommand: return false
        case .listGuildApplicationCommandPermissions: return false
        case .listApplicationCommands: return false
        case .getGuildApplicationCommand: return false
        case .setGuildApplicationCommandPermissions: return false
        case .bulkSetGuildApplicationCommands: return false
        case .bulkSetApplicationCommands: return false
        case .createGuildApplicationCommand: return false
        case .createApplicationCommand: return false
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
        case .listGuildIntegrations: return false
        case .getGuildWidgetPng: return false
        case .getGuildPreview: return false
        case .getGuildVanityUrl: return false
        case .listMyGuilds: return false
        case .getGuildWidget: return false
        case .getGuildBan: return false
        case .getGuildWelcomeScreen: return false
        case .previewPruneGuild: return false
        case .getGuild: return false
        case .getGuildWidgetSettings: return false
        case .listGuildBans: return false
        case .banUserFromGuild: return false
        case .setGuildMfaLevel: return false
        case .pruneGuild: return false
        case .createGuild: return false
        case .updateGuildWelcomeScreen: return false
        case .updateGuild: return false
        case .updateGuildWidgetSettings: return false
        case .leaveGuild: return false
        case .deleteGuildIntegration: return false
        case .unbanUserFromGuild: return false
        case .deleteGuild: return false
        case .getGuildTemplate: return false
        case .listGuildTemplates: return false
        case .syncGuildTemplate: return false
        case .createGuildFromTemplate: return false
        case .createGuildTemplate: return false
        case .updateGuildTemplate: return false
        case .deleteGuildTemplate: return false
        case .createInteractionResponse: return true
        case .listGuildInvites: return false
        case .inviteResolve: return false
        case .listChannelInvites: return false
        case .createChannelInvite: return false
        case .inviteRevoke: return false
        case .getMyGuildMember: return false
        case .getGuildMember: return false
        case .listGuildMembers: return false
        case .searchGuildMembers: return false
        case .addGuildMember: return false
        case .updateMyGuildMember: return false
        case .updateGuildMember: return false
        case .deleteGuildMember: return false
        case .getMessage: return false
        case .listMessageReactionsByEmoji: return false
        case .listMessages: return false
        case .addMyMessageReaction: return false
        case .bulkDeleteMessages: return false
        case .crosspostMessage: return false
        case .createMessage: return false
        case .updateMessage: return false
        case .deleteMessage: return false
        case .deleteAllMessageReactions: return false
        case .deleteMyMessageReaction: return false
        case .deleteUserMessageReaction: return false
        case .deleteAllMessageReactionsByEmoji: return false
        case .getMyOauth2Application: return false
        case .listGuildRoles: return false
        case .addGuildMemberRole: return false
        case .createGuildRole: return false
        case .updateGuildRole: return false
        case .bulkUpdateGuildRoles: return false
        case .deleteGuildRole: return false
        case .deleteGuildMemberRole: return false
        case .getApplicationRoleConnectionsMetadata: return false
        case .getApplicationUserRoleConnection: return false
        case .updateApplicationRoleConnectionsMetadata: return false
        case .updateApplicationUserRoleConnection: return false
        case .getGuildScheduledEvent: return false
        case .listGuildScheduledEvents: return false
        case .listGuildScheduledEventUsers: return false
        case .createGuildScheduledEvent: return false
        case .updateGuildScheduledEvent: return false
        case .deleteGuildScheduledEvent: return false
        case .getStageInstance: return false
        case .createStageInstance: return false
        case .updateStageInstance: return false
        case .deleteStageInstance: return false
        case .listStickerPacks: return false
        case .getSticker: return false
        case .listGuildStickers: return false
        case .getGuildSticker: return false
        case .createGuildSticker: return false
        case .updateGuildSticker: return false
        case .deleteGuildSticker: return false
        case .getThreadMember: return false
        case .listThreadMembers: return false
        case .getActiveGuildThreads: return false
        case .listPublicArchivedThreads: return false
        case .listMyPrivateArchivedThreads: return false
        case .listPrivateArchivedThreads: return false
        case .addThreadMember: return false
        case .joinThread: return false
        case .createThreadFromMessage: return false
        case .createThread: return false
        case .deleteThreadMember: return false
        case .leaveThread: return false
        case .listMyConnections: return false
        case .getMyUser: return false
        case .getUser: return false
        case .updateMyUser: return false
        case .listVoiceRegions: return false
        case .listGuildVoiceRegions: return false
        case .updateSelfVoiceState: return false
        case .updateVoiceState: return false
        case .getWebhooksMessagesOriginal: return false
        case .getWebhookMessage: return false
        case .getWebhookByToken: return false
        case .listChannelWebhooks: return false
        case .getWebhook: return false
        case .getGuildWebhooks: return false
        case .executeWebhook: return false
        case .createWebhook: return false
        case .patchWebhooksMessagesOriginal: return false
        case .updateWebhookMessage: return false
        case .updateWebhookByToken: return false
        case .updateWebhook: return false
        case .deleteWebhooksMessagesOriginal: return false
        case .deleteWebhookMessage: return false
        case .deleteWebhookByToken: return false
        case .deleteWebhook: return false
        }
    }

    public var requiresAuthorizationHeader: Bool {
        switch self {
        case .listAutoModerationRules: return false
        case .getAutoModerationRule: return false
        case .createAutoModerationRule: return false
        case .updateAutoModerationRule: return false
        case .deleteAutoModerationRule: return false
        case .listGuildAuditLogEntries: return false
        case .listPinnedMessages: return false
        case .getChannel: return false
        case .listGuildChannels: return false
        case .addGroupDmUser: return false
        case .pinMessage: return false
        case .setChannelPermissionOverwrite: return false
        case .followChannel: return false
        case .triggerTypingIndicator: return false
        case .createDm: return false
        case .createGuildChannel: return false
        case .updateChannel: return false
        case .bulkUpdateGuildChannels: return false
        case .deleteChannel: return false
        case .deleteGroupDmUser: return false
        case .unpinMessage: return false
        case .deleteChannelPermissionOverwrite: return false
        case .getGuildApplicationCommandPermissions: return false
        case .listGuildApplicationCommands: return false
        case .getApplicationCommand: return false
        case .listGuildApplicationCommandPermissions: return false
        case .listApplicationCommands: return false
        case .getGuildApplicationCommand: return false
        case .setGuildApplicationCommandPermissions: return false
        case .bulkSetGuildApplicationCommands: return false
        case .bulkSetApplicationCommands: return false
        case .createGuildApplicationCommand: return false
        case .createApplicationCommand: return false
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
        case .listGuildIntegrations: return false
        case .getGuildWidgetPng: return false
        case .getGuildPreview: return false
        case .getGuildVanityUrl: return false
        case .listMyGuilds: return false
        case .getGuildWidget: return false
        case .getGuildBan: return false
        case .getGuildWelcomeScreen: return false
        case .previewPruneGuild: return false
        case .getGuild: return false
        case .getGuildWidgetSettings: return false
        case .listGuildBans: return false
        case .banUserFromGuild: return false
        case .setGuildMfaLevel: return false
        case .pruneGuild: return false
        case .createGuild: return false
        case .updateGuildWelcomeScreen: return false
        case .updateGuild: return false
        case .updateGuildWidgetSettings: return false
        case .leaveGuild: return false
        case .deleteGuildIntegration: return false
        case .unbanUserFromGuild: return false
        case .deleteGuild: return false
        case .getGuildTemplate: return false
        case .listGuildTemplates: return false
        case .syncGuildTemplate: return false
        case .createGuildFromTemplate: return false
        case .createGuildTemplate: return false
        case .updateGuildTemplate: return false
        case .deleteGuildTemplate: return false
        case .createInteractionResponse: return false
        case .listGuildInvites: return false
        case .inviteResolve: return false
        case .listChannelInvites: return false
        case .createChannelInvite: return false
        case .inviteRevoke: return false
        case .getMyGuildMember: return false
        case .getGuildMember: return false
        case .listGuildMembers: return false
        case .searchGuildMembers: return false
        case .addGuildMember: return false
        case .updateMyGuildMember: return false
        case .updateGuildMember: return false
        case .deleteGuildMember: return false
        case .getMessage: return false
        case .listMessageReactionsByEmoji: return false
        case .listMessages: return false
        case .addMyMessageReaction: return false
        case .bulkDeleteMessages: return false
        case .crosspostMessage: return false
        case .createMessage: return false
        case .updateMessage: return false
        case .deleteMessage: return false
        case .deleteAllMessageReactions: return false
        case .deleteMyMessageReaction: return false
        case .deleteUserMessageReaction: return false
        case .deleteAllMessageReactionsByEmoji: return false
        case .getMyOauth2Application: return false
        case .listGuildRoles: return false
        case .addGuildMemberRole: return false
        case .createGuildRole: return false
        case .updateGuildRole: return false
        case .bulkUpdateGuildRoles: return false
        case .deleteGuildRole: return false
        case .deleteGuildMemberRole: return false
        case .getApplicationRoleConnectionsMetadata: return false
        case .getApplicationUserRoleConnection: return false
        case .updateApplicationRoleConnectionsMetadata: return false
        case .updateApplicationUserRoleConnection: return false
        case .getGuildScheduledEvent: return false
        case .listGuildScheduledEvents: return false
        case .listGuildScheduledEventUsers: return false
        case .createGuildScheduledEvent: return false
        case .updateGuildScheduledEvent: return false
        case .deleteGuildScheduledEvent: return false
        case .getStageInstance: return false
        case .createStageInstance: return false
        case .updateStageInstance: return false
        case .deleteStageInstance: return false
        case .listStickerPacks: return false
        case .getSticker: return false
        case .listGuildStickers: return false
        case .getGuildSticker: return false
        case .createGuildSticker: return false
        case .updateGuildSticker: return false
        case .deleteGuildSticker: return false
        case .getThreadMember: return false
        case .listThreadMembers: return false
        case .getActiveGuildThreads: return false
        case .listPublicArchivedThreads: return false
        case .listMyPrivateArchivedThreads: return false
        case .listPrivateArchivedThreads: return false
        case .addThreadMember: return false
        case .joinThread: return false
        case .createThreadFromMessage: return false
        case .createThread: return false
        case .deleteThreadMember: return false
        case .leaveThread: return false
        case .listMyConnections: return false
        case .getMyUser: return false
        case .getUser: return false
        case .updateMyUser: return false
        case .listVoiceRegions: return false
        case .listGuildVoiceRegions: return false
        case .updateSelfVoiceState: return false
        case .updateVoiceState: return false
        case .getWebhooksMessagesOriginal: return true
        case .getWebhookMessage: return true
        case .getWebhookByToken: return true
        case .listChannelWebhooks: return false
        case .getWebhook: return false
        case .getGuildWebhooks: return false
        case .executeWebhook: return true
        case .createWebhook: return false
        case .patchWebhooksMessagesOriginal: return true
        case .updateWebhookMessage: return true
        case .updateWebhookByToken: return true
        case .updateWebhook: return false
        case .deleteWebhooksMessagesOriginal: return true
        case .deleteWebhookMessage: return true
        case .deleteWebhookByToken: return true
        case .deleteWebhook: return false
        }
    }

    public var parameters: [String] {
        switch self {
        case let .listAutoModerationRules(guildId):
            return [guildId]
        case let .getAutoModerationRule(guildId, ruleId):
            return [guildId, ruleId]
        case let .createAutoModerationRule(guildId):
            return [guildId]
        case let .updateAutoModerationRule(guildId, ruleId):
            return [guildId, ruleId]
        case let .deleteAutoModerationRule(guildId, ruleId):
            return [guildId, ruleId]
        case let .listGuildAuditLogEntries(guildId):
            return [guildId]
        case let .listPinnedMessages(channelId):
            return [channelId]
        case let .getChannel(channelId):
            return [channelId]
        case let .listGuildChannels(guildId):
            return [guildId]
        case let .addGroupDmUser(channelId, userId):
            return [channelId, userId]
        case let .pinMessage(channelId, messageId):
            return [channelId, messageId]
        case let .setChannelPermissionOverwrite(channelId, overwriteId):
            return [channelId, overwriteId]
        case let .followChannel(channelId):
            return [channelId]
        case let .triggerTypingIndicator(channelId):
            return [channelId]
        case .createDm:
            return []
        case let .createGuildChannel(guildId):
            return [guildId]
        case let .updateChannel(channelId):
            return [channelId]
        case let .bulkUpdateGuildChannels(guildId):
            return [guildId]
        case let .deleteChannel(channelId):
            return [channelId]
        case let .deleteGroupDmUser(channelId, userId):
            return [channelId, userId]
        case let .unpinMessage(channelId, messageId):
            return [channelId, messageId]
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            return [channelId, overwriteId]
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            return [applicationId, guildId, commandId]
        case let .listGuildApplicationCommands(applicationId, guildId):
            return [applicationId, guildId]
        case let .getApplicationCommand(applicationId, commandId):
            return [applicationId, commandId]
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            return [applicationId, guildId]
        case let .listApplicationCommands(applicationId):
            return [applicationId]
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            return [applicationId, guildId, commandId]
        case let .setGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            return [applicationId, guildId, commandId]
        case let .bulkSetGuildApplicationCommands(applicationId, guildId):
            return [applicationId, guildId]
        case let .bulkSetApplicationCommands(applicationId):
            return [applicationId]
        case let .createGuildApplicationCommand(applicationId, guildId):
            return [applicationId, guildId]
        case let .createApplicationCommand(applicationId):
            return [applicationId]
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
        case let .listGuildIntegrations(guildId):
            return [guildId]
        case let .getGuildWidgetPng(guildId):
            return [guildId]
        case let .getGuildPreview(guildId):
            return [guildId]
        case let .getGuildVanityUrl(guildId):
            return [guildId]
        case .listMyGuilds:
            return []
        case let .getGuildWidget(guildId):
            return [guildId]
        case let .getGuildBan(guildId, userId):
            return [guildId, userId]
        case let .getGuildWelcomeScreen(guildId):
            return [guildId]
        case let .previewPruneGuild(guildId):
            return [guildId]
        case let .getGuild(guildId):
            return [guildId]
        case let .getGuildWidgetSettings(guildId):
            return [guildId]
        case let .listGuildBans(guildId):
            return [guildId]
        case let .banUserFromGuild(guildId, userId):
            return [guildId, userId]
        case let .setGuildMfaLevel(guildId):
            return [guildId]
        case let .pruneGuild(guildId):
            return [guildId]
        case .createGuild:
            return []
        case let .updateGuildWelcomeScreen(guildId):
            return [guildId]
        case let .updateGuild(guildId):
            return [guildId]
        case let .updateGuildWidgetSettings(guildId):
            return [guildId]
        case let .leaveGuild(guildId):
            return [guildId]
        case let .deleteGuildIntegration(guildId, integrationId):
            return [guildId, integrationId]
        case let .unbanUserFromGuild(guildId, userId):
            return [guildId, userId]
        case let .deleteGuild(guildId):
            return [guildId]
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
        case let .createInteractionResponse(interactionId, interactionToken):
            return [interactionId, interactionToken]
        case let .listGuildInvites(guildId):
            return [guildId]
        case let .inviteResolve(code):
            return [code]
        case let .listChannelInvites(channelId):
            return [channelId]
        case let .createChannelInvite(channelId):
            return [channelId]
        case let .inviteRevoke(code):
            return [code]
        case let .getMyGuildMember(guildId):
            return [guildId]
        case let .getGuildMember(guildId, userId):
            return [guildId, userId]
        case let .listGuildMembers(guildId):
            return [guildId]
        case let .searchGuildMembers(guildId):
            return [guildId]
        case let .addGuildMember(guildId, userId):
            return [guildId, userId]
        case let .updateMyGuildMember(guildId):
            return [guildId]
        case let .updateGuildMember(guildId, userId):
            return [guildId, userId]
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
        case let .crosspostMessage(channelId, messageId):
            return [channelId, messageId]
        case let .createMessage(channelId):
            return [channelId]
        case let .updateMessage(channelId, messageId):
            return [channelId, messageId]
        case let .deleteMessage(channelId, messageId):
            return [channelId, messageId]
        case let .deleteAllMessageReactions(channelId, messageId):
            return [channelId, messageId]
        case let .deleteMyMessageReaction(channelId, messageId, emojiName):
            return [channelId, messageId, emojiName]
        case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
            return [channelId, messageId, emojiName, userId]
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            return [channelId, messageId, emojiName]
        case .getMyOauth2Application:
            return []
        case let .listGuildRoles(guildId):
            return [guildId]
        case let .addGuildMemberRole(guildId, userId, roleId):
            return [guildId, userId, roleId]
        case let .createGuildRole(guildId):
            return [guildId]
        case let .updateGuildRole(guildId, roleId):
            return [guildId, roleId]
        case let .bulkUpdateGuildRoles(guildId):
            return [guildId]
        case let .deleteGuildRole(guildId, roleId):
            return [guildId, roleId]
        case let .deleteGuildMemberRole(guildId, userId, roleId):
            return [guildId, userId, roleId]
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
        case let .listGuildScheduledEvents(guildId):
            return [guildId]
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            return [guildId, guildScheduledEventId]
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
        case .listStickerPacks:
            return []
        case let .getSticker(stickerId):
            return [stickerId]
        case let .listGuildStickers(guildId):
            return [guildId]
        case let .getGuildSticker(guildId, stickerId):
            return [guildId, stickerId]
        case let .createGuildSticker(guildId):
            return [guildId]
        case let .updateGuildSticker(guildId, stickerId):
            return [guildId, stickerId]
        case let .deleteGuildSticker(guildId, stickerId):
            return [guildId, stickerId]
        case let .getThreadMember(channelId, userId):
            return [channelId, userId]
        case let .listThreadMembers(channelId):
            return [channelId]
        case let .getActiveGuildThreads(guildId):
            return [guildId]
        case let .listPublicArchivedThreads(channelId):
            return [channelId]
        case let .listMyPrivateArchivedThreads(channelId):
            return [channelId]
        case let .listPrivateArchivedThreads(channelId):
            return [channelId]
        case let .addThreadMember(channelId, userId):
            return [channelId, userId]
        case let .joinThread(channelId):
            return [channelId]
        case let .createThreadFromMessage(channelId, messageId):
            return [channelId, messageId]
        case let .createThread(channelId):
            return [channelId]
        case let .deleteThreadMember(channelId, userId):
            return [channelId, userId]
        case let .leaveThread(channelId):
            return [channelId]
        case .listMyConnections:
            return []
        case .getMyUser:
            return []
        case let .getUser(userId):
            return [userId]
        case .updateMyUser:
            return []
        case .listVoiceRegions:
            return []
        case let .listGuildVoiceRegions(guildId):
            return [guildId]
        case let .updateSelfVoiceState(guildId):
            return [guildId]
        case let .updateVoiceState(guildId, userId):
            return [guildId, userId]
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            return [webhookId, webhookToken, messageId]
        case let .getWebhookByToken(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .listChannelWebhooks(channelId):
            return [channelId]
        case let .getWebhook(webhookId):
            return [webhookId]
        case let .getGuildWebhooks(guildId):
            return [guildId]
        case let .executeWebhook(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .createWebhook(channelId):
            return [channelId]
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .updateWebhookMessage(webhookId, webhookToken, messageId):
            return [webhookId, webhookToken, messageId]
        case let .updateWebhookByToken(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .updateWebhook(webhookId):
            return [webhookId]
        case let .deleteWebhooksMessagesOriginal(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
            return [webhookId, webhookToken, messageId]
        case let .deleteWebhookByToken(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .deleteWebhook(webhookId):
            return [webhookId]
        }
    }

    public var id: Int {
        switch self {
        case .listAutoModerationRules: return 1
        case .getAutoModerationRule: return 2
        case .createAutoModerationRule: return 3
        case .updateAutoModerationRule: return 4
        case .deleteAutoModerationRule: return 5
        case .listGuildAuditLogEntries: return 6
        case .listPinnedMessages: return 7
        case .getChannel: return 8
        case .listGuildChannels: return 9
        case .addGroupDmUser: return 10
        case .pinMessage: return 11
        case .setChannelPermissionOverwrite: return 12
        case .followChannel: return 13
        case .triggerTypingIndicator: return 14
        case .createDm: return 15
        case .createGuildChannel: return 16
        case .updateChannel: return 17
        case .bulkUpdateGuildChannels: return 18
        case .deleteChannel: return 19
        case .deleteGroupDmUser: return 20
        case .unpinMessage: return 21
        case .deleteChannelPermissionOverwrite: return 22
        case .getGuildApplicationCommandPermissions: return 23
        case .listGuildApplicationCommands: return 24
        case .getApplicationCommand: return 25
        case .listGuildApplicationCommandPermissions: return 26
        case .listApplicationCommands: return 27
        case .getGuildApplicationCommand: return 28
        case .setGuildApplicationCommandPermissions: return 29
        case .bulkSetGuildApplicationCommands: return 30
        case .bulkSetApplicationCommands: return 31
        case .createGuildApplicationCommand: return 32
        case .createApplicationCommand: return 33
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
        case .listGuildIntegrations: return 45
        case .getGuildWidgetPng: return 46
        case .getGuildPreview: return 47
        case .getGuildVanityUrl: return 48
        case .listMyGuilds: return 49
        case .getGuildWidget: return 50
        case .getGuildBan: return 51
        case .getGuildWelcomeScreen: return 52
        case .previewPruneGuild: return 53
        case .getGuild: return 54
        case .getGuildWidgetSettings: return 55
        case .listGuildBans: return 56
        case .banUserFromGuild: return 57
        case .setGuildMfaLevel: return 58
        case .pruneGuild: return 59
        case .createGuild: return 60
        case .updateGuildWelcomeScreen: return 61
        case .updateGuild: return 62
        case .updateGuildWidgetSettings: return 63
        case .leaveGuild: return 64
        case .deleteGuildIntegration: return 65
        case .unbanUserFromGuild: return 66
        case .deleteGuild: return 67
        case .getGuildTemplate: return 68
        case .listGuildTemplates: return 69
        case .syncGuildTemplate: return 70
        case .createGuildFromTemplate: return 71
        case .createGuildTemplate: return 72
        case .updateGuildTemplate: return 73
        case .deleteGuildTemplate: return 74
        case .createInteractionResponse: return 75
        case .listGuildInvites: return 76
        case .inviteResolve: return 77
        case .listChannelInvites: return 78
        case .createChannelInvite: return 79
        case .inviteRevoke: return 80
        case .getMyGuildMember: return 81
        case .getGuildMember: return 82
        case .listGuildMembers: return 83
        case .searchGuildMembers: return 84
        case .addGuildMember: return 85
        case .updateMyGuildMember: return 86
        case .updateGuildMember: return 87
        case .deleteGuildMember: return 88
        case .getMessage: return 89
        case .listMessageReactionsByEmoji: return 90
        case .listMessages: return 91
        case .addMyMessageReaction: return 92
        case .bulkDeleteMessages: return 93
        case .crosspostMessage: return 94
        case .createMessage: return 95
        case .updateMessage: return 96
        case .deleteMessage: return 97
        case .deleteAllMessageReactions: return 98
        case .deleteMyMessageReaction: return 99
        case .deleteUserMessageReaction: return 100
        case .deleteAllMessageReactionsByEmoji: return 101
        case .getMyOauth2Application: return 102
        case .listGuildRoles: return 103
        case .addGuildMemberRole: return 104
        case .createGuildRole: return 105
        case .updateGuildRole: return 106
        case .bulkUpdateGuildRoles: return 107
        case .deleteGuildRole: return 108
        case .deleteGuildMemberRole: return 109
        case .getApplicationRoleConnectionsMetadata: return 110
        case .getApplicationUserRoleConnection: return 111
        case .updateApplicationRoleConnectionsMetadata: return 112
        case .updateApplicationUserRoleConnection: return 113
        case .getGuildScheduledEvent: return 114
        case .listGuildScheduledEvents: return 115
        case .listGuildScheduledEventUsers: return 116
        case .createGuildScheduledEvent: return 117
        case .updateGuildScheduledEvent: return 118
        case .deleteGuildScheduledEvent: return 119
        case .getStageInstance: return 120
        case .createStageInstance: return 121
        case .updateStageInstance: return 122
        case .deleteStageInstance: return 123
        case .listStickerPacks: return 124
        case .getSticker: return 125
        case .listGuildStickers: return 126
        case .getGuildSticker: return 127
        case .createGuildSticker: return 128
        case .updateGuildSticker: return 129
        case .deleteGuildSticker: return 130
        case .getThreadMember: return 131
        case .listThreadMembers: return 132
        case .getActiveGuildThreads: return 133
        case .listPublicArchivedThreads: return 134
        case .listMyPrivateArchivedThreads: return 135
        case .listPrivateArchivedThreads: return 136
        case .addThreadMember: return 137
        case .joinThread: return 138
        case .createThreadFromMessage: return 139
        case .createThread: return 140
        case .deleteThreadMember: return 141
        case .leaveThread: return 142
        case .listMyConnections: return 143
        case .getMyUser: return 144
        case .getUser: return 145
        case .updateMyUser: return 146
        case .listVoiceRegions: return 147
        case .listGuildVoiceRegions: return 148
        case .updateSelfVoiceState: return 149
        case .updateVoiceState: return 150
        case .getWebhooksMessagesOriginal: return 151
        case .getWebhookMessage: return 152
        case .getWebhookByToken: return 153
        case .listChannelWebhooks: return 154
        case .getWebhook: return 155
        case .getGuildWebhooks: return 156
        case .executeWebhook: return 157
        case .createWebhook: return 158
        case .patchWebhooksMessagesOriginal: return 159
        case .updateWebhookMessage: return 160
        case .updateWebhookByToken: return 161
        case .updateWebhook: return 162
        case .deleteWebhooksMessagesOriginal: return 163
        case .deleteWebhookMessage: return 164
        case .deleteWebhookByToken: return 165
        case .deleteWebhook: return 166
        }
    }
}