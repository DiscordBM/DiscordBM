
/// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-structure
public struct Interaction: Sendable, Codable {
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-type
    public enum Kind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case ping = 1
        case applicationCommand = 2
        case messageComponent = 3
        case applicationCommandAutocomplete = 4
        case modalSubmit = 5
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-data
    public enum Data: Sendable {
        case messageComponent(MessageComponentData)
        case applicationCommand(ApplicationCommandData)
        case modalSubmit(ModalSubmitData)
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-modal-submit-data-structure
    public struct ModalSubmitData: Sendable, Codable {
        public var customID: String
        public var components: [ActionRow.Component]

        enum CodingKeys: String, CodingKey {
            case customID = "custom_id"
            case components = "components"
        }
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-message-component-data-structure
    public struct MessageComponentData: Sendable, Codable {
        public var customID: String
        public var componentType: ActionRow.Kind
        public var values: [StringOrInt]?

        enum CodingKeys: String, CodingKey {
            case customID = "custom_id"
            case componentType = "component_type"
            case values = "values"
        }
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-application-command-data-structure
    public struct ApplicationCommandData: Sendable, Codable {
        
        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-resolved-data-structure
        public struct ResolvedData: Sendable, Codable {
            public var users: [String: DiscordUser]?
            public var members: [String: Guild.PartialMember]?
            public var roles: [String: Role]?
            public var channels: [String: PartialChannel]?
            public var messages: [String: DiscordChannel.PartialMessage]?
            public var attachments: [String: DiscordChannel.Message.Attachment]?
        }
        
        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-application-command-interaction-data-option-structure
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
            
            public var name: String
            public var type: Kind
            public var value: StringIntDoubleBool?
            public var options: [Option]?
            public var focused: Bool?
        }
        
        public var id: String
        public var name: String
        public var type: Kind
        public var resolved: ResolvedData?
        public var options: [Option]?
        public var guild_id: String?
        public var target_id: String?
    }
    
    public var id: String
    public var application_id: String
    public var type: Kind
    public var data: Data?
    public var guild_id: String?
    public var channel_id: String?
    public var member: Guild.Member?
    public var user: DiscordUser?
    public var token: String
    public var version: Int
    public var message: DiscordChannel.Message?
    public var locale: DiscordLocale?
    public var guild_locale: DiscordLocale?
    public var app_permissions: StringBitField<Permission>?
    public var entitlement_sku_ids: [String]?

    enum CodingKeys: CodingKey {
        case id
        case application_id
        case type
        case data
        case guild_id
        case channel_id
        case member
        case user
        case token
        case version
        case message
        case locale
        case guild_locale
        case app_permissions
        case entitlement_sku_ids
    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<Interaction.CodingKeys> = try decoder.container(keyedBy: Interaction.CodingKeys.self)

        self.id = try container.decode(String.self, forKey: Interaction.CodingKeys.id)
        self.application_id = try container.decode(String.self, forKey: Interaction.CodingKeys.application_id)
        self.type = try container.decode(Interaction.Kind.self, forKey: Interaction.CodingKeys.type)
        switch self.type {
        case .applicationCommand, .applicationCommandAutocomplete: 
            self.data = .applicationCommand(try container.decode(Interaction.ApplicationCommandData.self, forKey: Interaction.CodingKeys.data))
        case .messageComponent: 
            self.data = .messageComponent(try container.decode(Interaction.MessageComponentData.self, forKey: Interaction.CodingKeys.data))
        case .modalSubmit:
            self.data = .modalSubmit(try container.decode(Interaction.ModalSubmitData.self, forKey: Interaction.CodingKeys.data))
        case .ping:
            self.data = nil
        }
        self.guild_id = try container.decodeIfPresent(String.self, forKey: Interaction.CodingKeys.guild_id)
        self.channel_id = try container.decodeIfPresent(String.self, forKey: Interaction.CodingKeys.channel_id)
        self.member = try container.decodeIfPresent(Guild.Member.self, forKey: Interaction.CodingKeys.member)
        self.user = try container.decodeIfPresent(DiscordUser.self, forKey: Interaction.CodingKeys.user)
        self.token = try container.decode(String.self, forKey: Interaction.CodingKeys.token)
        self.version = try container.decode(Int.self, forKey: Interaction.CodingKeys.version)
        self.message = try container.decodeIfPresent(DiscordChannel.Message.self, forKey: Interaction.CodingKeys.message)
        self.locale = try container.decodeIfPresent(DiscordLocale.self, forKey: Interaction.CodingKeys.locale)
        self.guild_locale = try container.decodeIfPresent(DiscordLocale.self, forKey: Interaction.CodingKeys.guild_locale)
        self.app_permissions = try container.decodeIfPresent(StringBitField<Permission>.self, forKey: Interaction.CodingKeys.app_permissions)
        self.entitlement_sku_ids = try container.decodeIfPresent([String].self, forKey: Interaction.CodingKeys.entitlement_sku_ids)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Interaction.CodingKeys.self)

