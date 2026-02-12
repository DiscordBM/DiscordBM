/// https://docs.discord.com/developers/resources/stage-instance#stage-instance-object
public struct StageInstance: Sendable, Codable {

    /// https://docs.discord.com/developers/resources/stage-instance#stage-instance-object-privacy-level
    @UnstableEnum<_Int_CompatibilityTypealias>
    public enum PrivacyLevel: Sendable, Codable {
        case `public`  // 1
        case guildOnly  // 2
        case __undocumented(_Int_CompatibilityTypealias)
    }

    public var id: StageInstanceSnowflake
    public var guild_id: GuildSnowflake
    public var channel_id: ChannelSnowflake
    public var topic: String
    public var privacy_level: PrivacyLevel
    public var discoverable_disabled: Bool
    public var guild_scheduled_event_id: GuildScheduledEventSnowflake?
}
