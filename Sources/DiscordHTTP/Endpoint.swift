import NIOHTTP1

/// The endpoints that can be cached. Basically the GET endpoints.
public enum CacheableEndpointIdentity: Int, Sendable, Hashable, CustomStringConvertible {
    case getGateway
    case getGatewayBot
    case getInteractionResponse
    case getFollowupInteractionResponse
    case getGlobalApplicationCommands
    case getGlobalApplicationCommand
    case getGuildApplicationCommands
    case getGuildApplicationCommand
    case getGuildApplicationCommandPermissions
    case getApplicationCommandPermissions
    case getGuild
    case getGuildRoles
    case searchGuildMembers
    case getGuildMember
    case getChannel
    case getChannelMessages
    case getChannelMessage
    case getGuildAuditLogs
    case getReactions
    case getThreadMember
    case listThreadMembers
    case listPublicArchivedThreads
    case listPrivateArchivedThreads
    case listJoinedPrivateArchivedThreads
    case getChannelWebhooks
    case getGuildWebhooks
    case getWebhook1
    case getWebhook2
    case getWebhookMessage
    case CDNCustomEmoji
    case CDNGuildIcon
    case CDNGuildSplash
    case CDNGuildDiscoverySplash
    case CDNGuildBanner
    case CDNUserBanner
    case CDNDefaultUserAvatar
    case CDNUserAvatar
    case CDNGuildMemberAvatar
    case CDNApplicationIcon
    case CDNApplicationCover
    case CDNApplicationAsset
    case CDNAchievementIcon
    case CDNStorePageAsset
    case CDNStickerPackBanner
    case CDNTeamIcon
    case CDNSticker
    case CDNRoleIcon
    case CDNGuildScheduledEventCover
    case CDNGuildMemberBanner
    
    public var description: String {
        switch self {
        case .getGateway: return "getGateway"
        case .getGatewayBot: return "getGatewayBot"
        case .getInteractionResponse: return "getInteractionResponse"
        case .getFollowupInteractionResponse: return "getFollowupInteractionResponse"
        case .getGlobalApplicationCommands: return "getGlobalApplicationCommands"
        case .getGlobalApplicationCommand: return "getGlobalApplicationCommand"
        case .getGuildApplicationCommands: return "getGuildApplicationCommands"
        case .getGuildApplicationCommand: return "getGuildApplicationCommand"
        case .getGuildApplicationCommandPermissions: return "getGuildApplicationCommandPermissions"
        case .getApplicationCommandPermissions: return "getApplicationCommandPermissions"
        case .getGuild: return "getGuild"
        case .getGuildRoles: return "getGuildRoles"
        case .searchGuildMembers: return "searchGuildMembers"
        case .getGuildMember: return "getGuildMember"
        case .getChannel: return "getChannel"
        case .getChannelMessages: return "getChannelMessages"
        case .getChannelMessage: return "getChannelMessage"
        case .getGuildAuditLogs: return "getGuildAuditLogs"
        case .getReactions: return "getReactions"
        case .getThreadMember: return "getThreadMember"
        case .listThreadMembers: return "listThreadMembers"
        case .listPublicArchivedThreads: return "listPublicArchivedThreads"
        case .listPrivateArchivedThreads: return "listPrivateArchivedThreads"
        case .listJoinedPrivateArchivedThreads: return "listJoinedPrivateArchivedThreads"
        case .getChannelWebhooks: return "getChannelWebhooks"
        case .getGuildWebhooks: return "getGuildWebhooks"
        case .getWebhook1: return "getWebhook1"
        case .getWebhook2: return "getWebhook2"
        case .getWebhookMessage: return "getWebhookMessage"
        case .CDNCustomEmoji: return "CDNCustomEmoji"
        case .CDNGuildIcon: return "CDNGuildIcon"
        case .CDNGuildSplash: return "CDNGuildSplash"
        case .CDNGuildDiscoverySplash: return "CDNGuildDiscoverySplash"
        case .CDNGuildBanner: return "CDNGuildBanner"
        case .CDNUserBanner: return "CDNUserBanner"
        case .CDNDefaultUserAvatar: return "CDNDefaultUserAvatar"
        case .CDNUserAvatar: return "CDNUserAvatar"
        case .CDNGuildMemberAvatar: return "CDNGuildMemberAvatar"
        case .CDNApplicationIcon: return "CDNApplicationIcon"
        case .CDNApplicationCover: return "CDNApplicationCover"
        case .CDNApplicationAsset: return "CDNApplicationAsset"
        case .CDNAchievementIcon: return "CDNAchievementIcon"
        case .CDNStorePageAsset: return "CDNStorePageAsset"
        case .CDNStickerPackBanner: return "CDNStickerPackBanner"
        case .CDNTeamIcon: return "CDNTeamIcon"
        case .CDNSticker: return "CDNSticker"
        case .CDNRoleIcon: return "CDNRoleIcon"
        case .CDNGuildScheduledEventCover: return "CDNGuildScheduledEventCover"
        case .CDNGuildMemberBanner: return "CDNGuildMemberBanner"
        }
    }
    
