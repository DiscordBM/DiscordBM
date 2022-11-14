
/// https://discord.com/developers/docs/resources/application#application-object-application-structure
public struct PartialApplication: Sendable, Codable {
    
    /// https://discord.com/developers/docs/resources/application#application-object-application-flags
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
        case applicationCommandBadge = 23
        case unknownFlag24 = 24
    }
    
    /// https://discord.com/developers/docs/resources/application#install-params-object
    public struct InstallParams: Sendable, Codable {
        public var scopes: [OAuth2Scope]
        public var permissions: StringBitField<Permission>
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

/// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-structure
public struct ApplicationCommand: Sendable, Codable, Validatable {
    
    /// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-types
    public enum Kind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case chatInput = 1
        case user = 2
        case message = 3
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-structure
    public struct Option: Sendable, Codable {
        
    /// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-type
        public enum Kind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
            case subCommand = 1
            case subCommandGroup = 2
            case string = 3
            case integer = 4
            case boolean = 5
            case user = 6
            case channel = 7
            case role = 8
            case mentionable = 9
            case number = 10
            case attachment = 11
        }
        
        /// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-choice-structure
        public struct Choice: Sendable, Codable {
            
            public var name: String
            public var name_localizations: [DiscordLocale: String]?
            public var value: StringIntDoubleBool
            
            public var name_localized: String?
            
            public init(name: String, name_localizations: [DiscordLocale : String]? = nil, value: StringIntDoubleBool) {
                self.name = name
                self.name_localizations = name_localizations
                self.value = value
            }
        }
        
        public var type: Kind
        public var name: String
        public var name_localizations: [String: String]?
        public var description: String
        public var description_localizations: [String: String]?
        public var required: Bool?
        public var choices: [Choice]?
        public var options: [Option]?
        public var channel_types: [DiscordChannel.Kind]?
        public var min_value: IntOrDouble?
        public var max_value: IntOrDouble?
        public var autocomplete: Bool?
        
        /// Available after decode when user has inputted a value for the option.
        public var value: StringIntDoubleBool?
        public var name_localized: String?
        public var description_localized: String?
        
        public init(type: Kind, name: String, name_localizations: [String : String]? = nil, description: String, description_localizations: [String : String]? = nil, required: Bool? = nil, choices: [Choice]? = nil, options: [Option]? = nil, channel_types: [DiscordChannel.Kind]? = nil, min_value: IntOrDouble? = nil, max_value: IntOrDouble? = nil, autocomplete: Bool? = nil) {
            self.type = type
            self.name = name
            self.name_localizations = name_localizations
            self.description = description
            self.description_localizations = description_localizations
            self.required = required
            self.choices = choices
            self.options = options
            self.channel_types = channel_types == nil ? nil : .init(channel_types!)
            self.min_value = min_value
            self.max_value = max_value
            self.autocomplete = autocomplete
        }
    }
    
    public var name: String
    public var name_localizations: [DiscordLocale: String]?
    public var description: String
    public var description_localizations: [DiscordLocale: String]?
    public var options: [Option]?
    public var dm_permission: Bool?
    public var default_member_permissions: StringBitField<Permission>?
    public var type: Kind?
    
    //MARK: Below fields are only returned by Discord, and you don't need to send.
    public var name_localized: String?
    public var description_localized: String?
    /// Deprecated
    var default_permission: Bool?
    public var id: String?
    public var application_id: String?
    public var guild_id: String?
    public var version: String?
    
    public init(name: String, name_localizations: [DiscordLocale: String]? = nil, description: String, description_localizations: [DiscordLocale: String]? = nil, options: [Option]? = nil, dm_permission: Bool? = nil, default_member_permissions: [Permission]? = nil, type: Kind? = nil) {
        self.name = name
        self.name_localizations = name_localizations
        self.description = description
        self.description_localizations = description_localizations
        self.options = options
        self.dm_permission = dm_permission
        self.default_member_permissions = default_member_permissions.map { .init($0) }
        self.type = type
    }
    
    public func validate() throws {
        try validateHasPrecondition(
            condition: options?.isEmpty == false,
            allowedIf: (type ?? .chatInput) == .chatInput,
            name: "options",
            reason: "'options' is only allowed if 'type' is 'chatInput'"
        )
        try validateHasPrecondition(
            condition: !description.isEmpty || description_localizations?.isEmpty == false,
            allowedIf: (type ?? .chatInput) == .chatInput,
            name: "description+description_localizations",
            reason: "'description' or 'description_localizations' are only allowed if 'type' is 'chatInput'"
        )
        try validateElementCountDoesNotExceed(options, max: 25, name: "options")
        try validateAssertIsNotEmpty(!name.isEmpty, name: "name")
        try validateCharacterCountDoesNotExceed(name, max: 32, name: "name")
        for (_, value) in name_localizations ?? [:] {
            try validateAssertIsNotEmpty(!value.isEmpty, name: "name_localizations.name")
            try validateCharacterCountDoesNotExceed(value, max: 32, name: "name_localizations.name")
        }
        try validateAssertIsNotEmpty(!description.isEmpty, name: "description")
        try validateCharacterCountDoesNotExceed(description, max: 32, name: "description")
        for (_, value) in description_localizations ?? [:] {
            try validateAssertIsNotEmpty(!value.isEmpty, name: "description_localizations.name")
            try validateCharacterCountDoesNotExceed(value, max: 32, name: "description_localizations.name")
        }
    }
}
