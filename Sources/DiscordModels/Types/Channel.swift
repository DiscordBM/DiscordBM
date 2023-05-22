import Foundation

/// https://discord.com/developers/docs/resources/channel#channel-object-channel-structure
/// The same as what the Discord API docs call "partial channel".
/// Also the same as a "thread object".
public struct DiscordChannel: Sendable, Codable {
    
    /// https://discord.com/developers/docs/resources/channel#channel-object-channel-types
    public enum Kind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case guildText = 0
        case dm = 1
        case guildVoice = 2
        case groupDm = 3
        case guildCategory = 4
        case guildAnnouncement = 5
        case announcementThread = 10
        case publicThread = 11
        case privateThread = 12
        case guildStageVoice = 13
        case guildDirectory = 14
        case guildForum = 15
    }
    
    /// https://discord.com/developers/docs/resources/channel#overwrite-object
    public struct Overwrite: Sendable, Codable {
        
        /// https://discord.com/developers/docs/resources/channel#overwrite-object
        public enum Kind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
            case role = 0
            case member = 1
        }
        
        public var id: AnySnowflake
        public var type: Kind
        public var allow: StringBitField<Permission>
        public var deny: StringBitField<Permission>
    }
    
    /// https://discord.com/developers/docs/resources/channel#channel-object-sort-order-types
    public enum SortOrder: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case latestActivity = 0
        case creationDate = 1
    }
    
    /// https://discord.com/developers/docs/resources/channel#channel-object-forum-layout-types
    public enum ForumLayout: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case notSet = 0
        case listView = 1
        case galleryView = 2
    }
    
    /// https://discord.com/developers/docs/resources/channel#channel-object-channel-flags
    public enum Flag: Int, Sendable {
        case pinned = 1
        case requireTag = 4
    }
    
    /// https://discord.com/developers/docs/resources/channel#channel-object-video-quality-modes
    public enum VideoQualityMode: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case auto = 1
        case full = 2
    }
    
    /// Not exactly documented, but they do mention these times in a few different places.
    /// Times are in minutes.
    /// https://discord.com/developers/docs/resources/channel#channel-object-channel-structure
    public enum AutoArchiveDuration: Int, Sendable, Codable {
        case oneHour = 60
        case oneDay = 1_440
        case threeDays = 4_320
        case sevenDays = 10_080
    }

    /// https://discord.com/developers/docs/resources/channel#default-reaction-object-default-reaction-structure
    public struct DefaultReaction: Sendable, Codable {
        public var emoji_id: EmojiSnowflake?
        public var emoji_name: String?

        public init(emoji_id: EmojiSnowflake? = nil) {
            self.emoji_id = emoji_id
            self.emoji_name = nil
        }

        public init(emoji_name: String? = nil) {
            self.emoji_id = nil
            self.emoji_name = emoji_name
        }
    }

    /// https://discord.com/developers/docs/resources/channel#forum-tag-object-forum-tag-structure
    public struct ForumTag: Sendable, Codable {
        public var id: ForumTagSnowflake
        public var name: String
        public var moderated: Bool
        public var emoji_id: EmojiSnowflake?
        public var emoji_name: String?
    }
    
    public var id: ChannelSnowflake
    /// Type is optional because there are some endpoints that return
    /// partial channel objects, and very few of them exclude the `type`.
    public var type: Kind?
    public var guild_id: GuildSnowflake?
    public var position: Int?
    public var permission_overwrites: [Overwrite]?
    public var name: String?
    public var topic: String?
    public var nsfw: Bool?
    public var last_message_id: MessageSnowflake?
    public var bitrate: Int?
    public var user_limit: Int?
    public var rate_limit_per_user: Int?
    public var recipients: [DiscordUser]?
    public var icon: String?
    public var owner_id: UserSnowflake?
    public var application_id: ApplicationSnowflake?
    public var manage: Bool?
    public var parent_id: AnySnowflake?
    public var last_pin_timestamp: DiscordTimestamp?
    public var rtc_region: String?
    public var video_quality_mode: VideoQualityMode?
    public var message_count: Int?
    public var total_message_sent: Int?
    public var member_count: Int?
    public var thread_metadata: ThreadMetadata?
    public var default_auto_archive_duration: AutoArchiveDuration?
    public var default_thread_rate_limit_per_user: Int?
    public var default_reaction_emoji: DefaultReaction?
    public var default_sort_order: Int?
    public var default_forum_layout: ForumLayout?
    public var permissions: StringBitField<Permission>?
    public var flags: IntBitField<Flag>?
    public var available_tags: [ForumTag]?
    public var template: String?
    public var member_ids_preview: [String]?
    public var version: Int?
    /// Thread-only:
    public var member: ThreadMember?
    public var newly_created: Bool?
    /// Only populated by thread-related Gateway events.
    public var threadMembers: [Gateway.ThreadMembersUpdate.ThreadMember]?
}

