
/// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object
public struct GuildScheduledEvent: Sendable, Codable {
    
    /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-privacy-level
    public enum PrivacyLevel: Int, Sendable, Codable, ToleratesIntDecode {
        case guildOnly = 2
    }
    
    /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-status
    public enum Status: Int, Sendable, Codable, ToleratesIntDecode {
        case scheduled = 1
        case active = 2
        case completed = 3
        case canceled = 4
    }
    
    /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-entity-types
    public enum EntityKind: Int, Sendable, Codable, ToleratesIntDecode {
        case stageInstance = 1
        case voice = 2
        case external = 3
    }
    
    /// https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-entity-metadata
    public struct EntityMetadata: Sendable, Codable {
        public var location: String?
    }
    
    public var id: String
    public var guild_id: String
    public var channel_id: String?
    public var creator_id: String?
    public var name: String
    public var description: String?
    public var scheduled_start_time: DiscordTimestamp
    public var scheduled_end_time: DiscordTimestamp?
    public var privacy_level: PrivacyLevel
    public var status: Status
    public var entity_type: EntityKind
    public var entity_id: String?
    public var entity_metadata: EntityMetadata?
    public var creator: DiscordUser?
    public var user_count: Int?
    public var image: String?
    public var sku_ids: [String]?
}
