import Foundation

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
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-application-command-data-structure
    public struct ApplicationCommand: Sendable, Codable {
        
        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-resolved-data-structure
        public struct ResolvedData: Sendable, Codable {

            /// https://discord.com/developers/docs/resources/channel#channel-object-channel-structure
            /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-resolved-data-structure
            public struct PartialChannel: Sendable, Codable {
                public var id: ChannelSnowflake
                public var type: DiscordChannel.Kind
                public var name: String?
                public var permissions: StringBitField<Permission>?
                public var parent_id: AnySnowflake?
                public var thread_metadata: ThreadMetadata?
            }

            public var users: [UserSnowflake: DiscordUser]?
            public var members: [UserSnowflake: Guild.PartialMember]?
            public var roles: [RoleSnowflake: Role]?
            public var channels: [ChannelSnowflake: PartialChannel]?
            public var messages: [MessageSnowflake: DiscordChannel.PartialMessage]?
            public var attachments: [AttachmentSnowflake: DiscordChannel.Message.Attachment]?

            enum CodingKeys: CodingKey {
                case users
                case members
                case roles
                case channels
                case messages
                case attachments
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)

                /// `JSONDecoder` has a special-case decoding for dictionaries of `[String: some Decodable]`.
                /// We need to trigger that special-case, so we need to first decode the values
                /// to keys of `String`, then transform that `String` to the actual `Key` type.
                func decode<K, V>(forKey key: CodingKeys) throws -> [K: V]?
                where K: SnowflakeProtocol, V: Decodable {
                    let decoded = try container.decodeIfPresent([String: V].self, forKey: key)
                    let transformed = decoded?.map { key, value -> (K, V) in
                        return (K(key), value)
                    }
                    return transformed.map { .init(uniqueKeysWithValues: $0) }
                }

                self.users = try decode(forKey: .users)
                self.members = try decode(forKey: .members)
                self.roles = try decode(forKey: .roles)
                self.channels = try decode(forKey: .channels)
                self.messages = try decode(forKey: .messages)
                self.attachments = try decode(forKey: .attachments)
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                /// `JSONEncoder` has a special-case encoding for dictionaries of `[String: some Encodable]`.
                /// We need to trigger that special-case, so we need to encode the values
                /// with keys of type `String`.
                func encode<K, E>(_ dict: [K: E]?, forKey key: CodingKeys) throws
                where K: SnowflakeProtocol, E: Encodable {
                    let transformed = dict?.map { key, value -> (String, E) in
                        return (key.value, value)
                    }
                    let stringDict: [String: E]? = transformed.map { .init(uniqueKeysWithValues: $0) }
                    try container.encode(stringDict, forKey: key)
                }

                try encode(self.users, forKey: .users)
                try encode(self.members, forKey: .members)
                try encode(self.roles, forKey: .roles)
                try encode(self.channels, forKey: .channels)
                try encode(self.messages, forKey: .messages)
                try encode(self.attachments, forKey: .attachments)
            }
        }
        
        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-application-command-interaction-data-option-structure
        public struct Option: Sendable, Codable {
            public var name: String
            public var type: DiscordModels.ApplicationCommand.Option.Kind
            public var value: StringIntDoubleBool?
            public var options: [Option]?
            public var focused: Bool?
        }
        
        public var id: CommandSnowflake
        public var name: String
        public var type: Kind
        public var resolved: ResolvedData?
        public var options: [Option]?
        public var guild_id: GuildSnowflake?
        public var target_id: AnySnowflake?
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
        public var components: [ActionRow]
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-data
    public enum Data: Sendable {
        case applicationCommand(ApplicationCommand)
        case messageComponent(MessageComponent)
        case modalSubmit(ModalSubmit)
    }
    
    public var id: InteractionSnowflake
    public var application_id: ApplicationSnowflake
    public var type: Kind
    public var data: Data?
    public var guild_id: GuildSnowflake?
    public var channel_id: ChannelSnowflake?
    public var channel: DiscordChannel?
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
        case channel
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
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(InteractionSnowflake.self, forKey: .id)
        self.application_id = try container.decode(
            ApplicationSnowflake.self,
            forKey: .application_id
        )
        self.type = try container.decode(Interaction.Kind.self, forKey: .type)
        switch self.type {
        case .applicationCommand, .applicationCommandAutocomplete: 
            self.data = .applicationCommand(
                try container.decode(ApplicationCommand.self, forKey: .data)
            )
        case .messageComponent: 
            self.data = .messageComponent(
                try container.decode(MessageComponent.self, forKey: .data)
            )
        case .modalSubmit:
            self.data = .modalSubmit(
                try container.decode(ModalSubmit.self, forKey: .data)
            )
        case .ping:
            self.data = nil
        }
        self.guild_id = try container.decodeIfPresent(GuildSnowflake.self, forKey: .guild_id)
        self.channel_id = try container.decodeIfPresent(
            ChannelSnowflake.self,
            forKey: .channel_id
        )
        self.channel = try container.decodeIfPresent(DiscordChannel.self, forKey: .channel)
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
    /// `ActionRow` is an attempt to simplify/beautify Discord's messy components.
    /// Anything inside `ActionRow` must not be used on its own for decoding/encoding purposes.
    /// For example you always need to use `[ActionRow]` instead of `[ActionRow.Component]`.
    public struct ActionRow: Sendable, Codable, ExpressibleByArrayLiteral {
        
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

            /// The same as ``Style``, but has no `link`.
            /// https://discord.com/developers/docs/interactions/message-components#button-object-button-styles
            public enum NonLinkStyle: Sendable {
                case primary
                case secondary
                case success
                case danger

                public func toStyle() -> Style {
                    switch self {
                    case .primary: return .primary
                    case .secondary: return .secondary
                    case .success: return .success
                    case .danger: return .danger
                    }
                }

                public init? (style: Style) {
                    switch style {
                    case .primary: self = .primary
                    case .secondary: self = .secondary
                    case .success: self = .success
                    case .danger: self = .danger
                    case .link: return nil
                    }
                }
            }

            public var style: Style
            public var label: String?
            public var emoji: Emoji?
            public var custom_id: String?
            public var url: String?
            public var disabled: Bool?

            /// Makes a non-link button.
            /// At least one of `label` and `emoji` is required.
            public init(style: NonLinkStyle, label: String? = nil, emoji: Emoji? = nil, custom_id: String, disabled: Bool? = nil) {
                self.style = style.toStyle()
                self.label = label
                self.emoji = emoji
                self.custom_id = custom_id
                self.disabled = disabled
            }

            /// Makes a link button.
            /// At least one of `label` and `emoji` is required.
            public init(label: String? = nil, emoji: Emoji? = nil, url: String, disabled: Bool? = nil) {
                self.style = .link
                self.label = label
                self.emoji = emoji
                self.url = url
                self.disabled = disabled
            }
        }
        
        /// https://discord.com/developers/docs/interactions/message-components#select-menu-object-select-menu-structure
        public struct StringSelectMenu: Sendable, Codable {
            
        /// https://discord.com/developers/docs/interactions/message-components#select-menu-object-select-option-structure
            public struct Option: Sendable, Codable {
                public var label: String
                public var value: String
                public var description: String?
                public var emoji: Emoji?
                public var `default`: Bool?
                
                public init(label: String, value: String, description: String? = nil, emoji: Emoji? = nil, `default`: Bool? = nil) {
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

        /// https://discord.com/developers/docs/interactions/message-components#select-menu-object-select-menu-structure
        public struct ChannelSelectMenu: Sendable, Codable {
            public var custom_id: String
            public var channel_types: [DiscordChannel.Kind]?
            public var placeholder: String?
            public var min_values: Int?
            public var max_values: Int?
            public var disabled: Bool?

            public init(custom_id: String, channel_types: [DiscordChannel.Kind]? = nil, placeholder: String? = nil, min_values: Int? = nil, max_values: Int? = nil, disabled: Bool? = nil) {
                self.custom_id = custom_id
                self.channel_types = channel_types
                self.placeholder = placeholder
                self.min_values = min_values
                self.max_values = max_values
                self.disabled = disabled
            }
        }

        /// https://discord.com/developers/docs/interactions/message-components#select-menu-object-select-menu-structure
        public struct SelectMenu: Sendable, Codable {
            public var custom_id: String
            public var placeholder: String?
            public var min_values: Int?
            public var max_values: Int?
            public var disabled: Bool?

            public init(custom_id: String, placeholder: String? = nil, min_values: Int? = nil, max_values: Int? = nil, disabled: Bool? = nil) {
                self.custom_id = custom_id
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
            public var style: Style?
            public var label: String?
            public var min_length: Int?
            public var max_length: Int?
            public var required: Bool?
            public var value: String?
            public var placeholder: String?

            public init(custom_id: String, style: Style? = nil, label: String? = nil, min_length: Int? = nil, max_length: Int? = nil, required: Bool? = nil, value: String? = nil, placeholder: String? = nil) {
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
            case stringSelect(StringSelectMenu)
            case textInput(TextInput)
            case userSelect(SelectMenu)
            case roleSelect(SelectMenu)
            case mentionableSelect(SelectMenu)
            case channelSelect(ChannelSelectMenu)

            public var customId: String? {
                switch self {
                case let .button(value):
                    return value.custom_id
                case let .stringSelect(value):
                    return value.custom_id
                case let .textInput(value):
                    return value.custom_id
                case let .userSelect(value):
                    return value.custom_id
                case let .roleSelect(value):
                    return value.custom_id
                case let .mentionableSelect(value):
                    return value.custom_id
                case let .channelSelect(value):
                    return value.custom_id
                }
            }

            enum CodingKeys: String, CodingKey {
                case type
            }
            
            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(Kind.self, forKey: .type)
                switch type {
                case .actionRow:
                    throw CodingError.actionRowIsSupposedToOnlyAppearAtTopLevel
                case .button:
                    self = try .button(.init(from: decoder))
                case .stringSelect:
                    self = try .stringSelect(.init(from: decoder))
                case .userSelect:
                    self = try .userSelect(.init(from: decoder))
                case .roleSelect:
                    self = try .roleSelect(.init(from: decoder))
                case .mentionableSelect:
                    self = try .mentionableSelect(.init(from: decoder))
                case .channelSelect:
                    self = try .channelSelect(.init(from: decoder))
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
        
        /// Read `helpAnchor` for help about each error case.
        public enum CodingError: LocalizedError, CustomStringConvertible {
            case unexpectedComponentKind(Kind)
            case actionRowIsSupposedToOnlyAppearAtTopLevel

            public var description: String {
                switch self {
                case let .unexpectedComponentKind(kind):
                    return "Interaction.ActionRow.CodingError.unexpectedComponentKind(\(kind))"
                case .actionRowIsSupposedToOnlyAppearAtTopLevel:
                    return "Interaction.ActionRow.CodingError.actionRowIsSupposedToOnlyAppearAtTopLevel"
                }
            }

            public var errorDescription: String? {
                self.description
            }
            
            public var helpAnchor: String? {
                switch self {
                case let .unexpectedComponentKind(kind):
                    return "This component kind was not expected here. This is a library decoding issue, please report at: https://github.com/MahdiBM/DiscordBM/issues. Kind: \(kind)"
                case .actionRowIsSupposedToOnlyAppearAtTopLevel:
                    return "I thought action-row is supposed to only appear at top-level as a container for other components. This is a library decoding issue, please report at: https://github.com/MahdiBM/DiscordBM/issues"
                }
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case type
            case components
        }
        
        public init(from decoder: any Decoder) throws {
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

        public init(arrayLiteral elements: Component...) {
            self.components = elements
        }
    }
}
