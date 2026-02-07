/// https://discord.com/developers/docs/resources/soundboard#soundboard-sound-object
public struct SoundboardSound: Sendable, Codable {
    public var name: String
    public var sound_id: SoundboardSoundSnowflake
    public var volume: Double
    public var emoji_id: EmojiSnowflake?
    public var emoji_name: String?
    public var guild_id: GuildSnowflake?
    public var available: Bool
    public var user: DiscordUser?
}
