
/// https://discord.com/developers/docs/monetization/entitlements#entitlement-object-entitlement-structure
public struct Entitlement: Sendable, Codable {

    public enum Kind: Int, Sendable, Codable {
        case applicationSubscription = 8
    }

    public var id: EntitlementSnowflake
    public var sku_id: SKUSnowflake
    public var application_id: ApplicationSnowflake
    public var user_id: UserSnowflake?
    public var type: Kind
    public var deleted: Bool
    public var consumed: Bool
    public var starts_at: DiscordTimestamp?
    public var ends_at: DiscordTimestamp?
    public var guild_id: GuildSnowflake?
}
