import Foundation

/// https://discord.com/developers/docs/resources/channel#channel-object-channel-structure
public struct DiscordChannel: Sendable, Codable {
    
    /// https://discord.com/developers/docs/resources/channel#channel-object-channel-types
    public enum Kind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case guildText = 0
        case dm = 1
        case guildVoice = 2
        case groupDm = 3
        case guildCategory = 4
        case guildNews = 5
        case guildNewsThread = 10
        case guildPublicThread = 11
        case guildPrivateThread = 12
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
        
        public var id: String
        public var type: Kind
        public var allow: StringBitField<Permission>
        public var deny: StringBitField<Permission>
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
    
    public var id: String
    public var type: Kind
    public var guild_id: String?
    public var position: Int?
    public var permission_overwrites: [Overwrite]?
    public var name: String?
    public var topic: String?
    public var nsfw: Bool?
    public var last_message_id: String?
    public var bitrate: Int?
    public var user_limit: Int?
    public var rate_limit_per_user: Int?
    public var recipients: [DiscordUser]?
    public var icon: String?
    public var owner_id: String?
    public var application_id: String?
    public var parent_id: String?
    public var last_pin_timestamp: DiscordTimestamp?
    public var rtc_region: String?
    public var video_quality_mode: VideoQualityMode?
    public var message_count: Int?
    public var total_message_sent: Int?
    public var member_count: Int?
    public var thread_metadata: ThreadMetadata?
    public var member: ThreadMember?
    public var default_auto_archive_duration: Int?
    public var default_thread_rate_limit_per_user: Int?
    public var default_reaction_emoji: String?
    public var default_sort_order: String?
    public var permissions: StringBitField<Permission>?
    public var flags: IntBitField<Flag>?
    public var available_tags: [String]?
    public var template: String?
    public var member_ids_preview: [String]?
    public var version: Int?
    public var guild_hashes: Hashes?
    public var hashes: Hashes?
}

extension DiscordChannel {
    /// https://discord.com/developers/docs/resources/channel#message-object
    public struct Message: Sendable, Codable {
        
        /// https://discord.com/developers/docs/resources/channel#message-reference-object-message-reference-structure
        public struct MessageReference: Sendable, Codable {
            public var message_id: String?
            public var channel_id: String?
            public var guild_id: String?
            public var fail_if_not_exists: Bool?
            
            public init(message_id: String? = nil, channel_id: String? = nil, guild_id: String? = nil, fail_if_not_exists: Bool? = nil) {
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
            case unknownValue10 = 10
        }
        
        /// https://discord.com/developers/docs/resources/channel#channel-mention-object
        public struct ChannelMention: Sendable, Codable {
            public var id: String
            public var guild_id: String
            public var type: DiscordChannel.Kind
            public var name: String
        }
        
        /// https://discord.com/developers/docs/resources/channel#attachment-object
        public struct Attachment: Sendable, Codable {
            public var id: String
            public var filename: String
            public var description: String?
            public var content_type: String?
            public var size: Int
            public var url: String
            public var proxy_url: String
            public var height: Int?
            public var width: Int?
            public var ephemeral: Bool?
        }
        
        /// https://discord.com/developers/docs/resources/channel#reaction-object
        public struct Reaction: Sendable, Codable {
            public var count: Int
            public var me: Bool
            public var emoji: PartialEmoji
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
            public var party_id: String?
        }
        
        /// A ``DiscordUser`` with an extra `member` field.
        /// https://discord.com/developers/docs/resources/user#user-object-user-structure
        public struct MentionUser: Sendable, Codable {
            public var id: String
            public var username: String
            public var discriminator: String
            public var avatar: String?
            public var bot: Bool?
            public var system: Bool?
            public var mfa_enabled: Bool?
            public var banner: String?
            public var accent_color: DiscordColor?
            public var locale: DiscordLocale?
            public var verified: Bool?
            public var email: String?
            public var flags: IntBitField<DiscordUser.Flag>?
            public var premium_type: DiscordUser.PremiumKind?
            public var public_flags: IntBitField<DiscordUser.Flag>?
            public var avatar_decoration: String?
            public var bio: String?
            public var banner_color: DiscordColor?
            public var member: Guild.Member?
        }
        
