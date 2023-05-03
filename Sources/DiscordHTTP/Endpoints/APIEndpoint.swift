// DO NOT EDIT. Auto-generated using the GenerateAPIEndpoints command plugin.

/// If you want to add an endpoint that somehow doesn't exist, you'll need to
/// properly edit `/Plugins/GenerateAPIEndpointsExec/Resources/openapi.yml`, then trigger
/// the `GenerateAPIEndpoints` plugin (right click on `DiscordBM` in the file navigator)

import DiscordModels
import NIOHTTP1

public enum APIEndpoint: Endpoint {

    // MARK: AutoMod
    /// https://discord.com/developers/docs/resources/auto-moderation
    
    case getAutoModerationRule(guildId: GuildSnowflake, ruleId: RuleSnowflake)
    case listAutoModerationRules(guildId: GuildSnowflake)
    case createAutoModerationRule(guildId: GuildSnowflake)
    case updateAutoModerationRule(guildId: GuildSnowflake, ruleId: RuleSnowflake)
    case deleteAutoModerationRule(guildId: GuildSnowflake, ruleId: RuleSnowflake)
    
    // MARK: Audit Log
    /// https://discord.com/developers/docs/resources/audit-log
    
    case listGuildAuditLogEntries(guildId: GuildSnowflake)
    
    // MARK: Channels
    /// https://discord.com/developers/docs/resources/channel
    
    case getChannel(channelId: ChannelSnowflake)
    case listPinnedMessages(channelId: ChannelSnowflake)
    case addGroupDmUser(channelId: ChannelSnowflake, userId: UserSnowflake)
    case pinMessage(channelId: ChannelSnowflake, messageId: MessageSnowflake)
    case setChannelPermissionOverwrite(channelId: ChannelSnowflake, overwriteId: AnySnowflake)
    case createDm
    case followChannel(channelId: ChannelSnowflake)
    case triggerTypingIndicator(channelId: ChannelSnowflake)
    case updateChannel(channelId: ChannelSnowflake)
    case deleteChannel(channelId: ChannelSnowflake)
    case deleteChannelPermissionOverwrite(channelId: ChannelSnowflake, overwriteId: AnySnowflake)
    case deleteGroupDmUser(channelId: ChannelSnowflake, userId: UserSnowflake)
    case unpinMessage(channelId: ChannelSnowflake, messageId: MessageSnowflake)
    
    // MARK: Commands
    /// https://discord.com/developers/docs/interactions/application-commands
    
    case getApplicationCommand(applicationId: ApplicationSnowflake, commandId: CommandSnowflake)
    case getGuildApplicationCommand(applicationId: ApplicationSnowflake, guildId: GuildSnowflake, commandId: CommandSnowflake)
    case getGuildApplicationCommandPermissions(applicationId: ApplicationSnowflake, guildId: GuildSnowflake, commandId: CommandSnowflake)
    case listApplicationCommands(applicationId: ApplicationSnowflake)
    case listGuildApplicationCommandPermissions(applicationId: ApplicationSnowflake, guildId: GuildSnowflake)
    case listGuildApplicationCommands(applicationId: ApplicationSnowflake, guildId: GuildSnowflake)
    case bulkSetApplicationCommands(applicationId: ApplicationSnowflake)
    case bulkSetGuildApplicationCommands(applicationId: ApplicationSnowflake, guildId: GuildSnowflake)
    case setGuildApplicationCommandPermissions(applicationId: ApplicationSnowflake, guildId: GuildSnowflake, commandId: CommandSnowflake)
    case createApplicationCommand(applicationId: ApplicationSnowflake)
    case createGuildApplicationCommand(applicationId: ApplicationSnowflake, guildId: GuildSnowflake)
    case updateApplicationCommand(applicationId: ApplicationSnowflake, commandId: CommandSnowflake)
    case updateGuildApplicationCommand(applicationId: ApplicationSnowflake, guildId: GuildSnowflake, commandId: CommandSnowflake)
    case deleteApplicationCommand(applicationId: ApplicationSnowflake, commandId: CommandSnowflake)
    case deleteGuildApplicationCommand(applicationId: ApplicationSnowflake, guildId: GuildSnowflake, commandId: CommandSnowflake)
    
    // MARK: Emoji
    /// https://discord.com/developers/docs/resources/emoji
    
    case getGuildEmoji(guildId: GuildSnowflake, emojiId: EmojiSnowflake)
    case listGuildEmojis(guildId: GuildSnowflake)
    case createGuildEmoji(guildId: GuildSnowflake)
    case updateGuildEmoji(guildId: GuildSnowflake, emojiId: EmojiSnowflake)
    case deleteGuildEmoji(guildId: GuildSnowflake, emojiId: EmojiSnowflake)
    
    // MARK: Gateway
    /// https://discord.com/developers/docs/topics/gateway
    
    case getBotGateway
    case getGateway
    
    // MARK: Guilds
    /// https://discord.com/developers/docs/resources/guild
    
    case getGuild(guildId: GuildSnowflake)
    case getGuildBan(guildId: GuildSnowflake, userId: UserSnowflake)
    case getGuildOnboarding(guildId: GuildSnowflake)
    case getGuildPreview(guildId: GuildSnowflake)
    case getGuildVanityUrl(guildId: GuildSnowflake)
    case getGuildWelcomeScreen(guildId: GuildSnowflake)
    case getGuildWidget(guildId: GuildSnowflake)
    case getGuildWidgetPng(guildId: GuildSnowflake)
    case getGuildWidgetSettings(guildId: GuildSnowflake)
    case listGuildBans(guildId: GuildSnowflake)
    case listGuildChannels(guildId: GuildSnowflake)
    case listGuildIntegrations(guildId: GuildSnowflake)
    case listOwnGuilds
    case previewPruneGuild(guildId: GuildSnowflake)
    case banUserFromGuild(guildId: GuildSnowflake, userId: UserSnowflake)
    case createGuild
    case createGuildChannel(guildId: GuildSnowflake)
    case pruneGuild(guildId: GuildSnowflake)
    case setGuildMfaLevel(guildId: GuildSnowflake)
    case bulkUpdateGuildChannels(guildId: GuildSnowflake)
    case updateGuild(guildId: GuildSnowflake)
    case updateGuildWelcomeScreen(guildId: GuildSnowflake)
    case updateGuildWidgetSettings(guildId: GuildSnowflake)
    case deleteGuild(guildId: GuildSnowflake)
    case deleteGuildIntegration(guildId: GuildSnowflake, integrationId: IntegrationSnowflake)
    case leaveGuild(guildId: GuildSnowflake)
    case unbanUserFromGuild(guildId: GuildSnowflake, userId: UserSnowflake)
    
    // MARK: Guild Templates
    /// https://discord.com/developers/docs/resources/guild-template
    
    case getGuildTemplate(code: String)
    case listGuildTemplates(guildId: GuildSnowflake)
    case syncGuildTemplate(guildId: GuildSnowflake, code: String)
    case createGuildFromTemplate(code: String)
    case createGuildTemplate(guildId: GuildSnowflake)
    case updateGuildTemplate(guildId: GuildSnowflake, code: String)
    case deleteGuildTemplate(guildId: GuildSnowflake, code: String)
    
    // MARK: Interactions
    /// https://discord.com/developers/docs/interactions/receiving-and-responding
    
    case getFollowupMessage(applicationId: ApplicationSnowflake, interactionToken: String, messageId: MessageSnowflake)
    case getOriginalInteractionResponse(applicationId: ApplicationSnowflake, interactionToken: String)
    case createFollowupMessage(applicationId: ApplicationSnowflake, interactionToken: String)
    case createInteractionResponse(interactionId: InteractionSnowflake, interactionToken: String)
    case updateFollowupMessage(applicationId: ApplicationSnowflake, interactionToken: String, messageId: MessageSnowflake)
    case updateOriginalInteractionResponse(applicationId: ApplicationSnowflake, interactionToken: String)
    case deleteFollowupMessage(applicationId: ApplicationSnowflake, interactionToken: String, messageId: MessageSnowflake)
    case deleteOriginalInteractionResponse(applicationId: ApplicationSnowflake, interactionToken: String)
    
    // MARK: Invites
    /// https://discord.com/developers/docs/resources/invite
    
    case inviteResolve(code: String)
    case listChannelInvites(channelId: ChannelSnowflake)
    case listGuildInvites(guildId: GuildSnowflake)
    case createChannelInvite(channelId: ChannelSnowflake)
    case inviteRevoke(code: String)
    
    // MARK: Members
    /// https://discord.com/developers/docs/resources/guild
    
    case getGuildMember(guildId: GuildSnowflake, userId: UserSnowflake)
    case getOwnGuildMember(guildId: GuildSnowflake)
    case listGuildMembers(guildId: GuildSnowflake)
    case searchGuildMembers(guildId: GuildSnowflake)
    case addGuildMember(guildId: GuildSnowflake, userId: UserSnowflake)
    case updateGuildMember(guildId: GuildSnowflake, userId: UserSnowflake)
    case updateOwnGuildMember(guildId: GuildSnowflake)
    case deleteGuildMember(guildId: GuildSnowflake, userId: UserSnowflake)
    
    // MARK: Messages
    /// https://discord.com/developers/docs/resources/channel
    
    case getMessage(channelId: ChannelSnowflake, messageId: MessageSnowflake)
    case listMessageReactionsByEmoji(channelId: ChannelSnowflake, messageId: MessageSnowflake, emojiName: String)
    case listMessages(channelId: ChannelSnowflake)
    case addOwnMessageReaction(channelId: ChannelSnowflake, messageId: MessageSnowflake, emojiName: String)
    case bulkDeleteMessages(channelId: ChannelSnowflake)
    case createMessage(channelId: ChannelSnowflake)
    case crosspostMessage(channelId: ChannelSnowflake, messageId: MessageSnowflake)
    case updateMessage(channelId: ChannelSnowflake, messageId: MessageSnowflake)
    case deleteAllMessageReactions(channelId: ChannelSnowflake, messageId: MessageSnowflake)
    case deleteAllMessageReactionsByEmoji(channelId: ChannelSnowflake, messageId: MessageSnowflake, emojiName: String)
    case deleteMessage(channelId: ChannelSnowflake, messageId: MessageSnowflake)
    case deleteOwnMessageReaction(channelId: ChannelSnowflake, messageId: MessageSnowflake, emojiName: String)
    case deleteUserMessageReaction(channelId: ChannelSnowflake, messageId: MessageSnowflake, emojiName: String, userId: UserSnowflake)
    
    // MARK: OAuth
    /// https://discord.com/developers/docs/topics/oauth2
    
    case getOwnOauth2Application
    
    // MARK: Roles
    /// https://discord.com/developers/docs/resources/guild
    
    case listGuildRoles(guildId: GuildSnowflake)
    case addGuildMemberRole(guildId: GuildSnowflake, userId: UserSnowflake, roleId: RoleSnowflake)
    case createGuildRole(guildId: GuildSnowflake)
    case bulkUpdateGuildRoles(guildId: GuildSnowflake)
    case updateGuildRole(guildId: GuildSnowflake, roleId: RoleSnowflake)
    case deleteGuildMemberRole(guildId: GuildSnowflake, userId: UserSnowflake, roleId: RoleSnowflake)
    case deleteGuildRole(guildId: GuildSnowflake, roleId: RoleSnowflake)
    
    // MARK: Role Connections
    /// https://discord.com/developers/docs/resources/user
    
    case getApplicationRoleConnectionsMetadata(applicationId: ApplicationSnowflake)
    case getApplicationUserRoleConnection(applicationId: ApplicationSnowflake)
    case updateApplicationRoleConnectionsMetadata(applicationId: ApplicationSnowflake)
    case updateApplicationUserRoleConnection(applicationId: ApplicationSnowflake)
    
    // MARK: Scheduled Events
    /// https://discord.com/developers/docs/resources/guild-scheduled-event
    
    case getGuildScheduledEvent(guildId: GuildSnowflake, guildScheduledEventId: GuildScheduledEventSnowflake)
    case listGuildScheduledEventUsers(guildId: GuildSnowflake, guildScheduledEventId: GuildScheduledEventSnowflake)
    case listGuildScheduledEvents(guildId: GuildSnowflake)
    case createGuildScheduledEvent(guildId: GuildSnowflake)
    case updateGuildScheduledEvent(guildId: GuildSnowflake, guildScheduledEventId: GuildScheduledEventSnowflake)
    case deleteGuildScheduledEvent(guildId: GuildSnowflake, guildScheduledEventId: GuildScheduledEventSnowflake)
    
    // MARK: Stages
    /// https://discord.com/developers/docs/resources/stage-instance
    
    case getStageInstance(channelId: ChannelSnowflake)
    case createStageInstance
    case updateStageInstance(channelId: ChannelSnowflake)
    case deleteStageInstance(channelId: ChannelSnowflake)
    
    // MARK: Stickers
    /// https://discord.com/developers/docs/resources/sticker
    
    case getGuildSticker(guildId: GuildSnowflake, stickerId: StickerSnowflake)
    case getSticker(stickerId: StickerSnowflake)
    case listGuildStickers(guildId: GuildSnowflake)
    case listStickerPacks
    case createGuildSticker(guildId: GuildSnowflake)
    case updateGuildSticker(guildId: GuildSnowflake, stickerId: StickerSnowflake)
    case deleteGuildSticker(guildId: GuildSnowflake, stickerId: StickerSnowflake)
    
    // MARK: Threads
    /// https://discord.com/developers/docs/resources/channel
    
    case getActiveGuildThreads(guildId: GuildSnowflake)
    case getThreadMember(channelId: ChannelSnowflake, userId: UserSnowflake)
    case listOwnPrivateArchivedThreads(channelId: ChannelSnowflake)
    case listPrivateArchivedThreads(channelId: ChannelSnowflake)
    case listPublicArchivedThreads(channelId: ChannelSnowflake)
    case listThreadMembers(channelId: ChannelSnowflake)
    case addThreadMember(channelId: ChannelSnowflake, userId: UserSnowflake)
    case joinThread(channelId: ChannelSnowflake)
    case createThread(channelId: ChannelSnowflake)
    case createThreadFromMessage(channelId: ChannelSnowflake, messageId: MessageSnowflake)
    case createThreadInForumChannel(channelId: ChannelSnowflake)
    case deleteThreadMember(channelId: ChannelSnowflake, userId: UserSnowflake)
    case leaveThread(channelId: ChannelSnowflake)
    
    // MARK: Users
    /// https://discord.com/developers/docs/resources/user
    
    case getOwnUser
    case getUser(userId: UserSnowflake)
    case listOwnConnections
    case updateOwnUser
    
