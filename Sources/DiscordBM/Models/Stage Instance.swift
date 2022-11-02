
/// https://discord.com/developers/docs/resources/stage-instance#stage-instance-object
public struct StageInstance: Sendable, Codable {
    
    /// https://discord.com/developers/docs/resources/stage-instance#stage-instance-object-privacy-level
    public enum PrivacyLevel: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case `public` = 1
        case guildOnly = 2
    }
    
    public var id: String
    public var guild_id: String
    public var channel_id: String
    public var topic: String
    public var privacy_level: PrivacyLevel
    public var discoverable_disabled: Bool
    public var guild_scheduled_event_id: String?
}