extension DiscordChannel {
    /// https://discord.com/developers/docs/resources/channel#message-object
    public struct Message: Sendable, Codable {
        
        /// https://discord.com/developers/docs/resources/channel#message-reference-object-message-reference-structure
        public struct MessageReference: Sendable, Codable {
            public var message_id: MessageSnowflake?
            public var channel_id: ChannelSnowflake?
            public var guild_id: GuildSnowflake?
            public var fail_if_not_exists: Bool?
            
            public init(message_id: MessageSnowflake? = nil, channel_id: ChannelSnowflake? = nil, guild_id: GuildSnowflake? = nil, fail_if_not_exists: Bool? = nil) {
                self.message_id = message_id
                self.channel_id = channel_id
                self.guild_id = guild_id
                self.fail_if_not_exists = fail_if_not_exists
            }
        }
        
        /// https://discord.com/developers/docs/resources/channel#message-object-message-types
        public enum Kind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
            case `default` = 0
            case recipientAdd = 1
            case recipientRemove = 2
            case call = 3
            case channelNameChange = 4
            case channelIconChange = 5
            case channelPinnedMessage = 6
            case guildMemberJoin = 7
            case userPremiumGuildSubscription = 8
            case userPremiumGuildSubscriptionTier1 = 9
            case userPremiumGuildSubscriptionTier2 = 10
            case userPremiumGuildSubscriptionTier3 = 11
            case channelFollowAdd = 12
            case guildDiscoveryDisqualified = 14
            case guildDiscoveryRequalified = 15
            case guildDiscoveryGracePeriodInitialWarning = 16
            case guildDiscoveryGracePeriodFinalWarning = 17
            case threadCreated = 18
            case reply = 19
            case chatInputCommand = 20
            case threadStarterMessage = 21
            case guildInviteReminder = 22
            case contextMenuCommand = 23
            case autoModerationAction = 24
            case roleSubscriptionPurchase = 25
            case interactionPremiumUpsell = 26
            case stageStart = 27
            case stageEnd = 28
            case stageSpeaker = 29
            case stageTopic = 31
            case guildApplicationPremiumSubscription = 32
            
            public var isDeletable: Bool {
                switch self {
                case .`default`, .channelPinnedMessage, .guildMemberJoin, .userPremiumGuildSubscription, .userPremiumGuildSubscriptionTier1, .userPremiumGuildSubscriptionTier2, .userPremiumGuildSubscriptionTier3, .channelFollowAdd, .threadCreated, .reply, .chatInputCommand, .guildInviteReminder, .contextMenuCommand, .autoModerationAction, .roleSubscriptionPurchase, .interactionPremiumUpsell, .stageStart, .stageEnd, .stageSpeaker, .stageTopic:
                    return true
                case .recipientAdd, .recipientRemove, .call, .channelNameChange, .channelIconChange, .guildDiscoveryDisqualified, .guildDiscoveryRequalified, .guildDiscoveryGracePeriodInitialWarning, .guildDiscoveryGracePeriodFinalWarning, .threadStarterMessage, .guildApplicationPremiumSubscription:
                    return false
                }
            }
        }
        
        /// https://discord.com/developers/docs/resources/channel#message-object-message-flags
        public enum Flag: Int, Sendable {
            case crossposted = 0
            case isCrosspost = 1
            case suppressEmbeds = 2
            case sourceMessageDeleted = 3
            case urgent = 4
            case hasThread = 5
            case ephemeral = 6
            case loading = 7
            case failedToMentionSomeRolesInThread = 8
            case suppressNotifications = 12
            case isVoiceMessage = 13
        }
        
        /// https://discord.com/developers/docs/resources/channel#channel-mention-object
        public struct ChannelMention: Sendable, Codable {
            public var id: ChannelSnowflake
            public var guild_id: GuildSnowflake
            public var type: DiscordChannel.Kind
            public var name: String
        }
        