    // MARK: Voice
    /// https://discord.com/developers/docs/resources/voice#list-voice-regions
    
    case listGuildVoiceRegions(guildId: GuildSnowflake)
    case listVoiceRegions
    case updateSelfVoiceState(guildId: GuildSnowflake)
    case updateVoiceState(guildId: GuildSnowflake, userId: UserSnowflake)
    
    // MARK: Webhooks
    /// https://discord.com/developers/docs/resources/webhook
    
    case getGuildWebhooks(guildId: GuildSnowflake)
    case getWebhook(webhookId: WebhookSnowflake)
    case getWebhookByToken(webhookId: WebhookSnowflake, webhookToken: String)
    case getWebhookMessage(webhookId: WebhookSnowflake, webhookToken: String, messageId: MessageSnowflake)
    case getWebhooksMessagesOriginal(webhookId: WebhookSnowflake, webhookToken: String)
    case listChannelWebhooks(channelId: ChannelSnowflake)
    case createWebhook(channelId: ChannelSnowflake)
    case executeWebhook(webhookId: WebhookSnowflake, webhookToken: String)
    case patchWebhooksMessagesOriginal(webhookId: WebhookSnowflake, webhookToken: String)
    case updateWebhook(webhookId: WebhookSnowflake)
    case updateWebhookByToken(webhookId: WebhookSnowflake, webhookToken: String)
    case updateWebhookMessage(webhookId: WebhookSnowflake, webhookToken: String, messageId: MessageSnowflake)
    case deleteWebhook(webhookId: WebhookSnowflake)
    case deleteWebhookByToken(webhookId: WebhookSnowflake, webhookToken: String)
    case deleteWebhookMessage(webhookId: WebhookSnowflake, webhookToken: String, messageId: MessageSnowflake)
    case deleteWebhooksMessagesOriginal(webhookId: WebhookSnowflake, webhookToken: String)

    var urlPrefix: String {
        "https://discord.com/api/v\(DiscordGlobalConfiguration.apiVersion)/"
    }