    init? (endpoint: Endpoint) {
        switch endpoint {
        case .getGateway: self = .getGateway
        case .getGatewayBot: self = .getGatewayBot
        case .createInteractionResponse: return nil
        case .getInteractionResponse: self = .getInteractionResponse
        case .editInteractionResponse: return nil
        case .deleteInteractionResponse: return nil
        case .postFollowupInteractionResponse: return nil
        case .getFollowupInteractionResponse: self = .getFollowupInteractionResponse
        case .editFollowupInteractionResponse: return nil
        case .deleteFollowupInteractionResponse: return nil
        case .createMessage: return nil
        case .editMessage: return nil
        case .deleteMessage: return nil
        case .getGlobalApplicationCommands: self = .getGlobalApplicationCommands
        case .createGlobalApplicationCommand: return nil
        case .getGlobalApplicationCommand: self = .getGlobalApplicationCommand
        case .editGlobalApplicationCommand: return nil
        case .deleteGlobalApplicationCommand: return nil
        case .bulkOverwriteGlobalApplicationCommands: return nil
        case .getGuildApplicationCommands: self = .getGuildApplicationCommands
        case .createGuildApplicationCommand: return nil
        case .getGuildApplicationCommand: self = .getGuildApplicationCommand
        case .editGuildApplicationCommand: return nil
        case .deleteGuildApplicationCommand: return nil
        case .bulkOverwriteGuildApplicationCommands: return nil
        case .getGuildApplicationCommandPermissions: self = .getGuildApplicationCommandPermissions
        case .getApplicationCommandPermissions: self = .getApplicationCommandPermissions
        case .editApplicationCommandPermissions: return nil
        case .getGuild: self = .getGuild
        case .getGuildRoles: self = .getGuildRoles
        case .searchGuildMembers: self = .searchGuildMembers
        case .getGuildMember: self = .getGuildMember
        case .leaveGuild: return nil
        case .getChannel: self = .getChannel
        case .getChannelMessages: self = .getChannelMessages
        case .getChannelMessage: self = .getChannelMessage
        case .createGuildRole: return nil
        case .deleteGuildRole: return nil
        case .addGuildMemberRole: return nil
        case .removeGuildMemberRole: return nil
        case .getGuildAuditLogs: self = .getGuildAuditLogs
        case .createReaction: return nil
        case .deleteOwnReaction: return nil
        case .deleteUserReaction: return nil
        case .getReactions: self = .getReactions
        case .deleteAllReactions: return nil
        case .deleteAllReactionsForEmoji: return nil
        case .createDM: return nil
        case .startThreadFromMessage: return nil
        case .startThreadWithoutMessage: return nil
        case .startThreadInForumChannel: return nil
        case .joinThread: return nil
        case .addThreadMember: return nil
        case .leaveThread: return nil
        case .removeThreadMember: return nil
        case .getThreadMember: self = .getThreadMember
        case .listThreadMembers: self = .listThreadMembers
        case .listPublicArchivedThreads: self = .listPublicArchivedThreads
        case .listPrivateArchivedThreads: self = .listPrivateArchivedThreads
        case .listJoinedPrivateArchivedThreads: self = .listJoinedPrivateArchivedThreads
        case .createWebhook: return nil
        case .getChannelWebhooks: self = .getChannelWebhooks
        case .getGuildWebhooks: self = .getGuildWebhooks
        case .getWebhook1: self = .getWebhook1
        case .getWebhook2: self = .getWebhook2
        case .modifyWebhook1: return nil
        case .modifyWebhook2: return nil
        case .deleteWebhook1: return nil
        case .deleteWebhook2: return nil
        case .executeWebhook: return nil
        case .getWebhookMessage: self = .getWebhookMessage
        case .editWebhookMessage: return nil
        case .deleteWebhookMessage: return nil
        case .CDNCustomEmoji: self = .CDNCustomEmoji
        case .CDNGuildIcon: self = .CDNGuildIcon
        case .CDNGuildSplash: self = .CDNGuildSplash
        case .CDNGuildDiscoverySplash: self = .CDNGuildDiscoverySplash
        case .CDNGuildBanner: self = .CDNGuildBanner
        case .CDNUserBanner: self = .CDNUserBanner
        case .CDNDefaultUserAvatar: self = .CDNDefaultUserAvatar
        case .CDNUserAvatar: self = .CDNUserAvatar
        case .CDNGuildMemberAvatar: self = .CDNGuildMemberAvatar
        case .CDNApplicationIcon: self = .CDNApplicationIcon
        case .CDNApplicationCover: self = .CDNApplicationCover
        case .CDNApplicationAsset: self = .CDNApplicationAsset
        case .CDNAchievementIcon: self = .CDNAchievementIcon
        case .CDNStorePageAsset: self = .CDNStorePageAsset
        case .CDNStickerPackBanner: self = .CDNStickerPackBanner
        case .CDNTeamIcon: self = .CDNTeamIcon
        case .CDNSticker: self = .CDNSticker
        case .CDNRoleIcon: self = .CDNRoleIcon
        case .CDNGuildScheduledEventCover: self = .CDNGuildScheduledEventCover
        case .CDNGuildMemberBanner: self = .CDNGuildMemberBanner
        }
    }
}

/// API Endpoint.
public enum Endpoint: Sendable {
    /// Get Gateway
    case getGateway
    case getGatewayBot
    
    /// Respond to Application Commands
    case createInteractionResponse(id: String, token: String)
    case getInteractionResponse(appId: String, token: String)
    case editInteractionResponse(appId: String, token: String)
    case deleteInteractionResponse(appId: String, token: String)
    case postFollowupInteractionResponse(appId: String, token: String)
    case getFollowupInteractionResponse(appId: String, token: String, messageId: String)
    case editFollowupInteractionResponse(appId: String, token: String, messageId: String)
    case deleteFollowupInteractionResponse(appId: String, token: String, messageId: String)
    
    /// Send Messages
    case createMessage(channelId: String)
    case editMessage(channelId: String, messageId: String)
    case deleteMessage(channelId: String, messageId: String)
    
    /// Manage _Global_ Application Commands
    case getGlobalApplicationCommands(appId: String)
    case createGlobalApplicationCommand(appId: String)
    case getGlobalApplicationCommand(appId: String, commandId: String)
    case editGlobalApplicationCommand(appId: String, commandId: String)
    case deleteGlobalApplicationCommand(appId: String, commandId: String)
    case bulkOverwriteGlobalApplicationCommands(appId: String)
    
    /// Manage _Guild_ Application Commands
    case getGuildApplicationCommands(appId: String, guildId: String)
    case createGuildApplicationCommand(appId: String, guildId: String)
    case getGuildApplicationCommand(appId: String, guildId: String, commandId: String)
    case editGuildApplicationCommand(appId: String, guildId: String, commandId: String)
    case deleteGuildApplicationCommand(appId: String, guildId: String, commandId: String)
    case bulkOverwriteGuildApplicationCommands(appId: String, guildId: String)
    case getGuildApplicationCommandPermissions(appId: String, guildId: String)
    case getApplicationCommandPermissions(appId: String, guildId: String, commandId: String)
    case editApplicationCommandPermissions(appId: String, guildId: String, commandId: String)
    
    /// Guilds
    case getGuild(id: String)
    case getGuildRoles(id: String)
    case searchGuildMembers(id: String)
    case getGuildMember(id: String, userId: String)
    case leaveGuild(id: String)
    
    /// Channels
    case getChannel(id: String)
    case getChannelMessages(channelId: String)
    case getChannelMessage(channelId: String, messageId: String)
    
    /// Roles
    case createGuildRole(guildId: String)
    case deleteGuildRole(guildId: String, roleId: String)
    case addGuildMemberRole(guildId: String, userId: String, roleId: String)
    case removeGuildMemberRole(guildId: String, userId: String, roleId: String)
    case getGuildAuditLogs(guildId: String)
    
    /// Reactions
    case createReaction(channelId: String, messageId: String, emoji: String)
    case deleteOwnReaction(channelId: String, messageId: String, emoji: String)
    case deleteUserReaction(channelId: String, messageId: String, emoji: String, userId: String)
    case getReactions(channelId: String, messageId: String, emoji: String)
    case deleteAllReactions(channelId: String, messageId: String)
    case deleteAllReactionsForEmoji(channelId: String, messageId: String, emoji: String)
    
    /// DMs
    case createDM
    
