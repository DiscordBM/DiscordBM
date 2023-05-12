
public enum Responses {
    
    /// https://discord.com/developers/docs/resources/channel#list-public-archived-threads-response-body
    public struct ArchivedThread: Sendable, Codable {
        public var threads: [DiscordChannel]
        public var members: [ThreadMember]
        public var has_more: Bool
    }

    /// https://discord.com/developers/docs/resources/guild#list-active-guild-threads-response-body
    public struct ListActiveGuildThreads: Sendable, Codable {
        public var threads: [DiscordChannel]
        public var members: [ThreadMember]
    }

    /// https://discord.com/developers/docs/resources/sticker#list-nitro-sticker-packs-response-structure
    public struct ListStickerPacks: Sendable, Codable {
        public var sticker_packs: [StickerPack]
    }
}
