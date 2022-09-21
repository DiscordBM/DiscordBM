
public struct Guild: Sendable, Codable {
    
    public enum VerificationLevel: Int, Sendable, Codable {
        case none = 0
        case low = 1
        case medium = 2
        case high = 3
        case veryHigh = 4
    }
    
    public enum Feature: String, Sendable, Codable {
        case animatedBanner = "ANIMATED_BANNER"
        case animatedIcon = "ANIMATED_ICON"
        case banner = "BANNER"
        case commerce = "COMMERCE"
        case community = "COMMUNITY"
        case discoverable = "DISCOVERABLE"
        case featurable = "FEATURABLE"
        case inviteSplash = "INVITE_SPLASH"
        case memberVerificationGateEnabled = "MEMBER_VERIFICATION_GATE_ENABLED"
        case monetizationEnabled = "MONETIZATION_ENABLED"
        case moreStickers = "MORE_STICKERS"
        case news = "NEWS"
        case partnered = "PARTNERED"
        case previewEnabled = "PREVIEW_ENABLED"
        case privateThreads = "PRIVATE_THREADS"
        case roleIcons = "ROLE_ICONS"
        case sevenDayThreadArchive = "SEVEN_DAY_THREAD_ARCHIVE"
        case threeDayThreadArchive = "THREE_DAY_THREAD_ARCHIVE"
        case ticketedEventsEnabled = "TICKETED_EVENTS_ENABLED"
        case vanityUrl = "VANITY_URL"
        case verified = "VERIFIED"
        case vipRegions = "VIP_REGIONS"
        case welcomeScreenEnabled = "WELCOME_SCREEN_ENABLED"
        case textInVoiceEnabled = "TEXT_IN_VOICE_ENABLED"
        case memberProfiles = "MEMBER_PROFILES"
        case threadsEnabled = "THREADS_ENABLED"
        case exposedToActivitiesWtpExperiment = "EXPOSED_TO_ACTIVITIES_WTP_EXPERIMENT"
        case newThreadPermissions = "NEW_THREAD_PERMISSIONS"
        case autoModeration = "AUTO_MODERATION"
        case enabledDiscoverableBefore = "ENABLED_DISCOVERABLE_BEFORE"
    }
    
    public enum MFALevel: Int, Sendable, Codable {
        case none = 0
        case elevated = 1
    }
    
    public enum SystemChannelFlag: Int, Sendable {
        case suppressJoinNotifications = 0
        case suppressPremiumSubscriptions = 1
        case suppressGuildReminderNotifications = 2
        case suppressJoinNotificationReplies = 3
    }
    
    public enum PremiumTier: Int, Sendable, Codable {
        case none = 0
        case tier1 = 1
        case tier2 = 2
        case tier3 = 3
    }
    
    public struct WelcomeScreen: Sendable, Codable {
        
        public struct Channel: Sendable, Codable {
            public var channel_id: String
            public var description: String
            public var emoji_id: String?
            public var emoji_name: String?
        }
        
        public var description: String?
        public var welcome_channels: [Channel]
    }
    
    public enum NSFWLevel: Int, Sendable, Codable {
        case `default` = 0
        case explicit = 1
        case safe = 2
        case ageRestricted = 3
    }
    
    public var id: String
    public var name: String
    public var icon: String?
    public var icon_hash: String?
    public var splash: String?
    public var discovery_splash: String?
    public var owner: Bool?
    public var owner_id: String
    public var permissions: StringBitField<Gateway.Channel.Permission>?
    public var region: String?
    public var afk_channel_id: String?
    public var afk_timeout: Int
    public var widget_enabled: Bool?
    public var widget_channel_id: String?
    public var verification_level: VerificationLevel
    public var default_message_notifications: Int
    public var explicit_content_filter: Int
    public var roles: [Gateway.Role]
    public var emojis: [Gateway.Emoji]
    public var features: TolerantDecodeArray<Feature>
    public var mfa_level: MFALevel
    public var application_id: String?
    public var system_channel_id: String?
    public var system_channel_flags: IntBitField<SystemChannelFlag>
    public var rules_channel_id: String?
    public var joined_at: DiscordTimestamp?
    public var large: Bool?
    public var unavailable: Bool?
    public var member_count: Int?
    public var voice_states: [Gateway.PartialVoiceState]?
    public var members: Set<Gateway.Member>?
    public var channels: [Gateway.Channel]?
    public var threads: [Gateway.Channel]?
    public var presences: [Gateway.PartialPresenceUpdate]?
    public var max_presences: Int?
    public var max_members: Int?
    public var vanity_url_code: String?
    public var description: String?
    public var banner: String?
    public var premium_tier: PremiumTier
    public var premium_subscription_count: Int?
    public var preferred_locale: DiscordLocale
    public var public_updates_channel_id: String?
    public var max_video_channel_users: Int?
    public var approximate_member_count: Int?
    public var approximate_presence_count: Int?
    public var welcome_screen: [WelcomeScreen]?
    public var nsfw_level: NSFWLevel
    public var stage_instances: [Gateway.StageInstance]?
    public var stickers: [Gateway.Sticker]?
    public var guild_scheduled_events: [Gateway.GuildScheduledEvent]?
    public var premium_progress_bar_enabled: Bool
    public var `lazy`: Bool?
    public var hub_type: String?
    public var guild_hashes: Hashes?
    public var nsfw: Bool
    public var application_command_counts: [String: Int]?
    public var embedded_activities: [Gateway.Activity]?
    public var guild_id: String?
    public var hashes: Hashes?
    public var max_stage_video_channel_users: Int?
}

public struct CreateGuildRole: Sendable, Codable {
    public var name: String?
    public var permissions: StringBitField<Gateway.Channel.Permission>?
    public var color: DiscordColor?
    public var hoist: Bool?
//    public var icon: ImageData? not supported
    public var unicode_emoji: String?
    public var mentionable: Bool?
    
    public init(name: String? = nil, permissions: [Gateway.Channel.Permission]? = nil, color: DiscordColor? = nil, hoist: Bool? = nil, unicode_emoji: String? = nil, mentionable: Bool? = nil) {
        self.name = name
        self.permissions = permissions.map { .init($0) }
        self.color = color
        self.hoist = hoist
        self.unicode_emoji = unicode_emoji
        self.mentionable = mentionable
    }
}