    /// Threads
    case startThreadFromMessage(channelId: String, messageId: String)
    case startThreadWithoutMessage(channelId: String)
    case startThreadInForumChannel(channelId: String)
    case joinThread(id: String)
    case addThreadMember(threadId: String, userId: String)
    case leaveThread(id: String)
    case removeThreadMember(threadId: String, userId: String)
    case getThreadMember(threadId: String, userId: String)
    case listThreadMembers(threadId: String)
    case listPublicArchivedThreads(channelId: String)
    case listPrivateArchivedThreads(channelId: String)
    case listJoinedPrivateArchivedThreads(channelId: String)
    
    /// Webhooks
    case createWebhook(channelId: String)
    case getChannelWebhooks(channelId: String)
    case getGuildWebhooks(guildId: String)
    case getWebhook1(id: String)
    case getWebhook2(id: String, token: String)
    case modifyWebhook1(id: String)
    case modifyWebhook2(id: String, token: String)
    case deleteWebhook1(id: String)
    case deleteWebhook2(id: String, token: String)
    case executeWebhook(id: String, token: String)
    case getWebhookMessage(id: String, token: String, messageId: String)
    case editWebhookMessage(id: String, token: String, messageId: String)
    case deleteWebhookMessage(id: String, token: String, messageId: String)
    
    /// CDN
    case CDNCustomEmoji(emojiId: String)
    case CDNGuildIcon(guildId: String, icon: String)
    case CDNGuildSplash(guildId: String, splash: String)
    case CDNGuildDiscoverySplash(guildId: String, splash: String)
    case CDNGuildBanner(guildId: String, banner: String)
    case CDNUserBanner(userId: String, banner: String)
    case CDNDefaultUserAvatar(discriminator: String)
    case CDNUserAvatar(userId: String, avatar: String)
    case CDNGuildMemberAvatar(guildId: String, userId: String, avatar: String)
    case CDNApplicationIcon(appId: String, icon: String)
    case CDNApplicationCover(appId: String, cover: String)
    case CDNApplicationAsset(appId: String, assetId: String)
    case CDNAchievementIcon(appId: String, achievementId: String, icon: String)
    case CDNStorePageAsset(appId: String, assetId: String)
    case CDNStickerPackBanner(assetId: String)
    case CDNTeamIcon(teamId: String, icon: String)
    case CDNSticker(stickerId: String)
    case CDNRoleIcon(roleId: String, icon: String)
    case CDNGuildScheduledEventCover(eventId: String, cover: String)
    case CDNGuildMemberBanner(guildId: String, userId: String, banner: String)
    