        try container.encode(self.id, forKey: Interaction.CodingKeys.id)
        try container.encode(self.application_id, forKey: Interaction.CodingKeys.application_id)
        try container.encode(self.type, forKey: Interaction.CodingKeys.type)
        switch self.data {
        case .applicationCommand(let cmd):
            try container.encode(cmd, forKey: Interaction.CodingKeys.data)
        case .messageComponent(let msgc):
            try container.encode(msgc, forKey: Interaction.CodingKeys.data)
        case .modalSubmit(let modals):
            try container.encode(modals, forKey: Interaction.CodingKeys.data)
        default:
            ()
        }
        try container.encodeIfPresent(self.guild_id, forKey: Interaction.CodingKeys.guild_id)
        try container.encodeIfPresent(self.channel_id, forKey: Interaction.CodingKeys.channel_id)
        try container.encodeIfPresent(self.member, forKey: Interaction.CodingKeys.member)
        try container.encodeIfPresent(self.user, forKey: Interaction.CodingKeys.user)
        try container.encode(self.token, forKey: Interaction.CodingKeys.token)
        try container.encode(self.version, forKey: Interaction.CodingKeys.version)
        try container.encodeIfPresent(self.message, forKey: Interaction.CodingKeys.message)
        try container.encodeIfPresent(self.locale, forKey: Interaction.CodingKeys.locale)
        try container.encodeIfPresent(self.guild_locale, forKey: Interaction.CodingKeys.guild_locale)
        try container.encodeIfPresent(self.app_permissions, forKey: Interaction.CodingKeys.app_permissions)
        try container.encodeIfPresent(self.entitlement_sku_ids, forKey: Interaction.CodingKeys.entitlement_sku_ids)
    }
}

/// https://discord.com/developers/docs/interactions/receiving-and-responding#message-interaction-object-message-interaction-structure
public struct MessageInteraction: Sendable, Codable {
    public var id: String
    public var type: Interaction.Kind
    public var name: String
    public var user: DiscordUser
    public var member: Guild.PartialMember?
}

extension Interaction {
    /// https://discord.com/developers/docs/interactions/message-components#action-rows
    public struct ActionRow: Sendable, Codable {
        
        /// https://discord.com/developers/docs/interactions/message-components#component-object-component-types
        public enum Kind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
            case actionRow = 1
            case button = 2
            case stringSelect = 3
            case textInput = 4
            case userSelect = 5
            case roleSelect = 6
            case mentionableSelect = 7
            case channelSelect = 8
        }
        
        /// https://discord.com/developers/docs/interactions/message-components#button-object-button-structure
        public struct Button: Sendable, Codable {
            
            /// https://discord.com/developers/docs/interactions/message-components#button-object-button-styles
            public enum Style: Int, Sendable, Codable, ToleratesIntDecodeMarker {
                case primary = 1
                case secondary = 2
                case success = 3
                case danger = 4
                case link = 5
            }
            
            public var style: Style?
            public var label: String?
            public var emoji: PartialEmoji?
            public var custom_id: String?
            public var url: String?
            public var disabled: Bool?
            
            public init(style: Style? = nil, label: String? = nil, emoji: PartialEmoji? = nil, custom_id: String? = nil, url: String? = nil, disabled: Bool? = nil) {
                self.style = style
                self.label = label
                self.emoji = emoji
                self.custom_id = custom_id
                self.url = url
                self.disabled = disabled
            }
        }
        
        /// https://discord.com/developers/docs/interactions/message-components#select-menu-object-select-menu-structure
        public struct SelectMenu: Sendable, Codable {
            
        /// https://discord.com/developers/docs/interactions/message-components#select-menu-object-select-option-structure
            public struct Option: Sendable, Codable {
                public var label: String
                public var value: String
                public var description: String?
                public var emoji: PartialEmoji?
                public var `default`: Bool?
                