        /// https://discord.com/developers/docs/resources/channel#attachment-object
        public struct Attachment: Sendable, Codable {
            public var id: AttachmentSnowflake
            public var filename: String
            public var description: String?
            public var content_type: String?
            public var size: Int
            public var url: String
            public var proxy_url: String
            public var height: Int?
            public var width: Int?
            public var ephemeral: Bool?
            public var duration_secs: Double?
            public var waveform: String?
        }
        
        /// https://discord.com/developers/docs/resources/channel#reaction-object
        public struct Reaction: Sendable, Codable {
            public var count: Int
            public var me: Bool
            public var emoji: Emoji

            public init(count: Int, me: Bool, emoji: Emoji) {
                self.count = count
                self.me = me
                self.emoji = emoji
            }
        }
        
        /// https://discord.com/developers/docs/resources/channel#message-object-message-activity-structure
        public struct Activity: Sendable, Codable {
            
            /// https://discord.com/developers/docs/resources/channel#message-object-message-activity-types
            public enum Kind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
                case join = 1
                case spectate = 2
                case listen = 3
                case joinRequest = 5
            }
            
            public var type: Kind
            // FIXME: Don't have the type to use `Snowflake<Type>` instead
            public var party_id: AnySnowflake?
        }

        public var id: MessageSnowflake
        public var channel_id: ChannelSnowflake
        public var guild_id: GuildSnowflake?
        public var author: PartialUser?
        public var member: Guild.PartialMember?
        public var content: String
        public var timestamp: DiscordTimestamp
        public var edited_timestamp: DiscordTimestamp?
        public var tts: Bool
        public var mention_everyone: Bool
        public var mentions: [DiscordUser]
        public var mention_roles: [RoleSnowflake]
        public var mention_channels: [ChannelMention]?
        public var attachments: [Attachment]
        public var embeds: [Embed]
        public var reactions: [Reaction]?
        public var nonce: StringOrInt?
        public var pinned: Bool
        public var webhook_id: WebhookSnowflake?
        public var type: Kind
        public var activity: Activity?
        public var application: PartialApplication?
        public var application_id: ApplicationSnowflake?
        public var message_reference: MessageReference?
        public var flags: IntBitField<Flag>?
        public var referenced_message: DereferenceBox<Message>?
        public var interaction: MessageInteraction?
        public var thread: DiscordChannel?
        public var components: [Interaction.ActionRow]?
        public var sticker_items: [StickerItem]?
        public var stickers: [Sticker]?
        public var position: Int?
        public var role_subscription_data: RoleSubscriptionData?
    }
}

extension DiscordChannel {
    /// Partial ``DiscordChannel.Message`` object.
    public struct PartialMessage: Sendable, Codable {
        public var id:  MessageSnowflake
        public var channel_id: ChannelSnowflake
        public var author: PartialUser?
        public var content: String?
        public var timestamp: DiscordTimestamp?
        public var edited_timestamp: DiscordTimestamp?
        public var tts: Bool?
        public var mention_everyone: Bool?
        public var mentions: [DiscordUser]?
        public var mention_roles: [RoleSnowflake]?
        public var mention_channels: [DiscordChannel.Message.ChannelMention]?
        public var attachments: [DiscordChannel.Message.Attachment]?
        public var embeds: [Embed]?
        public var reactions: [DiscordChannel.Message.Reaction]?
        public var nonce: StringOrInt?
        public var pinned: Bool?
        public var webhook_id: WebhookSnowflake?
        public var type: DiscordChannel.Message.Kind?
        public var activity: DiscordChannel.Message.Activity?
        public var application: PartialApplication?
        public var application_id: ApplicationSnowflake?
        public var message_reference: DiscordChannel.Message.MessageReference?
        public var flags: IntBitField<DiscordChannel.Message.Flag>?
        public var referenced_message: DereferenceBox<PartialMessage>?
        public var interaction: MessageInteraction?
        public var thread: DiscordChannel?
        public var components: [Interaction.ActionRow]?
        public var sticker_items: [StickerItem]?
        public var stickers: [Sticker]?
        public var position: Int?
        public var role_subscription_data: RoleSubscriptionData?
        public var member: Guild.PartialMember?
        public var guild_id: GuildSnowflake?
    }
}

