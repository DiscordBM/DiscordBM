
/// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-structure
public struct Interaction: Sendable, Codable {
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-type
    public enum Kind: Int, Sendable, Codable {
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
            public var users: [String: User]?
            public var members: [String: Guild.PartialMember]?
            public var roles: [String: Role]?
            public var channels: [String: PartialChannel]?
            public var messages: [String: Channel.PartialMessage]?
            public var attachments: [String: Channel.Message.Attachment]?
        }
        
        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-application-command-interaction-data-option-structure
        public struct Option: Sendable, Codable {
            
            /// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-type
            public enum Kind: Int, Sendable, Codable {
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
        
        public enum ComponentKind: Int, Sendable, Codable {
            case actionRow = 1
            case button = 2
            case selectMenu = 3
            case textInput = 4
        }
        
        public struct SelectOption: Sendable, Codable {
            public var label: String
            public var value: String
            public var description: String?
            public var emoji: Emoji?
            public var `default`: Bool?
        }
        
        public var id: String
        public var name: String
        public var type: Kind
        public var resolved: ResolvedData?
        public var options: [Option]?
        public var guild_id: String?
        public var custom_id: String?
        public var component_type: ComponentKind?
        public var values: [SelectOption]?
        public var target_id: String?
        public var components: [ActionRow]?
    }
    
    public var id: String
    public var application_id: String
    public var type: Kind
    public var data: Data?
    public var guild_id: String?
    public var channel_id: String?
    public var member: Guild.Member?
    public var user: User?
    public var token: String
    public var version: Int
    public var message: Channel.Message?
    public var locale: DiscordLocale?
    public var guild_locale: DiscordLocale?
    public var app_permissions: StringBitField<Channel.Permission>?
}

public struct InteractionResponse: Sendable, Codable {
    
    public enum Kind: Int, Sendable, Codable {
        case pong = 1
        case message = 4
        case messageEditWithLoadingState = 5
        case messageEditNoLoadingState = 6
        case componentEditMessage = 7
        case autoCompleteResult = 8
        case modal = 9
    }
    
    public struct CallbackData: Sendable, Codable {
        
        public struct AllowedMentions: Sendable, Codable {
            
            public enum Kind: String, Sendable, Codable {
                case roles
                case users
                case everyone
            }
            
            public let parse: TolerantDecodeArray<Kind>
            public let roles: [String]
            public let users: [String]
            public let replied_user: Bool
        }
        
        public struct Attachment: Sendable, Codable {
            public let id: String
            public let filename: String
            public let description: String?
            public let content_type: String?
            public let size: Int
            public let url: String
            public let proxy_url: String
            public let height: Int?
            public let width: Int?
            public let ephemeral: Bool?
            
            public init(id: String, filename: String, description: String?, content_type: String?, size: Int, url: String, proxy_url: String, height: Int?, width: Int?, ephemeral: Bool?) {
                self.id = id
                self.filename = filename
                self.description = description
                self.content_type = content_type
                self.size = size
                self.url = url
                self.proxy_url = proxy_url
                self.height = height
                self.width = width
                self.ephemeral = ephemeral
            }
        }
        
        public var tts: Bool?
        public var content: String?
        public var embeds: [Embed]?
        public var allowedMentions: AllowedMentions?
        public var flags: IntBitField<Channel.Message.Flag>?
        public var components: [ActionRow]?
        public var attachments: [Attachment]?
        
        public init(tts: Bool? = nil, content: String? = nil, embeds: [Embed]? = nil, allowedMentions: AllowedMentions? = nil, flags: [Channel.Message.Flag]? = nil, components: [ActionRow]? = nil, attachments: [Attachment]? = nil) {
            self.tts = tts
            self.content = content
            self.embeds = embeds
            self.allowedMentions = allowedMentions
            self.flags = flags.map { .init($0) }
            self.components = components
            self.attachments = attachments
        }
    }
    
    public var type: Kind
    public var data: CallbackData?
    
    public init(type: InteractionResponse.Kind, data: InteractionResponse.CallbackData? = nil) {
        self.type = type
        self.data = data
    }
}

/// https://discord.com/developers/docs/interactions/receiving-and-responding#message-interaction-object-message-interaction-structure
public struct MessageInteraction: Sendable, Codable {
    
    public enum Kind: Int, Sendable, Codable {
        case ping = 1
        case applicationCommand = 2
        case messageComponent = 3
        case applicationCommandAutocomplete = 4
        case modalSubmit = 5
    }
    
    public var id: String
    public var type: Kind
    public var name: String
    public var user: User
    public var member: Guild.PartialMember?
}
