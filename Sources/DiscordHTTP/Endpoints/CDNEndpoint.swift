import DiscordModels
import NIOHTTP1

/// CDN Endpoints
/// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
public enum CDNEndpoint: Endpoint {
    case customEmoji(emojiId: Snowflake<PartialEmoji>)
    case guildIcon(guildId: Snowflake<Guild>, icon: String)
    case guildSplash(guildId: Snowflake<Guild>, splash: String)
    case guildDiscoverySplash(guildId: Snowflake<Guild>, splash: String)
    case guildBanner(guildId: Snowflake<Guild>, banner: String)
    case userBanner(userId: Snowflake<DiscordUser>, banner: String)
    case defaultUserAvatar(discriminator: String)
    case userAvatar(userId: Snowflake<DiscordUser>, avatar: String)
    case guildMemberAvatar(guildId: Snowflake<Guild>, userId: Snowflake<DiscordUser>, avatar: String)
    case applicationIcon(appId: Snowflake<PartialApplication>, icon: String)
    case applicationCover(appId: Snowflake<PartialApplication>, cover: String)
    case applicationAsset(
        appId: Snowflake<PartialApplication>,
        assetId: Snowflake<Gateway.Activity.Assets>
    )
    /// FIXME: `achievementId` should be of type `Snowflake<Achievement>` but
    /// `DiscordBM` doesn't yet have the `Achievement` type.
    case achievementIcon(
        appId: Snowflake<PartialApplication>,
        achievementId: AnySnowflake,
        icon: String
    )
    case storePageAsset(
        appId: Snowflake<PartialApplication>,
        assetId: Snowflake<Gateway.Activity.Assets>
    )
    case stickerPackBanner(assetId: Snowflake<Gateway.Activity.Assets>)
    case teamIcon(teamId: Snowflake<Team>, icon: String)
    case sticker(stickerId: Snowflake<Sticker>)
    case roleIcon(roleId: Snowflake<Role>, icon: String)
    case guildScheduledEventCover(eventId: Snowflake<GuildScheduledEvent>, cover: String)
    case guildMemberBanner(
        guildId: Snowflake<Guild>,
        userId: Snowflake<DiscordUser>,
        banner: String
    )
    
