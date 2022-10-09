
/// An Emoji with all fields marked as optional. AKA partial Emoji.
/// https://discord.com/developers/docs/resources/emoji#emoji-object
public struct Emoji: Sendable, Codable {
    public var id: String?
    public var name: String?
    public var roles: [String]?
    public var user: User?
    public var require_colons: Bool?
    public var managed: Bool?
    public var animated: Bool?
    public var available: Bool?
    public var version: Int?
    public var guild_hashes: Hashes?
    public var hashes: Hashes?
}
