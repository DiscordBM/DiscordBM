
/// https://discord.com/developers/docs/resources/guild-template#guild-template-object-guild-template-structure
public struct GuildTemplate: Codable, Sendable {
    public var code: String
    public var name: String
    public var description: String?
    public var usage_count: Int
    public var creator_id: UserSnowflake
    public var creator: DiscordUser
    public var created_at: DiscordTimestamp
    public var updated_at: DiscordTimestamp
    public var source_guild_id: GuildSnowflake
    public var serialized_source_guild: PartialGuild
    public var is_dirty: Bool?
}