/// https://discord.com/developers/docs/resources/channel#thread-metadata-object-thread-metadata-structure
public struct ThreadMetadata: Sendable, Codable {
    public var archived: Bool
    public var auto_archive_duration: DiscordChannel.AutoArchiveDuration
    public var archive_timestamp: DiscordTimestamp
    public var locked: Bool
    public var invitable: Bool?
    public var create_timestamp: DiscordTimestamp?
}

/// https://discord.com/developers/docs/resources/channel#thread-member-object-thread-member-structure
public struct ThreadMember: Sendable, Codable {
    public var id: ChannelSnowflake?
    public var user_id: UserSnowflake?
    public var join_timestamp: DiscordTimestamp
    /// FIXME:
    /// The field is documented but doesn't say what exactly it is.
    /// Discord says: "any user-thread settings, currently only used for notifications".
    /// I think currently it's set to `1` or `0` depending on if you have notifications
    /// enabled for the thread?
    public var flags: Int
    
    public init(threadMemberUpdate: Gateway.ThreadMemberUpdate) {
        self.id = threadMemberUpdate.id
        self.user_id = threadMemberUpdate.user_id
        self.join_timestamp = threadMemberUpdate.join_timestamp
        self.flags = threadMemberUpdate.flags
    }
}

/// For a limited amount of endpoints which return the `member` object too.
/// https://discord.com/developers/docs/resources/channel#thread-member-object-thread-member-structure
public struct ThreadMemberWithMember: Sendable, Codable {
    public var id: ChannelSnowflake?
    public var user_id: UserSnowflake?
    public var join_timestamp: DiscordTimestamp
    /// FIXME:
    /// The field is documented but doesn't say what exactly it is.
    /// Discord says: "any user-thread settings, currently only used for notifications".
    /// I think currently it's set to `1` or `0` depending on if you have notifications
    /// enabled for the thread?
    public var flags: Int
    public var member: Guild.Member
}

/// Thread-related subset of `DiscordChannel.Kind`
/// https://discord.com/developers/docs/resources/channel#channel-object-channel-types
public enum ThreadKind: Int, Sendable, Codable {
    case announcementThread = 10
    case publicThread = 11
    case privateThread = 12
}

extension DiscordChannel {
    /// https://discord.com/developers/docs/resources/channel#allowed-mentions-object
    public struct AllowedMentions: Sendable, Codable {
        
        /// https://discord.com/developers/docs/resources/channel#allowed-mentions-object-allowed-mention-types
        public enum Kind: String, Sendable, Codable, ToleratesStringDecodeMarker {
            case roles
            case users
            case everyone
        }
        
        public var parse: [Kind]
        public var roles: [RoleSnowflake]
        public var users: [UserSnowflake]
        public var replied_user: Bool
    }
}

/// https://discord.com/developers/docs/resources/channel#embed-object
public struct Embed: Sendable, Codable, ValidatablePayload {
    
    /// https://discord.com/developers/docs/resources/channel#embed-object-embed-types
    public enum Kind: String, Sendable, Codable, ToleratesStringDecodeMarker {
        case rich = "rich"
        case image = "image"
        case video = "video"
        case gifv = "gifv"
        case article = "article"
        case link = "link"
        case autoModerationMessage = "auto_moderation_message"
    }
    
    public enum DynamicURL: Sendable, Codable, ExpressibleByStringLiteral {
        public typealias StringLiteralType = String
        
        case exact(String)
        case attachment(name: String)
        
        public var asString: String {
            switch self {
            case let .exact(exact):
                return exact
            case let .attachment(name):
                return "attachment://\(name)"
            }
        }
        
        public init(stringLiteral string: String) {
            if string.hasPrefix("attachment://") {
                self = .attachment(name: String(string.dropFirst(13)))
            } else {
                self = .exact(string)
            }
        }
        
