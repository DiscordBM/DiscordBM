
/// https://discord.com/developers/docs/resources/user#user-object-user-structure
public struct DiscordUser: Sendable, Codable {
    
    /// https://discord.com/developers/docs/resources/user#user-object-premium-types
    public enum PremiumKind: Int, Sendable, Codable {
        case none = 0
        case nitroClassic = 1
        case nitro = 2
    }
    
    /// https://discord.com/developers/docs/resources/user#user-object-user-structure
    public enum Flag: Int, Sendable {
        case staff = 0
        case partner = 1
        case hypeSquad = 2
        case BugHunterLevel1 = 3
        case hypeSquadOnlineHouse1 = 6
        case hypeSquadOnlineHouse2 = 7
        case hypeSquadOnlineHouse3 = 8
        case premiumEarlySupporter = 9
        case teamPseudoUser = 10
        case bugHunterLevel2 = 14
        case verifiedBot = 16
        case verifiedDeveloper = 17
        case certifiedModerator = 18
        case botHttpInteractions = 19
        case unknownValue20 = 20
    }
    
    public var id: String
    public var username: String
    public var discriminator: String
    public var avatar: String?
    public var bot: Bool?
    public var system: Bool?
    public var mfa_enabled: Bool?
    public var banner: String?
    public var accent_color: DiscordColor?
    public var locale: DiscordLocale?
    public var verified: Bool?
    public var email: String?
    public var flags: IntBitField<Flag>?
    public var premium_type: PremiumKind?
    public var public_flags: IntBitField<Flag>?
    public var avatar_decoration: String?
}

/// A partial ``User`` object.
/// https://discord.com/developers/docs/resources/user#user-object-user-structure
public struct PartialUser: Sendable, Codable {
    public var id: String
    public var username: String?
    public var discriminator: String?
    public var avatar: String?
    public var bot: Bool?
    public var system: Bool?
    public var mfa_enabled: Bool?
    public var banner: String?
    public var accent_color: DiscordColor?
    public var locale: DiscordLocale?
    public var verified: Bool?
    public var email: String?
    public var flags: IntBitField<DiscordUser.Flag>?
    public var premium_type: DiscordUser.PremiumKind?
    public var public_flags: IntBitField<DiscordUser.Flag>?
    public var avatar_decoration: String?
}
