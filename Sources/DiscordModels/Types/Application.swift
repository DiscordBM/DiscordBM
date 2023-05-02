
/// https://discord.com/developers/docs/resources/application#application-object-application-structure
public struct PartialApplication: Sendable, Codable {
    
    /// https://discord.com/developers/docs/resources/application#application-object-application-flags
    public enum Flag: Int, Sendable {
        case applicationAutoModerationRuleCreateBadge = 6
        case gatewayPresence = 12
        case gatewayPresenceLimited = 13
        case gatewayGuildMembers = 14
        case gatewayGuildMembersLimited = 15
        case verificationPendingGuildLimit = 16
        case embedded = 17
        case gatewayMessageContent = 18
        case gatewayMessageContentLimited = 19
        case applicationCommandBadge = 23
    }
    
    /// https://discord.com/developers/docs/resources/application#install-params-object
    public struct InstallParams: Sendable, Codable {
        public var scopes: [OAuth2Scope]
        public var permissions: StringBitField<Permission>
    }
    
    public var id: ApplicationSnowflake
    public var name: String?
    public var icon: String?
    public var description: String?
    public var rpc_origins: [String]?
    public var bot_public: Bool?
    public var bot_require_code_grant: Bool?
    public var terms_of_service_url: String?
    public var privacy_policy_url: String?
    public var owner: PartialUser?
    public var verify_key: String?
    public var team: Team?
    public var guild_id: GuildSnowflake?
    public var primary_sku_id: AnySnowflake?
    public var slug: String?
    public var cover_image: String?
    public var flags: IntBitField<Flag>?
    public var tags: [String]?
    public var install_params: InstallParams?
    public var custom_install_url: String?
    public var summary: String?
    public var type: Int?
    public var max_participants: Int?
    public var hook: Bool?
}
