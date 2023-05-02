
/// https://discord.com/developers/docs/resources/sticker#sticker-object-sticker-structure
public struct Sticker: Sendable, Codable {
    
    /// https://discord.com/developers/docs/resources/sticker#sticker-object-sticker-types
    public enum Kind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case standard = 1
        case guild = 2
    }
    
    /// https://discord.com/developers/docs/resources/sticker#sticker-object-sticker-format-types
    public enum FormatKind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case png = 1
        case apng = 2
        case lottie = 3
    }
    
    public var id: StickerSnowflake
    public var pack_id: StickerPackSnowflake?
    public var name: String
    public var description: String?
    public var tags: String
    public var asset: String?
    public var type: Kind
    public var format_type: FormatKind
    public var available: Bool?
    public var guild_id: GuildSnowflake?
    public var user: DiscordUser?
    public var sort_value: Int?
    public var version: Int?
}

/// https://discord.com/developers/docs/resources/sticker#sticker-item-object
public struct StickerItem: Sendable, Codable {
    public var id: StickerSnowflake
    public var name: String
    public var format_type: Sticker.FormatKind
}

/// https://discord.com/developers/docs/resources/sticker#sticker-pack-object-sticker-pack-structure
/// To be implemented
public struct StickerPack: Sendable, Codable { }
