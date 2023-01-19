
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
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.name = try container.decode(String.self, forKey: .name)
                let nameContainer = try container.decodeIfPresent(
                    DiscordLocaleCodableContainer.self,
                    forKey: .name_localizations
                )
                self.name_localizations = nameContainer?.toDictionary()
                self.value = try container.decode(StringIntDoubleBool.self, forKey: .value)
                self.name_localized = try container.decodeIfPresent(String.self, forKey: .name_localized)
            }
            
            public enum CodingKeys: CodingKey {
                case name
                case name_localizations
                case value
                case name_localized
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(self.name, forKey: .name)
                if let name_localizations = name_localizations {
                    let nameContainer = DiscordLocaleCodableContainer(name_localizations)
                    try container.encode(nameContainer, forKey: .name_localizations)
                }
                try container.encode(self.value, forKey: .value)
                try container.encodeIfPresent(self.name_localized, forKey: .name_localized)
            }
        }
        
        public var type: Kind
        public var name: String
        public var name_localizations: [DiscordLocale: String]?
        public var description: String
        public var description_localizations: [DiscordLocale: String]?
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
        
        public init(type: Kind, name: String, name_localizations: [DiscordLocale : String]? = nil, description: String, description_localizations: [DiscordLocale : String]? = nil, required: Bool? = nil, choices: [Choice]? = nil, options: [Option]? = nil, channel_types: [DiscordChannel.Kind]? = nil, min_value: IntOrDouble? = nil, max_value: IntOrDouble? = nil, autocomplete: Bool? = nil) {
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
        
        enum CodingKeys: CodingKey {
            case type
            case name
            case name_localizations
            case description
            case description_localizations
            case required
            case choices
            case options
            case channel_types
            case min_value
            case max_value
            case autocomplete
            case value
            case name_localized
            case description_localized
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = try container.decode(Kind.self, forKey: .type)
            self.name = try container.decode(String.self, forKey: .name)
            let nameContainer = try container.decodeIfPresent(
                DiscordLocaleCodableContainer.self,
                forKey: .name_localizations
            )
            self.name_localizations = nameContainer?.toDictionary()
            self.description = try container.decode(String.self, forKey: .description)
            let descriptionContainer = try container.decodeIfPresent(
                DiscordLocaleCodableContainer.self,
                forKey: .description_localizations
            )
            self.description_localizations = descriptionContainer?.toDictionary()
            self.required = try container.decodeIfPresent(Bool.self, forKey: .required)
            self.choices = try container.decodeIfPresent([Choice].self, forKey: .choices)
            self.options = try container.decodeIfPresent([Option].self, forKey: .options)
            self.channel_types = try container.decodeIfPresent([DiscordChannel.Kind].self, forKey: .channel_types)
            self.min_value = try container.decodeIfPresent(IntOrDouble.self, forKey: .min_value)
            self.max_value = try container.decodeIfPresent(IntOrDouble.self, forKey: .max_value)
            self.autocomplete = try container.decodeIfPresent(Bool.self, forKey: .autocomplete)
            self.value = try container.decodeIfPresent(StringIntDoubleBool.self, forKey: .value)
            self.name_localized = try container.decodeIfPresent(String.self, forKey: .name_localized)
            self.description_localized = try container.decodeIfPresent(String.self, forKey: .description_localized)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.type, forKey: .type)
            try container.encode(self.name, forKey: .name)
            if let name_localizations = name_localizations {
                let nameContainer = DiscordLocaleCodableContainer(name_localizations)
                try container.encode(nameContainer, forKey: .name_localizations)
            }
            try container.encode(self.description, forKey: .description)
            if let description_localizations = description_localizations {
                let descriptionContainer = DiscordLocaleCodableContainer(description_localizations)
                try container.encode(descriptionContainer, forKey: .description_localizations)
            }
            try container.encode(self.required, forKey: .required)
            try container.encode(self.choices, forKey: .choices)
            try container.encode(self.options, forKey: .options)
            try container.encode(self.channel_types, forKey: .channel_types)
            try container.encode(self.min_value, forKey: .min_value)
            try container.encode(self.max_value, forKey: .max_value)
            try container.encode(self.autocomplete, forKey: .autocomplete)
        }
    }
    
    public var name: String
    public var name_localizations: [DiscordLocale: String]?
    public var description: String
    public var description_localizations: [DiscordLocale: String]?
    public var options: [Option]?
    public var dm_permission: Bool?
    public var default_member_permissions: StringBitField<Permission>?
    public var nsfw: Bool?
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
    
    public init(name: String, name_localizations: [DiscordLocale: String]? = nil, description: String, description_localizations: [DiscordLocale: String]? = nil, options: [Option]? = nil, dm_permission: Bool? = nil, default_member_permissions: [Permission]? = nil, nsfw: Bool? = nil, type: Kind? = nil) {
        self.name = name
        self.name_localizations = name_localizations
        self.description = description
        self.description_localizations = description_localizations
        self.options = options
        self.dm_permission = dm_permission
        self.default_member_permissions = default_member_permissions.map { .init($0) }
        self.nsfw = nsfw
        self.type = type
    }
    
    enum CodingKeys: CodingKey {
        case name
        case name_localizations
        case description
        case description_localizations
        case options
        case dm_permission
        case default_member_permissions
        case nsfw
        case type
        case name_localized
        case description_localized
        case default_permission
        case id
        case application_id
        case guild_id
        case version
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        let nameContainer = try container.decodeIfPresent(
            DiscordLocaleCodableContainer.self,
            forKey: .name_localizations
        )
        self.name_localizations = nameContainer?.toDictionary()
        self.description = try container.decode(String.self, forKey: .description)
        let descriptionContainer = try container.decodeIfPresent(
            DiscordLocaleCodableContainer.self,
            forKey: .description_localizations
        )
        self.description_localizations = descriptionContainer?.toDictionary()
        self.options = try container.decodeIfPresent([Option].self, forKey: .options)
        self.dm_permission = try container.decodeIfPresent(Bool.self, forKey: .dm_permission)
        self.default_member_permissions = try container.decodeIfPresent(StringBitField<Permission>.self, forKey: .default_member_permissions)
        self.nsfw = try container.decodeIfPresent(Bool.self, forKey: .nsfw)
        self.type = try container.decodeIfPresent(Kind.self, forKey: .type)
        self.name_localized = try container.decodeIfPresent(String.self, forKey: .name_localized)
        self.description_localized = try container.decodeIfPresent(String.self, forKey: .description_localized)
        self.default_permission = try container.decodeIfPresent(Bool.self, forKey: .default_permission)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.application_id = try container.decodeIfPresent(String.self, forKey: .application_id)
        self.guild_id = try container.decodeIfPresent(String.self, forKey: .guild_id)
        self.version = try container.decodeIfPresent(String.self, forKey: .version)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        if let name_localizations = name_localizations {
            let nameContainer = DiscordLocaleCodableContainer(name_localizations)
            try container.encode(nameContainer, forKey: .name_localizations)
        }
        try container.encode(self.description, forKey: .description)
        if let description_localizations = description_localizations {
            let descriptionContainer = DiscordLocaleCodableContainer(description_localizations)
            try container.encode(descriptionContainer, forKey: .description_localizations)
        }
        try container.encodeIfPresent(self.options, forKey: .options)
        try container.encodeIfPresent(self.dm_permission, forKey: .dm_permission)
        try container.encodeIfPresent(self.default_member_permissions, forKey: .default_member_permissions)
        try container.encodeIfPresent(self.nsfw, forKey: .nsfw)
        try container.encodeIfPresent(self.type, forKey: .type)
    }
    
    public func validate() throws {
        try validateAssertIsNotEmpty(!name.isEmpty, name: "name")
        try validateAssertIsNotEmpty(!description.isEmpty, name: "description")
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
        try validateCharacterCountDoesNotExceed(name, max: 32, name: "name")
        try validateCharacterCountDoesNotExceed(description, max: 100, name: "description")
        for (_, value) in name_localizations ?? [:] {
            try validateAssertIsNotEmpty(!value.isEmpty, name: "name_localizations.name")
            try validateCharacterCountDoesNotExceed(value, max: 32, name: "name_localizations.name")
        }
        for (_, value) in description_localizations ?? [:] {
            try validateAssertIsNotEmpty(!value.isEmpty, name: "description_localizations.name")
            try validateCharacterCountDoesNotExceed(value, max: 32, name: "description_localizations.name")
        }
    }
}