        public var id: String
        public var channel_id: String
        public var guild_id: String?
        public var author: PartialUser?
        public var member: Guild.PartialMember?
        public var content: String
        public var timestamp: DiscordTimestamp
        public var edited_timestamp: DiscordTimestamp?
        public var tts: Bool
        public var mention_everyone: Bool
        public var mentions: [MentionUser]
        public var mention_roles: [String]
        public var mention_channels: [ChannelMention]?
        public var attachments: [Attachment]
        public var embeds: [Embed]
        public var reactions: [Reaction]?
        public var nonce: StringOrInt?
        public var pinned: Bool
        public var webhook_id: String?
        public var type: Kind
        public var activity: Activity?
        public var application: PartialApplication?
        public var application_id: String?
        public var message_reference: MessageReference?
        public var flags: IntBitField<Flag>?
        public var referenced_message: DereferenceBox<Message>?
        public var interaction: MessageInteraction?
        public var thread: DiscordChannel?
        public var components: [Interaction.ActionRow]?
        public var sticker_items: [StickerItem]?
        public var stickers: [Sticker]?
        public var position: Int?
    }
}

extension DiscordChannel {
    /// An attachment object, but for sending.
    /// https://discord.com/developers/docs/resources/channel#attachment-object
    public struct AttachmentSend: Sendable, Codable, Validatable {
        /// When sending, `id` is the index of this attachment in the `files` you provide.
        public var id: String
        public var filename: String?
        public var description: String?
        public var content_type: String?
        public var size: Int?
        public var url: String?
        public var proxy_url: String?
        public var height: Int?
        public var width: Int?
        public var ephemeral: Bool?
        
        /// `index` is the index of this attachment in the `files` you provide.
        public init(index: UInt, filename: String? = nil, description: String? = nil, content_type: String? = nil, size: Int? = nil, url: String? = nil, proxy_url: String? = nil, height: Int? = nil, width: Int? = nil, ephemeral: Bool? = nil) {
            self.id = "\(index)"
            self.filename = filename
            self.description = description
            self.content_type = content_type
            self.size = size
            self.url = url
            self.proxy_url = proxy_url
            self.height = height
            self.width = width
            self.ephemeral = ephemeral
        }
        
        public func validate() throws {
            try validateCharacterCountDoesNotExceed(description, max: 1_024, name: "description")
        }
    }
}

extension DiscordChannel {
    /// Partial ``Channel.Message`` object.
    public struct PartialMessage: Sendable, Codable {
        public var id: String
        public var channel_id: String
        public var author: PartialUser?
        public var content: String?
        public var timestamp: DiscordTimestamp?
        public var edited_timestamp: DiscordTimestamp?
        public var tts: Bool?
        public var mention_everyone: Bool?
        public var mentions: [Message.MentionUser]?
        public var mention_roles: [String]?
        public var mention_channels: [DiscordChannel.Message.ChannelMention]?
        public var attachments: [DiscordChannel.Message.Attachment]?
        public var embeds: [Embed]?
        public var reactions: [DiscordChannel.Message.Reaction]?
        public var nonce: StringOrInt?
        public var pinned: Bool?
        public var webhook_id: String?
        public var type: DiscordChannel.Message.Kind?
        public var activity: DiscordChannel.Message.Activity?
        public var application: PartialApplication?
        public var application_id: String?
        public var message_reference: DiscordChannel.Message.MessageReference?
        public var flags: IntBitField<DiscordChannel.Message.Flag>?
        public var referenced_message: DereferenceBox<PartialMessage>?
        public var interaction: MessageInteraction?
        public var thread: DiscordChannel?
        public var components: [Interaction.ActionRow]?
        public var sticker_items: [StickerItem]?
        public var stickers: [Sticker]?
        public var position: Int?
        public var member: Guild.Member?
        public var guild_id: String?
    }
}

/// https://discord.com/developers/docs/resources/channel#thread-metadata-object
public struct ThreadMetadata: Sendable, Codable {
    public var archived: Bool
    public var auto_archive_duration: Int
    public var archive_timestamp: DiscordTimestamp
    public var locked: Bool
    public var invitable: Bool?
    public var create_timestamp: DiscordTimestamp?
}

/// https://discord.com/developers/docs/resources/channel#thread-member-object-thread-member-structure
public struct ThreadMember: Sendable, Codable {
    public var id: String
    public var user_id: String?
    public var join_timestamp: DiscordTimestamp
    /// FIXME:
    /// The field is documented but doesn't say what exactly it is.
    /// Discord says: "any user-thread settings, currently only used for notifications".
    public var flags: Int
    public var mute_config: String?
    public var muted: Bool?
}

/// https://discord.com/developers/docs/resources/channel#channel-object-channel-structure
public struct PartialChannel: Sendable, Codable {
    public var id: String
    public var type: DiscordChannel.Kind
    public var name: String?
    public var permissions: StringBitField<Permission>?
    public var parent_id: String?
    public var thread_metadata: ThreadMetadata?
}

extension DiscordChannel {
    /// https://discord.com/developers/docs/resources/channel#allowed-mentions-object
    public struct AllowedMentions: Sendable, Codable, Validatable {
        