    var urlSuffix: String {
        let suffix: String
        switch self {
        case let .customEmoji(emojiId):
            suffix = "emojis/\(emojiId.value)"
        case let .guildIcon(guildId, icon):
            suffix = "icons/\(guildId.value)/\(icon)"
        case let .guildSplash(guildId, splash):
            suffix = "splashes/\(guildId.value)/\(splash)"
        case let .guildDiscoverySplash(guildId, splash):
            suffix = "discovery-splashes/\(guildId.value)/\(splash)"
        case let .guildBanner(guildId, banner):
            suffix = "banners/\(guildId.value)/\(banner)"
        case let .userBanner(userId, banner):
            suffix = "banners/\(userId.value)/\(banner)"
        case let .defaultUserAvatar(discriminator):
            suffix = "embed/avatars/\(discriminator).png" /// Needs `.png`
        case let .userAvatar(userId, avatar):
            suffix = "avatars/\(userId.value)/\(avatar)"
        case let .guildMemberAvatar(guildId, userId, avatar):
            suffix = "guilds/\(guildId.value)/users/\(userId.value)/avatars/\(avatar)"
        case let .applicationIcon(appId, icon):
            suffix = "app-icons/\(appId.value)/\(icon)"
        case let .applicationCover(appId, cover):
            suffix = "app-icons/\(appId.value)/\(cover)"
        case let .applicationAsset(appId, assetId):
            suffix = "app-assets/\(appId.value)/\(assetId.value)"
        case let .achievementIcon(appId, achievementId, icon):
            suffix = "app-assets/\(appId.value)/achievements/\(achievementId.value)/icons/\(icon)"
        case let .storePageAsset(appId, assetId):
            suffix = "app-assets/\(appId.value)/store/\(assetId.value)"
        case let .stickerPackBanner(assetId):
            suffix = "app-assets/710982414301790216/store/\(assetId.value)"
        case let .teamIcon(teamId, icon):
            suffix = "team-icons/\(teamId.value)/\(icon)"
        case let .sticker(stickerId):
            suffix = "stickers/\(stickerId.value).png" /// Needs `.png`
        case let .roleIcon(roleId, icon):
            suffix = "role-icons/\(roleId.value)/\(icon)"
        case let .guildScheduledEventCover(eventId, cover):
            suffix = "guild-events/\(eventId.value)/\(cover)"
        case let .guildMemberBanner(guildId, userId, banner):
            suffix = "guilds/\(guildId.value)/users/\(userId.value)/banners/\(banner)"
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
            return [emojiId.value]
        case .guildIcon(let guildId, let icon):
            return [guildId.value, icon]
        case .guildSplash(let guildId, let splash):
            return [guildId.value, splash]
        case .guildDiscoverySplash(let guildId, let splash):
            return [guildId.value, splash]
        case .guildBanner(let guildId, let banner):
            return [guildId.value, banner]
        case .userBanner(let userId, let banner):
            return [userId.value, banner]
        case .defaultUserAvatar(let discriminator):
            return [discriminator]
        case .userAvatar(let userId, let avatar):
            return [userId.value, avatar]
        case .guildMemberAvatar(let guildId, let userId, let avatar):
            return [guildId.value, userId.value, avatar]
        case .applicationIcon(let appId, let icon):
            return [appId.value, icon]
        case .applicationCover(let appId, let cover):
            return [appId.value, cover]
        case .applicationAsset(let appId, let assetId):
            return [appId.value, assetId.value]
        case .achievementIcon(let appId, let achievementId, let icon):
            return [appId.value, achievementId.value, icon]
        case .storePageAsset(let appId, let assetId):
            return [appId.value, assetId.value]
        case .stickerPackBanner(let assetId):
            return [assetId.value]
        case .teamIcon(let teamId, let icon):
            return [teamId.value, icon]
        case .sticker(let stickerId):
            return [stickerId.value]
        case .roleIcon(let roleId, let icon):
            return [roleId.value, icon]
        case .guildScheduledEventCover(let eventId, let cover):
            return [eventId.value, cover]
        case .guildMemberBanner(let guildId, let userId, let banner):
            return [guildId.value, userId.value, banner]
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
    
    public var description: String {
        switch self {
        case let .customEmoji(emojiId):
            return "customEmoji(emojiId: \(emojiId))"
        case let .guildIcon(guildId, icon):
            return "guildIcon(guildId: \(guildId), icon: \(icon))"
        case let .guildSplash(guildId, splash):
            return "guildSplash(guildId: \(guildId), splash: \(splash))"
        case let .guildDiscoverySplash(guildId, splash):
            return "guildDiscoverySplash(guildId: \(guildId), splash: \(splash))"
        case let .guildBanner(guildId, banner):
            return "guildBanner(guildId: \(guildId), banner: \(banner))"
        case let .userBanner(userId, banner):
            return "userBanner(userId: \(userId), banner: \(banner))"
        case let .defaultUserAvatar(discriminator):
            return "defaultUserAvatar(discriminator: \(discriminator))"
        case let .userAvatar(userId, avatar):
            return "userAvatar(userId: \(userId), avatar: \(avatar))"
        case let .guildMemberAvatar(guildId, userId, avatar):
            return "guildMemberAvatar(guildId: \(guildId), userId: \(userId), avatar: \(avatar))"
        case let .applicationIcon(appId, icon):
            return "applicationIcon(appId: \(appId), icon: \(icon))"
        case let .applicationCover(appId, cover):
            return "applicationCover(appId: \(appId), cover: \(cover))"
        case let .applicationAsset(appId, assetId):
            return "applicationAsset(appId: \(appId), assetId: \(assetId))"
        case let .achievementIcon(appId, achievementId, icon):
            return "achievementIcon(appId: \(appId), achievementId: \(achievementId), icon: \(icon))"
        case let .storePageAsset(appId, assetId):
            return "storePageAsset(appId: \(appId), assetId: \(assetId))"
        case let .stickerPackBanner(assetId):
            return "stickerPackBanner(assetId: \(assetId))"
        case let .teamIcon(teamId, icon):
            return "teamIcon(teamId: \(teamId), icon: \(icon))"
        case let .sticker(stickerId):
            return "sticker(stickerId: \(stickerId))"
        case let .roleIcon(roleId, icon):
            return "roleIcon(roleId: \(roleId), icon: \(icon))"
        case let .guildScheduledEventCover(eventId, cover):
            return "guildScheduledEventCover(eventId: \(eventId), cover: \(cover))"
        case let .guildMemberBanner(guildId, userId, banner):
            return "guildMemberBanner(guildId: \(guildId), userId: \(userId), banner: \(banner))"
        }
    }
}

public enum CDNEndpointIdentity: Int, Sendable, Hashable, CustomStringConvertible {
    case customEmoji
    case guildIcon
    case guildSplash
    case guildDiscoverySplash
    case guildBanner
    case userBanner
    case defaultUserAvatar
    case userAvatar
    case guildMemberAvatar
    case applicationIcon
    case applicationCover
    case applicationAsset
    case achievementIcon
    case storePageAsset
    case stickerPackBanner
    case teamIcon
    case sticker
    case roleIcon
    case guildScheduledEventCover
    case guildMemberBanner
    
    public var description: String {
        switch self {
        case .customEmoji: return "customEmoji"
        case .guildIcon: return "guildIcon"
        case .guildSplash: return "guildSplash"
        case .guildDiscoverySplash: return "guildDiscoverySplash"
        case .guildBanner: return "guildBanner"
        case .userBanner: return "userBanner"
        case .defaultUserAvatar: return "defaultUserAvatar"
        case .userAvatar: return "userAvatar"
        case .guildMemberAvatar: return "guildMemberAvatar"
        case .applicationIcon: return "applicationIcon"
        case .applicationCover: return "applicationCover"
        case .applicationAsset: return "applicationAsset"
        case .achievementIcon: return "achievementIcon"
        case .storePageAsset: return "storePageAsset"
        case .stickerPackBanner: return "stickerPackBanner"
        case .teamIcon: return "teamIcon"
        case .sticker: return "sticker"
        case .roleIcon: return "roleIcon"
        case .guildScheduledEventCover: return "guildScheduledEventCover"
        case .guildMemberBanner: return "guildMemberBanner"
        }
    }
    
    init(endpoint: CDNEndpoint) {
        switch endpoint {
        case .customEmoji: self = .customEmoji
        case .guildIcon: self = .guildIcon
        case .guildSplash: self = .guildSplash
        case .guildDiscoverySplash: self = .guildDiscoverySplash
        case .guildBanner: self = .guildBanner
        case .userBanner: self = .userBanner
        case .defaultUserAvatar: self = .defaultUserAvatar
        case .userAvatar: self = .userAvatar
        case .guildMemberAvatar: self = .guildMemberAvatar
        case .applicationIcon: self = .applicationIcon
        case .applicationCover: self = .applicationCover
        case .applicationAsset: self = .applicationAsset
        case .achievementIcon: self = .achievementIcon
        case .storePageAsset: self = .storePageAsset
        case .stickerPackBanner: self = .stickerPackBanner
        case .teamIcon: self = .teamIcon
        case .sticker: self = .sticker
        case .roleIcon: self = .roleIcon
        case .guildScheduledEventCover: self = .guildScheduledEventCover
        case .guildMemberBanner: self = .guildMemberBanner
        }
    }
}