    var urlSuffix: String {
        let suffix: String
        switch self {
        case .getGateway:
            suffix = "gateway"
        case .getGatewayBot:
            suffix = "gateway/bot"
        case let .createInteractionResponse(id, token):
            suffix = "interactions/\(id)/\(token)/callback"
        case let .getInteractionResponse(appId, token):
            suffix = "webhooks/\(appId)/\(token)/messages/@original"
        case let .editInteractionResponse(appId, token):
            suffix = "webhooks/\(appId)/\(token)/messages/@original"
        case let .deleteInteractionResponse(appId, token):
            suffix = "webhooks/\(appId)/\(token)/messages/@original"
        case let .postFollowupInteractionResponse(appId, token):
            suffix = "webhooks/\(appId)/\(token)"
        case let .getFollowupInteractionResponse(appId, token, messageId):
            suffix = "webhooks/\(appId)/\(token)/messages/\(messageId)"
        case let .editFollowupInteractionResponse(appId, token, messageId):
            suffix = "webhooks/\(appId)/\(token)/messages/\(messageId)"
        case let .deleteFollowupInteractionResponse(appId, token, messageId):
            suffix = "webhooks/\(appId)/\(token)/messages/\(messageId)"
        case let .createMessage(channelId):
            suffix = "channels/\(channelId)/messages"
        case let .editMessage(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case let .deleteMessage(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)"
        case .getGlobalApplicationCommands(let appId):
            suffix = "applications/\(appId)/commands"
        case .createGlobalApplicationCommand(let appId):
            suffix = "applications/\(appId)/commands"
        case .getGlobalApplicationCommand(let appId, let commandId):
            suffix = "applications/\(appId)/commands/\(commandId)"
        case .editGlobalApplicationCommand(let appId, let commandId):
            suffix = "applications/\(appId)/commands/\(commandId)"
        case .deleteGlobalApplicationCommand(let appId, let commandId):
            suffix = "applications/\(appId)/commands/\(commandId)"
        case .bulkOverwriteGlobalApplicationCommands(let appId):
            suffix = "applications/\(appId)/commands"
        case .getGuildApplicationCommands(let appId, let guildId):
            suffix = "applications/\(appId)/guilds/\(guildId)/commands"
        case .createGuildApplicationCommand(let appId, let guildId):
            suffix = "applications/\(appId)/guilds/\(guildId)/commands"
        case .getGuildApplicationCommand(let appId, let guildId, let commandId):
            suffix = "applications/\(appId)/guilds/\(guildId)/commands/\(commandId)"
        case .editGuildApplicationCommand(let appId, let guildId, let commandId):
            suffix = "applications/\(appId)/guilds/\(guildId)/commands/\(commandId)"
        case .deleteGuildApplicationCommand(let appId, let guildId, let commandId):
            suffix = "applications/\(appId)/guilds/\(guildId)/commands/\(commandId)"
        case .bulkOverwriteGuildApplicationCommands(let appId, let guildId):
            suffix = "applications/\(appId)/guilds/\(guildId)/commands"
        case .getGuildApplicationCommandPermissions(let appId, let guildId):
            suffix = "applications/\(appId)/guilds/\(guildId)/commands/permissions"
        case .getApplicationCommandPermissions(let appId, let guildId, let commandId):
            suffix = "applications/\(appId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case .editApplicationCommandPermissions(let appId, let guildId, let commandId):
            suffix = "applications/\(appId)/guilds/\(guildId)/commands/\(commandId)/permissions"
        case let .getGuild(id):
            suffix = "guilds/\(id)"
        case let .getGuildRoles(id):
            suffix = "guilds/\(id)/roles"
        case let .searchGuildMembers(id):
            suffix = "guilds/\(id)/members/search"
        case let .getGuildMember(id, userId):
            suffix = "guilds/\(id)/members/\(userId)"
        case let .leaveGuild(id):
            suffix = "users/@me/guilds/\(id)"
        case let .getChannel(id):
            suffix = "channels/\(id)"
        case let .getChannelMessages(id):
            suffix = "channels/\(id)/messages"
        case let .getChannelMessage(id, messageId):
            suffix = "channels/\(id)/messages/\(messageId)"
        case let .createGuildRole(guildId):
            suffix = "guilds/\(guildId)/roles"
        case let .deleteGuildRole(guildId, roleId):
            suffix = "guilds/\(guildId)/roles/\(roleId)"
        case let .addGuildMemberRole(guildId, userId, roleId):
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .removeGuildMemberRole(guildId, userId, roleId):
            suffix = "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .getGuildAuditLogs(guildId):
            suffix = "guilds/\(guildId)/audit-logs"
        case let .createReaction(channelId, messageId, emoji):
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/@me"
        case let .deleteOwnReaction(channelId, messageId, emoji):
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/@me"
        case let .deleteUserReaction(channelId, messageId, emoji, userId):
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/\(userId)"
        case let .getReactions(channelId, messageId, emoji):
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)"
        case let .deleteAllReactions(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions"
        case let .deleteAllReactionsForEmoji(channelId, messageId, emoji):
            suffix = "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)"
        case .createDM:
            suffix = "users/@me/channels"
        case let .startThreadFromMessage(channelId, messageId):
            suffix = "channels/\(channelId)/messages/\(messageId)/threads"
        case let .startThreadWithoutMessage(channelId),
            let .startThreadInForumChannel(channelId):
            suffix = "channels/\(channelId)/threads"
        case let .joinThread(threadId):
            suffix = "channels/\(threadId)/thread-members/@me"
        case let .addThreadMember(threadId, userId):
            suffix = "channels/\(threadId)/thread-members/\(userId)"
        case let .leaveThread(threadId):
            suffix = "channels/\(threadId)/thread-members/@me"
        case let .removeThreadMember(threadId, userId):
            suffix = "channels/\(threadId)/thread-members/\(userId)"
        case let .getThreadMember(threadId, userId):
            suffix = "channels/\(threadId)/thread-members/\(userId)"
        case let .listThreadMembers(threadId):
            suffix = "channels/\(threadId)/thread-members"
        case let .listPublicArchivedThreads(channelId):
            suffix = "channels/\(channelId)/threads/archived/public"
        case let .listPrivateArchivedThreads(channelId):
            suffix = "channels/\(channelId)/threads/archived/private"
        case let .listJoinedPrivateArchivedThreads(channelId):
            suffix = "channels/\(channelId)/users/@me/threads/archived/private"
        case let .createWebhook(channelId):
            suffix = "channels/\(channelId)/webhooks"
        case let .getChannelWebhooks(channelId):
            suffix = "channels/\(channelId)/webhooks"
        case let .getGuildWebhooks(guildId):
            suffix = "guilds/\(guildId)/webhooks"
        case let .getWebhook1(id),
            let .modifyWebhook1(id),
            let .deleteWebhook1(id):
            suffix = "webhooks/\(id)"
        case let .getWebhook2(id, token),
            let .modifyWebhook2(id, token),
            let .deleteWebhook2(id, token),
            let .executeWebhook(id, token):
            suffix = "webhooks/\(id)/\(token)"
        case let .getWebhookMessage(id, token, messageId):
            suffix = "webhooks/\(id)/\(token)/messages/\(messageId)"
        case let .editWebhookMessage(id, token, messageId):
            suffix = "webhooks/\(id)/\(token)/messages/\(messageId)"
        case let .deleteWebhookMessage(id, token, messageId):
            suffix = "webhooks/\(id)/\(token)/messages/\(messageId)"
        case let .CDNCustomEmoji(emojiId):
            suffix = "emojis/\(emojiId)"
        case let .CDNGuildIcon(guildId, icon):
            suffix = "icons/\(guildId)/\(icon)"
        case let .CDNGuildSplash(guildId, splash):
            suffix = "splashes/\(guildId)/\(splash)"
        case let .CDNGuildDiscoverySplash(guildId, splash):
            suffix = "discovery-splashes/\(guildId)/\(splash)"
        case let .CDNGuildBanner(guildId, banner):
            suffix = "banners/\(guildId)/\(banner)"
        case let .CDNUserBanner(userId, banner):
            suffix = "banners/\(userId)/\(banner)"
        case let .CDNDefaultUserAvatar(discriminator):
            suffix = "embed/avatars/\(discriminator).png" /// Needs `.png`
        case let .CDNUserAvatar(userId, avatar):
            suffix = "avatars/\(userId)/\(avatar)"
        case let .CDNGuildMemberAvatar(guildId, userId, avatar):
            suffix = "guilds/\(guildId)/users/\(userId)/avatars/\(avatar)"
        case let .CDNApplicationIcon(appId, icon):
            suffix = "app-icons/\(appId)/\(icon)"
        case let .CDNApplicationCover(appId, cover):
            suffix = "app-icons/\(appId)/\(cover)"
        case let .CDNApplicationAsset(appId, assetId):
            suffix = "app-assets/\(appId)/\(assetId)"
        case let .CDNAchievementIcon(appId, achievementId, icon):
            suffix = "app-assets/\(appId)/achievements/\(achievementId)/icons/\(icon)"
        case let .CDNStorePageAsset(appId, assetId):
            suffix = "app-assets/\(appId)/store/\(assetId)"
        case let .CDNStickerPackBanner(assetId):
            suffix = "app-assets/710982414301790216/store/\(assetId)"
        case let .CDNTeamIcon(teamId, icon):
            suffix = "team-icons/\(teamId)/\(icon)"
        case let .CDNSticker(stickerId):
            suffix = "stickers/\(stickerId).png" /// Needs `.png`
        case let .CDNRoleIcon(roleId, icon):
            suffix = "role-icons/\(roleId)/\(icon)"
        case let .CDNGuildScheduledEventCover(eventId, cover):
            suffix = "guild-events/\(eventId)/\(cover)"
        case let .CDNGuildMemberBanner(guildId, userId, banner):
            suffix = "guilds/\(guildId)/users/\(userId)/banners/\(banner)"
        }
        return suffix.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? suffix
    }
    
    /// Doesn't expose secret url path parameters.
    private var urlSuffixDescription: String {
        switch self {
        case .getGateway, .getGatewayBot, .createInteractionResponse, .getInteractionResponse, .editInteractionResponse, .deleteInteractionResponse, .postFollowupInteractionResponse, .getFollowupInteractionResponse, .editFollowupInteractionResponse, .deleteFollowupInteractionResponse, .createMessage, .editMessage, .deleteMessage, .getGlobalApplicationCommands, .createGlobalApplicationCommand, .getGlobalApplicationCommand, .editGlobalApplicationCommand, .deleteGlobalApplicationCommand, .bulkOverwriteGlobalApplicationCommands, .getGuildApplicationCommands, .createGuildApplicationCommand, .getGuildApplicationCommand, .editGuildApplicationCommand, .deleteGuildApplicationCommand, .bulkOverwriteGuildApplicationCommands, .getGuildApplicationCommandPermissions, .getApplicationCommandPermissions, .editApplicationCommandPermissions, .getGuild, .getGuildRoles, .searchGuildMembers, .getGuildMember, .leaveGuild, .getChannel, .getChannelMessages, .getChannelMessage, .createGuildRole, .deleteGuildRole, .addGuildMemberRole, .removeGuildMemberRole, .getGuildAuditLogs, .createReaction, .deleteOwnReaction, .deleteUserReaction, .getReactions, .deleteAllReactions, .deleteAllReactionsForEmoji, .createDM, .startThreadFromMessage, .startThreadWithoutMessage, .startThreadInForumChannel, .joinThread, .addThreadMember, .leaveThread, .removeThreadMember, .getThreadMember, .listThreadMembers, .listPublicArchivedThreads, .listPrivateArchivedThreads, .listJoinedPrivateArchivedThreads, .createWebhook, .getChannelWebhooks, .getGuildWebhooks, .getWebhook1, .modifyWebhook1, .deleteWebhook1, .CDNCustomEmoji, .CDNGuildIcon, .CDNGuildSplash, .CDNGuildDiscoverySplash, .CDNGuildBanner, .CDNUserBanner, .CDNDefaultUserAvatar, .CDNUserAvatar, .CDNGuildMemberAvatar, .CDNApplicationIcon, .CDNApplicationCover, .CDNApplicationAsset, .CDNAchievementIcon, .CDNStorePageAsset, .CDNStickerPackBanner, .CDNTeamIcon, .CDNSticker, .CDNRoleIcon, .CDNGuildScheduledEventCover, .CDNGuildMemberBanner:
            return self.urlSuffix
        case let .getWebhook2(id, token),
            let .modifyWebhook2(id, token),
            let .deleteWebhook2(id, token),
            let .executeWebhook(id, token):
            return "webhooks/\(id)/\(token.hash)"
        case let .getWebhookMessage(id, token, messageId):
            return "webhooks/\(id)/\(token.hash)/messages/\(messageId)"
        case let .editWebhookMessage(id, token, messageId):
            return "webhooks/\(id)/\(token.hash)/messages/\(messageId)"
        case let .deleteWebhookMessage(id, token, messageId):
            return "webhooks/\(id)/\(token.hash)/messages/\(messageId)"
        }
    }
    
    var urlPrefix: String {
        switch self.isCDNEndpoint {
        case true: return "https://cdn.discordapp.com/"
        case false: return "https://discord.com/api/v\(DiscordGlobalConfiguration.apiVersion)/"
        }
    }
    
    var url: String {
        urlPrefix + urlSuffix
    }
    
    /// Doesn't expose secret url path parameters.
    var urlDescription: String {
        urlPrefix + urlSuffixDescription
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getGateway: return .GET
        case .getGatewayBot: return .GET
        case .createInteractionResponse: return .POST
        case .getInteractionResponse: return .GET
        case .editInteractionResponse: return .PATCH
        case .deleteInteractionResponse: return .DELETE
        case .postFollowupInteractionResponse: return .POST
        case .getFollowupInteractionResponse: return .GET
        case .editFollowupInteractionResponse: return .PATCH
        case .deleteFollowupInteractionResponse: return .DELETE
        case .createMessage: return .POST
        case .editMessage: return .PATCH
        case .deleteMessage: return .DELETE
        case .getGlobalApplicationCommands: return .GET
        case .createGlobalApplicationCommand: return .POST
        case .getGlobalApplicationCommand: return .GET
        case .editGlobalApplicationCommand: return .PATCH
        case .deleteGlobalApplicationCommand: return .DELETE
        case .bulkOverwriteGlobalApplicationCommands: return .PUT
        case .getGuildApplicationCommands: return .GET
        case .createGuildApplicationCommand: return .POST
        case .getGuildApplicationCommand: return .GET
        case .editGuildApplicationCommand: return .PATCH
        case .deleteGuildApplicationCommand: return .DELETE
        case .bulkOverwriteGuildApplicationCommands: return .PUT
        case .getGuildApplicationCommandPermissions: return .GET
        case .getApplicationCommandPermissions: return .GET
        case .editApplicationCommandPermissions: return .PUT
        case .getGuild: return .GET
        case .getGuildRoles: return .GET
        case .searchGuildMembers: return .GET
        case .getGuildMember: return .GET
        case .leaveGuild: return .DELETE
        case .getChannel: return .GET
        case .getChannelMessages: return .GET
        case .getChannelMessage: return .GET
        case .createGuildRole: return .POST
        case .deleteGuildRole: return .DELETE
        case .addGuildMemberRole: return .PUT
        case .removeGuildMemberRole: return .DELETE
        case .getGuildAuditLogs: return .GET
        case .createReaction: return .PUT
        case .deleteOwnReaction: return .DELETE
        case .deleteUserReaction: return .DELETE
        case .getReactions: return .GET
        case .deleteAllReactions: return .DELETE
        case .deleteAllReactionsForEmoji: return .DELETE
        case .createDM: return .POST
        case .startThreadFromMessage: return .POST
        case .startThreadWithoutMessage: return .POST
        case .startThreadInForumChannel: return .POST
        case .joinThread: return .PUT
        case .addThreadMember: return .PUT
        case .leaveThread: return .DELETE
        case .removeThreadMember: return .DELETE
        case .getThreadMember: return .GET
        case .listThreadMembers: return .GET
        case .listPublicArchivedThreads: return .GET
        case .listPrivateArchivedThreads: return .GET
        case .listJoinedPrivateArchivedThreads: return .GET
        case .createWebhook: return .POST
        case .getChannelWebhooks: return .GET
        case .getGuildWebhooks: return .GET
        case .getWebhook1: return .GET
        case .getWebhook2: return .GET
        case .modifyWebhook1: return .PATCH
        case .modifyWebhook2: return .PATCH
        case .deleteWebhook1: return .DELETE
        case .deleteWebhook2: return .DELETE
        case .executeWebhook: return .POST
        case .getWebhookMessage: return .GET
        case .editWebhookMessage: return .PATCH
        case .deleteWebhookMessage: return .DELETE
        case .CDNCustomEmoji: return .GET
        case .CDNGuildIcon: return .GET
        case .CDNGuildSplash: return .GET
        case .CDNGuildDiscoverySplash: return .GET
        case .CDNGuildBanner: return .GET
        case .CDNUserBanner: return .GET
        case .CDNDefaultUserAvatar: return .GET
        case .CDNUserAvatar: return .GET
        case .CDNGuildMemberAvatar: return .GET
        case .CDNApplicationIcon: return .GET
        case .CDNApplicationCover: return .GET
        case .CDNApplicationAsset: return .GET
        case .CDNAchievementIcon: return .GET
        case .CDNStorePageAsset: return .GET
        case .CDNStickerPackBanner: return .GET
        case .CDNTeamIcon: return .GET
        case .CDNSticker: return .GET
        case .CDNRoleIcon: return .GET
        case .CDNGuildScheduledEventCover: return .GET
        case .CDNGuildMemberBanner: return .GET
        }
    }
    