        /// https://discord.com/developers/docs/resources/channel#allowed-mentions-object-allowed-mention-types
        public enum Kind: String, Sendable, Codable, ToleratesStringDecodeMarker {
            case roles
            case users
            case everyone
        }
        
        public var parse: [Kind]
        public var roles: [String]
        public var users: [String]
        public var replied_user: Bool
        
        public init(parse: [Kind], roles: [String], users: [String], replied_user: Bool) {
            self.parse = parse
            self.roles = roles
            self.users = users
            self.replied_user = replied_user
        }
        
        public func validate() throws {
            try validateElementCountDoesNotExceed(roles, max: 100, name: "roles")
            try validateElementCountDoesNotExceed(users, max: 100, name: "users")
        }
    }
}

/// https://discord.com/developers/docs/resources/channel#embed-object
public struct Embed: Sendable, Codable, Validatable {
    
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
    
    public enum DynamicURL: Sendable, Codable {
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
        
        public init(from string: String) {
            if string.hasPrefix("attachment://") {
                self = .attachment(name: String(string.dropFirst(13)))
            } else {
                self = .exact(string)
            }
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            self = .init(from: string)
        }
        
        public func encode(to encoder: Encoder) throws {
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
    public var timestamp: TolerantDecodeDate? = nil
    public var color: DiscordColor?
    public var footer: Footer?
    public var image: Media?
    public var thumbnail: Media?
    public var video: Media?
    public var provider: Provider?
    public var author: Author?
    public var fields: [Field]?
    public var reference_id: String?
    
    public init(title: String? = nil, type: Embed.Kind? = nil, description: String? = nil, url: String? = nil, timestamp: Date? = nil, color: DiscordColor? = nil, footer: Embed.Footer? = nil, image: Embed.Media? = nil, thumbnail: Embed.Media? = nil, video: Embed.Media? = nil, provider: Embed.Provider? = nil, author: Embed.Author? = nil, fields: [Embed.Field]? = nil, reference_id: String? = nil) {
        self.title = title
        self.type = type
        self.description = description
        self.url = url
        self.timestamp = timestamp == nil ? nil : .init(date: timestamp!)
        self.color = color
        self.footer = footer
        self.image = image
        self.thumbnail = thumbnail
        self.video = video
        self.provider = provider
        self.author = author
        self.fields = fields
        self.reference_id = reference_id
    }
    
    /// The length that matters towards the Discord limit (currently 6000 across all embeds).
    var contentLength: Int {
        let fields = fields?.reduce(into: 0) {
            $0 = $1.name.unicodeScalars.count + $1.value.unicodeScalars.count
        } ?? 0
        return (title?.unicodeScalars.count ?? 0) +
        (description?.unicodeScalars.count ?? 0) +
        fields +
        (footer?.text.unicodeScalars.count ?? 0) +
        (author?.name.unicodeScalars.count ?? 0)
    }
    
    public func validate() throws {
        try validateElementCountDoesNotExceed(fields, max: 25, name: "fields")
        try validateCharacterCountDoesNotExceed(title, max: 256, name: "title")
        try validateCharacterCountDoesNotExceed(description, max: 4_096, name: "description")
        try validateCharacterCountDoesNotExceed(footer?.text, max: 2_048, name: "footer.text")
        try validateCharacterCountDoesNotExceed(author?.name, max: 256, name: "author.name")
        for field in fields ?? [] {
            try validateCharacterCountDoesNotExceed(field.name, max: 256, name: "field.name")
            try validateCharacterCountDoesNotExceed(field.value, max: 1_024, name: "field.value")
        }
    }
}
