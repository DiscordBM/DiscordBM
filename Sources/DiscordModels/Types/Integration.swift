
/// https://discord.com/developers/docs/resources/guild#integration-object
public struct Integration: Sendable, Codable {
    
    /// https://discord.com/developers/docs/resources/guild#integration-object-integration-structure
    public enum Kind: String, Sendable, Codable, ToleratesStringDecodeMarker {
        case twitch
        case youtube
        case discord
    }
    
    /// https://discord.com/developers/docs/resources/guild#integration-object-integration-expire-behaviors
    public enum ExpireBehavior: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case removeRole = 0
        case kick = 1
    }
    
    public var id: String
    public var name: String
    public var type: Kind
    public var enabled: Bool
    public var syncing: Bool?
    public var role_id: String?
    public var enable_emoticons: Bool?
    public var expire_behavior: ExpireBehavior?
    public var expire_grace_period: Int?
    public var user: DiscordUser?
    public var account: IntegrationAccount
    public var synced_at: DiscordTimestamp?
    public var subscriber_count: Int?
    public var revoked: Bool?
    public var application: IntegrationApplication?
    public var scopes: [OAuth2Scope]?
}

/// https://discord.com/developers/docs/resources/guild#integration-object
public struct PartialIntegration: Sendable, Codable {
    public var id: String
    public var name: String?
    public var type: Integration.Kind?
    public var enabled: Bool?
    public var syncing: Bool?
    public var role_id: String?
    public var enable_emoticons: Bool?
    public var expire_behavior: Integration.ExpireBehavior?
    public var expire_grace_period: Int?
    public var user: DiscordUser?
    public var account: IntegrationAccount?
    public var synced_at: DiscordTimestamp?
    public var subscriber_count: Int?
    public var revoked: Bool?
    public var application: IntegrationApplication?
    public var scopes: [OAuth2Scope]?
}