    public var url: String {
        let suffix: String
        switch self {
        case let .getAutoModerationRule(guildId, ruleId):
            let guildId = guildId.value
            let ruleId = ruleId.value
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .listAutoModerationRules(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/auto-moderation/rules"
        case let .createAutoModerationRule(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/auto-moderation/rules"
        case let .updateAutoModerationRule(guildId, ruleId):
            let guildId = guildId.value
            let ruleId = ruleId.value
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .deleteAutoModerationRule(guildId, ruleId):
            let guildId = guildId.value
            let ruleId = ruleId.value
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .listGuildAuditLogEntries(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/audit-logs"
        case let .getChannel(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)"
        case let .listPinnedMessages(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/pins"
        case let .addGroupDmUser(channelId, userId):
            let channelId = channelId.value
            let userId = userId.value
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .pinMessage(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .setChannelPermissionOverwrite(channelId, overwriteId):
            let channelId = channelId.value
            let overwriteId = overwriteId.value
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case .createDm:
            suffix = "users/@me/channels"
        case let .followChannel(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/followers"
        case let .triggerTypingIndicator(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/typing"
        case let .updateChannel(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)"
        case let .deleteChannel(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)"
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            let channelId = channelId.value
            let overwriteId = overwriteId.value
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case let .deleteGroupDmUser(channelId, userId):
            let channelId = channelId.value
            let userId = userId.value
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .unpinMessage(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .getApplicationCommand(applicationId, commandId):
            let applicationId = applicationId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .listApplicationCommands(applicationId):
            let applicationId = applicationId.value
            suffix = "applications/\(applicationId)/commands"
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
        case let .listGuildApplicationCommands(applicationId, guildId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .bulkSetApplicationCommands(applicationId):
            let applicationId = applicationId.value
            suffix = "applications/\(applicationId)/commands"
        case let .bulkSetGuildApplicationCommands(applicationId, guildId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .setGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .createApplicationCommand(applicationId):
            let applicationId = applicationId.value
            suffix = "applications/\(applicationId)/commands"
        case let .createGuildApplicationCommand(applicationId, guildId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .updateApplicationCommand(applicationId, commandId):
            let applicationId = applicationId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .updateGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .deleteApplicationCommand(applicationId, commandId):
            let applicationId = applicationId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .deleteGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .getGuildEmoji(guildId, emojiId):
            let guildId = guildId.value
            let emojiId = emojiId.value
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case let .listGuildEmojis(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/emojis"
        case let .createGuildEmoji(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/emojis"
        case let .updateGuildEmoji(guildId, emojiId):
            let guildId = guildId.value
            let emojiId = emojiId.value
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case let .deleteGuildEmoji(guildId, emojiId):
            let guildId = guildId.value
            let emojiId = emojiId.value
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case .getBotGateway:
            suffix = "gateway/bot"
        case .getGateway:
            suffix = "gateway"
        case let .getGuild(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)"
        case let .getGuildBan(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildOnboarding(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/onboarding"
        case let .getGuildPreview(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/preview"
        case let .getGuildVanityUrl(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/vanity-url"
        case let .getGuildWelcomeScreen(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .getGuildWidget(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/widget.json"
        case let .getGuildWidgetPng(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/widget.png"
        case let .getGuildWidgetSettings(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/widget"
        case let .listGuildBans(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/bans"
        case let .listGuildChannels(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/channels"
        case let .listGuildIntegrations(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/integrations"
        case .listOwnGuilds:
            suffix = "users/@me/guilds"
        case let .previewPruneGuild(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/prune"
        case let .banUserFromGuild(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case .createGuild:
            suffix = "guilds"
        case let .createGuildChannel(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/channels"
        case let .pruneGuild(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/prune"
        case let .setGuildMfaLevel(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/mfa"
        case let .bulkUpdateGuildChannels(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/channels"
        case let .updateGuild(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)"
        case let .updateGuildWelcomeScreen(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .updateGuildWidgetSettings(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/widget"
        case let .deleteGuild(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)"
        case let .deleteGuildIntegration(guildId, integrationId):
            let guildId = guildId.value
            let integrationId = integrationId.value
            suffix = "guilds/\(guildId)/integrations/\(integrationId)"
        case let .leaveGuild(guildId):
            let guildId = guildId.value
            suffix = "users/@me/guilds/\(guildId)"
        case let .unbanUserFromGuild(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildTemplate(code):
            suffix = "guilds/templates/\(code)"
        case let .listGuildTemplates(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/templates"
        case let .syncGuildTemplate(guildId, code):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .createGuildFromTemplate(code):
            suffix = "guilds/templates/\(code)"
        case let .createGuildTemplate(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/templates"
        case let .updateGuildTemplate(guildId, code):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .deleteGuildTemplate(guildId, code):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .getFollowupMessage(applicationId, interactionToken, messageId):
            let applicationId = applicationId.value
            let messageId = messageId.value
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
        case let .getOriginalInteractionResponse(applicationId, interactionToken):
            let applicationId = applicationId.value
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
        case let .createFollowupMessage(applicationId, interactionToken):
            let applicationId = applicationId.value
            suffix = "webhooks/\(applicationId)/\(interactionToken)"
        case let .createInteractionResponse(interactionId, interactionToken):
            let interactionId = interactionId.value
            suffix = "interactions/\(interactionId)/\(interactionToken)/callback"
        case let .updateFollowupMessage(applicationId, interactionToken, messageId):
            let applicationId = applicationId.value
            let messageId = messageId.value
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
        case let .updateOriginalInteractionResponse(applicationId, interactionToken):
            let applicationId = applicationId.value
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
        case let .deleteFollowupMessage(applicationId, interactionToken, messageId):
            let applicationId = applicationId.value
            let messageId = messageId.value
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
        case let .deleteOriginalInteractionResponse(applicationId, interactionToken):
            let applicationId = applicationId.value
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
        case let .inviteResolve(code):
            suffix = "invites/\(code)"
        case let .listChannelInvites(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/invites"
        case let .listGuildInvites(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/invites"
        case let .createChannelInvite(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/invites"
        case let .inviteRevoke(code):
            suffix = "invites/\(code)"
        case let .getGuildMember(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .getOwnGuildMember(guildId):
            let guildId = guildId.value
            suffix = "users/@me/guilds/\(guildId)/member"
        case let .listGuildMembers(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/members"
        case let .searchGuildMembers(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/members/search"
        case let .addGuildMember(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .updateGuildMember(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .updateOwnGuildMember(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/members/@me"
        case let .deleteGuildMember(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .getMessage(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
            let channelId = channelId.value
            let messageId = messageId.value
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .listMessages(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/messages"
        case let .addOwnMessageReaction(channelId, messageId, emojiName):
            let channelId = channelId.value
            let messageId = messageId.value
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .bulkDeleteMessages(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/messages/bulk-delete"
        case let .createMessage(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/messages"
        case let .crosspostMessage(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/messages/\(messageId)/crosspost"
        case let .updateMessage(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteAllMessageReactions(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions"
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            let channelId = channelId.value
            let messageId = messageId.value
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .deleteMessage(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteOwnMessageReaction(channelId, messageId, emojiName):
            let channelId = channelId.value
            let messageId = messageId.value
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
            let channelId = channelId.value
            let messageId = messageId.value
            let emojiName = emojiName.urlPathEncoded()
            let userId = userId.value
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/\(userId)"
        case .getOwnOauth2Application:
            suffix = "oauth2/applications/@me"
        case let .listGuildRoles(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/roles"
        case let .addGuildMemberRole(guildId, userId, roleId):
            let guildId = guildId.value
            let userId = userId.value
            let roleId = roleId.value
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .createGuildRole(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/roles"
        case let .bulkUpdateGuildRoles(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/roles"
        case let .updateGuildRole(guildId, roleId):
            let guildId = guildId.value
            let roleId = roleId.value
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .deleteGuildMemberRole(guildId, userId, roleId):
            let guildId = guildId.value
            let userId = userId.value
            let roleId = roleId.value
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .deleteGuildRole(guildId, roleId):
            let guildId = guildId.value
            let roleId = roleId.value
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .getApplicationRoleConnectionsMetadata(applicationId):
            let applicationId = applicationId.value
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .getApplicationUserRoleConnection(applicationId):
            let applicationId = applicationId.value
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .updateApplicationRoleConnectionsMetadata(applicationId):
            let applicationId = applicationId.value
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .updateApplicationUserRoleConnection(applicationId):
            let applicationId = applicationId.value
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
            let guildId = guildId.value
            let guildScheduledEventId = guildScheduledEventId.value
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            let guildId = guildId.value
            let guildScheduledEventId = guildScheduledEventId.value
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)/users"
        case let .listGuildScheduledEvents(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .createGuildScheduledEvent(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .updateGuildScheduledEvent(guildId, guildScheduledEventId):
            let guildId = guildId.value
            let guildScheduledEventId = guildScheduledEventId.value
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .deleteGuildScheduledEvent(guildId, guildScheduledEventId):
            let guildId = guildId.value
            let guildScheduledEventId = guildScheduledEventId.value
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .getStageInstance(channelId):
            let channelId = channelId.value
            suffix = "stage-instances/\(channelId)"
        case .createStageInstance:
            suffix = "stage-instances"
        case let .updateStageInstance(channelId):
            let channelId = channelId.value
            suffix = "stage-instances/\(channelId)"
        case let .deleteStageInstance(channelId):
            let channelId = channelId.value
            suffix = "stage-instances/\(channelId)"
        case let .getGuildSticker(guildId, stickerId):
            let guildId = guildId.value
            let stickerId = stickerId.value
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .getSticker(stickerId):
            let stickerId = stickerId.value
            suffix = "stickers/\(stickerId)"
        case let .listGuildStickers(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/stickers"
        case .listStickerPacks:
            suffix = "sticker-packs"
        case let .createGuildSticker(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/stickers"
        case let .updateGuildSticker(guildId, stickerId):
            let guildId = guildId.value
            let stickerId = stickerId.value
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .deleteGuildSticker(guildId, stickerId):
            let guildId = guildId.value
            let stickerId = stickerId.value
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .getActiveGuildThreads(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/threads/active"
        case let .getThreadMember(channelId, userId):
            let channelId = channelId.value
            let userId = userId.value
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .listOwnPrivateArchivedThreads(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/users/@me/threads/archived/private"
        case let .listPrivateArchivedThreads(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/threads/archived/private"
        case let .listPublicArchivedThreads(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/threads/archived/public"
        case let .listThreadMembers(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/thread-members"
        case let .addThreadMember(channelId, userId):
            let channelId = channelId.value
            let userId = userId.value
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .joinThread(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/thread-members/@me"
        case let .createThread(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/threads"
        case let .createThreadFromMessage(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/messages/\(messageId)/threads"
        case let .createThreadInForumChannel(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/threads"
        case let .deleteThreadMember(channelId, userId):
            let channelId = channelId.value
            let userId = userId.value
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .leaveThread(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/thread-members/@me"
        case .getOwnUser:
            suffix = "users/@me"
        case let .getUser(userId):
            let userId = userId.value
            suffix = "users/\(userId)"
        case .listOwnConnections:
            suffix = "users/@me/connections"
        case .updateOwnUser:
            suffix = "users/@me"
        case let .listGuildVoiceRegions(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/regions"
        case .listVoiceRegions:
            suffix = "voice/regions"
        case let .updateSelfVoiceState(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/voice-states/@me"
        case let .updateVoiceState(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/voice-states/\(userId)"
        case let .getGuildWebhooks(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/webhooks"
        case let .getWebhook(webhookId):
            let webhookId = webhookId.value
            suffix = "webhooks/\(webhookId)"
        case let .getWebhookByToken(webhookId, webhookToken):
            let webhookId = webhookId.value
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = webhookId.value
            let messageId = messageId.value
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = webhookId.value
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .listChannelWebhooks(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/webhooks"
        case let .createWebhook(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/webhooks"
        case let .executeWebhook(webhookId, webhookToken):
            let webhookId = webhookId.value
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = webhookId.value
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .updateWebhook(webhookId):
            let webhookId = webhookId.value
            suffix = "webhooks/\(webhookId)"
        case let .updateWebhookByToken(webhookId, webhookToken):
            let webhookId = webhookId.value
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .updateWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = webhookId.value
            let messageId = messageId.value
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .deleteWebhook(webhookId):
            let webhookId = webhookId.value
            suffix = "webhooks/\(webhookId)"
        case let .deleteWebhookByToken(webhookId, webhookToken):
            let webhookId = webhookId.value
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = webhookId.value
            let messageId = messageId.value
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .deleteWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = webhookId.value
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        }
        return urlPrefix + suffix
    }

    public var urlDescription: String {
        let suffix: String
        switch self {
        case let .getAutoModerationRule(guildId, ruleId):
            let guildId = guildId.value
            let ruleId = ruleId.value
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .listAutoModerationRules(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/auto-moderation/rules"
        case let .createAutoModerationRule(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/auto-moderation/rules"
        case let .updateAutoModerationRule(guildId, ruleId):
            let guildId = guildId.value
            let ruleId = ruleId.value
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .deleteAutoModerationRule(guildId, ruleId):
            let guildId = guildId.value
            let ruleId = ruleId.value
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .listGuildAuditLogEntries(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/audit-logs"
        case let .getChannel(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)"
        case let .listPinnedMessages(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/pins"
        case let .addGroupDmUser(channelId, userId):
            let channelId = channelId.value
            let userId = userId.value
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .pinMessage(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .setChannelPermissionOverwrite(channelId, overwriteId):
            let channelId = channelId.value
            let overwriteId = overwriteId.value
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case .createDm:
            suffix = "users/@me/channels"
        case let .followChannel(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/followers"
        case let .triggerTypingIndicator(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/typing"
        case let .updateChannel(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)"
        case let .deleteChannel(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)"
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            let channelId = channelId.value
            let overwriteId = overwriteId.value
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case let .deleteGroupDmUser(channelId, userId):
            let channelId = channelId.value
            let userId = userId.value
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .unpinMessage(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .getApplicationCommand(applicationId, commandId):
            let applicationId = applicationId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .listApplicationCommands(applicationId):
            let applicationId = applicationId.value
            suffix = "applications/\(applicationId)/commands"
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
        case let .listGuildApplicationCommands(applicationId, guildId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .bulkSetApplicationCommands(applicationId):
            let applicationId = applicationId.value
            suffix = "applications/\(applicationId)/commands"
        case let .bulkSetGuildApplicationCommands(applicationId, guildId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .setGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .createApplicationCommand(applicationId):
            let applicationId = applicationId.value
            suffix = "applications/\(applicationId)/commands"
        case let .createGuildApplicationCommand(applicationId, guildId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .updateApplicationCommand(applicationId, commandId):
            let applicationId = applicationId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .updateGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .deleteApplicationCommand(applicationId, commandId):
            let applicationId = applicationId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .deleteGuildApplicationCommand(applicationId, guildId, commandId):
            let applicationId = applicationId.value
            let guildId = guildId.value
            let commandId = commandId.value
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .getGuildEmoji(guildId, emojiId):
            let guildId = guildId.value
            let emojiId = emojiId.value
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case let .listGuildEmojis(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/emojis"
        case let .createGuildEmoji(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/emojis"
        case let .updateGuildEmoji(guildId, emojiId):
            let guildId = guildId.value
            let emojiId = emojiId.value
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case let .deleteGuildEmoji(guildId, emojiId):
            let guildId = guildId.value
            let emojiId = emojiId.value
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case .getBotGateway:
            suffix = "gateway/bot"
        case .getGateway:
            suffix = "gateway"
        case let .getGuild(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)"
        case let .getGuildBan(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildOnboarding(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/onboarding"
        case let .getGuildPreview(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/preview"
        case let .getGuildVanityUrl(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/vanity-url"
        case let .getGuildWelcomeScreen(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .getGuildWidget(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/widget.json"
        case let .getGuildWidgetPng(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/widget.png"
        case let .getGuildWidgetSettings(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/widget"
        case let .listGuildBans(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/bans"
        case let .listGuildChannels(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/channels"
        case let .listGuildIntegrations(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/integrations"
        case .listOwnGuilds:
            suffix = "users/@me/guilds"
        case let .previewPruneGuild(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/prune"
        case let .banUserFromGuild(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case .createGuild:
            suffix = "guilds"
        case let .createGuildChannel(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/channels"
        case let .pruneGuild(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/prune"
        case let .setGuildMfaLevel(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/mfa"
        case let .bulkUpdateGuildChannels(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/channels"
        case let .updateGuild(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)"
        case let .updateGuildWelcomeScreen(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .updateGuildWidgetSettings(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/widget"
        case let .deleteGuild(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)"
        case let .deleteGuildIntegration(guildId, integrationId):
            let guildId = guildId.value
            let integrationId = integrationId.value
            suffix = "guilds/\(guildId)/integrations/\(integrationId)"
        case let .leaveGuild(guildId):
            let guildId = guildId.value
            suffix = "users/@me/guilds/\(guildId)"
        case let .unbanUserFromGuild(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildTemplate(code):
            suffix = "guilds/templates/\(code)"
        case let .listGuildTemplates(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/templates"
        case let .syncGuildTemplate(guildId, code):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .createGuildFromTemplate(code):
            suffix = "guilds/templates/\(code)"
        case let .createGuildTemplate(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/templates"
        case let .updateGuildTemplate(guildId, code):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .deleteGuildTemplate(guildId, code):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .getFollowupMessage(applicationId, interactionToken, messageId):
            let applicationId = applicationId.value
            let messageId = messageId.value
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
        case let .getOriginalInteractionResponse(applicationId, interactionToken):
            let applicationId = applicationId.value
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
        case let .createFollowupMessage(applicationId, interactionToken):
            let applicationId = applicationId.value
            suffix = "webhooks/\(applicationId)/\(interactionToken)"
        case let .createInteractionResponse(interactionId, interactionToken):
            let interactionId = interactionId.value
            suffix = "interactions/\(interactionId)/\(interactionToken)/callback"
        case let .updateFollowupMessage(applicationId, interactionToken, messageId):
            let applicationId = applicationId.value
            let messageId = messageId.value
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
        case let .updateOriginalInteractionResponse(applicationId, interactionToken):
            let applicationId = applicationId.value
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
        case let .deleteFollowupMessage(applicationId, interactionToken, messageId):
            let applicationId = applicationId.value
            let messageId = messageId.value
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
        case let .deleteOriginalInteractionResponse(applicationId, interactionToken):
            let applicationId = applicationId.value
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
        case let .inviteResolve(code):
            suffix = "invites/\(code)"
        case let .listChannelInvites(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/invites"
        case let .listGuildInvites(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/invites"
        case let .createChannelInvite(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/invites"
        case let .inviteRevoke(code):
            suffix = "invites/\(code)"
        case let .getGuildMember(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .getOwnGuildMember(guildId):
            let guildId = guildId.value
            suffix = "users/@me/guilds/\(guildId)/member"
        case let .listGuildMembers(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/members"
        case let .searchGuildMembers(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/members/search"
        case let .addGuildMember(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .updateGuildMember(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .updateOwnGuildMember(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/members/@me"
        case let .deleteGuildMember(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .getMessage(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
            let channelId = channelId.value
            let messageId = messageId.value
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .listMessages(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/messages"
        case let .addOwnMessageReaction(channelId, messageId, emojiName):
            let channelId = channelId.value
            let messageId = messageId.value
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .bulkDeleteMessages(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/messages/bulk-delete"
        case let .createMessage(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/messages"
        case let .crosspostMessage(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/messages/\(messageId)/crosspost"
        case let .updateMessage(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteAllMessageReactions(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions"
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            let channelId = channelId.value
            let messageId = messageId.value
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .deleteMessage(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteOwnMessageReaction(channelId, messageId, emojiName):
            let channelId = channelId.value
            let messageId = messageId.value
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
            let channelId = channelId.value
            let messageId = messageId.value
            let emojiName = emojiName.urlPathEncoded()
            let userId = userId.value
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/\(userId)"
        case .getOwnOauth2Application:
            suffix = "oauth2/applications/@me"
        case let .listGuildRoles(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/roles"
        case let .addGuildMemberRole(guildId, userId, roleId):
            let guildId = guildId.value
            let userId = userId.value
            let roleId = roleId.value
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .createGuildRole(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/roles"
        case let .bulkUpdateGuildRoles(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/roles"
        case let .updateGuildRole(guildId, roleId):
            let guildId = guildId.value
            let roleId = roleId.value
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .deleteGuildMemberRole(guildId, userId, roleId):
            let guildId = guildId.value
            let userId = userId.value
            let roleId = roleId.value
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .deleteGuildRole(guildId, roleId):
            let guildId = guildId.value
            let roleId = roleId.value
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .getApplicationRoleConnectionsMetadata(applicationId):
            let applicationId = applicationId.value
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .getApplicationUserRoleConnection(applicationId):
            let applicationId = applicationId.value
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .updateApplicationRoleConnectionsMetadata(applicationId):
            let applicationId = applicationId.value
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .updateApplicationUserRoleConnection(applicationId):
            let applicationId = applicationId.value
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
            let guildId = guildId.value
            let guildScheduledEventId = guildScheduledEventId.value
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            let guildId = guildId.value
            let guildScheduledEventId = guildScheduledEventId.value
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)/users"
        case let .listGuildScheduledEvents(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .createGuildScheduledEvent(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .updateGuildScheduledEvent(guildId, guildScheduledEventId):
            let guildId = guildId.value
            let guildScheduledEventId = guildScheduledEventId.value
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .deleteGuildScheduledEvent(guildId, guildScheduledEventId):
            let guildId = guildId.value
            let guildScheduledEventId = guildScheduledEventId.value
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .getStageInstance(channelId):
            let channelId = channelId.value
            suffix = "stage-instances/\(channelId)"
        case .createStageInstance:
            suffix = "stage-instances"
        case let .updateStageInstance(channelId):
            let channelId = channelId.value
            suffix = "stage-instances/\(channelId)"
        case let .deleteStageInstance(channelId):
            let channelId = channelId.value
            suffix = "stage-instances/\(channelId)"
        case let .getGuildSticker(guildId, stickerId):
            let guildId = guildId.value
            let stickerId = stickerId.value
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .getSticker(stickerId):
            let stickerId = stickerId.value
            suffix = "stickers/\(stickerId)"
        case let .listGuildStickers(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/stickers"
        case .listStickerPacks:
            suffix = "sticker-packs"
        case let .createGuildSticker(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/stickers"
        case let .updateGuildSticker(guildId, stickerId):
            let guildId = guildId.value
            let stickerId = stickerId.value
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .deleteGuildSticker(guildId, stickerId):
            let guildId = guildId.value
            let stickerId = stickerId.value
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .getActiveGuildThreads(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/threads/active"
        case let .getThreadMember(channelId, userId):
            let channelId = channelId.value
            let userId = userId.value
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .listOwnPrivateArchivedThreads(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/users/@me/threads/archived/private"
        case let .listPrivateArchivedThreads(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/threads/archived/private"
        case let .listPublicArchivedThreads(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/threads/archived/public"
        case let .listThreadMembers(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/thread-members"
        case let .addThreadMember(channelId, userId):
            let channelId = channelId.value
            let userId = userId.value
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .joinThread(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/thread-members/@me"
        case let .createThread(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/threads"
        case let .createThreadFromMessage(channelId, messageId):
            let channelId = channelId.value
            let messageId = messageId.value
            suffix = "channels/\(channelId)/messages/\(messageId)/threads"
        case let .createThreadInForumChannel(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/threads"
        case let .deleteThreadMember(channelId, userId):
            let channelId = channelId.value
            let userId = userId.value
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .leaveThread(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/thread-members/@me"
        case .getOwnUser:
            suffix = "users/@me"
        case let .getUser(userId):
            let userId = userId.value
            suffix = "users/\(userId)"
        case .listOwnConnections:
            suffix = "users/@me/connections"
        case .updateOwnUser:
            suffix = "users/@me"
        case let .listGuildVoiceRegions(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/regions"
        case .listVoiceRegions:
            suffix = "voice/regions"
        case let .updateSelfVoiceState(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/voice-states/@me"
        case let .updateVoiceState(guildId, userId):
            let guildId = guildId.value
            let userId = userId.value
            suffix = "guilds/\(guildId)/voice-states/\(userId)"
        case let .getGuildWebhooks(guildId):
            let guildId = guildId.value
            suffix = "guilds/\(guildId)/webhooks"
        case let .getWebhook(webhookId):
            let webhookId = webhookId.value
            suffix = "webhooks/\(webhookId)"
        case let .getWebhookByToken(webhookId, webhookToken):
            let webhookId = webhookId.value
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = webhookId.value
            let webhookToken = webhookToken.urlPathEncoded().hash
            let messageId = messageId.value
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = webhookId.value
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .listChannelWebhooks(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/webhooks"
        case let .createWebhook(channelId):
            let channelId = channelId.value
            suffix = "channels/\(channelId)/webhooks"
        case let .executeWebhook(webhookId, webhookToken):
            let webhookId = webhookId.value
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = webhookId.value
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .updateWebhook(webhookId):
            let webhookId = webhookId.value
            suffix = "webhooks/\(webhookId)"
        case let .updateWebhookByToken(webhookId, webhookToken):
            let webhookId = webhookId.value
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .updateWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = webhookId.value
            let webhookToken = webhookToken.urlPathEncoded().hash
            let messageId = messageId.value
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .deleteWebhook(webhookId):
            let webhookId = webhookId.value
            suffix = "webhooks/\(webhookId)"
        case let .deleteWebhookByToken(webhookId, webhookToken):
            let webhookId = webhookId.value
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
            let webhookId = webhookId.value
            let webhookToken = webhookToken.urlPathEncoded().hash
            let messageId = messageId.value
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .deleteWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookId = webhookId.value
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
        case .listPinnedMessages: return .GET
        case .addGroupDmUser: return .PUT
        case .pinMessage: return .PUT
        case .setChannelPermissionOverwrite: return .PUT
        case .createDm: return .POST
        case .followChannel: return .POST
        case .triggerTypingIndicator: return .POST
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
        case .getGuildOnboarding: return .GET
        case .getGuildPreview: return .GET
        case .getGuildVanityUrl: return .GET
        case .getGuildWelcomeScreen: return .GET
        case .getGuildWidget: return .GET
        case .getGuildWidgetPng: return .GET
        case .getGuildWidgetSettings: return .GET
        case .listGuildBans: return .GET
        case .listGuildChannels: return .GET
        case .listGuildIntegrations: return .GET
        case .listOwnGuilds: return .GET
        case .previewPruneGuild: return .GET
        case .banUserFromGuild: return .PUT
        case .createGuild: return .POST
        case .createGuildChannel: return .POST
        case .pruneGuild: return .POST
        case .setGuildMfaLevel: return .POST
        case .bulkUpdateGuildChannels: return .PATCH
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
        case .getOwnGuildMember: return .GET
        case .listGuildMembers: return .GET
        case .searchGuildMembers: return .GET
        case .addGuildMember: return .PUT
        case .updateGuildMember: return .PATCH
        case .updateOwnGuildMember: return .PATCH
        case .deleteGuildMember: return .DELETE
        case .getMessage: return .GET
        case .listMessageReactionsByEmoji: return .GET
        case .listMessages: return .GET
        case .addOwnMessageReaction: return .PUT
        case .bulkDeleteMessages: return .POST
        case .createMessage: return .POST
        case .crosspostMessage: return .POST
        case .updateMessage: return .PATCH
        case .deleteAllMessageReactions: return .DELETE
        case .deleteAllMessageReactionsByEmoji: return .DELETE
        case .deleteMessage: return .DELETE
        case .deleteOwnMessageReaction: return .DELETE
        case .deleteUserMessageReaction: return .DELETE
        case .getOwnOauth2Application: return .GET
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
        case .listOwnPrivateArchivedThreads: return .GET
        case .listPrivateArchivedThreads: return .GET
        case .listPublicArchivedThreads: return .GET
        case .listThreadMembers: return .GET
        case .addThreadMember: return .PUT
        case .joinThread: return .PUT
        case .createThread: return .POST
        case .createThreadFromMessage: return .POST
        case .createThreadInForumChannel: return .POST
        case .deleteThreadMember: return .DELETE
        case .leaveThread: return .DELETE
        case .getOwnUser: return .GET
        case .getUser: return .GET
        case .listOwnConnections: return .GET
        case .updateOwnUser: return .PATCH
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
        case .getAutoModerationRule: return true
        case .listAutoModerationRules: return true
        case .createAutoModerationRule: return true
        case .updateAutoModerationRule: return true
        case .deleteAutoModerationRule: return true
        case .listGuildAuditLogEntries: return true
        case .getChannel: return true
        case .listPinnedMessages: return true
        case .addGroupDmUser: return true
        case .pinMessage: return true
        case .setChannelPermissionOverwrite: return true
        case .createDm: return true
        case .followChannel: return true
        case .triggerTypingIndicator: return true
        case .updateChannel: return true
        case .deleteChannel: return true
        case .deleteChannelPermissionOverwrite: return true
        case .deleteGroupDmUser: return true
        case .unpinMessage: return true
        case .getApplicationCommand: return true
        case .getGuildApplicationCommand: return true
        case .getGuildApplicationCommandPermissions: return true
        case .listApplicationCommands: return true
        case .listGuildApplicationCommandPermissions: return true
        case .listGuildApplicationCommands: return true
        case .bulkSetApplicationCommands: return true
        case .bulkSetGuildApplicationCommands: return true
        case .setGuildApplicationCommandPermissions: return true
        case .createApplicationCommand: return true
        case .createGuildApplicationCommand: return true
        case .updateApplicationCommand: return true
        case .updateGuildApplicationCommand: return true
        case .deleteApplicationCommand: return true
        case .deleteGuildApplicationCommand: return true
        case .getGuildEmoji: return true
        case .listGuildEmojis: return true
        case .createGuildEmoji: return true
        case .updateGuildEmoji: return true
        case .deleteGuildEmoji: return true
        case .getBotGateway: return true
        case .getGateway: return true
        case .getGuild: return true
        case .getGuildBan: return true
        case .getGuildOnboarding: return true
        case .getGuildPreview: return true
        case .getGuildVanityUrl: return true
        case .getGuildWelcomeScreen: return true
        case .getGuildWidget: return true
        case .getGuildWidgetPng: return true
        case .getGuildWidgetSettings: return true
        case .listGuildBans: return true
        case .listGuildChannels: return true
        case .listGuildIntegrations: return true
        case .listOwnGuilds: return true
        case .previewPruneGuild: return true
        case .banUserFromGuild: return true
        case .createGuild: return true
        case .createGuildChannel: return true
        case .pruneGuild: return true
        case .setGuildMfaLevel: return true
        case .bulkUpdateGuildChannels: return true
        case .updateGuild: return true
        case .updateGuildWelcomeScreen: return true
        case .updateGuildWidgetSettings: return true
        case .deleteGuild: return true
        case .deleteGuildIntegration: return true
        case .leaveGuild: return true
        case .unbanUserFromGuild: return true
        case .getGuildTemplate: return true
        case .listGuildTemplates: return true
        case .syncGuildTemplate: return true
        case .createGuildFromTemplate: return true
        case .createGuildTemplate: return true
        case .updateGuildTemplate: return true
        case .deleteGuildTemplate: return true
        case .getFollowupMessage: return false
        case .getOriginalInteractionResponse: return false
        case .createFollowupMessage: return false
        case .createInteractionResponse: return false
        case .updateFollowupMessage: return false
        case .updateOriginalInteractionResponse: return false
        case .deleteFollowupMessage: return false
        case .deleteOriginalInteractionResponse: return false
        case .inviteResolve: return true
        case .listChannelInvites: return true
        case .listGuildInvites: return true
        case .createChannelInvite: return true
        case .inviteRevoke: return true
        case .getGuildMember: return true
        case .getOwnGuildMember: return true
        case .listGuildMembers: return true
        case .searchGuildMembers: return true
        case .addGuildMember: return true
        case .updateGuildMember: return true
        case .updateOwnGuildMember: return true
        case .deleteGuildMember: return true
        case .getMessage: return true
        case .listMessageReactionsByEmoji: return true
        case .listMessages: return true
        case .addOwnMessageReaction: return true
        case .bulkDeleteMessages: return true
        case .createMessage: return true
        case .crosspostMessage: return true
        case .updateMessage: return true
        case .deleteAllMessageReactions: return true
        case .deleteAllMessageReactionsByEmoji: return true
        case .deleteMessage: return true
        case .deleteOwnMessageReaction: return true
        case .deleteUserMessageReaction: return true
        case .getOwnOauth2Application: return true
        case .listGuildRoles: return true
        case .addGuildMemberRole: return true
        case .createGuildRole: return true
        case .bulkUpdateGuildRoles: return true
        case .updateGuildRole: return true
        case .deleteGuildMemberRole: return true
        case .deleteGuildRole: return true
        case .getApplicationRoleConnectionsMetadata: return true
        case .getApplicationUserRoleConnection: return true
        case .updateApplicationRoleConnectionsMetadata: return true
        case .updateApplicationUserRoleConnection: return true
        case .getGuildScheduledEvent: return true
        case .listGuildScheduledEventUsers: return true
        case .listGuildScheduledEvents: return true
        case .createGuildScheduledEvent: return true
        case .updateGuildScheduledEvent: return true
        case .deleteGuildScheduledEvent: return true
        case .getStageInstance: return true
        case .createStageInstance: return true
        case .updateStageInstance: return true
        case .deleteStageInstance: return true
        case .getGuildSticker: return true
        case .getSticker: return true
        case .listGuildStickers: return true
        case .listStickerPacks: return true
        case .createGuildSticker: return true
        case .updateGuildSticker: return true
        case .deleteGuildSticker: return true
        case .getActiveGuildThreads: return true
        case .getThreadMember: return true
        case .listOwnPrivateArchivedThreads: return true
        case .listPrivateArchivedThreads: return true
        case .listPublicArchivedThreads: return true
        case .listThreadMembers: return true
        case .addThreadMember: return true
        case .joinThread: return true
        case .createThread: return true
        case .createThreadFromMessage: return true
        case .createThreadInForumChannel: return true
        case .deleteThreadMember: return true
        case .leaveThread: return true
        case .getOwnUser: return true
        case .getUser: return true
        case .listOwnConnections: return true
        case .updateOwnUser: return true
        case .listGuildVoiceRegions: return true
        case .listVoiceRegions: return true
        case .updateSelfVoiceState: return true
        case .updateVoiceState: return true
        case .getGuildWebhooks: return true
        case .getWebhook: return true
        case .getWebhookByToken: return true
        case .getWebhookMessage: return true
        case .getWebhooksMessagesOriginal: return true
        case .listChannelWebhooks: return true
        case .createWebhook: return true
        case .executeWebhook: return true
        case .patchWebhooksMessagesOriginal: return true
        case .updateWebhook: return true
        case .updateWebhookByToken: return true
        case .updateWebhookMessage: return true
        case .deleteWebhook: return true
        case .deleteWebhookByToken: return true
        case .deleteWebhookMessage: return true
        case .deleteWebhooksMessagesOriginal: return true
        }
    }

    public var requiresAuthorizationHeader: Bool {
        switch self {
        case .getAutoModerationRule: return true
        case .listAutoModerationRules: return true
        case .createAutoModerationRule: return true
        case .updateAutoModerationRule: return true
        case .deleteAutoModerationRule: return true
        case .listGuildAuditLogEntries: return true
        case .getChannel: return true
        case .listPinnedMessages: return true
        case .addGroupDmUser: return true
        case .pinMessage: return true
        case .setChannelPermissionOverwrite: return true
        case .createDm: return true
        case .followChannel: return true
        case .triggerTypingIndicator: return true
        case .updateChannel: return true
        case .deleteChannel: return true
        case .deleteChannelPermissionOverwrite: return true
        case .deleteGroupDmUser: return true
        case .unpinMessage: return true
        case .getApplicationCommand: return true
        case .getGuildApplicationCommand: return true
        case .getGuildApplicationCommandPermissions: return true
        case .listApplicationCommands: return true
        case .listGuildApplicationCommandPermissions: return true
        case .listGuildApplicationCommands: return true
        case .bulkSetApplicationCommands: return true
        case .bulkSetGuildApplicationCommands: return true
        case .setGuildApplicationCommandPermissions: return true
        case .createApplicationCommand: return true
        case .createGuildApplicationCommand: return true
        case .updateApplicationCommand: return true
        case .updateGuildApplicationCommand: return true
        case .deleteApplicationCommand: return true
        case .deleteGuildApplicationCommand: return true
        case .getGuildEmoji: return true
        case .listGuildEmojis: return true
        case .createGuildEmoji: return true
        case .updateGuildEmoji: return true
        case .deleteGuildEmoji: return true
        case .getBotGateway: return true
        case .getGateway: return true
        case .getGuild: return true
        case .getGuildBan: return true
        case .getGuildOnboarding: return true
        case .getGuildPreview: return true
        case .getGuildVanityUrl: return true
        case .getGuildWelcomeScreen: return true
        case .getGuildWidget: return true
        case .getGuildWidgetPng: return true
        case .getGuildWidgetSettings: return true
        case .listGuildBans: return true
        case .listGuildChannels: return true
        case .listGuildIntegrations: return true
        case .listOwnGuilds: return true
        case .previewPruneGuild: return true
        case .banUserFromGuild: return true
        case .createGuild: return true
        case .createGuildChannel: return true
        case .pruneGuild: return true
        case .setGuildMfaLevel: return true
        case .bulkUpdateGuildChannels: return true
        case .updateGuild: return true
        case .updateGuildWelcomeScreen: return true
        case .updateGuildWidgetSettings: return true
        case .deleteGuild: return true
        case .deleteGuildIntegration: return true
        case .leaveGuild: return true
        case .unbanUserFromGuild: return true
        case .getGuildTemplate: return true
        case .listGuildTemplates: return true
        case .syncGuildTemplate: return true
        case .createGuildFromTemplate: return true
        case .createGuildTemplate: return true
        case .updateGuildTemplate: return true
        case .deleteGuildTemplate: return true
        case .getFollowupMessage: return true
        case .getOriginalInteractionResponse: return true
        case .createFollowupMessage: return true
        case .createInteractionResponse: return true
        case .updateFollowupMessage: return true
        case .updateOriginalInteractionResponse: return true
        case .deleteFollowupMessage: return true
        case .deleteOriginalInteractionResponse: return true
        case .inviteResolve: return true
        case .listChannelInvites: return true
        case .listGuildInvites: return true
        case .createChannelInvite: return true
        case .inviteRevoke: return true
        case .getGuildMember: return true
        case .getOwnGuildMember: return true
        case .listGuildMembers: return true
        case .searchGuildMembers: return true
        case .addGuildMember: return true
        case .updateGuildMember: return true
        case .updateOwnGuildMember: return true
        case .deleteGuildMember: return true
        case .getMessage: return true
        case .listMessageReactionsByEmoji: return true
        case .listMessages: return true
        case .addOwnMessageReaction: return true
        case .bulkDeleteMessages: return true
        case .createMessage: return true
        case .crosspostMessage: return true
        case .updateMessage: return true
        case .deleteAllMessageReactions: return true
        case .deleteAllMessageReactionsByEmoji: return true
        case .deleteMessage: return true
        case .deleteOwnMessageReaction: return true
        case .deleteUserMessageReaction: return true
        case .getOwnOauth2Application: return true
        case .listGuildRoles: return true
        case .addGuildMemberRole: return true
        case .createGuildRole: return true
        case .bulkUpdateGuildRoles: return true
        case .updateGuildRole: return true
        case .deleteGuildMemberRole: return true
        case .deleteGuildRole: return true
        case .getApplicationRoleConnectionsMetadata: return true
        case .getApplicationUserRoleConnection: return true
        case .updateApplicationRoleConnectionsMetadata: return true
        case .updateApplicationUserRoleConnection: return true
        case .getGuildScheduledEvent: return true
        case .listGuildScheduledEventUsers: return true
        case .listGuildScheduledEvents: return true
        case .createGuildScheduledEvent: return true
        case .updateGuildScheduledEvent: return true
        case .deleteGuildScheduledEvent: return true
        case .getStageInstance: return true
        case .createStageInstance: return true
        case .updateStageInstance: return true
        case .deleteStageInstance: return true
        case .getGuildSticker: return true
        case .getSticker: return true
        case .listGuildStickers: return true
        case .listStickerPacks: return true
        case .createGuildSticker: return true
        case .updateGuildSticker: return true
        case .deleteGuildSticker: return true
        case .getActiveGuildThreads: return true
        case .getThreadMember: return true
        case .listOwnPrivateArchivedThreads: return true
        case .listPrivateArchivedThreads: return true
        case .listPublicArchivedThreads: return true
        case .listThreadMembers: return true
        case .addThreadMember: return true
        case .joinThread: return true
        case .createThread: return true
        case .createThreadFromMessage: return true
        case .createThreadInForumChannel: return true
        case .deleteThreadMember: return true
        case .leaveThread: return true
        case .getOwnUser: return true
        case .getUser: return true
        case .listOwnConnections: return true
        case .updateOwnUser: return true
        case .listGuildVoiceRegions: return true
        case .listVoiceRegions: return true
        case .updateSelfVoiceState: return true
        case .updateVoiceState: return true
        case .getGuildWebhooks: return true
        case .getWebhook: return true
        case .getWebhookByToken: return false
        case .getWebhookMessage: return false
        case .getWebhooksMessagesOriginal: return false
        case .listChannelWebhooks: return true
        case .createWebhook: return true
        case .executeWebhook: return false
        case .patchWebhooksMessagesOriginal: return false
        case .updateWebhook: return true
        case .updateWebhookByToken: return false
        case .updateWebhookMessage: return false
        case .deleteWebhook: return true
        case .deleteWebhookByToken: return false
        case .deleteWebhookMessage: return false
        case .deleteWebhooksMessagesOriginal: return false
        }
    }

    public var parameters: [String] {
        switch self {
        case let .getAutoModerationRule(guildId, ruleId):
            return [guildId.value, ruleId.value]
        case let .listAutoModerationRules(guildId):
            return [guildId.value]
        case let .createAutoModerationRule(guildId):
            return [guildId.value]
        case let .updateAutoModerationRule(guildId, ruleId):
            return [guildId.value, ruleId.value]
        case let .deleteAutoModerationRule(guildId, ruleId):
            return [guildId.value, ruleId.value]
        case let .listGuildAuditLogEntries(guildId):
            return [guildId.value]
        case let .getChannel(channelId):
            return [channelId.value]
        case let .listPinnedMessages(channelId):
            return [channelId.value]
        case let .addGroupDmUser(channelId, userId):
            return [channelId.value, userId.value]
        case let .pinMessage(channelId, messageId):
            return [channelId.value, messageId.value]
        case let .setChannelPermissionOverwrite(channelId, overwriteId):
            return [channelId.value, overwriteId.value]
        case .createDm:
            return []
        case let .followChannel(channelId):
            return [channelId.value]
        case let .triggerTypingIndicator(channelId):
            return [channelId.value]
        case let .updateChannel(channelId):
            return [channelId.value]
        case let .deleteChannel(channelId):
            return [channelId.value]
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            return [channelId.value, overwriteId.value]
        case let .deleteGroupDmUser(channelId, userId):
            return [channelId.value, userId.value]
        case let .unpinMessage(channelId, messageId):
            return [channelId.value, messageId.value]
        case let .getApplicationCommand(applicationId, commandId):
            return [applicationId.value, commandId.value]
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            return [applicationId.value, guildId.value, commandId.value]
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            return [applicationId.value, guildId.value, commandId.value]
        case let .listApplicationCommands(applicationId):
            return [applicationId.value]
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            return [applicationId.value, guildId.value]
        case let .listGuildApplicationCommands(applicationId, guildId):
            return [applicationId.value, guildId.value]
        case let .bulkSetApplicationCommands(applicationId):
            return [applicationId.value]
        case let .bulkSetGuildApplicationCommands(applicationId, guildId):
            return [applicationId.value, guildId.value]
        case let .setGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            return [applicationId.value, guildId.value, commandId.value]
        case let .createApplicationCommand(applicationId):
            return [applicationId.value]
        case let .createGuildApplicationCommand(applicationId, guildId):
            return [applicationId.value, guildId.value]
        case let .updateApplicationCommand(applicationId, commandId):
            return [applicationId.value, commandId.value]
        case let .updateGuildApplicationCommand(applicationId, guildId, commandId):
            return [applicationId.value, guildId.value, commandId.value]
        case let .deleteApplicationCommand(applicationId, commandId):
            return [applicationId.value, commandId.value]
        case let .deleteGuildApplicationCommand(applicationId, guildId, commandId):
            return [applicationId.value, guildId.value, commandId.value]
        case let .getGuildEmoji(guildId, emojiId):
            return [guildId.value, emojiId.value]
        case let .listGuildEmojis(guildId):
            return [guildId.value]
        case let .createGuildEmoji(guildId):
            return [guildId.value]
        case let .updateGuildEmoji(guildId, emojiId):
            return [guildId.value, emojiId.value]
        case let .deleteGuildEmoji(guildId, emojiId):
            return [guildId.value, emojiId.value]
        case .getBotGateway:
            return []
        case .getGateway:
            return []
        case let .getGuild(guildId):
            return [guildId.value]
        case let .getGuildBan(guildId, userId):
            return [guildId.value, userId.value]
        case let .getGuildOnboarding(guildId):
            return [guildId.value]
        case let .getGuildPreview(guildId):
            return [guildId.value]
        case let .getGuildVanityUrl(guildId):
            return [guildId.value]
        case let .getGuildWelcomeScreen(guildId):
            return [guildId.value]
        case let .getGuildWidget(guildId):
            return [guildId.value]
        case let .getGuildWidgetPng(guildId):
            return [guildId.value]
        case let .getGuildWidgetSettings(guildId):
            return [guildId.value]
        case let .listGuildBans(guildId):
            return [guildId.value]
        case let .listGuildChannels(guildId):
            return [guildId.value]
        case let .listGuildIntegrations(guildId):
            return [guildId.value]
        case .listOwnGuilds:
            return []
        case let .previewPruneGuild(guildId):
            return [guildId.value]
        case let .banUserFromGuild(guildId, userId):
            return [guildId.value, userId.value]
        case .createGuild:
            return []
        case let .createGuildChannel(guildId):
            return [guildId.value]
        case let .pruneGuild(guildId):
            return [guildId.value]
        case let .setGuildMfaLevel(guildId):
            return [guildId.value]
        case let .bulkUpdateGuildChannels(guildId):
            return [guildId.value]
        case let .updateGuild(guildId):
            return [guildId.value]
        case let .updateGuildWelcomeScreen(guildId):
            return [guildId.value]
        case let .updateGuildWidgetSettings(guildId):
            return [guildId.value]
        case let .deleteGuild(guildId):
            return [guildId.value]
        case let .deleteGuildIntegration(guildId, integrationId):
            return [guildId.value, integrationId.value]
        case let .leaveGuild(guildId):
            return [guildId.value]
        case let .unbanUserFromGuild(guildId, userId):
            return [guildId.value, userId.value]
        case let .getGuildTemplate(code):
            return [code]
        case let .listGuildTemplates(guildId):
            return [guildId.value]
        case let .syncGuildTemplate(guildId, code):
            return [guildId.value, code]
        case let .createGuildFromTemplate(code):
            return [code]
        case let .createGuildTemplate(guildId):
            return [guildId.value]
        case let .updateGuildTemplate(guildId, code):
            return [guildId.value, code]
        case let .deleteGuildTemplate(guildId, code):
            return [guildId.value, code]
        case let .getFollowupMessage(applicationId, interactionToken, messageId):
            return [applicationId.value, interactionToken, messageId.value]
        case let .getOriginalInteractionResponse(applicationId, interactionToken):
            return [applicationId.value, interactionToken]
        case let .createFollowupMessage(applicationId, interactionToken):
            return [applicationId.value, interactionToken]
        case let .createInteractionResponse(interactionId, interactionToken):
            return [interactionId.value, interactionToken]
        case let .updateFollowupMessage(applicationId, interactionToken, messageId):
            return [applicationId.value, interactionToken, messageId.value]
        case let .updateOriginalInteractionResponse(applicationId, interactionToken):
            return [applicationId.value, interactionToken]
        case let .deleteFollowupMessage(applicationId, interactionToken, messageId):
            return [applicationId.value, interactionToken, messageId.value]
        case let .deleteOriginalInteractionResponse(applicationId, interactionToken):
            return [applicationId.value, interactionToken]
        case let .inviteResolve(code):
            return [code]
        case let .listChannelInvites(channelId):
            return [channelId.value]
        case let .listGuildInvites(guildId):
            return [guildId.value]
        case let .createChannelInvite(channelId):
            return [channelId.value]
        case let .inviteRevoke(code):
            return [code]
        case let .getGuildMember(guildId, userId):
            return [guildId.value, userId.value]
        case let .getOwnGuildMember(guildId):
            return [guildId.value]
        case let .listGuildMembers(guildId):
            return [guildId.value]
        case let .searchGuildMembers(guildId):
            return [guildId.value]
        case let .addGuildMember(guildId, userId):
            return [guildId.value, userId.value]
        case let .updateGuildMember(guildId, userId):
            return [guildId.value, userId.value]
        case let .updateOwnGuildMember(guildId):
            return [guildId.value]
        case let .deleteGuildMember(guildId, userId):
            return [guildId.value, userId.value]
        case let .getMessage(channelId, messageId):
            return [channelId.value, messageId.value]
        case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
            return [channelId.value, messageId.value, emojiName]
        case let .listMessages(channelId):
            return [channelId.value]
        case let .addOwnMessageReaction(channelId, messageId, emojiName):
            return [channelId.value, messageId.value, emojiName]
        case let .bulkDeleteMessages(channelId):
            return [channelId.value]
        case let .createMessage(channelId):
            return [channelId.value]
        case let .crosspostMessage(channelId, messageId):
            return [channelId.value, messageId.value]
        case let .updateMessage(channelId, messageId):
            return [channelId.value, messageId.value]
        case let .deleteAllMessageReactions(channelId, messageId):
            return [channelId.value, messageId.value]
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            return [channelId.value, messageId.value, emojiName]
        case let .deleteMessage(channelId, messageId):
            return [channelId.value, messageId.value]
        case let .deleteOwnMessageReaction(channelId, messageId, emojiName):
            return [channelId.value, messageId.value, emojiName]
        case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
            return [channelId.value, messageId.value, emojiName, userId.value]
        case .getOwnOauth2Application:
            return []
        case let .listGuildRoles(guildId):
            return [guildId.value]
        case let .addGuildMemberRole(guildId, userId, roleId):
            return [guildId.value, userId.value, roleId.value]
        case let .createGuildRole(guildId):
            return [guildId.value]
        case let .bulkUpdateGuildRoles(guildId):
            return [guildId.value]
        case let .updateGuildRole(guildId, roleId):
            return [guildId.value, roleId.value]
        case let .deleteGuildMemberRole(guildId, userId, roleId):
            return [guildId.value, userId.value, roleId.value]
        case let .deleteGuildRole(guildId, roleId):
            return [guildId.value, roleId.value]
        case let .getApplicationRoleConnectionsMetadata(applicationId):
            return [applicationId.value]
        case let .getApplicationUserRoleConnection(applicationId):
            return [applicationId.value]
        case let .updateApplicationRoleConnectionsMetadata(applicationId):
            return [applicationId.value]
        case let .updateApplicationUserRoleConnection(applicationId):
            return [applicationId.value]
        case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
            return [guildId.value, guildScheduledEventId.value]
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            return [guildId.value, guildScheduledEventId.value]
        case let .listGuildScheduledEvents(guildId):
            return [guildId.value]
        case let .createGuildScheduledEvent(guildId):
            return [guildId.value]
        case let .updateGuildScheduledEvent(guildId, guildScheduledEventId):
            return [guildId.value, guildScheduledEventId.value]
        case let .deleteGuildScheduledEvent(guildId, guildScheduledEventId):
            return [guildId.value, guildScheduledEventId.value]
        case let .getStageInstance(channelId):
            return [channelId.value]
        case .createStageInstance:
            return []
        case let .updateStageInstance(channelId):
            return [channelId.value]
        case let .deleteStageInstance(channelId):
            return [channelId.value]
        case let .getGuildSticker(guildId, stickerId):
            return [guildId.value, stickerId.value]
        case let .getSticker(stickerId):
            return [stickerId.value]
        case let .listGuildStickers(guildId):
            return [guildId.value]
        case .listStickerPacks:
            return []
        case let .createGuildSticker(guildId):
            return [guildId.value]
        case let .updateGuildSticker(guildId, stickerId):
            return [guildId.value, stickerId.value]
        case let .deleteGuildSticker(guildId, stickerId):
            return [guildId.value, stickerId.value]
        case let .getActiveGuildThreads(guildId):
            return [guildId.value]
        case let .getThreadMember(channelId, userId):
            return [channelId.value, userId.value]
        case let .listOwnPrivateArchivedThreads(channelId):
            return [channelId.value]
        case let .listPrivateArchivedThreads(channelId):
            return [channelId.value]
        case let .listPublicArchivedThreads(channelId):
            return [channelId.value]
        case let .listThreadMembers(channelId):
            return [channelId.value]
        case let .addThreadMember(channelId, userId):
            return [channelId.value, userId.value]
        case let .joinThread(channelId):
            return [channelId.value]
        case let .createThread(channelId):
            return [channelId.value]
        case let .createThreadFromMessage(channelId, messageId):
            return [channelId.value, messageId.value]
        case let .createThreadInForumChannel(channelId):
            return [channelId.value]
        case let .deleteThreadMember(channelId, userId):
            return [channelId.value, userId.value]
        case let .leaveThread(channelId):
            return [channelId.value]
        case .getOwnUser:
            return []
        case let .getUser(userId):
            return [userId.value]
        case .listOwnConnections:
            return []
        case .updateOwnUser:
            return []
        case let .listGuildVoiceRegions(guildId):
            return [guildId.value]
        case .listVoiceRegions:
            return []
        case let .updateSelfVoiceState(guildId):
            return [guildId.value]
        case let .updateVoiceState(guildId, userId):
            return [guildId.value, userId.value]
        case let .getGuildWebhooks(guildId):
            return [guildId.value]
        case let .getWebhook(webhookId):
            return [webhookId.value]
        case let .getWebhookByToken(webhookId, webhookToken):
            return [webhookId.value, webhookToken]
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            return [webhookId.value, webhookToken, messageId.value]
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            return [webhookId.value, webhookToken]
        case let .listChannelWebhooks(channelId):
            return [channelId.value]
        case let .createWebhook(channelId):
            return [channelId.value]
        case let .executeWebhook(webhookId, webhookToken):
            return [webhookId.value, webhookToken]
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
            return [webhookId.value, webhookToken]
        case let .updateWebhook(webhookId):
            return [webhookId.value]
        case let .updateWebhookByToken(webhookId, webhookToken):
            return [webhookId.value, webhookToken]
        case let .updateWebhookMessage(webhookId, webhookToken, messageId):
            return [webhookId.value, webhookToken, messageId.value]
        case let .deleteWebhook(webhookId):
            return [webhookId.value]
        case let .deleteWebhookByToken(webhookId, webhookToken):
            return [webhookId.value, webhookToken]
        case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
            return [webhookId.value, webhookToken, messageId.value]
        case let .deleteWebhooksMessagesOriginal(webhookId, webhookToken):
            return [webhookId.value, webhookToken]
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
        case .listPinnedMessages: return 8
        case .addGroupDmUser: return 9
        case .pinMessage: return 10
        case .setChannelPermissionOverwrite: return 11
        case .createDm: return 12
        case .followChannel: return 13
        case .triggerTypingIndicator: return 14
        case .updateChannel: return 15
        case .deleteChannel: return 16
        case .deleteChannelPermissionOverwrite: return 17
        case .deleteGroupDmUser: return 18
        case .unpinMessage: return 19
        case .getApplicationCommand: return 20
        case .getGuildApplicationCommand: return 21
        case .getGuildApplicationCommandPermissions: return 22
        case .listApplicationCommands: return 23
        case .listGuildApplicationCommandPermissions: return 24
        case .listGuildApplicationCommands: return 25
        case .bulkSetApplicationCommands: return 26
        case .bulkSetGuildApplicationCommands: return 27
        case .setGuildApplicationCommandPermissions: return 28
        case .createApplicationCommand: return 29
        case .createGuildApplicationCommand: return 30
        case .updateApplicationCommand: return 31
        case .updateGuildApplicationCommand: return 32
        case .deleteApplicationCommand: return 33
        case .deleteGuildApplicationCommand: return 34
        case .getGuildEmoji: return 35
        case .listGuildEmojis: return 36
        case .createGuildEmoji: return 37
        case .updateGuildEmoji: return 38
        case .deleteGuildEmoji: return 39
        case .getBotGateway: return 40
        case .getGateway: return 41
        case .getGuild: return 42
        case .getGuildBan: return 43
        case .getGuildOnboarding: return 44
        case .getGuildPreview: return 45
        case .getGuildVanityUrl: return 46
        case .getGuildWelcomeScreen: return 47
        case .getGuildWidget: return 48
        case .getGuildWidgetPng: return 49
        case .getGuildWidgetSettings: return 50
        case .listGuildBans: return 51
        case .listGuildChannels: return 52
        case .listGuildIntegrations: return 53
        case .listOwnGuilds: return 54
        case .previewPruneGuild: return 55
        case .banUserFromGuild: return 56
        case .createGuild: return 57
        case .createGuildChannel: return 58
        case .pruneGuild: return 59
        case .setGuildMfaLevel: return 60
        case .bulkUpdateGuildChannels: return 61
        case .updateGuild: return 62
        case .updateGuildWelcomeScreen: return 63
        case .updateGuildWidgetSettings: return 64
        case .deleteGuild: return 65
        case .deleteGuildIntegration: return 66
        case .leaveGuild: return 67
        case .unbanUserFromGuild: return 68
        case .getGuildTemplate: return 69
        case .listGuildTemplates: return 70
        case .syncGuildTemplate: return 71
        case .createGuildFromTemplate: return 72
        case .createGuildTemplate: return 73
        case .updateGuildTemplate: return 74
        case .deleteGuildTemplate: return 75
        case .getFollowupMessage: return 76
        case .getOriginalInteractionResponse: return 77
        case .createFollowupMessage: return 78
        case .createInteractionResponse: return 79
        case .updateFollowupMessage: return 80
        case .updateOriginalInteractionResponse: return 81
        case .deleteFollowupMessage: return 82
        case .deleteOriginalInteractionResponse: return 83
        case .inviteResolve: return 84
        case .listChannelInvites: return 85
        case .listGuildInvites: return 86
        case .createChannelInvite: return 87
        case .inviteRevoke: return 88
        case .getGuildMember: return 89
        case .getOwnGuildMember: return 90
        case .listGuildMembers: return 91
        case .searchGuildMembers: return 92
        case .addGuildMember: return 93
        case .updateGuildMember: return 94
        case .updateOwnGuildMember: return 95
        case .deleteGuildMember: return 96
        case .getMessage: return 97
        case .listMessageReactionsByEmoji: return 98
        case .listMessages: return 99
        case .addOwnMessageReaction: return 100
        case .bulkDeleteMessages: return 101
        case .createMessage: return 102
        case .crosspostMessage: return 103
        case .updateMessage: return 104
        case .deleteAllMessageReactions: return 105
        case .deleteAllMessageReactionsByEmoji: return 106
        case .deleteMessage: return 107
        case .deleteOwnMessageReaction: return 108
        case .deleteUserMessageReaction: return 109
        case .getOwnOauth2Application: return 110
        case .listGuildRoles: return 111
        case .addGuildMemberRole: return 112
        case .createGuildRole: return 113
        case .bulkUpdateGuildRoles: return 114
        case .updateGuildRole: return 115
        case .deleteGuildMemberRole: return 116
        case .deleteGuildRole: return 117
        case .getApplicationRoleConnectionsMetadata: return 118
        case .getApplicationUserRoleConnection: return 119
        case .updateApplicationRoleConnectionsMetadata: return 120
        case .updateApplicationUserRoleConnection: return 121
        case .getGuildScheduledEvent: return 122
        case .listGuildScheduledEventUsers: return 123
        case .listGuildScheduledEvents: return 124
        case .createGuildScheduledEvent: return 125
        case .updateGuildScheduledEvent: return 126
        case .deleteGuildScheduledEvent: return 127
        case .getStageInstance: return 128
        case .createStageInstance: return 129
        case .updateStageInstance: return 130
        case .deleteStageInstance: return 131
        case .getGuildSticker: return 132
        case .getSticker: return 133
        case .listGuildStickers: return 134
        case .listStickerPacks: return 135
        case .createGuildSticker: return 136
        case .updateGuildSticker: return 137
        case .deleteGuildSticker: return 138
        case .getActiveGuildThreads: return 139
        case .getThreadMember: return 140
        case .listOwnPrivateArchivedThreads: return 141
        case .listPrivateArchivedThreads: return 142
        case .listPublicArchivedThreads: return 143
        case .listThreadMembers: return 144
        case .addThreadMember: return 145
        case .joinThread: return 146
        case .createThread: return 147
        case .createThreadFromMessage: return 148
        case .createThreadInForumChannel: return 149
        case .deleteThreadMember: return 150
        case .leaveThread: return 151
        case .getOwnUser: return 152
        case .getUser: return 153
        case .listOwnConnections: return 154
        case .updateOwnUser: return 155
        case .listGuildVoiceRegions: return 156
        case .listVoiceRegions: return 157
        case .updateSelfVoiceState: return 158
        case .updateVoiceState: return 159
        case .getGuildWebhooks: return 160
        case .getWebhook: return 161
        case .getWebhookByToken: return 162
        case .getWebhookMessage: return 163
        case .getWebhooksMessagesOriginal: return 164
        case .listChannelWebhooks: return 165
        case .createWebhook: return 166
        case .executeWebhook: return 167
        case .patchWebhooksMessagesOriginal: return 168
        case .updateWebhook: return 169
        case .updateWebhookByToken: return 170
        case .updateWebhookMessage: return 171
        case .deleteWebhook: return 172
        case .deleteWebhookByToken: return 173
        case .deleteWebhookMessage: return 174
        case .deleteWebhooksMessagesOriginal: return 175
        }
    }

    public var description: String {
        switch self {
        case let .getAutoModerationRule(guildId, ruleId):
            return "getAutoModerationRule(guildId.value: \(guildId.value), ruleId.value: \(ruleId.value))"
        case let .listAutoModerationRules(guildId):
            return "listAutoModerationRules(guildId.value: \(guildId.value))"
        case let .createAutoModerationRule(guildId):
            return "createAutoModerationRule(guildId.value: \(guildId.value))"
        case let .updateAutoModerationRule(guildId, ruleId):
            return "updateAutoModerationRule(guildId.value: \(guildId.value), ruleId.value: \(ruleId.value))"
        case let .deleteAutoModerationRule(guildId, ruleId):
            return "deleteAutoModerationRule(guildId.value: \(guildId.value), ruleId.value: \(ruleId.value))"
        case let .listGuildAuditLogEntries(guildId):
            return "listGuildAuditLogEntries(guildId.value: \(guildId.value))"
        case let .getChannel(channelId):
            return "getChannel(channelId.value: \(channelId.value))"
        case let .listPinnedMessages(channelId):
            return "listPinnedMessages(channelId.value: \(channelId.value))"
        case let .addGroupDmUser(channelId, userId):
            return "addGroupDmUser(channelId.value: \(channelId.value), userId.value: \(userId.value))"
        case let .pinMessage(channelId, messageId):
            return "pinMessage(channelId.value: \(channelId.value), messageId.value: \(messageId.value))"
        case let .setChannelPermissionOverwrite(channelId, overwriteId):
            return "setChannelPermissionOverwrite(channelId.value: \(channelId.value), overwriteId.value: \(overwriteId.value))"
        case .createDm:
            return "createDm"
        case let .followChannel(channelId):
            return "followChannel(channelId.value: \(channelId.value))"
        case let .triggerTypingIndicator(channelId):
            return "triggerTypingIndicator(channelId.value: \(channelId.value))"
        case let .updateChannel(channelId):
            return "updateChannel(channelId.value: \(channelId.value))"
        case let .deleteChannel(channelId):
            return "deleteChannel(channelId.value: \(channelId.value))"
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            return "deleteChannelPermissionOverwrite(channelId.value: \(channelId.value), overwriteId.value: \(overwriteId.value))"
        case let .deleteGroupDmUser(channelId, userId):
            return "deleteGroupDmUser(channelId.value: \(channelId.value), userId.value: \(userId.value))"
        case let .unpinMessage(channelId, messageId):
            return "unpinMessage(channelId.value: \(channelId.value), messageId.value: \(messageId.value))"
        case let .getApplicationCommand(applicationId, commandId):
            return "getApplicationCommand(applicationId.value: \(applicationId.value), commandId.value: \(commandId.value))"
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            return "getGuildApplicationCommand(applicationId.value: \(applicationId.value), guildId.value: \(guildId.value), commandId.value: \(commandId.value))"
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            return "getGuildApplicationCommandPermissions(applicationId.value: \(applicationId.value), guildId.value: \(guildId.value), commandId.value: \(commandId.value))"
        case let .listApplicationCommands(applicationId):
            return "listApplicationCommands(applicationId.value: \(applicationId.value))"
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            return "listGuildApplicationCommandPermissions(applicationId.value: \(applicationId.value), guildId.value: \(guildId.value))"
        case let .listGuildApplicationCommands(applicationId, guildId):
            return "listGuildApplicationCommands(applicationId.value: \(applicationId.value), guildId.value: \(guildId.value))"
        case let .bulkSetApplicationCommands(applicationId):
            return "bulkSetApplicationCommands(applicationId.value: \(applicationId.value))"
        case let .bulkSetGuildApplicationCommands(applicationId, guildId):
            return "bulkSetGuildApplicationCommands(applicationId.value: \(applicationId.value), guildId.value: \(guildId.value))"
        case let .setGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            return "setGuildApplicationCommandPermissions(applicationId.value: \(applicationId.value), guildId.value: \(guildId.value), commandId.value: \(commandId.value))"
        case let .createApplicationCommand(applicationId):
            return "createApplicationCommand(applicationId.value: \(applicationId.value))"
        case let .createGuildApplicationCommand(applicationId, guildId):
            return "createGuildApplicationCommand(applicationId.value: \(applicationId.value), guildId.value: \(guildId.value))"
        case let .updateApplicationCommand(applicationId, commandId):
            return "updateApplicationCommand(applicationId.value: \(applicationId.value), commandId.value: \(commandId.value))"
        case let .updateGuildApplicationCommand(applicationId, guildId, commandId):
            return "updateGuildApplicationCommand(applicationId.value: \(applicationId.value), guildId.value: \(guildId.value), commandId.value: \(commandId.value))"
        case let .deleteApplicationCommand(applicationId, commandId):
            return "deleteApplicationCommand(applicationId.value: \(applicationId.value), commandId.value: \(commandId.value))"
        case let .deleteGuildApplicationCommand(applicationId, guildId, commandId):
            return "deleteGuildApplicationCommand(applicationId.value: \(applicationId.value), guildId.value: \(guildId.value), commandId.value: \(commandId.value))"
        case let .getGuildEmoji(guildId, emojiId):
            return "getGuildEmoji(guildId.value: \(guildId.value), emojiId.value: \(emojiId.value))"
        case let .listGuildEmojis(guildId):
            return "listGuildEmojis(guildId.value: \(guildId.value))"
        case let .createGuildEmoji(guildId):
            return "createGuildEmoji(guildId.value: \(guildId.value))"
        case let .updateGuildEmoji(guildId, emojiId):
            return "updateGuildEmoji(guildId.value: \(guildId.value), emojiId.value: \(emojiId.value))"
        case let .deleteGuildEmoji(guildId, emojiId):
            return "deleteGuildEmoji(guildId.value: \(guildId.value), emojiId.value: \(emojiId.value))"
        case .getBotGateway:
            return "getBotGateway"
        case .getGateway:
            return "getGateway"
        case let .getGuild(guildId):
            return "getGuild(guildId.value: \(guildId.value))"
        case let .getGuildBan(guildId, userId):
            return "getGuildBan(guildId.value: \(guildId.value), userId.value: \(userId.value))"
        case let .getGuildOnboarding(guildId):
            return "getGuildOnboarding(guildId.value: \(guildId.value))"
        case let .getGuildPreview(guildId):
            return "getGuildPreview(guildId.value: \(guildId.value))"
        case let .getGuildVanityUrl(guildId):
            return "getGuildVanityUrl(guildId.value: \(guildId.value))"
        case let .getGuildWelcomeScreen(guildId):
            return "getGuildWelcomeScreen(guildId.value: \(guildId.value))"
        case let .getGuildWidget(guildId):
            return "getGuildWidget(guildId.value: \(guildId.value))"
        case let .getGuildWidgetPng(guildId):
            return "getGuildWidgetPng(guildId.value: \(guildId.value))"
        case let .getGuildWidgetSettings(guildId):
            return "getGuildWidgetSettings(guildId.value: \(guildId.value))"
        case let .listGuildBans(guildId):
            return "listGuildBans(guildId.value: \(guildId.value))"
        case let .listGuildChannels(guildId):
            return "listGuildChannels(guildId.value: \(guildId.value))"
        case let .listGuildIntegrations(guildId):
            return "listGuildIntegrations(guildId.value: \(guildId.value))"
        case .listOwnGuilds:
            return "listOwnGuilds"
        case let .previewPruneGuild(guildId):
            return "previewPruneGuild(guildId.value: \(guildId.value))"
        case let .banUserFromGuild(guildId, userId):
            return "banUserFromGuild(guildId.value: \(guildId.value), userId.value: \(userId.value))"
        case .createGuild:
            return "createGuild"
        case let .createGuildChannel(guildId):
            return "createGuildChannel(guildId.value: \(guildId.value))"
        case let .pruneGuild(guildId):
            return "pruneGuild(guildId.value: \(guildId.value))"
        case let .setGuildMfaLevel(guildId):
            return "setGuildMfaLevel(guildId.value: \(guildId.value))"
        case let .bulkUpdateGuildChannels(guildId):
            return "bulkUpdateGuildChannels(guildId.value: \(guildId.value))"
        case let .updateGuild(guildId):
            return "updateGuild(guildId.value: \(guildId.value))"
        case let .updateGuildWelcomeScreen(guildId):
            return "updateGuildWelcomeScreen(guildId.value: \(guildId.value))"
        case let .updateGuildWidgetSettings(guildId):
            return "updateGuildWidgetSettings(guildId.value: \(guildId.value))"
        case let .deleteGuild(guildId):
            return "deleteGuild(guildId.value: \(guildId.value))"
        case let .deleteGuildIntegration(guildId, integrationId):
            return "deleteGuildIntegration(guildId.value: \(guildId.value), integrationId.value: \(integrationId.value))"
        case let .leaveGuild(guildId):
            return "leaveGuild(guildId.value: \(guildId.value))"
        case let .unbanUserFromGuild(guildId, userId):
            return "unbanUserFromGuild(guildId.value: \(guildId.value), userId.value: \(userId.value))"
        case let .getGuildTemplate(code):
            return "getGuildTemplate(code: \(code))"
        case let .listGuildTemplates(guildId):
            return "listGuildTemplates(guildId.value: \(guildId.value))"
        case let .syncGuildTemplate(guildId, code):
            return "syncGuildTemplate(guildId.value: \(guildId.value), code: \(code))"
        case let .createGuildFromTemplate(code):
            return "createGuildFromTemplate(code: \(code))"
        case let .createGuildTemplate(guildId):
            return "createGuildTemplate(guildId.value: \(guildId.value))"
        case let .updateGuildTemplate(guildId, code):
            return "updateGuildTemplate(guildId.value: \(guildId.value), code: \(code))"
        case let .deleteGuildTemplate(guildId, code):
            return "deleteGuildTemplate(guildId.value: \(guildId.value), code: \(code))"
        case let .getFollowupMessage(applicationId, interactionToken, messageId):
            return "getFollowupMessage(applicationId.value: \(applicationId.value), interactionToken: \(interactionToken), messageId.value: \(messageId.value))"
        case let .getOriginalInteractionResponse(applicationId, interactionToken):
            return "getOriginalInteractionResponse(applicationId.value: \(applicationId.value), interactionToken: \(interactionToken))"
        case let .createFollowupMessage(applicationId, interactionToken):
            return "createFollowupMessage(applicationId.value: \(applicationId.value), interactionToken: \(interactionToken))"
        case let .createInteractionResponse(interactionId, interactionToken):
            return "createInteractionResponse(interactionId.value: \(interactionId.value), interactionToken: \(interactionToken))"
        case let .updateFollowupMessage(applicationId, interactionToken, messageId):
            return "updateFollowupMessage(applicationId.value: \(applicationId.value), interactionToken: \(interactionToken), messageId.value: \(messageId.value))"
        case let .updateOriginalInteractionResponse(applicationId, interactionToken):
            return "updateOriginalInteractionResponse(applicationId.value: \(applicationId.value), interactionToken: \(interactionToken))"
        case let .deleteFollowupMessage(applicationId, interactionToken, messageId):
            return "deleteFollowupMessage(applicationId.value: \(applicationId.value), interactionToken: \(interactionToken), messageId.value: \(messageId.value))"
        case let .deleteOriginalInteractionResponse(applicationId, interactionToken):
            return "deleteOriginalInteractionResponse(applicationId.value: \(applicationId.value), interactionToken: \(interactionToken))"
        case let .inviteResolve(code):
            return "inviteResolve(code: \(code))"
        case let .listChannelInvites(channelId):
            return "listChannelInvites(channelId.value: \(channelId.value))"
        case let .listGuildInvites(guildId):
            return "listGuildInvites(guildId.value: \(guildId.value))"
        case let .createChannelInvite(channelId):
            return "createChannelInvite(channelId.value: \(channelId.value))"
        case let .inviteRevoke(code):
            return "inviteRevoke(code: \(code))"
        case let .getGuildMember(guildId, userId):
            return "getGuildMember(guildId.value: \(guildId.value), userId.value: \(userId.value))"
        case let .getOwnGuildMember(guildId):
            return "getOwnGuildMember(guildId.value: \(guildId.value))"
        case let .listGuildMembers(guildId):
            return "listGuildMembers(guildId.value: \(guildId.value))"
        case let .searchGuildMembers(guildId):
            return "searchGuildMembers(guildId.value: \(guildId.value))"
        case let .addGuildMember(guildId, userId):
            return "addGuildMember(guildId.value: \(guildId.value), userId.value: \(userId.value))"
        case let .updateGuildMember(guildId, userId):
            return "updateGuildMember(guildId.value: \(guildId.value), userId.value: \(userId.value))"
        case let .updateOwnGuildMember(guildId):
            return "updateOwnGuildMember(guildId.value: \(guildId.value))"
        case let .deleteGuildMember(guildId, userId):
            return "deleteGuildMember(guildId.value: \(guildId.value), userId.value: \(userId.value))"
        case let .getMessage(channelId, messageId):
            return "getMessage(channelId.value: \(channelId.value), messageId.value: \(messageId.value))"
        case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
            return "listMessageReactionsByEmoji(channelId.value: \(channelId.value), messageId.value: \(messageId.value), emojiName: \(emojiName))"
        case let .listMessages(channelId):
            return "listMessages(channelId.value: \(channelId.value))"
        case let .addOwnMessageReaction(channelId, messageId, emojiName):
            return "addOwnMessageReaction(channelId.value: \(channelId.value), messageId.value: \(messageId.value), emojiName: \(emojiName))"
        case let .bulkDeleteMessages(channelId):
            return "bulkDeleteMessages(channelId.value: \(channelId.value))"
        case let .createMessage(channelId):
            return "createMessage(channelId.value: \(channelId.value))"
        case let .crosspostMessage(channelId, messageId):
            return "crosspostMessage(channelId.value: \(channelId.value), messageId.value: \(messageId.value))"
        case let .updateMessage(channelId, messageId):
            return "updateMessage(channelId.value: \(channelId.value), messageId.value: \(messageId.value))"
        case let .deleteAllMessageReactions(channelId, messageId):
            return "deleteAllMessageReactions(channelId.value: \(channelId.value), messageId.value: \(messageId.value))"
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            return "deleteAllMessageReactionsByEmoji(channelId.value: \(channelId.value), messageId.value: \(messageId.value), emojiName: \(emojiName))"
        case let .deleteMessage(channelId, messageId):
            return "deleteMessage(channelId.value: \(channelId.value), messageId.value: \(messageId.value))"
        case let .deleteOwnMessageReaction(channelId, messageId, emojiName):
            return "deleteOwnMessageReaction(channelId.value: \(channelId.value), messageId.value: \(messageId.value), emojiName: \(emojiName))"
        case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
            return "deleteUserMessageReaction(channelId.value: \(channelId.value), messageId.value: \(messageId.value), emojiName: \(emojiName), userId.value: \(userId.value))"
        case .getOwnOauth2Application:
            return "getOwnOauth2Application"
        case let .listGuildRoles(guildId):
            return "listGuildRoles(guildId.value: \(guildId.value))"
        case let .addGuildMemberRole(guildId, userId, roleId):
            return "addGuildMemberRole(guildId.value: \(guildId.value), userId.value: \(userId.value), roleId.value: \(roleId.value))"
        case let .createGuildRole(guildId):
            return "createGuildRole(guildId.value: \(guildId.value))"
        case let .bulkUpdateGuildRoles(guildId):
            return "bulkUpdateGuildRoles(guildId.value: \(guildId.value))"
        case let .updateGuildRole(guildId, roleId):
            return "updateGuildRole(guildId.value: \(guildId.value), roleId.value: \(roleId.value))"
        case let .deleteGuildMemberRole(guildId, userId, roleId):
            return "deleteGuildMemberRole(guildId.value: \(guildId.value), userId.value: \(userId.value), roleId.value: \(roleId.value))"
        case let .deleteGuildRole(guildId, roleId):
            return "deleteGuildRole(guildId.value: \(guildId.value), roleId.value: \(roleId.value))"
        case let .getApplicationRoleConnectionsMetadata(applicationId):
            return "getApplicationRoleConnectionsMetadata(applicationId.value: \(applicationId.value))"
        case let .getApplicationUserRoleConnection(applicationId):
            return "getApplicationUserRoleConnection(applicationId.value: \(applicationId.value))"
        case let .updateApplicationRoleConnectionsMetadata(applicationId):
            return "updateApplicationRoleConnectionsMetadata(applicationId.value: \(applicationId.value))"
        case let .updateApplicationUserRoleConnection(applicationId):
            return "updateApplicationUserRoleConnection(applicationId.value: \(applicationId.value))"
        case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
            return "getGuildScheduledEvent(guildId.value: \(guildId.value), guildScheduledEventId.value: \(guildScheduledEventId.value))"
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            return "listGuildScheduledEventUsers(guildId.value: \(guildId.value), guildScheduledEventId.value: \(guildScheduledEventId.value))"
        case let .listGuildScheduledEvents(guildId):
            return "listGuildScheduledEvents(guildId.value: \(guildId.value))"
        case let .createGuildScheduledEvent(guildId):
            return "createGuildScheduledEvent(guildId.value: \(guildId.value))"
        case let .updateGuildScheduledEvent(guildId, guildScheduledEventId):
            return "updateGuildScheduledEvent(guildId.value: \(guildId.value), guildScheduledEventId.value: \(guildScheduledEventId.value))"
        case let .deleteGuildScheduledEvent(guildId, guildScheduledEventId):
            return "deleteGuildScheduledEvent(guildId.value: \(guildId.value), guildScheduledEventId.value: \(guildScheduledEventId.value))"
        case let .getStageInstance(channelId):
            return "getStageInstance(channelId.value: \(channelId.value))"
        case .createStageInstance:
            return "createStageInstance"
        case let .updateStageInstance(channelId):
            return "updateStageInstance(channelId.value: \(channelId.value))"
        case let .deleteStageInstance(channelId):
            return "deleteStageInstance(channelId.value: \(channelId.value))"
        case let .getGuildSticker(guildId, stickerId):
            return "getGuildSticker(guildId.value: \(guildId.value), stickerId.value: \(stickerId.value))"
        case let .getSticker(stickerId):
            return "getSticker(stickerId.value: \(stickerId.value))"
        case let .listGuildStickers(guildId):
            return "listGuildStickers(guildId.value: \(guildId.value))"
        case .listStickerPacks:
            return "listStickerPacks"
        case let .createGuildSticker(guildId):
            return "createGuildSticker(guildId.value: \(guildId.value))"
        case let .updateGuildSticker(guildId, stickerId):
            return "updateGuildSticker(guildId.value: \(guildId.value), stickerId.value: \(stickerId.value))"
        case let .deleteGuildSticker(guildId, stickerId):
            return "deleteGuildSticker(guildId.value: \(guildId.value), stickerId.value: \(stickerId.value))"
        case let .getActiveGuildThreads(guildId):
            return "getActiveGuildThreads(guildId.value: \(guildId.value))"
        case let .getThreadMember(channelId, userId):
            return "getThreadMember(channelId.value: \(channelId.value), userId.value: \(userId.value))"
        case let .listOwnPrivateArchivedThreads(channelId):
            return "listOwnPrivateArchivedThreads(channelId.value: \(channelId.value))"
        case let .listPrivateArchivedThreads(channelId):
            return "listPrivateArchivedThreads(channelId.value: \(channelId.value))"
        case let .listPublicArchivedThreads(channelId):
            return "listPublicArchivedThreads(channelId.value: \(channelId.value))"
        case let .listThreadMembers(channelId):
            return "listThreadMembers(channelId.value: \(channelId.value))"
        case let .addThreadMember(channelId, userId):
            return "addThreadMember(channelId.value: \(channelId.value), userId.value: \(userId.value))"
        case let .joinThread(channelId):
            return "joinThread(channelId.value: \(channelId.value))"
        case let .createThread(channelId):
            return "createThread(channelId.value: \(channelId.value))"
        case let .createThreadFromMessage(channelId, messageId):
            return "createThreadFromMessage(channelId.value: \(channelId.value), messageId.value: \(messageId.value))"
        case let .createThreadInForumChannel(channelId):
            return "createThreadInForumChannel(channelId.value: \(channelId.value))"
        case let .deleteThreadMember(channelId, userId):
            return "deleteThreadMember(channelId.value: \(channelId.value), userId.value: \(userId.value))"
        case let .leaveThread(channelId):
            return "leaveThread(channelId.value: \(channelId.value))"
        case .getOwnUser:
            return "getOwnUser"
        case let .getUser(userId):
            return "getUser(userId.value: \(userId.value))"
        case .listOwnConnections:
            return "listOwnConnections"
        case .updateOwnUser:
            return "updateOwnUser"
        case let .listGuildVoiceRegions(guildId):
            return "listGuildVoiceRegions(guildId.value: \(guildId.value))"
        case .listVoiceRegions:
            return "listVoiceRegions"
        case let .updateSelfVoiceState(guildId):
            return "updateSelfVoiceState(guildId.value: \(guildId.value))"
        case let .updateVoiceState(guildId, userId):
            return "updateVoiceState(guildId.value: \(guildId.value), userId.value: \(userId.value))"
        case let .getGuildWebhooks(guildId):
            return "getGuildWebhooks(guildId.value: \(guildId.value))"
        case let .getWebhook(webhookId):
            return "getWebhook(webhookId.value: \(webhookId.value))"
        case let .getWebhookByToken(webhookId, webhookToken):
            return "getWebhookByToken(webhookId.value: \(webhookId.value), webhookToken: \(webhookToken))"
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            return "getWebhookMessage(webhookId.value: \(webhookId.value), webhookToken: \(webhookToken), messageId.value: \(messageId.value))"
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            return "getWebhooksMessagesOriginal(webhookId.value: \(webhookId.value), webhookToken: \(webhookToken))"
        case let .listChannelWebhooks(channelId):
            return "listChannelWebhooks(channelId.value: \(channelId.value))"
        case let .createWebhook(channelId):
            return "createWebhook(channelId.value: \(channelId.value))"
        case let .executeWebhook(webhookId, webhookToken):
            return "executeWebhook(webhookId.value: \(webhookId.value), webhookToken: \(webhookToken))"
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
            return "patchWebhooksMessagesOriginal(webhookId.value: \(webhookId.value), webhookToken: \(webhookToken))"
        case let .updateWebhook(webhookId):
            return "updateWebhook(webhookId.value: \(webhookId.value))"
        case let .updateWebhookByToken(webhookId, webhookToken):
            return "updateWebhookByToken(webhookId.value: \(webhookId.value), webhookToken: \(webhookToken))"
        case let .updateWebhookMessage(webhookId, webhookToken, messageId):
            return "updateWebhookMessage(webhookId.value: \(webhookId.value), webhookToken: \(webhookToken), messageId.value: \(messageId.value))"
        case let .deleteWebhook(webhookId):
            return "deleteWebhook(webhookId.value: \(webhookId.value))"
        case let .deleteWebhookByToken(webhookId, webhookToken):
            return "deleteWebhookByToken(webhookId.value: \(webhookId.value), webhookToken: \(webhookToken))"
        case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
            return "deleteWebhookMessage(webhookId.value: \(webhookId.value), webhookToken: \(webhookToken), messageId.value: \(messageId.value))"
        case let .deleteWebhooksMessagesOriginal(webhookId, webhookToken):
            return "deleteWebhooksMessagesOriginal(webhookId.value: \(webhookId.value), webhookToken: \(webhookToken))"
        }
    }
}

public enum CacheableAPIEndpointIdentity: Int, Sendable, Hashable, CustomStringConvertible {

    // MARK: AutoMod
    /// https://discord.com/developers/docs/resources/auto-moderation
    
    case getAutoModerationRule
    case listAutoModerationRules
    
    // MARK: Audit Log
    /// https://discord.com/developers/docs/resources/audit-log
    
    case listGuildAuditLogEntries
    
    // MARK: Channels
    /// https://discord.com/developers/docs/resources/channel
    
    case getChannel
    case listPinnedMessages
    
    // MARK: Commands
    /// https://discord.com/developers/docs/interactions/application-commands
    
    case getApplicationCommand
    case getGuildApplicationCommand
    case getGuildApplicationCommandPermissions
    case listApplicationCommands
    case listGuildApplicationCommandPermissions
    case listGuildApplicationCommands
    
    // MARK: Emoji
    /// https://discord.com/developers/docs/resources/emoji
    
    case getGuildEmoji
    case listGuildEmojis
    
    // MARK: Gateway
    /// https://discord.com/developers/docs/topics/gateway
    
    case getBotGateway
    case getGateway
    
    // MARK: Guilds
    /// https://discord.com/developers/docs/resources/guild
    
    case getGuild
    case getGuildBan
    case getGuildOnboarding
    case getGuildPreview
    case getGuildVanityUrl
    case getGuildWelcomeScreen
    case getGuildWidget
    case getGuildWidgetPng
    case getGuildWidgetSettings
    case listGuildBans
    case listGuildChannels
    case listGuildIntegrations
    case listOwnGuilds
    case previewPruneGuild
    
    // MARK: Guild Templates
    /// https://discord.com/developers/docs/resources/guild-template
    
    case getGuildTemplate
    case listGuildTemplates
    
    // MARK: Interactions
    /// https://discord.com/developers/docs/interactions/receiving-and-responding
    
    case getFollowupMessage
    case getOriginalInteractionResponse
    
    // MARK: Invites
    /// https://discord.com/developers/docs/resources/invite
    
    case inviteResolve
    case listChannelInvites
    case listGuildInvites
    
    // MARK: Members
    /// https://discord.com/developers/docs/resources/guild
    
    case getGuildMember
    case getOwnGuildMember
    case listGuildMembers
    case searchGuildMembers
    
    // MARK: Messages
    /// https://discord.com/developers/docs/resources/channel
    
    case getMessage
    case listMessageReactionsByEmoji
    case listMessages
    
    // MARK: OAuth
    /// https://discord.com/developers/docs/topics/oauth2
    
    case getOwnOauth2Application
    
    // MARK: Roles
    /// https://discord.com/developers/docs/resources/guild
    
    case listGuildRoles
    
    // MARK: Role Connections
    /// https://discord.com/developers/docs/resources/user
    
    case getApplicationRoleConnectionsMetadata
    case getApplicationUserRoleConnection
    
    // MARK: Scheduled Events
    /// https://discord.com/developers/docs/resources/guild-scheduled-event
    
    case getGuildScheduledEvent
    case listGuildScheduledEventUsers
    case listGuildScheduledEvents
    
    // MARK: Stages
    /// https://discord.com/developers/docs/resources/stage-instance
    
    case getStageInstance
    
    // MARK: Stickers
    /// https://discord.com/developers/docs/resources/sticker
    
    case getGuildSticker
    case getSticker
    case listGuildStickers
    case listStickerPacks
    
    // MARK: Threads
    /// https://discord.com/developers/docs/resources/channel
    
    case getActiveGuildThreads
    case getThreadMember
    case listOwnPrivateArchivedThreads
    case listPrivateArchivedThreads
    case listPublicArchivedThreads
    case listThreadMembers
    
    // MARK: Users
    /// https://discord.com/developers/docs/resources/user
    
    case getOwnUser
    case getUser
    case listOwnConnections
    
    // MARK: Voice
    /// https://discord.com/developers/docs/resources/voice#list-voice-regions
    
    case listGuildVoiceRegions
    case listVoiceRegions
    
    // MARK: Webhooks
    /// https://discord.com/developers/docs/resources/webhook
    
    case getGuildWebhooks
    case getWebhook
    case getWebhookByToken
    case getWebhookMessage
    case getWebhooksMessagesOriginal
    case listChannelWebhooks

    public var description: String {
        switch self {
        case .getAutoModerationRule: return "getAutoModerationRule"
        case .listAutoModerationRules: return "listAutoModerationRules"
        case .listGuildAuditLogEntries: return "listGuildAuditLogEntries"
        case .getChannel: return "getChannel"
        case .listPinnedMessages: return "listPinnedMessages"
        case .getApplicationCommand: return "getApplicationCommand"
        case .getGuildApplicationCommand: return "getGuildApplicationCommand"
        case .getGuildApplicationCommandPermissions: return "getGuildApplicationCommandPermissions"
        case .listApplicationCommands: return "listApplicationCommands"
        case .listGuildApplicationCommandPermissions: return "listGuildApplicationCommandPermissions"
        case .listGuildApplicationCommands: return "listGuildApplicationCommands"
        case .getGuildEmoji: return "getGuildEmoji"
        case .listGuildEmojis: return "listGuildEmojis"
        case .getBotGateway: return "getBotGateway"
        case .getGateway: return "getGateway"
        case .getGuild: return "getGuild"
        case .getGuildBan: return "getGuildBan"
        case .getGuildOnboarding: return "getGuildOnboarding"
        case .getGuildPreview: return "getGuildPreview"
        case .getGuildVanityUrl: return "getGuildVanityUrl"
        case .getGuildWelcomeScreen: return "getGuildWelcomeScreen"
        case .getGuildWidget: return "getGuildWidget"
        case .getGuildWidgetPng: return "getGuildWidgetPng"
        case .getGuildWidgetSettings: return "getGuildWidgetSettings"
        case .listGuildBans: return "listGuildBans"
        case .listGuildChannels: return "listGuildChannels"
        case .listGuildIntegrations: return "listGuildIntegrations"
        case .listOwnGuilds: return "listOwnGuilds"
        case .previewPruneGuild: return "previewPruneGuild"
        case .getGuildTemplate: return "getGuildTemplate"
        case .listGuildTemplates: return "listGuildTemplates"
        case .getFollowupMessage: return "getFollowupMessage"
        case .getOriginalInteractionResponse: return "getOriginalInteractionResponse"
        case .inviteResolve: return "inviteResolve"
        case .listChannelInvites: return "listChannelInvites"
        case .listGuildInvites: return "listGuildInvites"
        case .getGuildMember: return "getGuildMember"
        case .getOwnGuildMember: return "getOwnGuildMember"
        case .listGuildMembers: return "listGuildMembers"
        case .searchGuildMembers: return "searchGuildMembers"
        case .getMessage: return "getMessage"
        case .listMessageReactionsByEmoji: return "listMessageReactionsByEmoji"
        case .listMessages: return "listMessages"
        case .getOwnOauth2Application: return "getOwnOauth2Application"
        case .listGuildRoles: return "listGuildRoles"
        case .getApplicationRoleConnectionsMetadata: return "getApplicationRoleConnectionsMetadata"
        case .getApplicationUserRoleConnection: return "getApplicationUserRoleConnection"
        case .getGuildScheduledEvent: return "getGuildScheduledEvent"
        case .listGuildScheduledEventUsers: return "listGuildScheduledEventUsers"
        case .listGuildScheduledEvents: return "listGuildScheduledEvents"
        case .getStageInstance: return "getStageInstance"
        case .getGuildSticker: return "getGuildSticker"
        case .getSticker: return "getSticker"
        case .listGuildStickers: return "listGuildStickers"
        case .listStickerPacks: return "listStickerPacks"
        case .getActiveGuildThreads: return "getActiveGuildThreads"
        case .getThreadMember: return "getThreadMember"
        case .listOwnPrivateArchivedThreads: return "listOwnPrivateArchivedThreads"
        case .listPrivateArchivedThreads: return "listPrivateArchivedThreads"
        case .listPublicArchivedThreads: return "listPublicArchivedThreads"
        case .listThreadMembers: return "listThreadMembers"
        case .getOwnUser: return "getOwnUser"
        case .getUser: return "getUser"
        case .listOwnConnections: return "listOwnConnections"
        case .listGuildVoiceRegions: return "listGuildVoiceRegions"
        case .listVoiceRegions: return "listVoiceRegions"
        case .getGuildWebhooks: return "getGuildWebhooks"
        case .getWebhook: return "getWebhook"
        case .getWebhookByToken: return "getWebhookByToken"
        case .getWebhookMessage: return "getWebhookMessage"
        case .getWebhooksMessagesOriginal: return "getWebhooksMessagesOriginal"
        case .listChannelWebhooks: return "listChannelWebhooks"
        }
    }

    init? (endpoint: APIEndpoint) {
        switch endpoint {
        case .getAutoModerationRule: self = .getAutoModerationRule
        case .listAutoModerationRules: self = .listAutoModerationRules
        case .listGuildAuditLogEntries: self = .listGuildAuditLogEntries
        case .getChannel: self = .getChannel
        case .listPinnedMessages: self = .listPinnedMessages
        case .getApplicationCommand: self = .getApplicationCommand
        case .getGuildApplicationCommand: self = .getGuildApplicationCommand
        case .getGuildApplicationCommandPermissions: self = .getGuildApplicationCommandPermissions
        case .listApplicationCommands: self = .listApplicationCommands
        case .listGuildApplicationCommandPermissions: self = .listGuildApplicationCommandPermissions
        case .listGuildApplicationCommands: self = .listGuildApplicationCommands
        case .getGuildEmoji: self = .getGuildEmoji
        case .listGuildEmojis: self = .listGuildEmojis
        case .getBotGateway: self = .getBotGateway
        case .getGateway: self = .getGateway
        case .getGuild: self = .getGuild
        case .getGuildBan: self = .getGuildBan
        case .getGuildOnboarding: self = .getGuildOnboarding
        case .getGuildPreview: self = .getGuildPreview
        case .getGuildVanityUrl: self = .getGuildVanityUrl
        case .getGuildWelcomeScreen: self = .getGuildWelcomeScreen
        case .getGuildWidget: self = .getGuildWidget
        case .getGuildWidgetPng: self = .getGuildWidgetPng
        case .getGuildWidgetSettings: self = .getGuildWidgetSettings
        case .listGuildBans: self = .listGuildBans
        case .listGuildChannels: self = .listGuildChannels
        case .listGuildIntegrations: self = .listGuildIntegrations
        case .listOwnGuilds: self = .listOwnGuilds
        case .previewPruneGuild: self = .previewPruneGuild
        case .getGuildTemplate: self = .getGuildTemplate
        case .listGuildTemplates: self = .listGuildTemplates
        case .getFollowupMessage: self = .getFollowupMessage
        case .getOriginalInteractionResponse: self = .getOriginalInteractionResponse
        case .inviteResolve: self = .inviteResolve
        case .listChannelInvites: self = .listChannelInvites
        case .listGuildInvites: self = .listGuildInvites
        case .getGuildMember: self = .getGuildMember
        case .getOwnGuildMember: self = .getOwnGuildMember
        case .listGuildMembers: self = .listGuildMembers
        case .searchGuildMembers: self = .searchGuildMembers
        case .getMessage: self = .getMessage
        case .listMessageReactionsByEmoji: self = .listMessageReactionsByEmoji
        case .listMessages: self = .listMessages
        case .getOwnOauth2Application: self = .getOwnOauth2Application
        case .listGuildRoles: self = .listGuildRoles
        case .getApplicationRoleConnectionsMetadata: self = .getApplicationRoleConnectionsMetadata
        case .getApplicationUserRoleConnection: self = .getApplicationUserRoleConnection
        case .getGuildScheduledEvent: self = .getGuildScheduledEvent
        case .listGuildScheduledEventUsers: self = .listGuildScheduledEventUsers
        case .listGuildScheduledEvents: self = .listGuildScheduledEvents
        case .getStageInstance: self = .getStageInstance
        case .getGuildSticker: self = .getGuildSticker
        case .getSticker: self = .getSticker
        case .listGuildStickers: self = .listGuildStickers
        case .listStickerPacks: self = .listStickerPacks
        case .getActiveGuildThreads: self = .getActiveGuildThreads
        case .getThreadMember: self = .getThreadMember
        case .listOwnPrivateArchivedThreads: self = .listOwnPrivateArchivedThreads
        case .listPrivateArchivedThreads: self = .listPrivateArchivedThreads
        case .listPublicArchivedThreads: self = .listPublicArchivedThreads
        case .listThreadMembers: self = .listThreadMembers
        case .getOwnUser: self = .getOwnUser
        case .getUser: self = .getUser
        case .listOwnConnections: self = .listOwnConnections
        case .listGuildVoiceRegions: self = .listGuildVoiceRegions
        case .listVoiceRegions: self = .listVoiceRegions
        case .getGuildWebhooks: self = .getGuildWebhooks
        case .getWebhook: self = .getWebhook
        case .getWebhookByToken: self = .getWebhookByToken
        case .getWebhookMessage: self = .getWebhookMessage
        case .getWebhooksMessagesOriginal: self = .getWebhooksMessagesOriginal
        case .listChannelWebhooks: self = .listChannelWebhooks
        default: return nil
        }
    }
}