                public init(label: String, value: String, description: String? = nil, emoji: PartialEmoji? = nil, `default`: Bool? = nil) {
                    self.label = label
                    self.value = value
                    self.description = description
                    self.emoji = emoji
                    self.`default` = `default`
                }
            }
            
            public var custom_id: String
            public var options: [Option]
            public var placeholder: String?
            public var min_values: Int?
            public var max_values: Int?
            public var disabled: Bool?
            
            public init(custom_id: String, options: [Option], placeholder: String? = nil, min_values: Int? = nil, max_values: Int? = nil, disabled: Bool? = nil) {
                self.custom_id = custom_id
                self.options = options
                self.placeholder = placeholder
                self.min_values = min_values
                self.max_values = max_values
                self.disabled = disabled
            }
        }
        
        /// https://discord.com/developers/docs/interactions/message-components#text-inputs
        public struct TextInput: Sendable, Codable {
            
        /// https://discord.com/developers/docs/interactions/message-components#text-inputs-text-input-styles
            public enum Style: Int, Sendable, Codable, ToleratesIntDecodeMarker {
                case short = 1
                case paragraph = 2
            }
            
            public var custom_id: String
            public var style: Style
            public var label: String
            public var min_length: Int?
            public var max_length: Int?
            public var required: Bool?
            public var value: String?
            public var placeholder: String?
            
            public init(custom_id: String, style: Interaction.ActionRow.TextInput.Style, label: String, min_length: Int? = nil, max_length: Int? = nil, required: Bool? = nil, value: String? = nil, placeholder: String? = nil) {
                self.custom_id = custom_id
                self.style = style
                self.label = label
                self.min_length = min_length
                self.max_length = max_length
                self.required = required
                self.value = value
                self.placeholder = placeholder
            }
        }
        
        public enum Component: Sendable, Codable {
            case button(Button)
            case stringSelect(SelectMenu)
            case textInput(TextInput)
            case userSelect(SelectMenu)
            case roleSelect(SelectMenu)
            case mentionableSelect(SelectMenu)
            case channelSelect(SelectMenu)
            
            enum CodingKeys: String, CodingKey {
                case type
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(Kind.self, forKey: .type)
                switch type {
                case .actionRow:
                    throw CodingError.actionRowIsSupposedToOnlyAppearAtTopLevel
                case .button:
                    self = try .button(.init(from: decoder))
                case .stringSelect, .userSelect, .roleSelect, .mentionableSelect, .channelSelect:
                    self = try .stringSelect(.init(from: decoder))
                case .textInput:
                    self = try .textInput(.init(from: decoder))
                }
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                switch self {
                case let .button(button):
                    try container.encode(Kind.button, forKey: .type)
                    try button.encode(to: encoder)
                case let .stringSelect(selectMenu):
                    try container.encode(Kind.stringSelect, forKey: .type)
                    try selectMenu.encode(to: encoder)
                case let .textInput(textInput):
                    try container.encode(Kind.textInput, forKey: .type)
                    try textInput.encode(to: encoder)
                case let .userSelect(selectMenu):
                    try container.encode(Kind.userSelect, forKey: .type)
                    try selectMenu.encode(to: encoder)
                case let .roleSelect(selectMenu):
                    try container.encode(Kind.roleSelect, forKey: .type)
                    try selectMenu.encode(to: encoder)
                case let .mentionableSelect(selectMenu):
                    try container.encode(Kind.mentionableSelect, forKey: .type)
                    try selectMenu.encode(to: encoder)
                case let .channelSelect(selectMenu):
                    try container.encode(Kind.channelSelect, forKey: .type)
                    try selectMenu.encode(to: encoder)
                }
            }
        }
        
        public var components: [Component]
        
        enum CodingError: Error {
            case unexpectedComponentKind(Kind)
            case actionRowIsSupposedToOnlyAppearAtTopLevel
        }
        
        enum CodingKeys: String, CodingKey {
            case type
            case components
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(Kind.self, forKey: .type)
            guard type == .actionRow else {
                throw CodingError.unexpectedComponentKind(type)
            }
            self.components = try container.decode([Component].self, forKey: .components)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(Kind.actionRow, forKey: .type)
            try container.encode(self.components, forKey: .components)
        }
        
        public init(components: [Component]) {
            self.components = components
        }
    }
}
