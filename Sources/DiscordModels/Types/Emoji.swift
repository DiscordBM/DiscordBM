
/// An Emoji with all fields marked as optional.
/// https://discord.com/developers/docs/resources/emoji#emoji-object
public struct PartialEmoji: Sendable, Codable {
    public var id: String?
    public var name: String?
    public var roles: [String]?
    public var user: DiscordUser?
    public var require_colons: Bool?
    public var managed: Bool?
    public var animated: Bool?
    public var available: Bool?
    public var version: Int?
    
    public init(id: String? = nil, name: String? = nil, roles: [String]? = nil, user: DiscordUser? = nil, require_colons: Bool? = nil, managed: Bool? = nil, animated: Bool? = nil, available: Bool? = nil, version: Int? = nil) {
        self.id = id
        self.name = name
        self.roles = roles
        self.user = user
        self.require_colons = require_colons
        self.managed = managed
        self.animated = animated
        self.available = available
        self.version = version
    }
}

/// A reaction emoji.
public struct Reaction: Sendable, Equatable, Codable {
    
    private enum Base: Sendable, Codable, Equatable {
        case unicodeEmoji(String)
        case guildEmoji(name: String, id: String)
    }
    
    private let base: Base
    
    public var urlPathDescription: String {
        switch self.base {
        case let .unicodeEmoji(emoji): return emoji
        case let .guildEmoji(name, id): return "\(name):\(id)"
        }
    }
    
    private init(base: Base) {
        self.base = base
    }
    
    public init(from decoder: Decoder) throws {
        self.base = try .init(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        try self.base.encode(to: encoder)
    }
    
    public enum Error: Swift.Error {
        case emojiScalarsCountIsNot1(String, count: Int)
        case scalarIsNotEmoji(Unicode.Scalar)
    }
    
    /// Unicode emoji. The function verifies that your input is an emoji or not.
    public static func unicodeEmoji(_ emoji: Unicode.Scalar) throws -> Reaction {
        guard emoji.properties.isEmoji else {
            throw Error.scalarIsNotEmoji(emoji)
        }
        return Reaction(base: .unicodeEmoji(.init(emoji)))
    }
    
    /// Unicode emoji. The function verifies that your input is an emoji or not.
    public static func unicodeEmoji(_ emoji: String) throws -> Reaction {
        let scalars = emoji.unicodeScalars
        guard scalars.count == 1 else {
            throw Error.emojiScalarsCountIsNot1(emoji, count: emoji.unicodeScalars.count)
        }
        return try .unicodeEmoji(scalars.first!)
    }
    
    /// Custom discord guild emoji.
    public static func guildEmoji(name: String, id: String) -> Reaction {
        Reaction(base: .guildEmoji(name: name, id: id))
    }
    
    /// Is the same as the partial emoji?
    public func `is`(_ emoji: PartialEmoji) -> Bool {
        switch self.base {
        case let .unicodeEmoji(unicode): return unicode == emoji.name
        case let .guildEmoji(_, id): return id == emoji.id
        }
    }
}