    var isCDNEndpoint: Bool {
        switch self {
        case .getGateway, .getGatewayBot, .createInteractionResponse, .getInteractionResponse, .editInteractionResponse, .deleteInteractionResponse, .postFollowupInteractionResponse, .getFollowupInteractionResponse, .editFollowupInteractionResponse, .deleteFollowupInteractionResponse, .createMessage, .editMessage, .deleteMessage, .getGlobalApplicationCommands, .createGlobalApplicationCommand, .getGlobalApplicationCommand, .editGlobalApplicationCommand, .deleteGlobalApplicationCommand, .bulkOverwriteGlobalApplicationCommands, .getGuildApplicationCommands, .createGuildApplicationCommand, .getGuildApplicationCommand, .editGuildApplicationCommand, .deleteGuildApplicationCommand, .bulkOverwriteGuildApplicationCommands, .getGuildApplicationCommandPermissions, .getApplicationCommandPermissions, .editApplicationCommandPermissions, .getGuild, .getGuildRoles, .searchGuildMembers, .getGuildMember, .leaveGuild, .getChannel, .getChannelMessages, .getChannelMessage, .createGuildRole, .deleteGuildRole, .addGuildMemberRole, .removeGuildMemberRole, .getGuildAuditLogs, .createReaction, .deleteOwnReaction, .deleteUserReaction, .getReactions, .deleteAllReactions, .deleteAllReactionsForEmoji, .createDM, .startThreadFromMessage, .startThreadWithoutMessage, .startThreadInForumChannel, .joinThread, .addThreadMember, .leaveThread, .removeThreadMember, .getThreadMember, .listThreadMembers, .listPublicArchivedThreads, .listPrivateArchivedThreads, .listJoinedPrivateArchivedThreads, .createWebhook, .getChannelWebhooks, .getGuildWebhooks, .getWebhook1, .getWebhook2, .modifyWebhook1, .modifyWebhook2, .deleteWebhook1, .deleteWebhook2, .executeWebhook, .getWebhookMessage, .editWebhookMessage, .deleteWebhookMessage:
            return false
        case  .CDNCustomEmoji, .CDNGuildIcon, .CDNGuildSplash, .CDNGuildDiscoverySplash, .CDNGuildBanner, .CDNUserBanner, .CDNDefaultUserAvatar, .CDNUserAvatar, .CDNGuildMemberAvatar, .CDNApplicationIcon, .CDNApplicationCover, .CDNApplicationAsset, .CDNAchievementIcon, .CDNStorePageAsset, .CDNStickerPackBanner, .CDNTeamIcon, .CDNSticker, .CDNRoleIcon, .CDNGuildScheduledEventCover, .CDNGuildMemberBanner:
            return true
        }
    }
    
