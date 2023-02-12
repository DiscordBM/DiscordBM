
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
        case messageComponent(MessageComponent)
        case applicationCommand(ApplicationCommand)
        case modalSubmit(ModalSubmit)
        
        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-application-command-data-structure
        public struct ApplicationCommand: Sendable, Codable {
            
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
        
        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-message-component-data-structure
        public struct MessageComponent: Sendable, Codable {
            public var custom_id: String
            public var component_type: ActionRow.Kind
            public var values: [String]?
        }
        
        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-modal-submit-data-structure
        public struct ModalSubmit: Sendable, Codable {
            public var custom_id: String
            public var components: [ActionRow.Component]
        }
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
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.application_id = try container.decode(String.self, forKey: .application_id)
        self.type = try container.decode(Interaction.Kind.self, forKey: .type)
        switch self.type {
        case .applicationCommand, .applicationCommandAutocomplete: 
            self.data = .applicationCommand(
                try container.decode(Data.ApplicationCommand.self, forKey: .data)
            )
        case .messageComponent: 
            self.data = .messageComponent(
                try container.decode(Data.MessageComponent.self, forKey: .data)
            )
        case .modalSubmit:
            self.data = .modalSubmit(
                try container.decode(Data.ModalSubmit.self, forKey: .data)
            )
        case .ping:
            self.data = nil
        }
        self.guild_id = try container.decodeIfPresent(String.self, forKey: .guild_id)
        self.channel_id = try container.decodeIfPresent(String.self, forKey: .channel_id)
        self.member = try container.decodeIfPresent(Guild.Member.self, forKey: .member)
        self.user = try container.decodeIfPresent(DiscordUser.self, forKey: .user)
        self.token = try container.decode(String.self, forKey: .token)
        self.version = try container.decode(Int.self, forKey: .version)
        self.message = try container.decodeIfPresent(DiscordChannel.Message.self, forKey: .message)
        self.locale = try container.decodeIfPresent(DiscordLocale.self, forKey: .locale)
        self.guild_locale = try container.decodeIfPresent(DiscordLocale.self, forKey: .guild_locale)
        self.app_permissions = try container.decodeIfPresent(
            StringBitField<Permission>.self,
            forKey: .app_permissions
        )
        self.entitlement_sku_ids = try container.decodeIfPresent(
            [String].self,
            forKey: .entitlement_sku_ids
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.application_id, forKey: .application_id)
        try container.encode(self.type, forKey: .type)
        switch self.data {
        case .applicationCommand(let command):
            try container.encode(command, forKey: .data)
        case .messageComponent(let component):
            try container.encode(component, forKey: .data)
        case .modalSubmit(let modal):
            try container.encode(modal, forKey: .data)
        case .none: break
        }
        try container.encodeIfPresent(self.guild_id, forKey: .guild_id)
        try container.encodeIfPresent(self.channel_id, forKey: .channel_id)
        try container.encodeIfPresent(self.member, forKey: .member)
        try container.encodeIfPresent(self.user, forKey: .user)
        try container.encode(self.token, forKey: .token)
        try container.encode(self.version, forKey: .version)
        try container.encodeIfPresent(self.message, forKey: .message)
        try container.encodeIfPresent(self.locale, forKey: .locale)
        try container.encodeIfPresent(self.guild_locale, forKey: .guild_locale)
        try container.encodeIfPresent(self.app_permissions, forKey: .app_permissions)
        try container.encodeIfPresent(self.entitlement_sku_ids, forKey: .entitlement_sku_ids)
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
