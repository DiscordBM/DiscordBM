
/// https://discord.com/developers/docs/topics/permissions#role-object
public struct Role: Sendable, Codable {
    
    /// https://discord.com/developers/docs/topics/permissions#role-object-role-tags-structure
    public struct Tags: Sendable, Codable {
        public var bot_id: String?
        public var integration_id: String?
        public var premium_subscriber: Bool?
    }
    
    public var id: String
    public var name: String
    public var color: DiscordColor
    public var hoist: Bool
    public var icon: String?
    public var unicode_emoji: String?
    public var position: Int
    public var permissions: StringBitField<Channel.Permission>
    public var managed: Bool
    public var mentionable: Bool
    public var flags: IntBitField<User.Flag>? // FIXME not sure about `User.Flag`
    public var tags: Tags?
    public var version: Int?
    public var guild_hashes: Hashes?
    public var hashes: Hashes?
}
