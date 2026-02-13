public enum Responses {

    /// https://docs.discord.com/developers/resources/emoji#list-application-emojis
    public struct ListApplicationEmojis: Sendable, Codable {
        public var items: [Emoji]
    }

    /// https://docs.discord.com/developers/resources/channel#list-public-archived-threads-response-body
    public struct ListArchivedThreads: Sendable, Codable {
        public var threads: [DiscordChannel]
        public var members: [ThreadMember]
        public var has_more: Bool
    }

    /// https://docs.discord.com/developers/resources/guild#list-active-guild-threads-response-body
    public struct ListActiveGuildThreads: Sendable, Codable {
        public var threads: [DiscordChannel]
        public var members: [ThreadMember]
    }

    /// https://docs.discord.com/developers/resources/message#get-channel-pins
    public struct ListMessagePins: Sendable, Codable {
        public var items: [DiscordChannel.Message.Pin]
        public var has_more: Bool
    }

    /// https://docs.discord.com/developers/resources/sticker#list-nitro-sticker-packs-response-structure
    public struct ListStickerPacks: Sendable, Codable {
        public var sticker_packs: [StickerPack]
    }

    /// https://docs.discord.com/developers/resources/guild#get-guild-prune-count
    public struct GuildPrune: Sendable, Codable {
        public var pruned: Int
    }

    /// https://docs.discord.com/developers/resources/guild#bulk-guild-ban-bulk-ban-response
    public struct GuildBulkBan: Sendable, Codable {
        public var banned_users: [UserSnowflake]
        public var failed_users: [UserSnowflake]
    }

    /// https://docs.discord.com/developers/resources/channel#start-thread-in-forum-or-media-channel
    public struct ChannelWithMessage: Sendable, Codable {
        public var channel: DiscordChannel
        public var message: DiscordChannel.Message

        private enum MessageCodingKeys: String, CodingKey {
            case message
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.channel = try container.decode(DiscordChannel.self)
            let messageContainer = try decoder.container(keyedBy: MessageCodingKeys.self)
            self.message = try messageContainer.decode(DiscordChannel.Message.self, forKey: .message)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.channel)
            var messageContainer = encoder.container(keyedBy: MessageCodingKeys.self)
            try messageContainer.encode(self.message, forKey: .message)
        }
    }

    /// https://docs.discord.com/developers/resources/poll#get-answer-voters-response-body
    public struct ListPollAnswerVoters: Sendable, Codable {
        public var users: [DiscordUser]
    }

    /// https://docs.discord.com/developers/resources/soundboard#list-guild-soundboard-sounds
    public struct ListGuildSoundboardSounds: Sendable, Codable {
        public var items: [SoundboardSound]
    }

    /// https://docs.discord.com/developers/resources/invite#get-target-users-job-status
    public struct GetTargetUsersJobStatus: Sendable, Codable {

        /// https://docs.discord.com/developers/resources/invite#get-target-users-job-status
        @UnstableEnum<_Int_CompatibilityTypealias>
        public enum Status: Sendable, Codable {
            case unspecified  // 0
            case processing  // 1
            case completed  // 2
            case failed  // 3
            case __undocumented(_Int_CompatibilityTypealias)
        }

        public var status: Status
        public var total_users: Int?
        public var processed_users: Int?
        public var created_at: DiscordTimestamp?
        public var completed_at: DiscordTimestamp?
        public var error_message: String?
    }
}
