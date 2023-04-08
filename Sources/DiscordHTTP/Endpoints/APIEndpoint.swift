// DO NOT EDIT. Auto-generated using the GenerateAPIEndpoints command plugin.

/// If you want to add an endpoint that somehow doesn't exist, you'll need to
/// properly edit `/Plugins/GenerateAPIEndpointsExec/Resources/openapi.yml`, then trigger
/// the `GenerateAPIEndpoints` plugin (right click on `DiscordBM` in the file navigator)

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
    case getGuildOnboarding(guildId: String)
    case getGuildPreview(guildId: String)
    case getGuildVanityUrl(guildId: String)
    case getGuildWelcomeScreen(guildId: String)
    case getGuildWidget(guildId: String)
    case getGuildWidgetPng(guildId: String)
    case getGuildWidgetSettings(guildId: String)
    case listGuildBans(guildId: String)
    case listGuildIntegrations(guildId: String)
    case listOwnGuilds
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
    case getOwnGuildMember(guildId: String)
    case listGuildMembers(guildId: String)
    case searchGuildMembers(guildId: String)
    case addGuildMember(guildId: String, userId: String)
    case updateGuildMember(guildId: String, userId: String)
    case updateOwnGuildMember(guildId: String)
    case deleteGuildMember(guildId: String, userId: String)
    
    // MARK: Messages
    /// https://discord.com/developers/docs/resources/channel
    
    case getMessage(channelId: String, messageId: String)
    case listMessageReactionsByEmoji(channelId: String, messageId: String, emojiName: String)
    case listMessages(channelId: String)
    case addOwnMessageReaction(channelId: String, messageId: String, emojiName: String)
    case bulkDeleteMessages(channelId: String)
    case createMessage(channelId: String)
    case crosspostMessage(channelId: String, messageId: String)
    case updateMessage(channelId: String, messageId: String)
    case deleteAllMessageReactions(channelId: String, messageId: String)
    case deleteAllMessageReactionsByEmoji(channelId: String, messageId: String, emojiName: String)
    case deleteMessage(channelId: String, messageId: String)
    case deleteOwnMessageReaction(channelId: String, messageId: String, emojiName: String)
    case deleteUserMessageReaction(channelId: String, messageId: String, emojiName: String, userId: String)
    
    // MARK: OAuth
    /// https://discord.com/developers/docs/topics/oauth2
    
    case getOwnOauth2Application
    
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
    case listOwnPrivateArchivedThreads(channelId: String)
    case listPrivateArchivedThreads(channelId: String)
    case listPublicArchivedThreads(channelId: String)
    case listThreadMembers(channelId: String)
    case addThreadMember(channelId: String, userId: String)
    case joinThread(channelId: String)
    case createThread(channelId: String)
    case createThreadFromMessage(channelId: String, messageId: String)
    case createThreadInForumChannel(channelId: String)
    case deleteThreadMember(channelId: String, userId: String)
    case leaveThread(channelId: String)
    
    // MARK: Users
    /// https://discord.com/developers/docs/resources/user
    
    case getOwnUser
    case getUser(userId: String)
    case listOwnConnections
    case updateOwnUser
    
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
        let suffix: String
        switch self {
        case let .getAutoModerationRule(guildId, ruleId):
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .listAutoModerationRules(guildId):
            suffix = "guilds/\(guildId)/auto-moderation/rules"
        case let .createAutoModerationRule(guildId):
            suffix = "guilds/\(guildId)/auto-moderation/rules"
        case let .updateAutoModerationRule(guildId, ruleId):
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .deleteAutoModerationRule(guildId, ruleId):
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .listGuildAuditLogEntries(guildId):
            suffix = "guilds/\(guildId)/audit-logs"
        case let .getChannel(channelId):
            suffix = "channels/\(channelId)"
        case let .listGuildChannels(guildId):
            suffix = "guilds/\(guildId)/channels"
        case let .listPinnedMessages(channelId):
            suffix = "channels/\(channelId)/pins"
        case let .addGroupDmUser(channelId, userId):
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .pinMessage(channelId, messageId):
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .setChannelPermissionOverwrite(channelId, overwriteId):
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case .createDm:
            suffix = "users/@me/channels"
        case let .createGuildChannel(guildId):
            suffix = "guilds/\(guildId)/channels"
        case let .followChannel(channelId):
            suffix = "channels/\(channelId)/followers"
        case let .triggerTypingIndicator(channelId):
            suffix = "channels/\(channelId)/typing"
        case let .bulkUpdateGuildChannels(guildId):
            suffix = "guilds/\(guildId)/channels"
        case let .updateChannel(channelId):
            suffix = "channels/\(channelId)"
        case let .deleteChannel(channelId):
            suffix = "channels/\(channelId)"
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case let .deleteGroupDmUser(channelId, userId):
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .unpinMessage(channelId, messageId):
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .getApplicationCommand(applicationId, commandId):
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .listApplicationCommands(applicationId):
            suffix = "applications/\(applicationId)/commands"
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
        case let .listGuildApplicationCommands(applicationId, guildId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .bulkSetApplicationCommands(applicationId):
            suffix = "applications/\(applicationId)/commands"
        case let .bulkSetGuildApplicationCommands(applicationId, guildId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .setGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .createApplicationCommand(applicationId):
            suffix = "applications/\(applicationId)/commands"
        case let .createGuildApplicationCommand(applicationId, guildId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .updateApplicationCommand(applicationId, commandId):
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .updateGuildApplicationCommand(applicationId, guildId, commandId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .deleteApplicationCommand(applicationId, commandId):
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .deleteGuildApplicationCommand(applicationId, guildId, commandId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .getGuildEmoji(guildId, emojiId):
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case let .listGuildEmojis(guildId):
            suffix = "guilds/\(guildId)/emojis"
        case let .createGuildEmoji(guildId):
            suffix = "guilds/\(guildId)/emojis"
        case let .updateGuildEmoji(guildId, emojiId):
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case let .deleteGuildEmoji(guildId, emojiId):
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case .getBotGateway:
            suffix = "gateway/bot"
        case .getGateway:
            suffix = "gateway"
        case let .getGuild(guildId):
            suffix = "guilds/\(guildId)"
        case let .getGuildBan(guildId, userId):
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildOnboarding(guildId):
            suffix = "guilds/\(guildId)/onboarding"
        case let .getGuildPreview(guildId):
            suffix = "guilds/\(guildId)/preview"
        case let .getGuildVanityUrl(guildId):
            suffix = "guilds/\(guildId)/vanity-url"
        case let .getGuildWelcomeScreen(guildId):
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .getGuildWidget(guildId):
            suffix = "guilds/\(guildId)/widget.json"
        case let .getGuildWidgetPng(guildId):
            suffix = "guilds/\(guildId)/widget.png"
        case let .getGuildWidgetSettings(guildId):
            suffix = "guilds/\(guildId)/widget"
        case let .listGuildBans(guildId):
            suffix = "guilds/\(guildId)/bans"
        case let .listGuildIntegrations(guildId):
            suffix = "guilds/\(guildId)/integrations"
        case .listOwnGuilds:
            suffix = "users/@me/guilds"
        case let .previewPruneGuild(guildId):
            suffix = "guilds/\(guildId)/prune"
        case let .banUserFromGuild(guildId, userId):
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case .createGuild:
            suffix = "guilds"
        case let .pruneGuild(guildId):
            suffix = "guilds/\(guildId)/prune"
        case let .setGuildMfaLevel(guildId):
            suffix = "guilds/\(guildId)/mfa"
        case let .updateGuild(guildId):
            suffix = "guilds/\(guildId)"
        case let .updateGuildWelcomeScreen(guildId):
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .updateGuildWidgetSettings(guildId):
            suffix = "guilds/\(guildId)/widget"
        case let .deleteGuild(guildId):
            suffix = "guilds/\(guildId)"
        case let .deleteGuildIntegration(guildId, integrationId):
            suffix = "guilds/\(guildId)/integrations/\(integrationId)"
        case let .leaveGuild(guildId):
            suffix = "users/@me/guilds/\(guildId)"
        case let .unbanUserFromGuild(guildId, userId):
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildTemplate(code):
            suffix = "guilds/templates/\(code)"
        case let .listGuildTemplates(guildId):
            suffix = "guilds/\(guildId)/templates"
        case let .syncGuildTemplate(guildId, code):
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .createGuildFromTemplate(code):
            suffix = "guilds/templates/\(code)"
        case let .createGuildTemplate(guildId):
            suffix = "guilds/\(guildId)/templates"
        case let .updateGuildTemplate(guildId, code):
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .deleteGuildTemplate(guildId, code):
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .getFollowupMessage(applicationId, interactionToken, messageId):
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
        case let .getOriginalInteractionResponse(applicationId, interactionToken):
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
        case let .createFollowupMessage(applicationId, interactionToken):
            suffix = "webhooks/\(applicationId)/\(interactionToken)"
        case let .createInteractionResponse(interactionId, interactionToken):
            suffix = "interactions/\(interactionId)/\(interactionToken)/callback"
        case let .updateFollowupMessage(applicationId, interactionToken, messageId):
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
        case let .updateOriginalInteractionResponse(applicationId, interactionToken):
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
        case let .deleteFollowupMessage(applicationId, interactionToken, messageId):
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
        case let .deleteOriginalInteractionResponse(applicationId, interactionToken):
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
        case let .inviteResolve(code):
            suffix = "invites/\(code)"
        case let .listChannelInvites(channelId):
            suffix = "channels/\(channelId)/invites"
        case let .listGuildInvites(guildId):
            suffix = "guilds/\(guildId)/invites"
        case let .createChannelInvite(channelId):
            suffix = "channels/\(channelId)/invites"
        case let .inviteRevoke(code):
            suffix = "invites/\(code)"
        case let .getGuildMember(guildId, userId):
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .getOwnGuildMember(guildId):
            suffix = "users/@me/guilds/\(guildId)/member"
        case let .listGuildMembers(guildId):
            suffix = "guilds/\(guildId)/members"
        case let .searchGuildMembers(guildId):
            suffix = "guilds/\(guildId)/members/search"
        case let .addGuildMember(guildId, userId):
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .updateGuildMember(guildId, userId):
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .updateOwnGuildMember(guildId):
            suffix = "guilds/\(guildId)/members/@me"
        case let .deleteGuildMember(guildId, userId):
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .getMessage(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .listMessages(channelId):
            suffix = "channels/\(channelId)/messages"
        case let .addOwnMessageReaction(channelId, messageId, emojiName):
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .bulkDeleteMessages(channelId):
            suffix = "channels/\(channelId)/messages/bulk-delete"
        case let .createMessage(channelId):
            suffix = "channels/\(channelId)/messages"
        case let .crosspostMessage(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)/crosspost"
        case let .updateMessage(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteAllMessageReactions(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions"
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .deleteMessage(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteOwnMessageReaction(channelId, messageId, emojiName):
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/\(userId)"
        case .getOwnOauth2Application:
            suffix = "oauth2/applications/@me"
        case let .listGuildRoles(guildId):
            suffix = "guilds/\(guildId)/roles"
        case let .addGuildMemberRole(guildId, userId, roleId):
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .createGuildRole(guildId):
            suffix = "guilds/\(guildId)/roles"
        case let .bulkUpdateGuildRoles(guildId):
            suffix = "guilds/\(guildId)/roles"
        case let .updateGuildRole(guildId, roleId):
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .deleteGuildMemberRole(guildId, userId, roleId):
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .deleteGuildRole(guildId, roleId):
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .getApplicationRoleConnectionsMetadata(applicationId):
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .getApplicationUserRoleConnection(applicationId):
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .updateApplicationRoleConnectionsMetadata(applicationId):
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .updateApplicationUserRoleConnection(applicationId):
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)/users"
        case let .listGuildScheduledEvents(guildId):
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .createGuildScheduledEvent(guildId):
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .updateGuildScheduledEvent(guildId, guildScheduledEventId):
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .deleteGuildScheduledEvent(guildId, guildScheduledEventId):
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .getStageInstance(channelId):
            suffix = "stage-instances/\(channelId)"
        case .createStageInstance:
            suffix = "stage-instances"
        case let .updateStageInstance(channelId):
            suffix = "stage-instances/\(channelId)"
        case let .deleteStageInstance(channelId):
            suffix = "stage-instances/\(channelId)"
        case let .getGuildSticker(guildId, stickerId):
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .getSticker(stickerId):
            suffix = "stickers/\(stickerId)"
        case let .listGuildStickers(guildId):
            suffix = "guilds/\(guildId)/stickers"
        case .listStickerPacks:
            suffix = "sticker-packs"
        case let .createGuildSticker(guildId):
            suffix = "guilds/\(guildId)/stickers"
        case let .updateGuildSticker(guildId, stickerId):
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .deleteGuildSticker(guildId, stickerId):
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .getActiveGuildThreads(guildId):
            suffix = "guilds/\(guildId)/threads/active"
        case let .getThreadMember(channelId, userId):
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .listOwnPrivateArchivedThreads(channelId):
            suffix = "channels/\(channelId)/users/@me/threads/archived/private"
        case let .listPrivateArchivedThreads(channelId):
            suffix = "channels/\(channelId)/threads/archived/private"
        case let .listPublicArchivedThreads(channelId):
            suffix = "channels/\(channelId)/threads/archived/public"
        case let .listThreadMembers(channelId):
            suffix = "channels/\(channelId)/thread-members"
        case let .addThreadMember(channelId, userId):
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .joinThread(channelId):
            suffix = "channels/\(channelId)/thread-members/@me"
        case let .createThread(channelId):
            suffix = "channels/\(channelId)/threads"
        case let .createThreadFromMessage(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)/threads"
        case let .createThreadInForumChannel(channelId):
            suffix = "channels/\(channelId)/threads"
        case let .deleteThreadMember(channelId, userId):
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .leaveThread(channelId):
            suffix = "channels/\(channelId)/thread-members/@me"
        case .getOwnUser:
            suffix = "users/@me"
        case let .getUser(userId):
            suffix = "users/\(userId)"
        case .listOwnConnections:
            suffix = "users/@me/connections"
        case .updateOwnUser:
            suffix = "users/@me"
        case let .listGuildVoiceRegions(guildId):
            suffix = "guilds/\(guildId)/regions"
        case .listVoiceRegions:
            suffix = "voice/regions"
        case let .updateSelfVoiceState(guildId):
            suffix = "guilds/\(guildId)/voice-states/@me"
        case let .updateVoiceState(guildId, userId):
            suffix = "guilds/\(guildId)/voice-states/\(userId)"
        case let .getGuildWebhooks(guildId):
            suffix = "guilds/\(guildId)/webhooks"
        case let .getWebhook(webhookId):
            suffix = "webhooks/\(webhookId)"
        case let .getWebhookByToken(webhookId, webhookToken):
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .listChannelWebhooks(channelId):
            suffix = "channels/\(channelId)/webhooks"
        case let .createWebhook(channelId):
            suffix = "channels/\(channelId)/webhooks"
        case let .executeWebhook(webhookId, webhookToken):
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .updateWebhook(webhookId):
            suffix = "webhooks/\(webhookId)"
        case let .updateWebhookByToken(webhookId, webhookToken):
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .updateWebhookMessage(webhookId, webhookToken, messageId):
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .deleteWebhook(webhookId):
            suffix = "webhooks/\(webhookId)"
        case let .deleteWebhookByToken(webhookId, webhookToken):
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .deleteWebhooksMessagesOriginal(webhookId, webhookToken):
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        }
        return urlPrefix + suffix
    }

    public var urlDescription: String {
        let suffix: String
        switch self {
        case let .getAutoModerationRule(guildId, ruleId):
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .listAutoModerationRules(guildId):
            suffix = "guilds/\(guildId)/auto-moderation/rules"
        case let .createAutoModerationRule(guildId):
            suffix = "guilds/\(guildId)/auto-moderation/rules"
        case let .updateAutoModerationRule(guildId, ruleId):
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .deleteAutoModerationRule(guildId, ruleId):
            suffix = "guilds/\(guildId)/auto-moderation/rules/\(ruleId)"
        case let .listGuildAuditLogEntries(guildId):
            suffix = "guilds/\(guildId)/audit-logs"
        case let .getChannel(channelId):
            suffix = "channels/\(channelId)"
        case let .listGuildChannels(guildId):
            suffix = "guilds/\(guildId)/channels"
        case let .listPinnedMessages(channelId):
            suffix = "channels/\(channelId)/pins"
        case let .addGroupDmUser(channelId, userId):
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .pinMessage(channelId, messageId):
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .setChannelPermissionOverwrite(channelId, overwriteId):
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case .createDm:
            suffix = "users/@me/channels"
        case let .createGuildChannel(guildId):
            suffix = "guilds/\(guildId)/channels"
        case let .followChannel(channelId):
            suffix = "channels/\(channelId)/followers"
        case let .triggerTypingIndicator(channelId):
            suffix = "channels/\(channelId)/typing"
        case let .bulkUpdateGuildChannels(guildId):
            suffix = "guilds/\(guildId)/channels"
        case let .updateChannel(channelId):
            suffix = "channels/\(channelId)"
        case let .deleteChannel(channelId):
            suffix = "channels/\(channelId)"
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            suffix = "channels/\(channelId)/permissions/\(overwriteId)"
        case let .deleteGroupDmUser(channelId, userId):
            suffix = "channels/\(channelId)/recipients/\(userId)"
        case let .unpinMessage(channelId, messageId):
            suffix = "channels/\(channelId)/pins/\(messageId)"
        case let .getApplicationCommand(applicationId, commandId):
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .listApplicationCommands(applicationId):
            suffix = "applications/\(applicationId)/commands"
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/permissions"
        case let .listGuildApplicationCommands(applicationId, guildId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .bulkSetApplicationCommands(applicationId):
            suffix = "applications/\(applicationId)/commands"
        case let .bulkSetGuildApplicationCommands(applicationId, guildId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .setGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .createApplicationCommand(applicationId):
            suffix = "applications/\(applicationId)/commands"
        case let .createGuildApplicationCommand(applicationId, guildId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands"
        case let .updateApplicationCommand(applicationId, commandId):
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .updateGuildApplicationCommand(applicationId, guildId, commandId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .deleteApplicationCommand(applicationId, commandId):
            suffix = "applications/\(applicationId)/commands/\(commandId)"
        case let .deleteGuildApplicationCommand(applicationId, guildId, commandId):
            suffix = "applications/\(applicationId)/guilds/\(guildId)/commands/\(commandId)"
        case let .getGuildEmoji(guildId, emojiId):
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case let .listGuildEmojis(guildId):
            suffix = "guilds/\(guildId)/emojis"
        case let .createGuildEmoji(guildId):
            suffix = "guilds/\(guildId)/emojis"
        case let .updateGuildEmoji(guildId, emojiId):
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case let .deleteGuildEmoji(guildId, emojiId):
            suffix = "guilds/\(guildId)/emojis/\(emojiId)"
        case .getBotGateway:
            suffix = "gateway/bot"
        case .getGateway:
            suffix = "gateway"
        case let .getGuild(guildId):
            suffix = "guilds/\(guildId)"
        case let .getGuildBan(guildId, userId):
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildOnboarding(guildId):
            suffix = "guilds/\(guildId)/onboarding"
        case let .getGuildPreview(guildId):
            suffix = "guilds/\(guildId)/preview"
        case let .getGuildVanityUrl(guildId):
            suffix = "guilds/\(guildId)/vanity-url"
        case let .getGuildWelcomeScreen(guildId):
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .getGuildWidget(guildId):
            suffix = "guilds/\(guildId)/widget.json"
        case let .getGuildWidgetPng(guildId):
            suffix = "guilds/\(guildId)/widget.png"
        case let .getGuildWidgetSettings(guildId):
            suffix = "guilds/\(guildId)/widget"
        case let .listGuildBans(guildId):
            suffix = "guilds/\(guildId)/bans"
        case let .listGuildIntegrations(guildId):
            suffix = "guilds/\(guildId)/integrations"
        case .listOwnGuilds:
            suffix = "users/@me/guilds"
        case let .previewPruneGuild(guildId):
            suffix = "guilds/\(guildId)/prune"
        case let .banUserFromGuild(guildId, userId):
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case .createGuild:
            suffix = "guilds"
        case let .pruneGuild(guildId):
            suffix = "guilds/\(guildId)/prune"
        case let .setGuildMfaLevel(guildId):
            suffix = "guilds/\(guildId)/mfa"
        case let .updateGuild(guildId):
            suffix = "guilds/\(guildId)"
        case let .updateGuildWelcomeScreen(guildId):
            suffix = "guilds/\(guildId)/welcome-screen"
        case let .updateGuildWidgetSettings(guildId):
            suffix = "guilds/\(guildId)/widget"
        case let .deleteGuild(guildId):
            suffix = "guilds/\(guildId)"
        case let .deleteGuildIntegration(guildId, integrationId):
            suffix = "guilds/\(guildId)/integrations/\(integrationId)"
        case let .leaveGuild(guildId):
            suffix = "users/@me/guilds/\(guildId)"
        case let .unbanUserFromGuild(guildId, userId):
            suffix = "guilds/\(guildId)/bans/\(userId)"
        case let .getGuildTemplate(code):
            suffix = "guilds/templates/\(code)"
        case let .listGuildTemplates(guildId):
            suffix = "guilds/\(guildId)/templates"
        case let .syncGuildTemplate(guildId, code):
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .createGuildFromTemplate(code):
            suffix = "guilds/templates/\(code)"
        case let .createGuildTemplate(guildId):
            suffix = "guilds/\(guildId)/templates"
        case let .updateGuildTemplate(guildId, code):
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .deleteGuildTemplate(guildId, code):
            suffix = "guilds/\(guildId)/templates/\(code)"
        case let .getFollowupMessage(applicationId, interactionToken, messageId):
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
        case let .getOriginalInteractionResponse(applicationId, interactionToken):
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
        case let .createFollowupMessage(applicationId, interactionToken):
            suffix = "webhooks/\(applicationId)/\(interactionToken)"
        case let .createInteractionResponse(interactionId, interactionToken):
            suffix = "interactions/\(interactionId)/\(interactionToken)/callback"
        case let .updateFollowupMessage(applicationId, interactionToken, messageId):
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
        case let .updateOriginalInteractionResponse(applicationId, interactionToken):
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
        case let .deleteFollowupMessage(applicationId, interactionToken, messageId):
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/\(messageId)"
        case let .deleteOriginalInteractionResponse(applicationId, interactionToken):
            suffix = "webhooks/\(applicationId)/\(interactionToken)/messages/@original"
        case let .inviteResolve(code):
            suffix = "invites/\(code)"
        case let .listChannelInvites(channelId):
            suffix = "channels/\(channelId)/invites"
        case let .listGuildInvites(guildId):
            suffix = "guilds/\(guildId)/invites"
        case let .createChannelInvite(channelId):
            suffix = "channels/\(channelId)/invites"
        case let .inviteRevoke(code):
            suffix = "invites/\(code)"
        case let .getGuildMember(guildId, userId):
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .getOwnGuildMember(guildId):
            suffix = "users/@me/guilds/\(guildId)/member"
        case let .listGuildMembers(guildId):
            suffix = "guilds/\(guildId)/members"
        case let .searchGuildMembers(guildId):
            suffix = "guilds/\(guildId)/members/search"
        case let .addGuildMember(guildId, userId):
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .updateGuildMember(guildId, userId):
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .updateOwnGuildMember(guildId):
            suffix = "guilds/\(guildId)/members/@me"
        case let .deleteGuildMember(guildId, userId):
            suffix = "guilds/\(guildId)/members/\(userId)"
        case let .getMessage(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .listMessages(channelId):
            suffix = "channels/\(channelId)/messages"
        case let .addOwnMessageReaction(channelId, messageId, emojiName):
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .bulkDeleteMessages(channelId):
            suffix = "channels/\(channelId)/messages/bulk-delete"
        case let .createMessage(channelId):
            suffix = "channels/\(channelId)/messages"
        case let .crosspostMessage(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)/crosspost"
        case let .updateMessage(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteAllMessageReactions(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions"
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)"
        case let .deleteMessage(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteOwnMessageReaction(channelId, messageId, emojiName):
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/@me"
        case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
            let emojiName = emojiName.urlPathEncoded()
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emojiName)/\(userId)"
        case .getOwnOauth2Application:
            suffix = "oauth2/applications/@me"
        case let .listGuildRoles(guildId):
            suffix = "guilds/\(guildId)/roles"
        case let .addGuildMemberRole(guildId, userId, roleId):
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .createGuildRole(guildId):
            suffix = "guilds/\(guildId)/roles"
        case let .bulkUpdateGuildRoles(guildId):
            suffix = "guilds/\(guildId)/roles"
        case let .updateGuildRole(guildId, roleId):
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .deleteGuildMemberRole(guildId, userId, roleId):
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .deleteGuildRole(guildId, roleId):
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .getApplicationRoleConnectionsMetadata(applicationId):
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .getApplicationUserRoleConnection(applicationId):
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .updateApplicationRoleConnectionsMetadata(applicationId):
            suffix = "applications/\(applicationId)/role-connections/metadata"
        case let .updateApplicationUserRoleConnection(applicationId):
            suffix = "users/@me/applications/\(applicationId)/role-connection"
        case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)/users"
        case let .listGuildScheduledEvents(guildId):
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .createGuildScheduledEvent(guildId):
            suffix = "guilds/\(guildId)/scheduled-events"
        case let .updateGuildScheduledEvent(guildId, guildScheduledEventId):
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .deleteGuildScheduledEvent(guildId, guildScheduledEventId):
            suffix = "guilds/\(guildId)/scheduled-events/\(guildScheduledEventId)"
        case let .getStageInstance(channelId):
            suffix = "stage-instances/\(channelId)"
        case .createStageInstance:
            suffix = "stage-instances"
        case let .updateStageInstance(channelId):
            suffix = "stage-instances/\(channelId)"
        case let .deleteStageInstance(channelId):
            suffix = "stage-instances/\(channelId)"
        case let .getGuildSticker(guildId, stickerId):
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .getSticker(stickerId):
            suffix = "stickers/\(stickerId)"
        case let .listGuildStickers(guildId):
            suffix = "guilds/\(guildId)/stickers"
        case .listStickerPacks:
            suffix = "sticker-packs"
        case let .createGuildSticker(guildId):
            suffix = "guilds/\(guildId)/stickers"
        case let .updateGuildSticker(guildId, stickerId):
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .deleteGuildSticker(guildId, stickerId):
            suffix = "guilds/\(guildId)/stickers/\(stickerId)"
        case let .getActiveGuildThreads(guildId):
            suffix = "guilds/\(guildId)/threads/active"
        case let .getThreadMember(channelId, userId):
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .listOwnPrivateArchivedThreads(channelId):
            suffix = "channels/\(channelId)/users/@me/threads/archived/private"
        case let .listPrivateArchivedThreads(channelId):
            suffix = "channels/\(channelId)/threads/archived/private"
        case let .listPublicArchivedThreads(channelId):
            suffix = "channels/\(channelId)/threads/archived/public"
        case let .listThreadMembers(channelId):
            suffix = "channels/\(channelId)/thread-members"
        case let .addThreadMember(channelId, userId):
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .joinThread(channelId):
            suffix = "channels/\(channelId)/thread-members/@me"
        case let .createThread(channelId):
            suffix = "channels/\(channelId)/threads"
        case let .createThreadFromMessage(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)/threads"
        case let .createThreadInForumChannel(channelId):
            suffix = "channels/\(channelId)/threads"
        case let .deleteThreadMember(channelId, userId):
            suffix = "channels/\(channelId)/thread-members/\(userId)"
        case let .leaveThread(channelId):
            suffix = "channels/\(channelId)/thread-members/@me"
        case .getOwnUser:
            suffix = "users/@me"
        case let .getUser(userId):
            suffix = "users/\(userId)"
        case .listOwnConnections:
            suffix = "users/@me/connections"
        case .updateOwnUser:
            suffix = "users/@me"
        case let .listGuildVoiceRegions(guildId):
            suffix = "guilds/\(guildId)/regions"
        case .listVoiceRegions:
            suffix = "voice/regions"
        case let .updateSelfVoiceState(guildId):
            suffix = "guilds/\(guildId)/voice-states/@me"
        case let .updateVoiceState(guildId, userId):
            suffix = "guilds/\(guildId)/voice-states/\(userId)"
        case let .getGuildWebhooks(guildId):
            suffix = "guilds/\(guildId)/webhooks"
        case let .getWebhook(webhookId):
            suffix = "webhooks/\(webhookId)"
        case let .getWebhookByToken(webhookId, webhookToken):
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .listChannelWebhooks(channelId):
            suffix = "channels/\(channelId)/webhooks"
        case let .createWebhook(channelId):
            suffix = "channels/\(channelId)/webhooks"
        case let .executeWebhook(webhookId, webhookToken):
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/@original"
        case let .updateWebhook(webhookId):
            suffix = "webhooks/\(webhookId)"
        case let .updateWebhookByToken(webhookId, webhookToken):
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .updateWebhookMessage(webhookId, webhookToken, messageId):
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .deleteWebhook(webhookId):
            suffix = "webhooks/\(webhookId)"
        case let .deleteWebhookByToken(webhookId, webhookToken):
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)"
        case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
            let webhookToken = webhookToken.urlPathEncoded().hash
            suffix = "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        case let .deleteWebhooksMessagesOriginal(webhookId, webhookToken):
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
        case .getGuildOnboarding: return .GET
        case .getGuildPreview: return .GET
        case .getGuildVanityUrl: return .GET
        case .getGuildWelcomeScreen: return .GET
        case .getGuildWidget: return .GET
        case .getGuildWidgetPng: return .GET
        case .getGuildWidgetSettings: return .GET
        case .listGuildBans: return .GET
        case .listGuildIntegrations: return .GET
        case .listOwnGuilds: return .GET
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
        case .listGuildChannels: return true
        case .listPinnedMessages: return true
        case .addGroupDmUser: return true
        case .pinMessage: return true
        case .setChannelPermissionOverwrite: return true
        case .createDm: return true
        case .createGuildChannel: return true
        case .followChannel: return true
        case .triggerTypingIndicator: return true
        case .bulkUpdateGuildChannels: return true
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
        case .listGuildIntegrations: return true
        case .listOwnGuilds: return true
        case .previewPruneGuild: return true
        case .banUserFromGuild: return true
        case .createGuild: return true
        case .pruneGuild: return true
        case .setGuildMfaLevel: return true
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
        case .listGuildChannels: return true
        case .listPinnedMessages: return true
        case .addGroupDmUser: return true
        case .pinMessage: return true
        case .setChannelPermissionOverwrite: return true
        case .createDm: return true
        case .createGuildChannel: return true
        case .followChannel: return true
        case .triggerTypingIndicator: return true
        case .bulkUpdateGuildChannels: return true
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
        case .listGuildIntegrations: return true
        case .listOwnGuilds: return true
        case .previewPruneGuild: return true
        case .banUserFromGuild: return true
        case .createGuild: return true
        case .pruneGuild: return true
        case .setGuildMfaLevel: return true
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
        case let .getGuildOnboarding(guildId):
            return [guildId]
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
        case .listOwnGuilds:
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
        case let .getOwnGuildMember(guildId):
            return [guildId]
        case let .listGuildMembers(guildId):
            return [guildId]
        case let .searchGuildMembers(guildId):
            return [guildId]
        case let .addGuildMember(guildId, userId):
            return [guildId, userId]
        case let .updateGuildMember(guildId, userId):
            return [guildId, userId]
        case let .updateOwnGuildMember(guildId):
            return [guildId]
        case let .deleteGuildMember(guildId, userId):
            return [guildId, userId]
        case let .getMessage(channelId, messageId):
            return [channelId, messageId]
        case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
            return [channelId, messageId, emojiName]
        case let .listMessages(channelId):
            return [channelId]
        case let .addOwnMessageReaction(channelId, messageId, emojiName):
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
        case let .deleteOwnMessageReaction(channelId, messageId, emojiName):
            return [channelId, messageId, emojiName]
        case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
            return [channelId, messageId, emojiName, userId]
        case .getOwnOauth2Application:
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
        case let .listOwnPrivateArchivedThreads(channelId):
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
        case let .createThreadInForumChannel(channelId):
            return [channelId]
        case let .deleteThreadMember(channelId, userId):
            return [channelId, userId]
        case let .leaveThread(channelId):
            return [channelId]
        case .getOwnUser:
            return []
        case let .getUser(userId):
            return [userId]
        case .listOwnConnections:
            return []
        case .updateOwnUser:
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
        case .getGuildOnboarding: return 47
        case .getGuildPreview: return 48
        case .getGuildVanityUrl: return 49
        case .getGuildWelcomeScreen: return 50
        case .getGuildWidget: return 51
        case .getGuildWidgetPng: return 52
        case .getGuildWidgetSettings: return 53
        case .listGuildBans: return 54
        case .listGuildIntegrations: return 55
        case .listOwnGuilds: return 56
        case .previewPruneGuild: return 57
        case .banUserFromGuild: return 58
        case .createGuild: return 59
        case .pruneGuild: return 60
        case .setGuildMfaLevel: return 61
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
            return "getAutoModerationRule(guildId: \(guildId), ruleId: \(ruleId))"
        case let .listAutoModerationRules(guildId):
            return "listAutoModerationRules(guildId: \(guildId))"
        case let .createAutoModerationRule(guildId):
            return "createAutoModerationRule(guildId: \(guildId))"
        case let .updateAutoModerationRule(guildId, ruleId):
            return "updateAutoModerationRule(guildId: \(guildId), ruleId: \(ruleId))"
        case let .deleteAutoModerationRule(guildId, ruleId):
            return "deleteAutoModerationRule(guildId: \(guildId), ruleId: \(ruleId))"
        case let .listGuildAuditLogEntries(guildId):
            return "listGuildAuditLogEntries(guildId: \(guildId))"
        case let .getChannel(channelId):
            return "getChannel(channelId: \(channelId))"
        case let .listGuildChannels(guildId):
            return "listGuildChannels(guildId: \(guildId))"
        case let .listPinnedMessages(channelId):
            return "listPinnedMessages(channelId: \(channelId))"
        case let .addGroupDmUser(channelId, userId):
            return "addGroupDmUser(channelId: \(channelId), userId: \(userId))"
        case let .pinMessage(channelId, messageId):
            return "pinMessage(channelId: \(channelId), messageId: \(messageId))"
        case let .setChannelPermissionOverwrite(channelId, overwriteId):
            return "setChannelPermissionOverwrite(channelId: \(channelId), overwriteId: \(overwriteId))"
        case .createDm:
            return "createDm"
        case let .createGuildChannel(guildId):
            return "createGuildChannel(guildId: \(guildId))"
        case let .followChannel(channelId):
            return "followChannel(channelId: \(channelId))"
        case let .triggerTypingIndicator(channelId):
            return "triggerTypingIndicator(channelId: \(channelId))"
        case let .bulkUpdateGuildChannels(guildId):
            return "bulkUpdateGuildChannels(guildId: \(guildId))"
        case let .updateChannel(channelId):
            return "updateChannel(channelId: \(channelId))"
        case let .deleteChannel(channelId):
            return "deleteChannel(channelId: \(channelId))"
        case let .deleteChannelPermissionOverwrite(channelId, overwriteId):
            return "deleteChannelPermissionOverwrite(channelId: \(channelId), overwriteId: \(overwriteId))"
        case let .deleteGroupDmUser(channelId, userId):
            return "deleteGroupDmUser(channelId: \(channelId), userId: \(userId))"
        case let .unpinMessage(channelId, messageId):
            return "unpinMessage(channelId: \(channelId), messageId: \(messageId))"
        case let .getApplicationCommand(applicationId, commandId):
            return "getApplicationCommand(applicationId: \(applicationId), commandId: \(commandId))"
        case let .getGuildApplicationCommand(applicationId, guildId, commandId):
            return "getGuildApplicationCommand(applicationId: \(applicationId), guildId: \(guildId), commandId: \(commandId))"
        case let .getGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            return "getGuildApplicationCommandPermissions(applicationId: \(applicationId), guildId: \(guildId), commandId: \(commandId))"
        case let .listApplicationCommands(applicationId):
            return "listApplicationCommands(applicationId: \(applicationId))"
        case let .listGuildApplicationCommandPermissions(applicationId, guildId):
            return "listGuildApplicationCommandPermissions(applicationId: \(applicationId), guildId: \(guildId))"
        case let .listGuildApplicationCommands(applicationId, guildId):
            return "listGuildApplicationCommands(applicationId: \(applicationId), guildId: \(guildId))"
        case let .bulkSetApplicationCommands(applicationId):
            return "bulkSetApplicationCommands(applicationId: \(applicationId))"
        case let .bulkSetGuildApplicationCommands(applicationId, guildId):
            return "bulkSetGuildApplicationCommands(applicationId: \(applicationId), guildId: \(guildId))"
        case let .setGuildApplicationCommandPermissions(applicationId, guildId, commandId):
            return "setGuildApplicationCommandPermissions(applicationId: \(applicationId), guildId: \(guildId), commandId: \(commandId))"
        case let .createApplicationCommand(applicationId):
            return "createApplicationCommand(applicationId: \(applicationId))"
        case let .createGuildApplicationCommand(applicationId, guildId):
            return "createGuildApplicationCommand(applicationId: \(applicationId), guildId: \(guildId))"
        case let .updateApplicationCommand(applicationId, commandId):
            return "updateApplicationCommand(applicationId: \(applicationId), commandId: \(commandId))"
        case let .updateGuildApplicationCommand(applicationId, guildId, commandId):
            return "updateGuildApplicationCommand(applicationId: \(applicationId), guildId: \(guildId), commandId: \(commandId))"
        case let .deleteApplicationCommand(applicationId, commandId):
            return "deleteApplicationCommand(applicationId: \(applicationId), commandId: \(commandId))"
        case let .deleteGuildApplicationCommand(applicationId, guildId, commandId):
            return "deleteGuildApplicationCommand(applicationId: \(applicationId), guildId: \(guildId), commandId: \(commandId))"
        case let .getGuildEmoji(guildId, emojiId):
            return "getGuildEmoji(guildId: \(guildId), emojiId: \(emojiId))"
        case let .listGuildEmojis(guildId):
            return "listGuildEmojis(guildId: \(guildId))"
        case let .createGuildEmoji(guildId):
            return "createGuildEmoji(guildId: \(guildId))"
        case let .updateGuildEmoji(guildId, emojiId):
            return "updateGuildEmoji(guildId: \(guildId), emojiId: \(emojiId))"
        case let .deleteGuildEmoji(guildId, emojiId):
            return "deleteGuildEmoji(guildId: \(guildId), emojiId: \(emojiId))"
        case .getBotGateway:
            return "getBotGateway"
        case .getGateway:
            return "getGateway"
        case let .getGuild(guildId):
            return "getGuild(guildId: \(guildId))"
        case let .getGuildBan(guildId, userId):
            return "getGuildBan(guildId: \(guildId), userId: \(userId))"
        case let .getGuildOnboarding(guildId):
            return "getGuildOnboarding(guildId: \(guildId))"
        case let .getGuildPreview(guildId):
            return "getGuildPreview(guildId: \(guildId))"
        case let .getGuildVanityUrl(guildId):
            return "getGuildVanityUrl(guildId: \(guildId))"
        case let .getGuildWelcomeScreen(guildId):
            return "getGuildWelcomeScreen(guildId: \(guildId))"
        case let .getGuildWidget(guildId):
            return "getGuildWidget(guildId: \(guildId))"
        case let .getGuildWidgetPng(guildId):
            return "getGuildWidgetPng(guildId: \(guildId))"
        case let .getGuildWidgetSettings(guildId):
            return "getGuildWidgetSettings(guildId: \(guildId))"
        case let .listGuildBans(guildId):
            return "listGuildBans(guildId: \(guildId))"
        case let .listGuildIntegrations(guildId):
            return "listGuildIntegrations(guildId: \(guildId))"
        case .listOwnGuilds:
            return "listOwnGuilds"
        case let .previewPruneGuild(guildId):
            return "previewPruneGuild(guildId: \(guildId))"
        case let .banUserFromGuild(guildId, userId):
            return "banUserFromGuild(guildId: \(guildId), userId: \(userId))"
        case .createGuild:
            return "createGuild"
        case let .pruneGuild(guildId):
            return "pruneGuild(guildId: \(guildId))"
        case let .setGuildMfaLevel(guildId):
            return "setGuildMfaLevel(guildId: \(guildId))"
        case let .updateGuild(guildId):
            return "updateGuild(guildId: \(guildId))"
        case let .updateGuildWelcomeScreen(guildId):
            return "updateGuildWelcomeScreen(guildId: \(guildId))"
        case let .updateGuildWidgetSettings(guildId):
            return "updateGuildWidgetSettings(guildId: \(guildId))"
        case let .deleteGuild(guildId):
            return "deleteGuild(guildId: \(guildId))"
        case let .deleteGuildIntegration(guildId, integrationId):
            return "deleteGuildIntegration(guildId: \(guildId), integrationId: \(integrationId))"
        case let .leaveGuild(guildId):
            return "leaveGuild(guildId: \(guildId))"
        case let .unbanUserFromGuild(guildId, userId):
            return "unbanUserFromGuild(guildId: \(guildId), userId: \(userId))"
        case let .getGuildTemplate(code):
            return "getGuildTemplate(code: \(code))"
        case let .listGuildTemplates(guildId):
            return "listGuildTemplates(guildId: \(guildId))"
        case let .syncGuildTemplate(guildId, code):
            return "syncGuildTemplate(guildId: \(guildId), code: \(code))"
        case let .createGuildFromTemplate(code):
            return "createGuildFromTemplate(code: \(code))"
        case let .createGuildTemplate(guildId):
            return "createGuildTemplate(guildId: \(guildId))"
        case let .updateGuildTemplate(guildId, code):
            return "updateGuildTemplate(guildId: \(guildId), code: \(code))"
        case let .deleteGuildTemplate(guildId, code):
            return "deleteGuildTemplate(guildId: \(guildId), code: \(code))"
        case let .getFollowupMessage(applicationId, interactionToken, messageId):
            return "getFollowupMessage(applicationId: \(applicationId), interactionToken: \(interactionToken), messageId: \(messageId))"
        case let .getOriginalInteractionResponse(applicationId, interactionToken):
            return "getOriginalInteractionResponse(applicationId: \(applicationId), interactionToken: \(interactionToken))"
        case let .createFollowupMessage(applicationId, interactionToken):
            return "createFollowupMessage(applicationId: \(applicationId), interactionToken: \(interactionToken))"
        case let .createInteractionResponse(interactionId, interactionToken):
            return "createInteractionResponse(interactionId: \(interactionId), interactionToken: \(interactionToken))"
        case let .updateFollowupMessage(applicationId, interactionToken, messageId):
            return "updateFollowupMessage(applicationId: \(applicationId), interactionToken: \(interactionToken), messageId: \(messageId))"
        case let .updateOriginalInteractionResponse(applicationId, interactionToken):
            return "updateOriginalInteractionResponse(applicationId: \(applicationId), interactionToken: \(interactionToken))"
        case let .deleteFollowupMessage(applicationId, interactionToken, messageId):
            return "deleteFollowupMessage(applicationId: \(applicationId), interactionToken: \(interactionToken), messageId: \(messageId))"
        case let .deleteOriginalInteractionResponse(applicationId, interactionToken):
            return "deleteOriginalInteractionResponse(applicationId: \(applicationId), interactionToken: \(interactionToken))"
        case let .inviteResolve(code):
            return "inviteResolve(code: \(code))"
        case let .listChannelInvites(channelId):
            return "listChannelInvites(channelId: \(channelId))"
        case let .listGuildInvites(guildId):
            return "listGuildInvites(guildId: \(guildId))"
        case let .createChannelInvite(channelId):
            return "createChannelInvite(channelId: \(channelId))"
        case let .inviteRevoke(code):
            return "inviteRevoke(code: \(code))"
        case let .getGuildMember(guildId, userId):
            return "getGuildMember(guildId: \(guildId), userId: \(userId))"
        case let .getOwnGuildMember(guildId):
            return "getOwnGuildMember(guildId: \(guildId))"
        case let .listGuildMembers(guildId):
            return "listGuildMembers(guildId: \(guildId))"
        case let .searchGuildMembers(guildId):
            return "searchGuildMembers(guildId: \(guildId))"
        case let .addGuildMember(guildId, userId):
            return "addGuildMember(guildId: \(guildId), userId: \(userId))"
        case let .updateGuildMember(guildId, userId):
            return "updateGuildMember(guildId: \(guildId), userId: \(userId))"
        case let .updateOwnGuildMember(guildId):
            return "updateOwnGuildMember(guildId: \(guildId))"
        case let .deleteGuildMember(guildId, userId):
            return "deleteGuildMember(guildId: \(guildId), userId: \(userId))"
        case let .getMessage(channelId, messageId):
            return "getMessage(channelId: \(channelId), messageId: \(messageId))"
        case let .listMessageReactionsByEmoji(channelId, messageId, emojiName):
            return "listMessageReactionsByEmoji(channelId: \(channelId), messageId: \(messageId), emojiName: \(emojiName))"
        case let .listMessages(channelId):
            return "listMessages(channelId: \(channelId))"
        case let .addOwnMessageReaction(channelId, messageId, emojiName):
            return "addOwnMessageReaction(channelId: \(channelId), messageId: \(messageId), emojiName: \(emojiName))"
        case let .bulkDeleteMessages(channelId):
            return "bulkDeleteMessages(channelId: \(channelId))"
        case let .createMessage(channelId):
            return "createMessage(channelId: \(channelId))"
        case let .crosspostMessage(channelId, messageId):
            return "crosspostMessage(channelId: \(channelId), messageId: \(messageId))"
        case let .updateMessage(channelId, messageId):
            return "updateMessage(channelId: \(channelId), messageId: \(messageId))"
        case let .deleteAllMessageReactions(channelId, messageId):
            return "deleteAllMessageReactions(channelId: \(channelId), messageId: \(messageId))"
        case let .deleteAllMessageReactionsByEmoji(channelId, messageId, emojiName):
            return "deleteAllMessageReactionsByEmoji(channelId: \(channelId), messageId: \(messageId), emojiName: \(emojiName))"
        case let .deleteMessage(channelId, messageId):
            return "deleteMessage(channelId: \(channelId), messageId: \(messageId))"
        case let .deleteOwnMessageReaction(channelId, messageId, emojiName):
            return "deleteOwnMessageReaction(channelId: \(channelId), messageId: \(messageId), emojiName: \(emojiName))"
        case let .deleteUserMessageReaction(channelId, messageId, emojiName, userId):
            return "deleteUserMessageReaction(channelId: \(channelId), messageId: \(messageId), emojiName: \(emojiName), userId: \(userId))"
        case .getOwnOauth2Application:
            return "getOwnOauth2Application"
        case let .listGuildRoles(guildId):
            return "listGuildRoles(guildId: \(guildId))"
        case let .addGuildMemberRole(guildId, userId, roleId):
            return "addGuildMemberRole(guildId: \(guildId), userId: \(userId), roleId: \(roleId))"
        case let .createGuildRole(guildId):
            return "createGuildRole(guildId: \(guildId))"
        case let .bulkUpdateGuildRoles(guildId):
            return "bulkUpdateGuildRoles(guildId: \(guildId))"
        case let .updateGuildRole(guildId, roleId):
            return "updateGuildRole(guildId: \(guildId), roleId: \(roleId))"
        case let .deleteGuildMemberRole(guildId, userId, roleId):
            return "deleteGuildMemberRole(guildId: \(guildId), userId: \(userId), roleId: \(roleId))"
        case let .deleteGuildRole(guildId, roleId):
            return "deleteGuildRole(guildId: \(guildId), roleId: \(roleId))"
        case let .getApplicationRoleConnectionsMetadata(applicationId):
            return "getApplicationRoleConnectionsMetadata(applicationId: \(applicationId))"
        case let .getApplicationUserRoleConnection(applicationId):
            return "getApplicationUserRoleConnection(applicationId: \(applicationId))"
        case let .updateApplicationRoleConnectionsMetadata(applicationId):
            return "updateApplicationRoleConnectionsMetadata(applicationId: \(applicationId))"
        case let .updateApplicationUserRoleConnection(applicationId):
            return "updateApplicationUserRoleConnection(applicationId: \(applicationId))"
        case let .getGuildScheduledEvent(guildId, guildScheduledEventId):
            return "getGuildScheduledEvent(guildId: \(guildId), guildScheduledEventId: \(guildScheduledEventId))"
        case let .listGuildScheduledEventUsers(guildId, guildScheduledEventId):
            return "listGuildScheduledEventUsers(guildId: \(guildId), guildScheduledEventId: \(guildScheduledEventId))"
        case let .listGuildScheduledEvents(guildId):
            return "listGuildScheduledEvents(guildId: \(guildId))"
        case let .createGuildScheduledEvent(guildId):
            return "createGuildScheduledEvent(guildId: \(guildId))"
        case let .updateGuildScheduledEvent(guildId, guildScheduledEventId):
            return "updateGuildScheduledEvent(guildId: \(guildId), guildScheduledEventId: \(guildScheduledEventId))"
        case let .deleteGuildScheduledEvent(guildId, guildScheduledEventId):
            return "deleteGuildScheduledEvent(guildId: \(guildId), guildScheduledEventId: \(guildScheduledEventId))"
        case let .getStageInstance(channelId):
            return "getStageInstance(channelId: \(channelId))"
        case .createStageInstance:
            return "createStageInstance"
        case let .updateStageInstance(channelId):
            return "updateStageInstance(channelId: \(channelId))"
        case let .deleteStageInstance(channelId):
            return "deleteStageInstance(channelId: \(channelId))"
        case let .getGuildSticker(guildId, stickerId):
            return "getGuildSticker(guildId: \(guildId), stickerId: \(stickerId))"
        case let .getSticker(stickerId):
            return "getSticker(stickerId: \(stickerId))"
        case let .listGuildStickers(guildId):
            return "listGuildStickers(guildId: \(guildId))"
        case .listStickerPacks:
            return "listStickerPacks"
        case let .createGuildSticker(guildId):
            return "createGuildSticker(guildId: \(guildId))"
        case let .updateGuildSticker(guildId, stickerId):
            return "updateGuildSticker(guildId: \(guildId), stickerId: \(stickerId))"
        case let .deleteGuildSticker(guildId, stickerId):
            return "deleteGuildSticker(guildId: \(guildId), stickerId: \(stickerId))"
        case let .getActiveGuildThreads(guildId):
            return "getActiveGuildThreads(guildId: \(guildId))"
        case let .getThreadMember(channelId, userId):
            return "getThreadMember(channelId: \(channelId), userId: \(userId))"
        case let .listOwnPrivateArchivedThreads(channelId):
            return "listOwnPrivateArchivedThreads(channelId: \(channelId))"
        case let .listPrivateArchivedThreads(channelId):
            return "listPrivateArchivedThreads(channelId: \(channelId))"
        case let .listPublicArchivedThreads(channelId):
            return "listPublicArchivedThreads(channelId: \(channelId))"
        case let .listThreadMembers(channelId):
            return "listThreadMembers(channelId: \(channelId))"
        case let .addThreadMember(channelId, userId):
            return "addThreadMember(channelId: \(channelId), userId: \(userId))"
        case let .joinThread(channelId):
            return "joinThread(channelId: \(channelId))"
        case let .createThread(channelId):
            return "createThread(channelId: \(channelId))"
        case let .createThreadFromMessage(channelId, messageId):
            return "createThreadFromMessage(channelId: \(channelId), messageId: \(messageId))"
        case let .createThreadInForumChannel(channelId):
            return "createThreadInForumChannel(channelId: \(channelId))"
        case let .deleteThreadMember(channelId, userId):
            return "deleteThreadMember(channelId: \(channelId), userId: \(userId))"
        case let .leaveThread(channelId):
            return "leaveThread(channelId: \(channelId))"
        case .getOwnUser:
            return "getOwnUser"
        case let .getUser(userId):
            return "getUser(userId: \(userId))"
        case .listOwnConnections:
            return "listOwnConnections"
        case .updateOwnUser:
            return "updateOwnUser"
        case let .listGuildVoiceRegions(guildId):
            return "listGuildVoiceRegions(guildId: \(guildId))"
        case .listVoiceRegions:
            return "listVoiceRegions"
        case let .updateSelfVoiceState(guildId):
            return "updateSelfVoiceState(guildId: \(guildId))"
        case let .updateVoiceState(guildId, userId):
            return "updateVoiceState(guildId: \(guildId), userId: \(userId))"
        case let .getGuildWebhooks(guildId):
            return "getGuildWebhooks(guildId: \(guildId))"
        case let .getWebhook(webhookId):
            return "getWebhook(webhookId: \(webhookId))"
        case let .getWebhookByToken(webhookId, webhookToken):
            return "getWebhookByToken(webhookId: \(webhookId), webhookToken: \(webhookToken))"
        case let .getWebhookMessage(webhookId, webhookToken, messageId):
            return "getWebhookMessage(webhookId: \(webhookId), webhookToken: \(webhookToken), messageId: \(messageId))"
        case let .getWebhooksMessagesOriginal(webhookId, webhookToken):
            return "getWebhooksMessagesOriginal(webhookId: \(webhookId), webhookToken: \(webhookToken))"
        case let .listChannelWebhooks(channelId):
            return "listChannelWebhooks(channelId: \(channelId))"
        case let .createWebhook(channelId):
            return "createWebhook(channelId: \(channelId))"
        case let .executeWebhook(webhookId, webhookToken):
            return "executeWebhook(webhookId: \(webhookId), webhookToken: \(webhookToken))"
        case let .patchWebhooksMessagesOriginal(webhookId, webhookToken):
            return "patchWebhooksMessagesOriginal(webhookId: \(webhookId), webhookToken: \(webhookToken))"
        case let .updateWebhook(webhookId):
            return "updateWebhook(webhookId: \(webhookId))"
        case let .updateWebhookByToken(webhookId, webhookToken):
            return "updateWebhookByToken(webhookId: \(webhookId), webhookToken: \(webhookToken))"
        case let .updateWebhookMessage(webhookId, webhookToken, messageId):
            return "updateWebhookMessage(webhookId: \(webhookId), webhookToken: \(webhookToken), messageId: \(messageId))"
        case let .deleteWebhook(webhookId):
            return "deleteWebhook(webhookId: \(webhookId))"
        case let .deleteWebhookByToken(webhookId, webhookToken):
            return "deleteWebhookByToken(webhookId: \(webhookId), webhookToken: \(webhookToken))"
        case let .deleteWebhookMessage(webhookId, webhookToken, messageId):
            return "deleteWebhookMessage(webhookId: \(webhookId), webhookToken: \(webhookToken), messageId: \(messageId))"
        case let .deleteWebhooksMessagesOriginal(webhookId, webhookToken):
            return "deleteWebhooksMessagesOriginal(webhookId: \(webhookId), webhookToken: \(webhookToken))"
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
    case listGuildChannels
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
        case .listGuildChannels: return "listGuildChannels"
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
        case .listGuildChannels: self = .listGuildChannels
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