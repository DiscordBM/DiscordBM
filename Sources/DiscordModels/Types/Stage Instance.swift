
/// https://discord.com/developers/docs/resources/stage-instance#stage-instance-object
public struct StageInstance: Sendable, Codable {
    
    /// https://discord.com/developers/docs/resources/stage-instance#stage-instance-object-privacy-level
#if swift(>=5.9) && $Macros
    @UnstableEnum<Int>
    public enum PrivacyLevel: Sendable, Codable {
        case `public` // 1
        case guildOnly // 2
    }
#else
    public enum PrivacyLevel: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case `public` = 1
        case guildOnly = 2
    }
#endif

    public var id: StageInstanceSnowflake
    public var guild_id: GuildSnowflake
    public var channel_id: ChannelSnowflake
    public var topic: String
    public var privacy_level: PrivacyLevel
    public var discoverable_disabled: Bool
    public var guild_scheduled_event_id: GuildScheduledEventSnowflake?
}
