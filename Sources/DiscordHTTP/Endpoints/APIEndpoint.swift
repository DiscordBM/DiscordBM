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
    
    case getChannel(channelId: String)
    case listPinnedMessages(channelId: String)
    case listGuildChannels(guildId: String)
    case setChannelPermissionOverwrite(channelId: String, overwriteId: String)
    case pinMessage(channelId: String, messageId: String)
    case addGroupDmUser(channelId: String, userId: String)
    case triggerTypingIndicator(channelId: String)
    case followChannel(channelId: String)
    case createDm
    case createGuildChannel(guildId: String)
    case updateChannel(channelId: String)
    case bulkUpdateGuildChannels(guildId: String)
    case deleteChannelPermissionOverwrite(channelId: String, overwriteId: String)
    case deleteChannel(channelId: String)
    case unpinMessage(channelId: String, messageId: String)
    case deleteGroupDmUser(channelId: String, userId: String)
    
    // MARK: Commands
    /// https://discord.com/developers/docs/interactions/application-commands
    
    case getApplicationCommand(applicationId: String, commandId: String)
    case listGuildApplicationCommands(applicationId: String, guildId: String)
    case getGuildApplicationCommandPermissions(applicationId: String, guildId: String, commandId: String)
    case listGuildApplicationCommandPermissions(applicationId: String, guildId: String)
    case getGuildApplicationCommand(applicationId: String, guildId: String, commandId: String)
    case listApplicationCommands(applicationId: String)
    case bulkSetGuildApplicationCommands(applicationId: String, guildId: String)
    case setGuildApplicationCommandPermissions(applicationId: String, guildId: String, commandId: String)
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
    case getGuildVanityUrl(guildId: String)
    case previewPruneGuild(guildId: String)
    case listMyGuilds
    case getGuildWidgetSettings(guildId: String)
    case getGuild(guildId: String)
    case getGuildPreview(guildId: String)
    case getGuildWidgetPng(guildId: String)
    case getGuildBan(guildId: String, userId: String)
    case getGuildWelcomeScreen(guildId: String)
    case listGuildBans(guildId: String)
    case getGuildWidget(guildId: String)
    case banUserFromGuild(guildId: String, userId: String)
    case pruneGuild(guildId: String)
    case setGuildMfaLevel(guildId: String)
    case createGuild
    case updateGuildWidgetSettings(guildId: String)
    case updateGuild(guildId: String)
    case updateGuildWelcomeScreen(guildId: String)
    case leaveGuild(guildId: String)
    case deleteGuild(guildId: String)
    case unbanUserFromGuild(guildId: String, userId: String)
    case deleteGuildIntegration(guildId: String, integrationId: String)
    
    // MARK: Guild Templates
    /// https://discord.com/developers/docs/resources/guild-template
    
    case listGuildTemplates(guildId: String)
    case getGuildTemplate(code: String)
    case syncGuildTemplate(guildId: String, code: String)
    case createGuildTemplate(guildId: String)
    case createGuildFromTemplate(code: String)
    case updateGuildTemplate(guildId: String, code: String)
    case deleteGuildTemplate(guildId: String, code: String)
    
    // MARK: Interactions
    /// https://discord.com/developers/docs/interactions/receiving-and-responding
    
    case createInteractionResponse(interactionId: String, interactionToken: String)
    
    // MARK: Invites
    /// https://discord.com/developers/docs/resources/invite
    
    case listChannelInvites(channelId: String)
    case listGuildInvites(guildId: String)
    case inviteResolve(code: String)
    case createChannelInvite(channelId: String)
    case inviteRevoke(code: String)
    
    // MARK: Members
    /// https://discord.com/developers/docs/resources/guild
    
    case searchGuildMembers(guildId: String)
    case getGuildMember(guildId: String, userId: String)
    case listGuildMembers(guildId: String)
    case getMyGuildMember(guildId: String)
    case addGuildMember(guildId: String, userId: String)
    case updateMyGuildMember(guildId: String)
    case updateGuildMember(guildId: String, userId: String)
    case deleteGuildMember(guildId: String, userId: String)
    
    // MARK: Messages
    /// https://discord.com/developers/docs/resources/channel
    
    case listMessages(channelId: String)
    case listMessageReactionsByEmoji(channelId: String, messageId: String, emojiName: String)
    case getMessage(channelId: String, messageId: String)
    case addMyMessageReaction(channelId: String, messageId: String, emojiName: String)
    case createMessage(channelId: String)
    case bulkDeleteMessages(channelId: String)
    case crosspostMessage(channelId: String, messageId: String)
    case updateMessage(channelId: String, messageId: String)
    case deleteAllMessageReactionsByEmoji(channelId: String, messageId: String, emojiName: String)
    case deleteUserMessageReaction(channelId: String, messageId: String, emojiName: String, userId: String)
    case deleteAllMessageReactions(channelId: String, messageId: String)
    case deleteMyMessageReaction(channelId: String, messageId: String, emojiName: String)
    case deleteMessage(channelId: String, messageId: String)
    
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
    
    case getApplicationUserRoleConnection(applicationId: String)
    case getApplicationRoleConnectionsMetadata(applicationId: String)
    case updateApplicationUserRoleConnection(applicationId: String)
    case updateApplicationRoleConnectionsMetadata(applicationId: String)
    
    // MARK: Scheduled Events
    /// https://discord.com/developers/docs/resources/guild-scheduled-event
    
    case listGuildScheduledEventUsers(guildId: String, guildScheduledEventId: String)
    case listGuildScheduledEvents(guildId: String)
    case getGuildScheduledEvent(guildId: String, guildScheduledEventId: String)
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
    
    case listGuildStickers(guildId: String)
    case getSticker(stickerId: String)
    case listStickerPacks
    case getGuildSticker(guildId: String, stickerId: String)
    case createGuildSticker(guildId: String)
    case updateGuildSticker(guildId: String, stickerId: String)
    case deleteGuildSticker(guildId: String, stickerId: String)
    
    // MARK: Threads
    /// https://discord.com/developers/docs/resources/channel
    
    case getThreadMember(channelId: String, userId: String)
    case listThreadMembers(channelId: String)
    case listPublicArchivedThreads(channelId: String)
    case listPrivateArchivedThreads(channelId: String)
    case listMyPrivateArchivedThreads(channelId: String)
    case getActiveGuildThreads(guildId: String)
    case addThreadMember(channelId: String, userId: String)
    case joinThread(channelId: String)
    case createThread(channelId: String)
    case createThreadFromMessage(channelId: String, messageId: String)
    case deleteThreadMember(channelId: String, userId: String)
    case leaveThread(channelId: String)
    
    // MARK: Users
    /// https://discord.com/developers/docs/resources/user
    
    case getUser(userId: String)
    case getMyUser
    case listMyConnections
    case updateMyUser
    
    // MARK: Voice
    /// https://discord.com/developers/docs/resources/voice#list-voice-regions
    
    case listVoiceRegions
    case listGuildVoiceRegions(guildId: String)
    case updateVoiceState(guildId: String, userId: String)
    case updateSelfVoiceState(guildId: String)
    
    // MARK: Webhooks
    /// https://discord.com/developers/docs/resources/webhook
    
    case listChannelWebhooks(channelId: String)
    case getWebhookMessage(webhookId: String, webhookToken: String, messageId: String)
    case getGuildWebhooks(guildId: String)
    case getWebhookByToken(webhookId: String, webhookToken: String)
    case getWebhook(webhookId: String)
    case getWebhooksMessagesOriginal(webhookId: String, webhookToken: String)
    case createWebhook(channelId: String)
    case executeWebhook(webhookId: String, webhookToken: String)
    case updateWebhookMessage(webhookId: String, webhookToken: String, messageId: String)
    case updateWebhookByToken(webhookId: String, webhookToken: String)
    case updateWebhook(webhookId: String)
    case patchWebhooksMessagesOriginal(webhookId: String, webhookToken: String)
    case deleteWebhookMessage(webhookId: String, webhookToken: String, messageId: String)
    case deleteWebhookByToken(webhookId: String, webhookToken: String)
    case deleteWebhook(webhookId: String)
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
        case let .getChannel(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)"
        case let .listPinnedMessages(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/pins"
        case let .listGuildChannels(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/channels"
        case let .setChannelPermissionOverwrite(channelId, overwriteId):
            let channelId = encoded(channelId)
            let overwriteId = encoded(overwriteId)
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case let .pinMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .addGroupDmUser(channelId, userId):
            let channelId = encoded(channelId)
            let userId = encoded(userId)
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .triggerTypingIndicator(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/typing"
        case let .followChannel(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/followers"
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
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            let channelId = encoded(channelId)
            let overwriteId = encoded(overwriteId)
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case let .deleteChannel(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)"
        case let .unpinMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .deleteGroupDmUser(channelId, userId):
            let channelId = encoded(channelId)
            let userId = encoded(userId)
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .getApplicationCommand(applicationId, commandId):
            let applicationId = encoded(applicationId)
            let commandId = encoded(commandId)
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .listGuildApplicationCommands(applicationId, guildId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            let commandId = encoded(commandId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = encoded(applicationId)
            let guildId = encoded(guildId)
            let commandId = encoded(commandId)
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .listApplicationCommands(applicationId):
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
        case let .getGuildVanityUrl(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/vanity-url"
        case let .previewPruneGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/prune"
        case .listMyGuilds:
            suffix = "users/@me/guilds"
        case let .getGuildWidgetSettings(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/widget"
        case let .getGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)"
        case let .getGuildPreview(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/preview"
        case let .getGuildWidgetPng(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/widget.png"
        case let .getGuildBan(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildWelcomeScreen(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .listGuildBans(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/bans"
        case let .getGuildWidget(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/widget.json"
        case let .banUserFromGuild(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .pruneGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/prune"
        case let .setGuildMfaLevel(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/mfa"
        case .createGuild:
            suffix = "guilds"
        case let .updateGuildWidgetSettings(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/widget"
        case let .updateGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)"
        case let .updateGuildWelcomeScreen(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .leaveGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "users/@me/guilds/\(guildId)"
        case let .deleteGuild(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)"
        case let .unbanUserFromGuild(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .deleteGuildIntegration(guildId, integrationId):
            let guildId = encoded(guildId)
            let integrationId = encoded(integrationId)
            suffix = "guilds/\(guildId)/integrations/\(integrationId)"
        case let .listGuildTemplates(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/templates"
        case let .getGuildTemplate(code):
            let code = encoded(code)
            suffix = "guilds/templates/\(code)"
        case let .syncGuildTemplate(guildId, code):
            let guildId = encoded(guildId)
            let code = encoded(code)
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .createGuildTemplate(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/templates"
        case let .createGuildFromTemplate(code):
            let code = encoded(code)
            suffix = "guilds/templates/\(code)"
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
        case let .listChannelInvites(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/invites"
        case let .listGuildInvites(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/invites"
        case let .inviteResolve(code):
            let code = encoded(code)
            suffix = "invites/\(code)"
        case let .createChannelInvite(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/invites"
        case let .inviteRevoke(code):
            let code = encoded(code)
            suffix = "invites/\(code)"
        case let .searchGuildMembers(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/members/search"
        case let .getGuildMember(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .listGuildMembers(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/members"
        case let .getMyGuildMember(guildId):
            let guildId = encoded(guildId)
            suffix = "users/@me/guilds/\(guildId)/member"
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
        case let .listMessages(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/messages"
        case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            let emojiName = encoded(emojiName)
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .getMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .addMyMessageReaction(channelId, messageId, emojiName):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            let emojiName = encoded(emojiName)
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .createMessage(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/messages"
        case let .bulkDeleteMessages(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/messages/bulk-delete"
        case let .crosspostMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)/crosspost"
        case let .updateMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            let emojiName = encoded(emojiName)
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            let emojiName = encoded(emojiName)
            let userId = encoded(userId)
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/\(userId)"
        case let .deleteAllMessageReactions(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions"
        case let .deleteMyMessageReaction(channelId, messageId, emojiName):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            let emojiName = encoded(emojiName)
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .deleteMessage(channelId, messageId):
            let channelId = encoded(channelId)
            let messageId = encoded(messageId)
            suffix = "channels/\(channelId)/messages/\(messageId)"
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
        case let .getApplicationUserRoleConnection(applicationId):
            let applicationId = encoded(applicationId)
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .getApplicationRoleConnectionsMetadata(applicationId):
            let applicationId = encoded(applicationId)
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .updateApplicationUserRoleConnection(applicationId):
            let applicationId = encoded(applicationId)
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .updateApplicationRoleConnectionsMetadata(applicationId):
            let applicationId = encoded(applicationId)
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            let guildId = encoded(guildId)
            let guildScheduledEventId = encoded(guildScheduledEventId)
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)/users"
        case let .listGuildScheduledEvents(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
            let guildId = encoded(guildId)
            let guildScheduledEventId = encoded(guildScheduledEventId)
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
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
        case let .listGuildStickers(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/stickers"
        case let .getSticker(stickerId):
            let stickerId = encoded(stickerId)
            suffix = "stickers/\(stickerId)"
        case .listStickerPacks:
            suffix = "sticker-packs"
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
        case let .listPublicArchivedThreads(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/threads/archived/public"
        case let .listPrivateArchivedThreads(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/threads/archived/private"
        case let .listMyPrivateArchivedThreads(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/users/@me/threads/archived/private"
        case let .getActiveGuildThreads(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/threads/active"
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
        case let .getUser(userId):
            let userId = encoded(userId)
            suffix = "users/\(userId)"
        case .getMyUser:
            suffix = "users/@me"
        case .listMyConnections:
            suffix = "users/@me/connections"
        case .updateMyUser:
            suffix = "users/@me"
        case .listVoiceRegions:
            suffix = "voice/regions"
        case let .listGuildVoiceRegions(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/regions"
        case let .updateVoiceState(guildId, userId):
            let guildId = encoded(guildId)
            let userId = encoded(userId)
            suffix = "guilds/\(guildId)/voice-states/\(userId)"
        case let .updateSelfVoiceState(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/voice-states/@me"
        case let .listChannelWebhooks(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/webhooks"
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            let messageId = encoded(messageId)
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .getGuildWebhooks(guildId):
            let guildId = encoded(guildId)
            suffix = "guilds/\(guildId)/webhooks"
        case let .getWebhookByToken(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .getWebhook(webhookId):
            let webhookId = encoded(webhookId)
            suffix = "webhooks/\(webhookId)"
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .createWebhook(channelId):
            let channelId = encoded(channelId)
            suffix = "channels/\(channelId)/webhooks"
        case let .executeWebhook(webhookId, webhookToken):
            let webhookId = encoded(webhookId)
            let webhookToken = encoded(webhookToken)
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
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
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
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
        case let .getChannel(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)"
        case let .listPinnedMessages(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/pins"
        case let .listGuildChannels(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/channels"
        case let .setChannelPermissionOverwrite(channelId, overwriteId):
            let channelId = channelId.urlPathEncoded()
            let overwriteId = overwriteId.urlPathEncoded()
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case let .pinMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .addGroupDmUser(channelId, userId):
            let channelId = channelId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .triggerTypingIndicator(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/typing"
        case let .followChannel(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/followers"
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
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            let channelId = channelId.urlPathEncoded()
            let overwriteId = overwriteId.urlPathEncoded()
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case let .deleteChannel(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)"
        case let .unpinMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .deleteGroupDmUser(channelId, userId):
            let channelId = channelId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .getApplicationCommand(applicationId, commandId):
            let applicationId = applicationId.urlPathEncoded()
            let commandId = commandId.urlPathEncoded()
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .listGuildApplicationCommands(applicationId, guildId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            let commandId = commandId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = applicationId.urlPathEncoded()
            let guildId = guildId.urlPathEncoded()
            let commandId = commandId.urlPathEncoded()
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .listApplicationCommands(applicationId):
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
        case let .getGuildVanityUrl(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/vanity-url"
        case let .previewPruneGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/prune"
        case .listMyGuilds:
            suffix = "users/@me/guilds"
        case let .getGuildWidgetSettings(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/widget"
        case let .getGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)"
        case let .getGuildPreview(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/preview"
        case let .getGuildWidgetPng(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/widget.png"
        case let .getGuildBan(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildWelcomeScreen(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .listGuildBans(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/bans"
        case let .getGuildWidget(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/widget.json"
        case let .banUserFromGuild(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .pruneGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/prune"
        case let .setGuildMfaLevel(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/mfa"
        case .createGuild:
            suffix = "guilds"
        case let .updateGuildWidgetSettings(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/widget"
        case let .updateGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)"
        case let .updateGuildWelcomeScreen(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .leaveGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "users/@me/guilds/\(guildId)"
        case let .deleteGuild(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)"
        case let .unbanUserFromGuild(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .deleteGuildIntegration(guildId, integrationId):
            let guildId = guildId.urlPathEncoded()
            let integrationId = integrationId.urlPathEncoded()
            suffix = "guilds/\(guildId)/integrations/\(integrationId)"
        case let .listGuildTemplates(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/templates"
        case let .getGuildTemplate(code):
            let code = code.urlPathEncoded()
            suffix = "guilds/templates/\(code)"
        case let .syncGuildTemplate(guildId, code):
            let guildId = guildId.urlPathEncoded()
            let code = code.urlPathEncoded()
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .createGuildTemplate(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/templates"
        case let .createGuildFromTemplate(code):
            let code = code.urlPathEncoded()
            suffix = "guilds/templates/\(code)"
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
        case let .listChannelInvites(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/invites"
        case let .listGuildInvites(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/invites"
        case let .inviteResolve(code):
            let code = code.urlPathEncoded()
            suffix = "invites/\(code)"
        case let .createChannelInvite(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/invites"
        case let .inviteRevoke(code):
            let code = code.urlPathEncoded()
            suffix = "invites/\(code)"
        case let .searchGuildMembers(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members/search"
        case let .getGuildMember(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .listGuildMembers(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/members"
        case let .getMyGuildMember(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "users/@me/guilds/\(guildId)/member"
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
        case let .listMessages(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages"
        case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .getMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .addMyMessageReaction(channelId, messageId, emojiName):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .createMessage(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages"
        case let .bulkDeleteMessages(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/bulk-delete"
        case let .crosspostMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/crosspost"
        case let .updateMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            let emojiName = emojiName.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/\(userId)"
        case let .deleteAllMessageReactions(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions"
        case let .deleteMyMessageReaction(channelId, messageId, emojiName):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .deleteMessage(channelId, messageId):
            let channelId = channelId.urlPathEncoded()
            let messageId = messageId.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)"
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
        case let .getApplicationUserRoleConnection(applicationId):
            let applicationId = applicationId.urlPathEncoded()
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .getApplicationRoleConnectionsMetadata(applicationId):
            let applicationId = applicationId.urlPathEncoded()
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .updateApplicationUserRoleConnection(applicationId):
            let applicationId = applicationId.urlPathEncoded()
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .updateApplicationRoleConnectionsMetadata(applicationId):
            let applicationId = applicationId.urlPathEncoded()
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            let guildId = guildId.urlPathEncoded()
            let guildScheduledEventId = guildScheduledEventId.urlPathEncoded()
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)/users"
        case let .listGuildScheduledEvents(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
            let guildId = guildId.urlPathEncoded()
            let guildScheduledEventId = guildScheduledEventId.urlPathEncoded()
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
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
        case let .listGuildStickers(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/stickers"
        case let .getSticker(stickerId):
            let stickerId = stickerId.urlPathEncoded()
            suffix = "stickers/\(stickerId)"
        case .listStickerPacks:
            suffix = "sticker-packs"
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
        case let .listPublicArchivedThreads(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/threads/archived/public"
        case let .listPrivateArchivedThreads(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/threads/archived/private"
        case let .listMyPrivateArchivedThreads(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/users/@me/threads/archived/private"
        case let .getActiveGuildThreads(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/threads/active"
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
        case let .getUser(userId):
            let userId = userId.urlPathEncoded()
            suffix = "users/\(userId)"
        case .getMyUser:
            suffix = "users/@me"
        case .listMyConnections:
            suffix = "users/@me/connections"
        case .updateMyUser:
            suffix = "users/@me"
        case .listVoiceRegions:
            suffix = "voice/regions"
        case let .listGuildVoiceRegions(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/regions"
        case let .updateVoiceState(guildId, userId):
            let guildId = guildId.urlPathEncoded()
            let userId = userId.urlPathEncoded()
            suffix = "guilds/\(guildId)/voice-states/\(userId)"
        case let .updateSelfVoiceState(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/voice-states/@me"
        case let .listChannelWebhooks(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/webhooks"
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            let messageId = messageId.urlPathEncoded()
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .getGuildWebhooks(guildId):
            let guildId = guildId.urlPathEncoded()
            suffix = "guilds/\(guildId)/webhooks"
        case let .getWebhookByToken(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .getWebhook(webhookId):
            let webhookId = webhookId.urlPathEncoded()
            suffix = "webhooks/\(webhookId)"
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .createWebhook(channelId):
            let channelId = channelId.urlPathEncoded()
            suffix = "channels/\(channelId)/webhooks"
        case let .executeWebhook(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
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
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
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
        case let .deleteWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = webhookId.urlPathEncoded()
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
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
        case .getChannel: return .GET
        case .listPinnedMessages: return .GET
        case .listGuildChannels: return .GET
        case .setChannelPermissionOverwrite: return .PUT
        case .pinMessage: return .PUT
        case .addGroupDmUser: return .PUT
        case .triggerTypingIndicator: return .POST
        case .followChannel: return .POST
        case .createDm: return .POST
        case .createGuildChannel: return .POST
        case .updateChannel: return .PATCH
        case .bulkUpdateGuildChannels: return .PATCH
        case .deleteChannelPermissionOverwrite: return .DELETE
        case .deleteChannel: return .DELETE
        case .unpinMessage: return .DELETE
        case .deleteGroupDmUser: return .DELETE
        case .getApplicationCommand: return .GET
        case .listGuildApplicationCommands: return .GET
        case .getGuildApplicationCommandPermissions: return .GET
        case .listGuildApplicationCommandPermissions: return .GET
        case .getGuildApplicationCommand: return .GET
        case .listApplicationCommands: return .GET
        case .bulkSetGuildApplicationCommands: return .PUT
        case .setGuildApplicationCommandPermissions: return .PUT
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
        case .getGuildVanityUrl: return .GET
        case .previewPruneGuild: return .GET
        case .listMyGuilds: return .GET
        case .getGuildWidgetSettings: return .GET
        case .getGuild: return .GET
        case .getGuildPreview: return .GET
        case .getGuildWidgetPng: return .GET
        case .getGuildBan: return .GET
        case .getGuildWelcomeScreen: return .GET
        case .listGuildBans: return .GET
        case .getGuildWidget: return .GET
        case .banUserFromGuild: return .PUT
        case .pruneGuild: return .POST
        case .setGuildMfaLevel: return .POST
        case .createGuild: return .POST
        case .updateGuildWidgetSettings: return .PATCH
        case .updateGuild: return .PATCH
        case .updateGuildWelcomeScreen: return .PATCH
        case .leaveGuild: return .DELETE
        case .deleteGuild: return .DELETE
        case .unbanUserFromGuild: return .DELETE
        case .deleteGuildIntegration: return .DELETE
        case .listGuildTemplates: return .GET
        case .getGuildTemplate: return .GET
        case .syncGuildTemplate: return .PUT
        case .createGuildTemplate: return .POST
        case .createGuildFromTemplate: return .POST
        case .updateGuildTemplate: return .PATCH
        case .deleteGuildTemplate: return .DELETE
        case .createInteractionResponse: return .POST
        case .listChannelInvites: return .GET
        case .listGuildInvites: return .GET
        case .inviteResolve: return .GET
        case .createChannelInvite: return .POST
        case .inviteRevoke: return .DELETE
        case .searchGuildMembers: return .GET
        case .getGuildMember: return .GET
        case .listGuildMembers: return .GET
        case .getMyGuildMember: return .GET
        case .addGuildMember: return .PUT
        case .updateMyGuildMember: return .PATCH
        case .updateGuildMember: return .PATCH
        case .deleteGuildMember: return .DELETE
        case .listMessages: return .GET
        case .listMessageReactionsByEmoji: return .GET
        case .getMessage: return .GET
        case .addMyMessageReaction: return .PUT
        case .createMessage: return .POST
        case .bulkDeleteMessages: return .POST
        case .crosspostMessage: return .POST
        case .updateMessage: return .PATCH
        case .deleteAllMessageReactionsByEmoji: return .DELETE
        case .deleteUserMessageReaction: return .DELETE
        case .deleteAllMessageReactions: return .DELETE
        case .deleteMyMessageReaction: return .DELETE
        case .deleteMessage: return .DELETE
        case .getMyOauth2Application: return .GET
        case .listGuildRoles: return .GET
        case .addGuildMemberRole: return .PUT
        case .createGuildRole: return .POST
        case .bulkUpdateGuildRoles: return .PATCH
        case .updateGuildRole: return .PATCH
        case .deleteGuildMemberRole: return .DELETE
        case .deleteGuildRole: return .DELETE
        case .getApplicationUserRoleConnection: return .GET
        case .getApplicationRoleConnectionsMetadata: return .GET
        case .updateApplicationUserRoleConnection: return .PUT
        case .updateApplicationRoleConnectionsMetadata: return .PUT
        case .listGuildScheduledEventUsers: return .GET
        case .listGuildScheduledEvents: return .GET
        case .getGuildScheduledEvent: return .GET
        case .createGuildScheduledEvent: return .POST
        case .updateGuildScheduledEvent: return .PATCH
        case .deleteGuildScheduledEvent: return .DELETE
        case .getStageInstance: return .GET
        case .createStageInstance: return .POST
        case .updateStageInstance: return .PATCH
        case .deleteStageInstance: return .DELETE
        case .listGuildStickers: return .GET
        case .getSticker: return .GET
        case .listStickerPacks: return .GET
        case .getGuildSticker: return .GET
        case .createGuildSticker: return .POST
        case .updateGuildSticker: return .PATCH
        case .deleteGuildSticker: return .DELETE
        case .getThreadMember: return .GET
        case .listThreadMembers: return .GET
        case .listPublicArchivedThreads: return .GET
        case .listPrivateArchivedThreads: return .GET
        case .listMyPrivateArchivedThreads: return .GET
        case .getActiveGuildThreads: return .GET
        case .addThreadMember: return .PUT
        case .joinThread: return .PUT
        case .createThread: return .POST
        case .createThreadFromMessage: return .POST
        case .deleteThreadMember: return .DELETE
        case .leaveThread: return .DELETE
        case .getUser: return .GET
        case .getMyUser: return .GET
        case .listMyConnections: return .GET
        case .updateMyUser: return .PATCH
        case .listVoiceRegions: return .GET
        case .listGuildVoiceRegions: return .GET
        case .updateVoiceState: return .PATCH
        case .updateSelfVoiceState: return .PATCH
        case .listChannelWebhooks: return .GET
        case .getWebhookMessage: return .GET
        case .getGuildWebhooks: return .GET
        case .getWebhookByToken: return .GET
        case .getWebhook: return .GET
        case .getWebhooksMessagesOriginal: return .GET
        case .createWebhook: return .POST
        case .executeWebhook: return .POST
        case .updateWebhookMessage: return .PATCH
        case .updateWebhookByToken: return .PATCH
        case .updateWebhook: return .PATCH
        case .patchWebhooksMessagesOriginal: return .PATCH
        case .deleteWebhookMessage: return .DELETE
        case .deleteWebhookByToken: return .DELETE
        case .deleteWebhook: return .DELETE
        case .deleteWebhooksMessagesOriginal: return .DELETE
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
        case .getChannel: return false
        case .listPinnedMessages: return false
        case .listGuildChannels: return false
        case .setChannelPermissionOverwrite: return false
        case .pinMessage: return false
        case .addGroupDmUser: return false
        case .triggerTypingIndicator: return false
        case .followChannel: return false
        case .createDm: return false
        case .createGuildChannel: return false
        case .updateChannel: return false
        case .bulkUpdateGuildChannels: return false
        case .deleteChannelPermissionOverwrite: return false
        case .deleteChannel: return false
        case .unpinMessage: return false
        case .deleteGroupDmUser: return false
        case .getApplicationCommand: return false
        case .listGuildApplicationCommands: return false
        case .getGuildApplicationCommandPermissions: return false
        case .listGuildApplicationCommandPermissions: return false
        case .getGuildApplicationCommand: return false
        case .listApplicationCommands: return false
        case .bulkSetGuildApplicationCommands: return false
        case .setGuildApplicationCommandPermissions: return false
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
        case .getGuildVanityUrl: return false
        case .previewPruneGuild: return false
        case .listMyGuilds: return false
        case .getGuildWidgetSettings: return false
        case .getGuild: return false
        case .getGuildPreview: return false
        case .getGuildWidgetPng: return false
        case .getGuildBan: return false
        case .getGuildWelcomeScreen: return false
        case .listGuildBans: return false
        case .getGuildWidget: return false
        case .banUserFromGuild: return false
        case .pruneGuild: return false
        case .setGuildMfaLevel: return false
        case .createGuild: return false
        case .updateGuildWidgetSettings: return false
        case .updateGuild: return false
        case .updateGuildWelcomeScreen: return false
        case .leaveGuild: return false
        case .deleteGuild: return false
        case .unbanUserFromGuild: return false
        case .deleteGuildIntegration: return false
        case .listGuildTemplates: return false
        case .getGuildTemplate: return false
        case .syncGuildTemplate: return false
        case .createGuildTemplate: return false
        case .createGuildFromTemplate: return false
        case .updateGuildTemplate: return false
        case .deleteGuildTemplate: return false
        case .createInteractionResponse: return true
        case .listChannelInvites: return false
        case .listGuildInvites: return false
        case .inviteResolve: return false
        case .createChannelInvite: return false
        case .inviteRevoke: return false
        case .searchGuildMembers: return false
        case .getGuildMember: return false
        case .listGuildMembers: return false
        case .getMyGuildMember: return false
        case .addGuildMember: return false
        case .updateMyGuildMember: return false
        case .updateGuildMember: return false
        case .deleteGuildMember: return false
        case .listMessages: return false
        case .listMessageReactionsByEmoji: return false
        case .getMessage: return false
        case .addMyMessageReaction: return false
        case .createMessage: return false
        case .bulkDeleteMessages: return false
        case .crosspostMessage: return false
        case .updateMessage: return false
        case .deleteAllMessageReactionsByEmoji: return false
        case .deleteUserMessageReaction: return false
        case .deleteAllMessageReactions: return false
        case .deleteMyMessageReaction: return false
        case .deleteMessage: return false
        case .getMyOauth2Application: return false
        case .listGuildRoles: return false
        case .addGuildMemberRole: return false
        case .createGuildRole: return false
        case .bulkUpdateGuildRoles: return false
        case .updateGuildRole: return false
        case .deleteGuildMemberRole: return false
        case .deleteGuildRole: return false
        case .getApplicationUserRoleConnection: return false
        case .getApplicationRoleConnectionsMetadata: return false
        case .updateApplicationUserRoleConnection: return false
        case .updateApplicationRoleConnectionsMetadata: return false
        case .listGuildScheduledEventUsers: return false
        case .listGuildScheduledEvents: return false
        case .getGuildScheduledEvent: return false
        case .createGuildScheduledEvent: return false
        case .updateGuildScheduledEvent: return false
        case .deleteGuildScheduledEvent: return false
        case .getStageInstance: return false
        case .createStageInstance: return false
        case .updateStageInstance: return false
        case .deleteStageInstance: return false
        case .listGuildStickers: return false
        case .getSticker: return false
        case .listStickerPacks: return false
        case .getGuildSticker: return false
        case .createGuildSticker: return false
        case .updateGuildSticker: return false
        case .deleteGuildSticker: return false
        case .getThreadMember: return false
        case .listThreadMembers: return false
        case .listPublicArchivedThreads: return false
        case .listPrivateArchivedThreads: return false
        case .listMyPrivateArchivedThreads: return false
        case .getActiveGuildThreads: return false
        case .addThreadMember: return false
        case .joinThread: return false
        case .createThread: return false
        case .createThreadFromMessage: return false
        case .deleteThreadMember: return false
        case .leaveThread: return false
        case .getUser: return false
        case .getMyUser: return false
        case .listMyConnections: return false
        case .updateMyUser: return false
        case .listVoiceRegions: return false
        case .listGuildVoiceRegions: return false
        case .updateVoiceState: return false
        case .updateSelfVoiceState: return false
        case .listChannelWebhooks: return false
        case .getWebhookMessage: return false
        case .getGuildWebhooks: return false
        case .getWebhookByToken: return false
        case .getWebhook: return false
        case .getWebhooksMessagesOriginal: return false
        case .createWebhook: return false
        case .executeWebhook: return false
        case .updateWebhookMessage: return false
        case .updateWebhookByToken: return false
        case .updateWebhook: return false
        case .patchWebhooksMessagesOriginal: return false
        case .deleteWebhookMessage: return false
        case .deleteWebhookByToken: return false
        case .deleteWebhook: return false
        case .deleteWebhooksMessagesOriginal: return false
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
        case .getChannel: return false
        case .listPinnedMessages: return false
        case .listGuildChannels: return false
        case .setChannelPermissionOverwrite: return false
        case .pinMessage: return false
        case .addGroupDmUser: return false
        case .triggerTypingIndicator: return false
        case .followChannel: return false
        case .createDm: return false
        case .createGuildChannel: return false
        case .updateChannel: return false
        case .bulkUpdateGuildChannels: return false
        case .deleteChannelPermissionOverwrite: return false
        case .deleteChannel: return false
        case .unpinMessage: return false
        case .deleteGroupDmUser: return false
        case .getApplicationCommand: return false
        case .listGuildApplicationCommands: return false
        case .getGuildApplicationCommandPermissions: return false
        case .listGuildApplicationCommandPermissions: return false
        case .getGuildApplicationCommand: return false
        case .listApplicationCommands: return false
        case .bulkSetGuildApplicationCommands: return false
        case .setGuildApplicationCommandPermissions: return false
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
        case .getGuildVanityUrl: return false
        case .previewPruneGuild: return false
        case .listMyGuilds: return false
        case .getGuildWidgetSettings: return false
        case .getGuild: return false
        case .getGuildPreview: return false
        case .getGuildWidgetPng: return false
        case .getGuildBan: return false
        case .getGuildWelcomeScreen: return false
        case .listGuildBans: return false
        case .getGuildWidget: return false
        case .banUserFromGuild: return false
        case .pruneGuild: return false
        case .setGuildMfaLevel: return false
        case .createGuild: return false
        case .updateGuildWidgetSettings: return false
        case .updateGuild: return false
        case .updateGuildWelcomeScreen: return false
        case .leaveGuild: return false
        case .deleteGuild: return false
        case .unbanUserFromGuild: return false
        case .deleteGuildIntegration: return false
        case .listGuildTemplates: return false
        case .getGuildTemplate: return false
        case .syncGuildTemplate: return false
        case .createGuildTemplate: return false
        case .createGuildFromTemplate: return false
        case .updateGuildTemplate: return false
        case .deleteGuildTemplate: return false
        case .createInteractionResponse: return false
        case .listChannelInvites: return false
        case .listGuildInvites: return false
        case .inviteResolve: return false
        case .createChannelInvite: return false
        case .inviteRevoke: return false
        case .searchGuildMembers: return false
        case .getGuildMember: return false
        case .listGuildMembers: return false
        case .getMyGuildMember: return false
        case .addGuildMember: return false
        case .updateMyGuildMember: return false
        case .updateGuildMember: return false
        case .deleteGuildMember: return false
        case .listMessages: return false
        case .listMessageReactionsByEmoji: return false
        case .getMessage: return false
        case .addMyMessageReaction: return false
        case .createMessage: return false
        case .bulkDeleteMessages: return false
        case .crosspostMessage: return false
        case .updateMessage: return false
        case .deleteAllMessageReactionsByEmoji: return false
        case .deleteUserMessageReaction: return false
        case .deleteAllMessageReactions: return false
        case .deleteMyMessageReaction: return false
        case .deleteMessage: return false
        case .getMyOauth2Application: return false
        case .listGuildRoles: return false
        case .addGuildMemberRole: return false
        case .createGuildRole: return false
        case .bulkUpdateGuildRoles: return false
        case .updateGuildRole: return false
        case .deleteGuildMemberRole: return false
        case .deleteGuildRole: return false
        case .getApplicationUserRoleConnection: return false
        case .getApplicationRoleConnectionsMetadata: return false
        case .updateApplicationUserRoleConnection: return false
        case .updateApplicationRoleConnectionsMetadata: return false
        case .listGuildScheduledEventUsers: return false
        case .listGuildScheduledEvents: return false
        case .getGuildScheduledEvent: return false
        case .createGuildScheduledEvent: return false
        case .updateGuildScheduledEvent: return false
        case .deleteGuildScheduledEvent: return false
        case .getStageInstance: return false
        case .createStageInstance: return false
        case .updateStageInstance: return false
        case .deleteStageInstance: return false
        case .listGuildStickers: return false
        case .getSticker: return false
        case .listStickerPacks: return false
        case .getGuildSticker: return false
        case .createGuildSticker: return false
        case .updateGuildSticker: return false
        case .deleteGuildSticker: return false
        case .getThreadMember: return false
        case .listThreadMembers: return false
        case .listPublicArchivedThreads: return false
        case .listPrivateArchivedThreads: return false
        case .listMyPrivateArchivedThreads: return false
        case .getActiveGuildThreads: return false
        case .addThreadMember: return false
        case .joinThread: return false
        case .createThread: return false
        case .createThreadFromMessage: return false
        case .deleteThreadMember: return false
        case .leaveThread: return false
        case .getUser: return false
        case .getMyUser: return false
        case .listMyConnections: return false
        case .updateMyUser: return false
        case .listVoiceRegions: return false
        case .listGuildVoiceRegions: return false
        case .updateVoiceState: return false
        case .updateSelfVoiceState: return false
        case .listChannelWebhooks: return false
        case .getWebhookMessage: return true
        case .getGuildWebhooks: return false
        case .getWebhookByToken: return true
        case .getWebhook: return false
        case .getWebhooksMessagesOriginal: return true
        case .createWebhook: return false
        case .executeWebhook: return true
        case .updateWebhookMessage: return true
        case .updateWebhookByToken: return true
        case .updateWebhook: return false
        case .patchWebhooksMessagesOriginal: return true
        case .deleteWebhookMessage: return true
        case .deleteWebhookByToken: return true
        case .deleteWebhook: return false
        case .deleteWebhooksMessagesOriginal: return true
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
        case let .getChannel(channelId):
            return [channelId]
        case let .listPinnedMessages(channelId):
            return [channelId]
        case let .listGuildChannels(guildId):
            return [guildId]
        case let .setChannelPermissionOverwrite(channelId, overwriteId):
            return [channelId, overwriteId]
        case let .pinMessage(channelId, messageId):
            return [channelId, messageId]
        case let .addGroupDmUser(channelId, userId):
            return [channelId, userId]
        case let .triggerTypingIndicator(channelId):
            return [channelId]
        case let .followChannel(channelId):
            return [channelId]
        case .createDm:
            return []
        case let .createGuildChannel(guildId):
            return [guildId]
        case let .updateChannel(channelId):
            return [channelId]
        case let .bulkUpdateGuildChannels(guildId):
            return [guildId]
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            return [channelId, overwriteId]
        case let .deleteChannel(channelId):
            return [channelId]
        case let .unpinMessage(channelId, messageId):
            return [channelId, messageId]
        case let .deleteGroupDmUser(channelId, userId):
            return [channelId, userId]
        case let .getApplicationCommand(applicationId, commandId):
            return [applicationId, commandId]
        case let .listGuildApplicationCommands(applicationId, guildId):
            return [applicationId, guildId]
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            return [applicationId, guildId, commandId]
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            return [applicationId, guildId]
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            return [applicationId, guildId, commandId]
        case let .listApplicationCommands(applicationId):
            return [applicationId]
        case let .bulkSetGuildApplicationCommands(applicationId, guildId):
            return [applicationId, guildId]
        case let .setGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            return [applicationId, guildId, commandId]
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
        case let .getGuildVanityUrl(guildId):
            return [guildId]
        case let .previewPruneGuild(guildId):
            return [guildId]
        case .listMyGuilds:
            return []
        case let .getGuildWidgetSettings(guildId):
            return [guildId]
        case let .getGuild(guildId):
            return [guildId]
        case let .getGuildPreview(guildId):
            return [guildId]
        case let .getGuildWidgetPng(guildId):
            return [guildId]
        case let .getGuildBan(guildId, userId):
            return [guildId, userId]
        case let .getGuildWelcomeScreen(guildId):
            return [guildId]
        case let .listGuildBans(guildId):
            return [guildId]
        case let .getGuildWidget(guildId):
            return [guildId]
        case let .banUserFromGuild(guildId, userId):
            return [guildId, userId]
        case let .pruneGuild(guildId):
            return [guildId]
        case let .setGuildMfaLevel(guildId):
            return [guildId]
        case .createGuild:
            return []
        case let .updateGuildWidgetSettings(guildId):
            return [guildId]
        case let .updateGuild(guildId):
            return [guildId]
        case let .updateGuildWelcomeScreen(guildId):
            return [guildId]
        case let .leaveGuild(guildId):
            return [guildId]
        case let .deleteGuild(guildId):
            return [guildId]
        case let .unbanUserFromGuild(guildId, userId):
            return [guildId, userId]
        case let .deleteGuildIntegration(guildId, integrationId):
            return [guildId, integrationId]
        case let .listGuildTemplates(guildId):
            return [guildId]
        case let .getGuildTemplate(code):
            return [code]
        case let .syncGuildTemplate(guildId, code):
            return [guildId, code]
        case let .createGuildTemplate(guildId):
            return [guildId]
        case let .createGuildFromTemplate(code):
            return [code]
        case let .updateGuildTemplate(guildId, code):
            return [guildId, code]
        case let .deleteGuildTemplate(guildId, code):
            return [guildId, code]
        case let .createInteractionResponse(interactionId, interactionToken):
            return [interactionId, interactionToken]
        case let .listChannelInvites(channelId):
            return [channelId]
        case let .listGuildInvites(guildId):
            return [guildId]
        case let .inviteResolve(code):
            return [code]
        case let .createChannelInvite(channelId):
            return [channelId]
        case let .inviteRevoke(code):
            return [code]
        case let .searchGuildMembers(guildId):
            return [guildId]
        case let .getGuildMember(guildId, userId):
            return [guildId, userId]
        case let .listGuildMembers(guildId):
            return [guildId]
        case let .getMyGuildMember(guildId):
            return [guildId]
        case let .addGuildMember(guildId, userId):
            return [guildId, userId]
        case let .updateMyGuildMember(guildId):
            return [guildId]
        case let .updateGuildMember(guildId, userId):
            return [guildId, userId]
        case let .deleteGuildMember(guildId, userId):
            return [guildId, userId]
        case let .listMessages(channelId):
            return [channelId]
        case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
            return [channelId, messageId, emojiName]
        case let .getMessage(channelId, messageId):
            return [channelId, messageId]
        case let .addMyMessageReaction(channelId, messageId, emojiName):
            return [channelId, messageId, emojiName]
        case let .createMessage(channelId):
            return [channelId]
        case let .bulkDeleteMessages(channelId):
            return [channelId]
        case let .crosspostMessage(channelId, messageId):
            return [channelId, messageId]
        case let .updateMessage(channelId, messageId):
            return [channelId, messageId]
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            return [channelId, messageId, emojiName]
        case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
            return [channelId, messageId, emojiName, userId]
        case let .deleteAllMessageReactions(channelId, messageId):
            return [channelId, messageId]
        case let .deleteMyMessageReaction(channelId, messageId, emojiName):
            return [channelId, messageId, emojiName]
        case let .deleteMessage(channelId, messageId):
            return [channelId, messageId]
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
        case let .getApplicationUserRoleConnection(applicationId):
            return [applicationId]
        case let .getApplicationRoleConnectionsMetadata(applicationId):
            return [applicationId]
        case let .updateApplicationUserRoleConnection(applicationId):
            return [applicationId]
        case let .updateApplicationRoleConnectionsMetadata(applicationId):
            return [applicationId]
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            return [guildId, guildScheduledEventId]
        case let .listGuildScheduledEvents(guildId):
            return [guildId]
        case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
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
        case let .listGuildStickers(guildId):
            return [guildId]
        case let .getSticker(stickerId):
            return [stickerId]
        case .listStickerPacks:
            return []
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
        case let .listPublicArchivedThreads(channelId):
            return [channelId]
        case let .listPrivateArchivedThreads(channelId):
            return [channelId]
        case let .listMyPrivateArchivedThreads(channelId):
            return [channelId]
        case let .getActiveGuildThreads(guildId):
            return [guildId]
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
        case let .getUser(userId):
            return [userId]
        case .getMyUser:
            return []
        case .listMyConnections:
            return []
        case .updateMyUser:
            return []
        case .listVoiceRegions:
            return []
        case let .listGuildVoiceRegions(guildId):
            return [guildId]
        case let .updateVoiceState(guildId, userId):
            return [guildId, userId]
        case let .updateSelfVoiceState(guildId):
            return [guildId]
        case let .listChannelWebhooks(channelId):
            return [channelId]
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            return [webhookId, webhookToken, messageId]
        case let .getGuildWebhooks(guildId):
            return [guildId]
        case let .getWebhookByToken(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .getWebhook(webhookId):
            return [webhookId]
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .createWebhook(channelId):
            return [channelId]
        case let .executeWebhook(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .updateWebhookMessage(webhookId, webhookToken, messageId):
            return [webhookId, webhookToken, messageId]
        case let .updateWebhookByToken(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .updateWebhook(webhookId):
            return [webhookId]
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
            return [webhookId, webhookToken, messageId]
        case let .deleteWebhookByToken(webhookId, webhookToken):
            return [webhookId, webhookToken]
        case let .deleteWebhook(webhookId):
            return [webhookId]
        case let .deleteWebhooksMessagesOriginal(webhookId, webhookToken):
            return [webhookId, webhookToken]
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
        case .getChannel: return 7
        case .listPinnedMessages: return 8
        case .listGuildChannels: return 9
        case .setChannelPermissionOverwrite: return 10
        case .pinMessage: return 11
        case .addGroupDmUser: return 12
        case .triggerTypingIndicator: return 13
        case .followChannel: return 14
        case .createDm: return 15
        case .createGuildChannel: return 16
        case .updateChannel: return 17
        case .bulkUpdateGuildChannels: return 18
        case .deleteChannelPermissionOverwrite: return 19
        case .deleteChannel: return 20
        case .unpinMessage: return 21
        case .deleteGroupDmUser: return 22
        case .getApplicationCommand: return 23
        case .listGuildApplicationCommands: return 24
        case .getGuildApplicationCommandPermissions: return 25
        case .listGuildApplicationCommandPermissions: return 26
        case .getGuildApplicationCommand: return 27
        case .listApplicationCommands: return 28
        case .bulkSetGuildApplicationCommands: return 29
        case .setGuildApplicationCommandPermissions: return 30
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
        case .getGuildVanityUrl: return 46
        case .previewPruneGuild: return 47
        case .listMyGuilds: return 48
        case .getGuildWidgetSettings: return 49
        case .getGuild: return 50
        case .getGuildPreview: return 51
        case .getGuildWidgetPng: return 52
        case .getGuildBan: return 53
        case .getGuildWelcomeScreen: return 54
        case .listGuildBans: return 55
        case .getGuildWidget: return 56
        case .banUserFromGuild: return 57
        case .pruneGuild: return 58
        case .setGuildMfaLevel: return 59
        case .createGuild: return 60
        case .updateGuildWidgetSettings: return 61
        case .updateGuild: return 62
        case .updateGuildWelcomeScreen: return 63
        case .leaveGuild: return 64
        case .deleteGuild: return 65
        case .unbanUserFromGuild: return 66
        case .deleteGuildIntegration: return 67
        case .listGuildTemplates: return 68
        case .getGuildTemplate: return 69
        case .syncGuildTemplate: return 70
        case .createGuildTemplate: return 71
        case .createGuildFromTemplate: return 72
        case .updateGuildTemplate: return 73
        case .deleteGuildTemplate: return 74
        case .createInteractionResponse: return 75
        case .listChannelInvites: return 76
        case .listGuildInvites: return 77
        case .inviteResolve: return 78
        case .createChannelInvite: return 79
        case .inviteRevoke: return 80
        case .searchGuildMembers: return 81
        case .getGuildMember: return 82
        case .listGuildMembers: return 83
        case .getMyGuildMember: return 84
        case .addGuildMember: return 85
        case .updateMyGuildMember: return 86
        case .updateGuildMember: return 87
        case .deleteGuildMember: return 88
        case .listMessages: return 89
        case .listMessageReactionsByEmoji: return 90
        case .getMessage: return 91
        case .addMyMessageReaction: return 92
        case .createMessage: return 93
        case .bulkDeleteMessages: return 94
        case .crosspostMessage: return 95
        case .updateMessage: return 96
        case .deleteAllMessageReactionsByEmoji: return 97
        case .deleteUserMessageReaction: return 98
        case .deleteAllMessageReactions: return 99
        case .deleteMyMessageReaction: return 100
        case .deleteMessage: return 101
        case .getMyOauth2Application: return 102
        case .listGuildRoles: return 103
        case .addGuildMemberRole: return 104
        case .createGuildRole: return 105
        case .bulkUpdateGuildRoles: return 106
        case .updateGuildRole: return 107
        case .deleteGuildMemberRole: return 108
        case .deleteGuildRole: return 109
        case .getApplicationUserRoleConnection: return 110
        case .getApplicationRoleConnectionsMetadata: return 111
        case .updateApplicationUserRoleConnection: return 112
        case .updateApplicationRoleConnectionsMetadata: return 113
        case .listGuildScheduledEventUsers: return 114
        case .listGuildScheduledEvents: return 115
        case .getGuildScheduledEvent: return 116
        case .createGuildScheduledEvent: return 117
        case .updateGuildScheduledEvent: return 118
        case .deleteGuildScheduledEvent: return 119
        case .getStageInstance: return 120
        case .createStageInstance: return 121
        case .updateStageInstance: return 122
        case .deleteStageInstance: return 123
        case .listGuildStickers: return 124
        case .getSticker: return 125
        case .listStickerPacks: return 126
        case .getGuildSticker: return 127
        case .createGuildSticker: return 128
        case .updateGuildSticker: return 129
        case .deleteGuildSticker: return 130
        case .getThreadMember: return 131
        case .listThreadMembers: return 132
        case .listPublicArchivedThreads: return 133
        case .listPrivateArchivedThreads: return 134
        case .listMyPrivateArchivedThreads: return 135
        case .getActiveGuildThreads: return 136
        case .addThreadMember: return 137
        case .joinThread: return 138
        case .createThread: return 139
        case .createThreadFromMessage: return 140
        case .deleteThreadMember: return 141
        case .leaveThread: return 142
        case .getUser: return 143
        case .getMyUser: return 144
        case .listMyConnections: return 145
        case .updateMyUser: return 146
        case .listVoiceRegions: return 147
        case .listGuildVoiceRegions: return 148
        case .updateVoiceState: return 149
        case .updateSelfVoiceState: return 150
        case .listChannelWebhooks: return 151
        case .getWebhookMessage: return 152
        case .getGuildWebhooks: return 153
        case .getWebhookByToken: return 154
        case .getWebhook: return 155
        case .getWebhooksMessagesOriginal: return 156
        case .createWebhook: return 157
        case .executeWebhook: return 158
        case .updateWebhookMessage: return 159
        case .updateWebhookByToken: return 160
        case .updateWebhook: return 161
        case .patchWebhooksMessagesOriginal: return 162
        case .deleteWebhookMessage: return 163
        case .deleteWebhookByToken: return 164
        case .deleteWebhook: return 165
        case .deleteWebhooksMessagesOriginal: return 166
        }
    }
}