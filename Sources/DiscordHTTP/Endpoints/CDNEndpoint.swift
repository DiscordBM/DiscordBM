import NIOHTTP1

/// CDN Endpoints
/// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
public enum CDNEndpoint: Endpoint {
    case customEmoji(emojiId: String)
    case guildIcon(guildId: String, icon: String)
    case guildSplash(guildId: String, splash: String)
    case guildDiscoverySplash(guildId: String, splash: String)
    case guildBanner(guildId: String, banner: String)
    case userBanner(userId: String, banner: String)
    case defaultUserAvatar(discriminator: String)
    case userAvatar(userId: String, avatar: String)
    case guildMemberAvatar(guildId: String, userId: String, avatar: String)
    case applicationIcon(appId: String, icon: String)
    case applicationCover(appId: String, cover: String)
    case applicationAsset(appId: String, assetId: String)
    case achievementIcon(appId: String, achievementId: String, icon: String)
    case storePageAsset(appId: String, assetId: String)
    case stickerPackBanner(assetId: String)
    case teamIcon(teamId: String, icon: String)
    case sticker(stickerId: String)
    case roleIcon(roleId: String, icon: String)
    case guildScheduledEventCover(eventId: String, cover: String)
    case guildMemberBanner(guildId: String, userId: String, banner: String)
    
    var urlSuffix: String {
        let suffix: String
        switch self {
        case let .customEmoji(emojiId):
            suffix = "emojis/\(emojiId)"
        case let .guildIcon(guildId, icon):
            suffix = "icons/\(guildId)/\(icon)"
        case let .guildSplash(guildId, splash):
            suffix = "splashes/\(guildId)/\(splash)"
        case let .guildDiscoverySplash(guildId, splash):
            suffix = "discovery-splashes/\(guildId)/\(splash)"
        case let .guildBanner(guildId, banner):
            suffix = "banners/\(guildId)/\(banner)"
        case let .userBanner(userId, banner):
            suffix = "banners/\(userId)/\(banner)"
        case let .defaultUserAvatar(discriminator):
            suffix = "embed/avatars/\(discriminator).png" /// Needs `.png`
        case let .userAvatar(userId, avatar):
            suffix = "avatars/\(userId)/\(avatar)"
        case let .guildMemberAvatar(guildId, userId, avatar):
            suffix = "guilds/\(guildId)/users/\(userId)/avatars/\(avatar)"
        case let .applicationIcon(appId, icon):
            suffix = "app-icons/\(appId)/\(icon)"
        case let .applicationCover(appId, cover):
            suffix = "app-icons/\(appId)/\(cover)"
        case let .applicationAsset(appId, assetId):
            suffix = "app-assets/\(appId)/\(assetId)"
        case let .achievementIcon(appId, achievementId, icon):
            suffix = "app-assets/\(appId)/achievements/\(achievementId)/icons/\(icon)"
        case let .storePageAsset(appId, assetId):
            suffix = "app-assets/\(appId)/store/\(assetId)"
        case let .stickerPackBanner(assetId):
            suffix = "app-assets/710982414301790216/store/\(assetId)"
        case let .teamIcon(teamId, icon):
            suffix = "team-icons/\(teamId)/\(icon)"
        case let .sticker(stickerId):
            suffix = "stickers/\(stickerId).png" /// Needs `.png`
        case let .roleIcon(roleId, icon):
            suffix = "role-icons/\(roleId)/\(icon)"
        case let .guildScheduledEventCover(eventId, cover):
            suffix = "guild-events/\(eventId)/\(cover)"
        case let .guildMemberBanner(guildId, userId, banner):
            suffix = "guilds/\(guildId)/users/\(userId)/banners/\(banner)"
        }
        return suffix.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? suffix
    }
    
    private var urlSuffixDescription: String {
        urlSuffix
    }
    
    public var url: String {
        "https://cdn.discordapp.com/" + urlSuffix
    }
    
    /// Doesn't expose secret url path parameters.
    public var urlDescription: String {
        url
    }
    
    public var httpMethod: HTTPMethod {
        switch self {
        case .customEmoji: return .GET
        case .guildIcon: return .GET
        case .guildSplash: return .GET
        case .guildDiscoverySplash: return .GET
        case .guildBanner: return .GET
        case .userBanner: return .GET
        case .defaultUserAvatar: return .GET
        case .userAvatar: return .GET
        case .guildMemberAvatar: return .GET
        case .applicationIcon: return .GET
        case .applicationCover: return .GET
        case .applicationAsset: return .GET
        case .achievementIcon: return .GET
        case .storePageAsset: return .GET
        case .stickerPackBanner: return .GET
        case .teamIcon: return .GET
        case .sticker: return .GET
        case .roleIcon: return .GET
        case .guildScheduledEventCover: return .GET
        case .guildMemberBanner: return .GET
        }
    }
    
    /// Interaction endpoints don't count against the global rate limit.
    /// Even if the global rate-limit is exceeded, you can still respond to interactions.
    public var countsAgainstGlobalRateLimit: Bool {
        true
    }
    
    /// Some endpoints like don't require an authorization header because the endpoint itself
    /// contains some kind of authorization token. Like half of the webhook endpoints.
    public var requiresAuthorizationHeader: Bool {
        false
    }
    
    /// URL-path parameters.
    public var parameters: [String] {
        switch self {
        case .customEmoji(let emojiId):
            return [emojiId]
        case .guildIcon(let guildId, let icon):
            return [guildId, icon]
        case .guildSplash(let guildId, let splash):
            return [guildId, splash]
        case .guildDiscoverySplash(let guildId, let splash):
            return [guildId, splash]
        case .guildBanner(let guildId, let banner):
            return [guildId, banner]
        case .userBanner(let userId, let banner):
            return [userId, banner]
        case .defaultUserAvatar(let discriminator):
            return [discriminator]
        case .userAvatar(let userId, let avatar):
            return [userId, avatar]
        case .guildMemberAvatar(let guildId, let userId, let avatar):
            return [guildId, userId, avatar]
        case .applicationIcon(let appId, let icon):
            return [appId, icon]
        case .applicationCover(let appId, let cover):
            return [appId, cover]
        case .applicationAsset(let appId, let assetId):
            return [appId, assetId]
        case .achievementIcon(let appId, let achievementId, let icon):
            return [appId, achievementId, icon]
        case .storePageAsset(let appId, let assetId):
            return [appId, assetId]
        case .stickerPackBanner(let assetId):
            return [assetId]
        case .teamIcon(let teamId, let icon):
            return [teamId, icon]
        case .sticker(let stickerId):
            return [stickerId]
        case .roleIcon(let roleId, let icon):
            return [roleId, icon]
        case .guildScheduledEventCover(let eventId, let cover):
            return [eventId, cover]
        case .guildMemberBanner(let guildId, let userId, let banner):
            return [guildId, userId, banner]
        }
    }
    
    public var id: Int {
        switch self {
        case .customEmoji: return 1
        case .guildIcon: return 2
        case .guildSplash: return 3
        case .guildDiscoverySplash: return 4
        case .guildBanner: return 5
        case .userBanner: return 6
        case .defaultUserAvatar: return 7
        case .userAvatar: return 8
        case .guildMemberAvatar: return 9
        case .applicationIcon: return 10
        case .applicationCover: return 11
        case .applicationAsset: return 12
        case .achievementIcon: return 13
        case .storePageAsset: return 14
        case .stickerPackBanner: return 15
        case .teamIcon: return 16
        case .sticker: return 17
        case .roleIcon: return 18
        case .guildScheduledEventCover: return 19
        case .guildMemberBanner: return 20
        }
    }
}
