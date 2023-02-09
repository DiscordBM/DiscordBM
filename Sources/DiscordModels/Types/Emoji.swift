
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

#warning("Swift 5.6 / 5.7 have different codable behaviors ?!")
public enum Reaction: Sendable, Equatable, Codable, ExpressibleByStringLiteral {
    case unicodeEmoji(String)
    case guildEmoji(name: String, id: String)
    
    public init(stringLiteral value: String) {
        self = .unicodeEmoji(value)
    }
    
    public var urlPathDescription: String {
        switch self {
        case let .unicodeEmoji(emoji): return emoji
        case let .guildEmoji(name, id): return "\(name):\(id)"
        }
    }
    
    public func `is`(_ emoji: PartialEmoji) -> Bool {
        switch self {
        case let .unicodeEmoji(unicode): return unicode == emoji.name
        case let .guildEmoji(_, id): return id == emoji.id
        }
    }
}