    /// Interaction endpoints don't count against the global rate limit.
    /// Even if the global rate-limit is exceeded, you can still respond to interactions.
    var countsAgainstGlobalRateLimit: Bool {
        switch self {
        case .createInteractionResponse, .getInteractionResponse, .editInteractionResponse, .deleteInteractionResponse, .postFollowupInteractionResponse, .getFollowupInteractionResponse, .editFollowupInteractionResponse, .deleteFollowupInteractionResponse:
            return false
        case .getGateway, .getGatewayBot, .createMessage, .editMessage, .deleteMessage, .getGlobalApplicationCommands, .createGlobalApplicationCommand, .getGlobalApplicationCommand, .editGlobalApplicationCommand, .deleteGlobalApplicationCommand, .bulkOverwriteGlobalApplicationCommands, .getGuildApplicationCommands, .createGuildApplicationCommand, .getGuildApplicationCommand, .editGuildApplicationCommand, .deleteGuildApplicationCommand, .bulkOverwriteGuildApplicationCommands, .getGuildApplicationCommandPermissions, .getApplicationCommandPermissions, .editApplicationCommandPermissions, .getGuild, .getGuildRoles, .searchGuildMembers, .getGuildMember, .leaveGuild, .getChannel, .getChannelMessages, .getChannelMessage, .createGuildRole, .deleteGuildRole, .addGuildMemberRole, .removeGuildMemberRole, .getGuildAuditLogs, .createReaction, .deleteOwnReaction, .deleteUserReaction, .getReactions, .deleteAllReactions, .deleteAllReactionsForEmoji, .createDM, .startThreadFromMessage, .startThreadWithoutMessage, .startThreadInForumChannel, .joinThread, .addThreadMember, .leaveThread, .removeThreadMember, .getThreadMember, .listThreadMembers, .listPublicArchivedThreads, .listPrivateArchivedThreads, .listJoinedPrivateArchivedThreads, .createWebhook, .getChannelWebhooks, .getGuildWebhooks, .getWebhook1, .getWebhook2, .modifyWebhook1, .modifyWebhook2, .deleteWebhook1, .deleteWebhook2, .executeWebhook, .getWebhookMessage, .editWebhookMessage, .deleteWebhookMessage, .CDNCustomEmoji, .CDNGuildIcon, .CDNGuildSplash, .CDNGuildDiscoverySplash, .CDNGuildBanner, .CDNUserBanner, .CDNDefaultUserAvatar, .CDNUserAvatar, .CDNGuildMemberAvatar, .CDNApplicationIcon, .CDNApplicationCover, .CDNApplicationAsset, .CDNAchievementIcon, .CDNStorePageAsset, .CDNStickerPackBanner, .CDNTeamIcon, .CDNSticker, .CDNRoleIcon, .CDNGuildScheduledEventCover, .CDNGuildMemberBanner:
            return true
        }
    }
    
