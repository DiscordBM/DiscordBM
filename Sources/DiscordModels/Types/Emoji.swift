import Foundation

/// An Emoji with all fields marked as optional.
/// https://discord.com/developers/docs/resources/emoji#emoji-object
public struct PartialEmoji: Sendable, Codable {
    public var id: Snowflake<PartialEmoji>?
    public var name: String?
    public var roles: [Snowflake<Role>]?
    public var user: DiscordUser?
    public var require_colons: Bool?
    public var managed: Bool?
    public var animated: Bool?
    public var available: Bool?
    public var version: Int?
    
    public init(id: Snowflake<PartialEmoji>? = nil, name: String? = nil, roles: [Snowflake<Role>]? = nil, user: DiscordUser? = nil, require_colons: Bool? = nil, managed: Bool? = nil, animated: Bool? = nil, available: Bool? = nil, version: Int? = nil) {
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
public struct Reaction: Sendable, Hashable, Codable {
    
    private enum Base: Sendable, Codable, Hashable {
        case unicodeEmoji(String)
        case guildEmoji(name: String?, id: Snowflake<PartialEmoji>)
    }
    
    private let base: Base
    
    public var urlPathDescription: String {
        switch self.base {
        case let .unicodeEmoji(emoji): return emoji
        case let .guildEmoji(name, id): return "\(name ?? ""):\(id.value)"
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
    
    /// Read `helpAnchor` for help about each error case.
    public enum Error: LocalizedError {
        case moreThan1Emoji(String, count: Int)
        case notEmoji(String)
        case cantConvertPartialEmoji(PartialEmoji)
        
        public var errorDescription: String? {
            switch self {
            case let .moreThan1Emoji(input, count):
                return "moreThan1Emoji(\(input), count: \(count))"
            case let .notEmoji(input):
                return "notEmoji(\(input))"
            case let .cantConvertPartialEmoji(partialEmoji):
                return "cantConvertPartialEmoji(\(partialEmoji))"
            }
        }
        
        public var helpAnchor: String? {
            switch self {
            case let .moreThan1Emoji(input, count):
                return "Expected only 1 emoji in the input '\(input)' but recognized '\(count)' emojis"
            case let .notEmoji(input):
                return "The input '\(input)' does not seem like an emoji"
            case let .cantConvertPartialEmoji(partialEmoji):
                return "Can't convert a partial emoji to a Reaction. Emoji: \(partialEmoji)"
            }
        }
    }
    
    /// Unicode emoji. The function verifies that your input is an emoji or not.
    public static func unicodeEmoji(_ emoji: String) throws -> Reaction {
        guard emoji.count == 1 else {
            throw Error.moreThan1Emoji(emoji, count: emoji.unicodeScalars.count)
        }
        guard emoji.unicodeScalars.contains(where: \.properties.isEmoji) else {
            throw Error.notEmoji(emoji)
        }
        return Reaction(base: .unicodeEmoji(emoji))
    }
    
    /// Custom discord guild emoji.
    public static func guildEmoji(name: String?, id: Snowflake<PartialEmoji>) -> Reaction {
        Reaction(base: .guildEmoji(name: name, id: id))
    }
    
    public init(emoji: PartialEmoji) throws {
        if let id = emoji.id {
            self = .guildEmoji(name: emoji.name, id: id)
        } else if let name = emoji.name {
            self = try .unicodeEmoji(name)
        } else {
            throw Error.cantConvertPartialEmoji(emoji)
        }
    }
    
    /// Is the same as the partial emoji?
    public func `is`(_ emoji: PartialEmoji) -> Bool {
        switch self.base {
        case let .unicodeEmoji(unicode): return unicode == emoji.name
        case let .guildEmoji(_, id): return id == emoji.id
        }
    }
}
