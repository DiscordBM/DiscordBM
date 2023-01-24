
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
    public var guild_hashes: Hashes?
    public var hashes: Hashes?
    
    public init(id: String? = nil, name: String? = nil, roles: [String]? = nil, user: DiscordUser? = nil, require_colons: Bool? = nil, managed: Bool? = nil, animated: Bool? = nil, available: Bool? = nil, version: Int? = nil, guild_hashes: Hashes? = nil, hashes: Hashes? = nil) {
        self.id = id
        self.name = name
        self.roles = roles
        self.user = user
        self.require_colons = require_colons
        self.managed = managed
        self.animated = animated
        self.available = available
        self.version = version
        self.guild_hashes = guild_hashes
        self.hashes = hashes
    }
}