    /// Some endpoints like don't require an authorization header because the endpoint itself
    /// contains some kind of authorization token. Like half of the webhook endpoints.
    var requiresAuthorizationHeader: Bool {
        switch self {
        case .getGateway, .getGatewayBot, .createInteractionResponse, .getInteractionResponse, .editInteractionResponse, .deleteInteractionResponse, .postFollowupInteractionResponse, .getFollowupInteractionResponse, .editFollowupInteractionResponse, .deleteFollowupInteractionResponse, .createMessage, .editMessage, .deleteMessage, .getGlobalApplicationCommands, .createGlobalApplicationCommand, .getGlobalApplicationCommand, .editGlobalApplicationCommand, .deleteGlobalApplicationCommand, .bulkOverwriteGlobalApplicationCommands, .getGuildApplicationCommands, .createGuildApplicationCommand, .getGuildApplicationCommand, .editGuildApplicationCommand, .deleteGuildApplicationCommand, .bulkOverwriteGuildApplicationCommands, .getGuildApplicationCommandPermissions, .getApplicationCommandPermissions, .editApplicationCommandPermissions, .getGuild, .getGuildRoles, .searchGuildMembers, .getGuildMember, .leaveGuild, .getChannel, .getChannelMessages, .getChannelMessage, .createGuildRole, .deleteGuildRole, .addGuildMemberRole, .removeGuildMemberRole, .getGuildAuditLogs, .createReaction, .deleteOwnReaction, .deleteUserReaction, .getReactions, .deleteAllReactions, .deleteAllReactionsForEmoji, .createDM, .startThreadFromMessage, .startThreadWithoutMessage, .startThreadInForumChannel, .joinThread, .addThreadMember, .leaveThread, .removeThreadMember, .getThreadMember, .listThreadMembers, .listPublicArchivedThreads, .listPrivateArchivedThreads, .listJoinedPrivateArchivedThreads, .createWebhook, .getChannelWebhooks, .getGuildWebhooks, .getWebhook1, .modifyWebhook1, .deleteWebhook1:
            return true
        case .getWebhook2, .modifyWebhook2, .deleteWebhook2, .executeWebhook, .getWebhookMessage, .editWebhookMessage, .deleteWebhookMessage, .CDNCustomEmoji, .CDNGuildIcon, .CDNGuildSplash, .CDNGuildDiscoverySplash, .CDNGuildBanner, .CDNUserBanner, .CDNDefaultUserAvatar, .CDNUserAvatar, .CDNGuildMemberAvatar, .CDNApplicationIcon, .CDNApplicationCover, .CDNApplicationAsset, .CDNAchievementIcon, .CDNStorePageAsset, .CDNStickerPackBanner, .CDNTeamIcon, .CDNSticker, .CDNRoleIcon, .CDNGuildScheduledEventCover, .CDNGuildMemberBanner:
            return false
        }
    }
    
    /// URL-path parameters.
    var parameters: [String] {
        switch self {
        case .getGateway, .getGatewayBot, .createDM:
            return []
        case .createInteractionResponse(let id, let token):
            return [id, token]
        case .getInteractionResponse(let appId, let token):
            return [appId, token]
        case .editInteractionResponse(let appId, let token):
            return [appId, token]
        case .deleteInteractionResponse(let appId, let token):
            return [appId, token]
        case .postFollowupInteractionResponse(let appId, let token):
            return [appId, token]
        case .getFollowupInteractionResponse(let appId, let token, let messageId):
            return [appId, token, messageId]
        case .editFollowupInteractionResponse(let appId, let token, let messageId):
            return [appId, token, messageId]
        case .deleteFollowupInteractionResponse(let appId, let token, let messageId):
            return [appId, token, messageId]
        case .createMessage(let channelId):
            return [channelId]
        case .editMessage(let channelId, let messageId):
            return [channelId, messageId]
        case .deleteMessage(let channelId, let messageId):
            return [channelId, messageId]
        case .getGlobalApplicationCommands(let appId):
            return [appId]
        case .createGlobalApplicationCommand(let appId):
            return [appId]
        case .getGlobalApplicationCommand(let appId, let commandId):
            return [appId, commandId]
        case .editGlobalApplicationCommand(let appId, let commandId):
            return [appId, commandId]
        case .deleteGlobalApplicationCommand(let appId, let commandId):
            return [appId, commandId]
        case .bulkOverwriteGlobalApplicationCommands(let appId):
            return [appId]
        case .getGuildApplicationCommands(let appId, let guildId):
            return [appId, guildId]
        case .createGuildApplicationCommand(let appId, let guildId):
            return [appId, guildId]
        case .getGuildApplicationCommand(let appId, let guildId, let commandId):
            return [appId, guildId, commandId]
        case .editGuildApplicationCommand(let appId, let guildId, let commandId):
            return [appId, guildId, commandId]
        case .deleteGuildApplicationCommand(let appId, let guildId, let commandId):
            return [appId, guildId, commandId]
        case .bulkOverwriteGuildApplicationCommands(let appId, let guildId):
            return [appId, guildId]
        case .getGuildApplicationCommandPermissions(let appId, let guildId):
            return [appId, guildId]
        case .getApplicationCommandPermissions(let appId, let guildId, let commandId):
            return [appId, guildId, commandId]
        case .editApplicationCommandPermissions(let appId, let guildId, let commandId):
            return [appId, guildId, commandId]
        case .getGuild(let id):
            return [id]
        case .getGuildRoles(let id):
            return [id]
        case .searchGuildMembers(let id):
            return [id]
        case .getGuildMember(let id, let userId):
            return [id, userId]
        case .leaveGuild(let id):
            return [id]
        case .getChannel(let id):
            return [id]
        case .getChannelMessages(let channelId):
            return [channelId]
        case .getChannelMessage(let channelId, let messageId):
            return [channelId, messageId]
        case .createGuildRole(let guildId):
            return [guildId]
        case .deleteGuildRole(let guildId, let roleId):
            return [guildId, roleId]
        case .addGuildMemberRole(let guildId, let userId, let roleId):
            return [guildId, userId, roleId]
        case .removeGuildMemberRole(let guildId, let userId, let roleId):
            return [guildId, userId, roleId]
        case .getGuildAuditLogs(let guildId):
            return [guildId]
        case .createReaction(let channelId, let messageId, let emoji):
            return [channelId, messageId, emoji]
        case .deleteOwnReaction(let channelId, let messageId, let emoji):
            return [channelId, messageId, emoji]
        case .deleteUserReaction(let channelId, let messageId, let emoji, let userId):
            return [channelId, messageId, emoji, userId]
        case .getReactions(let channelId, let messageId, let emoji):
            return [channelId, messageId, emoji]
        case .deleteAllReactions(let channelId, let messageId):
            return [channelId, messageId]
        case .deleteAllReactionsForEmoji(let channelId, let messageId, let emoji):
            return [channelId, messageId, emoji]
        case .startThreadFromMessage(let channelId, let messageId):
            return [channelId, messageId]
        case .startThreadWithoutMessage(let channelId):
            return [channelId]
        case .startThreadInForumChannel(let channelId):
            return [channelId]
        case .joinThread(let id):
            return [id]
        case .addThreadMember(let threadId, let userId):
            return [threadId, userId]
        case .leaveThread(let id):
            return [id]
        case .removeThreadMember(let threadId, let userId):
            return [threadId, userId]
        case .getThreadMember(let threadId, let userId):
            return [threadId, userId]
        case .listThreadMembers(let threadId):
            return [threadId]
        case .listPublicArchivedThreads(let channelId):
            return [channelId]
        case .listPrivateArchivedThreads(let channelId):
            return [channelId]
        case .listJoinedPrivateArchivedThreads(let channelId):
            return [channelId]
        case .createWebhook(let channelId):
            return [channelId]
        case .getChannelWebhooks(let channelId):
            return [channelId]
        case .getGuildWebhooks(let guildId):
            return [guildId]
        case .getWebhook1(let id):
            return [id]
        case .getWebhook2(let id, let token):
            return [id, token]
        case .modifyWebhook1(let id):
            return [id]
        case .modifyWebhook2(let id, let token):
            return [id, token]
        case .deleteWebhook1(let id):
            return [id]
        case .deleteWebhook2(let id, let token):
            return [id, token]
        case .executeWebhook(let id, let token):
            return [id, token]
        case .getWebhookMessage(let id, let token, let messageId):
            return [id, token, messageId]
        case .editWebhookMessage(let id, let token, let messageId):
            return [id, token, messageId]
        case .deleteWebhookMessage(let id, let token, let messageId):
            return [id, token, messageId]
        case .CDNCustomEmoji(let emojiId):
            return [emojiId]
        case .CDNGuildIcon(let guildId, let icon):
            return [guildId, icon]
        case .CDNGuildSplash(let guildId, let splash):
            return [guildId, splash]
        case .CDNGuildDiscoverySplash(let guildId, let splash):
            return [guildId, splash]
        case .CDNGuildBanner(let guildId, let banner):
            return [guildId, banner]
        case .CDNUserBanner(let userId, let banner):
            return [userId, banner]
        case .CDNDefaultUserAvatar(let discriminator):
            return [discriminator]
        case .CDNUserAvatar(let userId, let avatar):
            return [userId, avatar]
        case .CDNGuildMemberAvatar(let guildId, let userId, let avatar):
            return [guildId, userId, avatar]
        case .CDNApplicationIcon(let appId, let icon):
            return [appId, icon]
        case .CDNApplicationCover(let appId, let cover):
            return [appId, cover]
        case .CDNApplicationAsset(let appId, let assetId):
            return [appId, assetId]
        case .CDNAchievementIcon(let appId, let achievementId, let icon):
            return [appId, achievementId, icon]
        case .CDNStorePageAsset(let appId, let assetId):
            return [appId, assetId]
        case .CDNStickerPackBanner(let assetId):
            return [assetId]
        case .CDNTeamIcon(let teamId, let icon):
            return [teamId, icon]
        case .CDNSticker(let stickerId):
            return [stickerId]
        case .CDNRoleIcon(let roleId, let icon):
            return [roleId, icon]
        case .CDNGuildScheduledEventCover(let eventId, let cover):
            return [eventId, cover]
        case .CDNGuildMemberBanner(let guildId, let userId, let banner):
            return [guildId, userId, banner]
        }
    }
    