        public init(from string: String) {
            if string.hasPrefix("attachment://") {
                self = .attachment(name: String(string.dropFirst(13)))
            } else {
                self = .exact(string)
            }
        }
        
        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            self = .init(from: string)
        }
        
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.asString)
        }
    }
    
    /// https://discord.com/developers/docs/resources/channel#embed-object-embed-footer-structure
    public struct Footer: Sendable, Codable {
        public var text: String
        public var icon_url: DynamicURL?
        public var proxy_icon_url: String?
        
        public init(text: String, icon_url: DynamicURL? = nil, proxy_icon_url: String? = nil) {
            self.text = text
            self.icon_url = icon_url
            self.proxy_icon_url = proxy_icon_url
        }
    }
    
    /// https://discord.com/developers/docs/resources/channel#embed-object-embed-image-structure
    public struct Media: Sendable, Codable {
        public var url: DynamicURL
        public var proxy_url: String?
        public var height: Int?
        public var width: Int?
        
        public init(url: DynamicURL, proxy_url: String? = nil, height: Int? = nil, width: Int? = nil) {
            self.url = url
            self.proxy_url = proxy_url
            self.height = height
            self.width = width
        }
    }
    
    /// https://discord.com/developers/docs/resources/channel#embed-object-embed-provider-structure
    public struct Provider: Sendable, Codable {
        public var name: String?
        public var url: String?
        
        public init(name: String? = nil, url: String? = nil) {
            self.name = name
            self.url = url
        }
    }
    
    /// https://discord.com/developers/docs/resources/channel#embed-object-embed-author-structure
    public struct Author: Sendable, Codable {
        public var name: String
        public var url: String?
        public var icon_url: DynamicURL?
        public var proxy_icon_url: String?
        
        public init(name: String, url: String? = nil, icon_url: DynamicURL? = nil, proxy_icon_url: String? = nil) {
            self.name = name
            self.url = url
            self.icon_url = icon_url
            self.proxy_icon_url = proxy_icon_url
        }
    }
    
    /// https://discord.com/developers/docs/resources/channel#embed-object-embed-field-structure
    public struct Field: Sendable, Codable {
        public var name: String
        public var value: String
        public var inline: Bool?
        
        public init(name: String, value: String, inline: Bool? = nil) {
            self.name = name
            self.value = value
            self.inline = inline
        }
    }
    
    public var title: String?
    public var type: Kind?
    public var description: String?
    public var url: String?
    public var timestamp: DiscordTimestamp?
    public var color: DiscordColor?
    public var footer: Footer?
    public var image: Media?
    public var thumbnail: Media?
    public var video: Media?
    public var provider: Provider?
    public var author: Author?
    public var fields: [Field]?

    /// The length that matters towards the Discord limit (currently 6000 across all embeds).
    public var contentLength: Int {
        let fields = fields?.reduce(into: 0) {
            $0 += $1.name.unicodeScalars.count + $1.value.unicodeScalars.count
        } ?? 0
        return (title?.unicodeScalars.count ?? 0) +
        (description?.unicodeScalars.count ?? 0) +
        fields +
        (footer?.text.unicodeScalars.count ?? 0) +
        (author?.name.unicodeScalars.count ?? 0)
    }
    
    public init(title: String? = nil, type: Embed.Kind? = nil, description: String? = nil, url: String? = nil, timestamp: Date? = nil, color: DiscordColor? = nil, footer: Embed.Footer? = nil, image: Embed.Media? = nil, thumbnail: Embed.Media? = nil, video: Embed.Media? = nil, provider: Embed.Provider? = nil, author: Embed.Author? = nil, fields: [Embed.Field]? = nil) {
        self.title = title
        self.type = type
        self.description = description
        self.url = url
        self.timestamp = timestamp.map { DiscordTimestamp(date: $0) }
        self.color = color
        self.footer = footer
        self.image = image
        self.thumbnail = thumbnail
        self.video = video
        self.provider = provider
        self.author = author
        self.fields = fields
    }
    
    public func validate() -> [ValidationFailure] {
        validateElementCountDoesNotExceed(fields, max: 25, name: "fields")
        validateCharacterCountDoesNotExceed(title, max: 256, name: "title")
        validateCharacterCountDoesNotExceed(description, max: 4_096, name: "description")
        validateCharacterCountDoesNotExceed(footer?.text, max: 2_048, name: "footer.text")
        validateCharacterCountDoesNotExceed(author?.name, max: 256, name: "author.name")
        for field in fields ?? [] {
            validateCharacterCountDoesNotExceed(field.name, max: 256, name: "field.name")
            validateCharacterCountDoesNotExceed(field.value, max: 1_024, name: "field.value")
        }
    }
}

/// https://discord.com/developers/docs/resources/channel#role-subscription-data-object-role-subscription-data-object-structure
public struct RoleSubscriptionData: Sendable, Codable {
    // FIXME: use `Snowflake<Type>` instead
    public var role_subscription_listing_id: AnySnowflake
    public var tier_name: String
    public var total_months_subscribed: Int
    public var is_renewal: Bool
}
