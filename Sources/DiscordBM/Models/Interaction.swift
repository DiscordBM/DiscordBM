
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
    public struct Data: Sendable, Codable {
        
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
}

/// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object
public struct InteractionResponse: Sendable, Codable, MultipartEncodable {
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-interaction-callback-type
    public enum Kind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case pong = 1
        case message = 4
        case messageEditWithLoadingState = 5
        case messageEditNoLoadingState = 6
        case componentEditMessage = 7
        case autoCompleteResult = 8
        case modal = 9
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-interaction-callback-data-structure
    public struct CallbackData: Sendable, Codable, MultipartEncodable {
        public var tts: Bool?
        public var content: String?
        public var embeds: [Embed]?
        public var allowedMentions: DiscordChannel.AllowedMentions?
        public var flags: IntBitField<DiscordChannel.Message.Flag>?
        public var components: [Interaction.ActionRow]?
        public var attachments: [DiscordChannel.AttachmentSend]?
        public var files: [File]?
        
        enum CodingKeys: String, CodingKey {
            case tts
            case content
            case embeds
            case allowedMentions
            case flags
            case components
            case attachments
        }
        
        public init(tts: Bool? = nil, content: String? = nil, embeds: [Embed]? = nil, allowedMentions: DiscordChannel.AllowedMentions? = nil, flags: [DiscordChannel.Message.Flag]? = nil, components: [Interaction.ActionRow]? = nil, attachments: [DiscordChannel.AttachmentSend]? = nil, files: [File]? = nil) {
            self.tts = tts
            self.content = content
            self.embeds = embeds
            self.allowedMentions = allowedMentions
            self.flags = flags.map { .init($0) }
            self.components = components
            self.attachments = attachments
            self.files = files
        }
    }
    
    public var type: Kind
    public var data: CallbackData?
    public var files: [File]? {
        data?.files
    }
    
    public init(type: Kind, data: CallbackData? = nil) {
        self.type = type
        self.data = data
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
            case container = 1
            case button = 2
            case selectMenu = 3
            case textInput = 4
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
            case selectMenu(SelectMenu)
            case textInput(TextInput)
            
            enum CodingKeys: String, CodingKey {
                case type
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(Kind.self, forKey: .type)
                switch type {
                case .container:
                    throw CodingError.containerIsSupposedToOnlyAppearAtTopLevel
                case .button:
                    self = try .button(.init(from: decoder))
                case .selectMenu:
                    self = try .selectMenu(.init(from: decoder))
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
                case let .selectMenu(selectMenu):
                    try container.encode(Kind.selectMenu, forKey: .type)
                    try selectMenu.encode(to: encoder)
                case let .textInput(textInput):
                    try container.encode(Kind.textInput, forKey: .type)
                    try textInput.encode(to: encoder)
                }
            }
        }
        
        public var components: [Component]
        
        enum CodingError: Error {
            case unexpectedComponentKind(Kind)
            case containerIsSupposedToOnlyAppearAtTopLevel
        }
        
        enum CodingKeys: String, CodingKey {
            case type
            case components
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(Kind.self, forKey: .type)
            guard type == .container else {
                throw CodingError.unexpectedComponentKind(type)
            }
            self.components = try container.decode([Component].self, forKey: .components)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(Kind.container, forKey: .type)
            try container.encode(self.components, forKey: .components)
        }
        
        public init(components: [Component]) {
            self.components = components
        }
    }
}
