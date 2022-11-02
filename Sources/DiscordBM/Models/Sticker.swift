
/// https://discord.com/developers/docs/resources/sticker#sticker-object-sticker-structure
public struct Sticker: Sendable, Codable {
    
    /// https://discord.com/developers/docs/resources/sticker#sticker-object-sticker-types
    public enum Kind: Int, Sendable, Codable, ToleratesIntDecode {
        case standard = 1
        case guild = 2
    }
    
    /// https://discord.com/developers/docs/resources/sticker#sticker-object-sticker-format-types
    public enum FormatKind: Int, Sendable, Codable, ToleratesIntDecode {
        case png = 1
        case apng = 2
        case lottie = 3
    }
    
    public var id: String
    public var pack_id: String?
    public var name: String
    public var description: String?
    public var tags: String
    public var asset: String?
    public var type: Kind
    public var format_type: FormatKind
    public var available: Bool?
    public var guild_id: String?
    public var user: DiscordUser?
    public var sort_value: Int?
    public var version: Int?
}

/// https://discord.com/developers/docs/resources/sticker#sticker-item-object
public struct StickerItem: Sendable, Codable {
    public var id: String
    public var name: String
    public var format_type: Sticker.FormatKind
}
