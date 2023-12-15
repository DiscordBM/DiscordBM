
public struct SKU: Sendable, Codable {

    public enum Kind: Int, Sendable, Codable {
        case subscription = 5
        case subscriptionGroup = 6
    }

    public enum Flag: UInt, Sendable {
        case available = 2
        case guildSubscription = 7
        case userSubscription = 8
    }

    public var id: SKUSnowflake
    public var type: Kind
    public var application_id: ApplicationSnowflake
    public var name: String
    public var slug: String
    public var flags: IntBitField<Flag>
}
