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
    case getWebhook
    case getWebhookWithToken
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
        case .getWebhook: return "getWebhook"
        case .getWebhookWithToken: return "getWebhookWithToken"
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
    
    init? (endpoint: APIEndpoint) {
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
        case .getWebhook: self = .getWebhook
        case .getWebhookWithToken: self = .getWebhookWithToken
        case .modifyWebhook: return nil
        case .modifyWebhookWithToken: return nil
        case .deleteWebhook: return nil
        case .deleteWebhookWithToken: return nil
        case .executeWebhook: return nil
        case .getWebhookMessage: self = .getWebhookMessage
        case .editWebhookMessage: return nil
        case .deleteWebhookMessage: return nil
        }
    }
    
    init (endpoint: CDNEndpoint) {
        switch self {
        case .customEmoji: self = .CDNCustomEmoji
        case .guildIcon: self = .CDNGuildIcon
        case .guildSplash: self = .CDNGuildSplash
        case .guildDiscoverySplash: self = .CDNGuildDiscoverySplash
        case .guildBanner: self = .CDNGuildBanner
        case .userBanner: self = .CDNUserBanner
        case .defaultUserAvatar: self = .CDNDefaultUserAvatar
        case .userAvatar: self = .CDNUserAvatar
        case .guildMemberAvatar: self = .CDNGuildMemberAvatar
        case .applicationIcon: self = .CDNApplicationIcon
        case .applicationCover: self = .CDNApplicationCover
        case .applicationAsset: self = .CDNApplicationAsset
        case .achievementIcon: self = .CDNAchievementIcon
        case .storePageAsset: self = .CDNStorePageAsset
        case .stickerPackBanner: self = .CDNStickerPackBanner
        case .teamIcon: self = .CDNTeamIcon
        case .sticker: self = .CDNSticker
        case .roleIcon: self = .CDNRoleIcon
        case .guildScheduledEventCover: self = .CDNGuildScheduledEventCover
        case .guildMemberBanner: self = .CDNGuildMemberBanner
        }
    }
    
    init? (endpoint: Endpoint) {
        if let endpoint = endpoint as? APIEndpoint {
            self.init(endpoint: endpoint)
        } else if let endpoint = endpoint as? CDNEndpoint {
            self.init(endpoint: endpoint)
        } else {
            fatalError("Unknown endpoint type: \(type(of: endpoint))")
        }
    }
}
