
public struct InteractionResponse: Codable {
    
    public enum Kind: Int, Codable {
        case pong = 1
        case message = 4
        case messageEditWithLoadingState = 5
        case messageEditNoLoadingState = 6
        case componentEditMessage = 7
        case autoCompleteResult = 8
        case modal = 9
    }
    
    public struct CallbackData: Codable {
        
        public struct AllowedMentions: Codable {
            
            public enum Kind: String, Codable {
                case roles
                case users
                case everyone
            }
            
            public let parse: TolerantDecodeArray<Kind>
            public let roles: [String]
            public let users: [String]
            public let replied_user: Bool
        }
        
        public struct Attachment: Codable {
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
        public var flags: Int?
        public var components: [ActionRow]?
        public var attachments: [Attachment]?
        
        public init(tts: Bool? = nil, content: String? = nil, embeds: [Embed]? = nil, allowedMentions: AllowedMentions? = nil, flags: Int? = nil, components: [ActionRow]? = nil, attachments: [Attachment]? = nil) {
            self.tts = tts
            self.content = content
            self.embeds = embeds
            self.allowedMentions = allowedMentions
            self.flags = flags
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