    var id: Int {
        switch self {
        case .getGateway: return 1
        case .getGatewayBot: return 2
        case .createInteractionResponse: return 3
        case .getInteractionResponse: return 4
        case .editInteractionResponse: return 5
        case .deleteInteractionResponse: return 6
        case .postFollowupInteractionResponse: return 7
        case .getFollowupInteractionResponse: return 8
        case .editFollowupInteractionResponse: return 9
        case .deleteFollowupInteractionResponse: return 10
        case .createMessage: return 11
        case .editMessage: return 12
        case .deleteMessage: return 13
        case .getGlobalApplicationCommands: return 14
        case .createGlobalApplicationCommand: return 15
        case .getGlobalApplicationCommand: return 16
        case .editGlobalApplicationCommand: return 17
        case .deleteGlobalApplicationCommand: return 18
        case .bulkOverwriteGlobalApplicationCommands: return 19
        case .getGuildApplicationCommands: return 20
        case .createGuildApplicationCommand: return 21
        case .getGuildApplicationCommand: return 22
        case .editGuildApplicationCommand: return 23
        case .deleteGuildApplicationCommand: return 24
        case .bulkOverwriteGuildApplicationCommands: return 25
        case .getGuildApplicationCommandPermissions: return 26
        case .getApplicationCommandPermissions: return 27
        case .editApplicationCommandPermissions: return 28
        case .getGuild: return 29
        case .getGuildRoles: return 30
        case .searchGuildMembers: return 31
        case .getGuildMember: return 32
        case .leaveGuild: return 33
        case .getChannel: return 34
        case .getChannelMessages: return 35
        case .getChannelMessage: return 36
        case .createGuildRole: return 37
        case .deleteGuildRole: return 38
        case .addGuildMemberRole: return 39
        case .removeGuildMemberRole: return 40
        case .getGuildAuditLogs: return 41
        case .createReaction: return 42
        case .deleteOwnReaction: return 43
        case .deleteUserReaction: return 44
        case .getReactions: return 45
        case .deleteAllReactions: return 46
        case .deleteAllReactionsForEmoji: return 47
        case .createDM: return 48
        case .startThreadFromMessage: return 49
        case .startThreadWithoutMessage: return 50
        case .startThreadInForumChannel: return 51
        case .joinThread: return 52
        case .addThreadMember: return 53
        case .leaveThread: return 54
        case .removeThreadMember: return 55
        case .getThreadMember: return 56
        case .listThreadMembers: return 57
        case .listPublicArchivedThreads: return 58
        case .listPrivateArchivedThreads: return 59
        case .listJoinedPrivateArchivedThreads: return 60
        case .createWebhook: return 61
        case .getChannelWebhooks: return 62
        case .getGuildWebhooks: return 63
        case .getWebhook1: return 64
        case .getWebhook2: return 65
        case .modifyWebhook1: return 66
        case .modifyWebhook2: return 67
        case .deleteWebhook1: return 68
        case .deleteWebhook2: return 69
        case .executeWebhook: return 70
        case .getWebhookMessage: return 71
        case .editWebhookMessage: return 72
        case .deleteWebhookMessage: return 73
        case .CDNCustomEmoji: return 74
        case .CDNGuildIcon: return 75
        case .CDNGuildSplash: return 76
        case .CDNGuildDiscoverySplash: return 77
        case .CDNGuildBanner: return 78
        case .CDNUserBanner: return 79
        case .CDNDefaultUserAvatar: return 80
        case .CDNUserAvatar: return 81
        case .CDNGuildMemberAvatar: return 82
        case .CDNApplicationIcon: return 83
        case .CDNApplicationCover: return 84
        case .CDNApplicationAsset: return 85
        case .CDNAchievementIcon: return 86
        case .CDNStorePageAsset: return 87
        case .CDNStickerPackBanner: return 88
        case .CDNTeamIcon: return 89
        case .CDNSticker: return 90
        case .CDNRoleIcon: return 91
        case .CDNGuildScheduledEventCover: return 92
        case .CDNGuildMemberBanner: return 93
        }
    }
}
