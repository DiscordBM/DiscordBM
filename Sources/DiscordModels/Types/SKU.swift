/// https://discord.com/developers/docs/monetization/skus#sku-object-sku-structure
public struct SKU: Sendable, Codable {

    /// https://discord.com/developers/docs/monetization/skus#sku-object-sku-types
    @UnstableEnum<_Int_CompatibilityTypealias>
    public enum Kind: Sendable, Codable {
        case durable  // 2
        case consumable  // 3
        case subscription  // 5
        case subscriptionGroup  // 6
        case __undocumented(_Int_CompatibilityTypealias)
    }

    /// https://discord.com/developers/docs/monetization/skus#sku-object-sku-flags
    @UnstableEnum<_UInt_CompatibilityTypealias>
    public enum Flag: Sendable {
        case available  // 2
        case guildSubscription  // 7
        case userSubscription  // 8
        case __undocumented(_UInt_CompatibilityTypealias)
    }

    public var id: SKUSnowflake
    public var type: Kind
    public var application_id: ApplicationSnowflake
    public var name: String
    public var slug: String
    public var flags: IntBitField<Flag>
}
