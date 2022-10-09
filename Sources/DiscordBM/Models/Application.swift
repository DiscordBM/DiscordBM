
/// https://discord.com/developers/docs/resources/application#application-object-application-structure
public struct PartialApplication: Sendable, Codable {
    
    public struct Team: Sendable, Codable {
        
        public struct Member: Sendable, Codable {
            
            public enum State: Int, Sendable, Codable {
                case invited = 1
                case accepted = 2
            }
            
            public var membership_state: State
            public var permissions: [String]
            public var team_id: String?
            public var user: PartialUser
        }
        
        public var icon: String?
        public var id: String
        public var members: [Member]
        public var name: String
        public var owner_user_id: String
    }
    
    public enum Flag: Int, Sendable {
        case gatewayPresence = 12
        case gatewayPresenceLimited = 13
        case gatewayGuildMembers = 14
        case gatewayGuildMembersLimited = 15
        case verificationPendingGuildLimit = 16
        case embedded = 17
        case gatewayMessageContent = 18
        case gatewayMessageContentLimited = 19
        case unknownFlag20 = 20
        case unknownFlag21 = 21
        case unknownFlag23 = 23
    }
    
    public struct InstallParams: Sendable, Codable {
        public var scopes: TolerantDecodeArray<OAuthScope>
        public var permissions: StringBitField<Channel.Permission>
    }
    
    public var id: String
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
    public var guild_id: String?
    public var primary_sku_id: String?
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

public struct SlashCommand: Sendable, Codable {
    
    public enum Kind: Int, Sendable, Codable {
        case chatInput = 1
        case user = 2
        case message = 3
    }
    
    public var name: String
    public var name_localizations: [String: String]?
    public var description: String
    public var description_localizations: [String: String]?
    public var options: [CommandOption]?
    public var dm_permission: Bool?
    public var default_member_permissions: StringBitField<Channel.Permission>?
    public var type: Kind?
    
    //MARK: Below fields are returned by Discord, and you don't need to send.
    /// deprecated
    var default_permission: Bool?
    public var id: String?
    public var application_id: String?
    public var guild_id: String?
    public var version: String?
    
    public init(name: String, name_localizations: [String : String]? = nil, description: String, description_localizations: [String : String]? = nil, options: [CommandOption]? = nil, dm_permission: Bool? = nil, default_member_permissions: [Channel.Permission]? = nil, type: Kind? = nil) {
        self.name = name
        self.name_localizations = name_localizations
        self.description = description
        self.description_localizations = description_localizations
        self.options = options
        self.dm_permission = dm_permission
        self.default_member_permissions = default_member_permissions.map { .init($0) }
        self.type = type
    }
}
