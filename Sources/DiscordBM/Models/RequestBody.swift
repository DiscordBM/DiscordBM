import Foundation

public enum RequestBody {
    
    public struct CreateDM: Sendable, Codable, Validatable {
        public var recipient_id: String
        
        @inlinable
        init(recipient_id: String) {
            self.recipient_id = recipient_id
        }
        
        @inlinable
        public func validate() throws { }
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object
    public struct InteractionResponse: Sendable, Codable, MultipartEncodable, Validatable {
        
        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-interaction-callback-type
        public enum Kind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
            /// For ping-pong.
            case pong = 1
            /// Normal response.
            case channelMessageWithSource = 4
            /// Accepts a message to answer later. Shows a loading indicator.
            case deferredChannelMessageWithSource = 5
            /// Accepts a message to answer later. Doesn't show any loading indicators.
            case deferredUpdateMessage = 6
            /// Edit a message.
            case updateMessage = 7
            /// Auto-complete result for slash commands.
            case applicationCommandAutoCompleteResult = 8
            /// A modal.
            case modal = 9
        }
        
        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-interaction-callback-data-structure
        public struct CallbackData: Sendable, Codable, MultipartEncodable, Validatable {
            public var tts: Bool?
            public var content: String?
            public var embeds: [Embed]?
            public var allowedMentions: DiscordChannel.AllowedMentions?
            public var flags: IntBitField<DiscordChannel.Message.Flag>?
            public var components: [Interaction.ActionRow]?
            public var attachments: [DiscordChannel.AttachmentSend]?
            public var files: [RawFile]?
            
            enum CodingKeys: String, CodingKey {
                case tts
                case content
                case embeds
                case allowedMentions
                case flags
                case components
                case attachments
            }
            
            public init(tts: Bool? = nil, content: String? = nil, embeds: [Embed]? = nil, allowedMentions: DiscordChannel.AllowedMentions? = nil, flags: [DiscordChannel.Message.Flag]? = nil, components: [Interaction.ActionRow]? = nil, attachments: [DiscordChannel.AttachmentSend]? = nil, files: [RawFile]? = nil) {
                self.tts = tts
                self.content = content
                self.embeds = embeds
                self.allowedMentions = allowedMentions
                self.flags = flags.map { .init($0) }
                self.components = components
                self.attachments = attachments
                self.files = files
            }
            
            public func validate() throws {
                try validateElementCountDoesNotExceed(embeds, max: 10, name: "embeds")
                try allowedMentions?.validate()
                try validateOnlyContains(
                    flags?.values,
                    name: "flags",
                    reason: "Can only contain 'suppressEmbeds'",
                    where: { $0 == .suppressEmbeds }
                )
                for attachment in attachments ?? [] {
                    try attachment.validate()
                }
                for embed in embeds ?? [] {
                    try embed.validate()
                }
            }
        }
        
        public var type: Kind
        public var data: CallbackData?
        public var files: [RawFile]? {
            data?.files
        }
        
        public init(type: Kind, data: CallbackData? = nil) {
            self.type = type
            self.data = data
        }
        
        public func validate() throws {
            try data?.validate()
        }
    }
    
    /// https://discord.com/developers/docs/resources/guild#create-guild-role-json-params
    public struct CreateGuildRole: Sendable, Codable, Validatable {
        
        public struct ImageData: Sendable, Codable {
            public var file: RawFile
            
            public init(from decoder: Decoder) throws {
                let string = try String(from: decoder)
                var filename: String?
                guard string.hasPrefix("data:") else {
                    throw DecodingError.dataCorrupted(.init(
                        codingPath: decoder.codingPath,
                        debugDescription: "'\(string)' does not start with 'data:'"
                    ))
                }
                guard let semicolon = string.firstIndex(of: ";") else {
                    throw DecodingError.dataCorrupted(.init(
                        codingPath: decoder.codingPath,
                        debugDescription: "'\(string)' does not contain ';'"
                    ))
                }
                let type = string[string.startIndex..<semicolon].dropFirst(5)
                let typeComps = type.split(separator: "/", maxSplits: 1)
                if typeComps.count == 2,
                   let ext = fileExtensionMediaTypeMapping.first(
                    where: { $1.0 == typeComps[0] && $1.1 == typeComps[1] }
                   )?.key {
                    filename = "unknown.\(ext)"
                }
                guard string[semicolon...].hasPrefix(";base64,") else {
                    throw DecodingError.dataCorrupted(.init(
                        codingPath: decoder.codingPath,
                        debugDescription: "'\(string)' does not contain 'base64,'"
                    ))
                }
                let encodedString = string[semicolon...].dropFirst(8)
                guard let data = Data(base64Encoded: String(encodedString)) else {
                    throw DecodingError.dataCorrupted(.init(
                        codingPath: decoder.codingPath,
                        debugDescription: "'\(string)' does not valid data"
                    ))
                }
                self.file = .init(data: .init(data: data), filename: filename ?? "unknown")
            }
            
            public func encode(to encoder: Encoder) throws {
                guard let type = file.type else {
                    throw EncodingError.invalidValue(file, .init(
                        codingPath: encoder.codingPath,
                        debugDescription: "Can't find the file type. Please provide the file extension in the 'filename'. For example, use 'penguin.png' instead of 'penguin'"
                    ))
                }
                var buffer = file.data
                let data = buffer.readData(length: buffer.readableBytes)
                guard let encoded = data?.base64EncodedString() else {
                    throw EncodingError.invalidValue(
                        data ?? Data(), .init(
                            codingPath: encoder.codingPath,
                            debugDescription: "Can't base64 encode the data"
                        )
                    )
                }
                var container = encoder.singleValueContainer()
                try container.encode("data:\(type);base64,\(encoded)")
            }
        }
        
        public var name: String?
        public var permissions: StringBitField<Permission>?
        public var color: DiscordColor?
        public var hoist: Bool?
        public var icon: ImageData?
        public var unicode_emoji: String?
        public var mentionable: Bool?
        
        public init(name: String? = nil, permissions: [Permission]? = nil, color: DiscordColor? = nil, hoist: Bool? = nil, icon: ImageData? = nil, unicode_emoji: String? = nil, mentionable: Bool? = nil) {
            self.name = name
            self.permissions = permissions.map { .init($0) }
            self.color = color
            self.hoist = hoist
            self.icon = icon
            self.unicode_emoji = unicode_emoji
            self.mentionable = mentionable
        }
        
        public func validate() throws {
            try validateCharacterCountDoesNotExceed(name, max: 1_000, name: "name")
        }
    }
    
    /// https://discord.com/developers/docs/resources/channel#create-message-jsonform-params
    public struct CreateMessage: Sendable, Codable, MultipartEncodable, Validatable {
        public var content: String?
        public var nonce: StringOrInt?
        public var tts: Bool?
        public var embeds: [Embed]?
        public var allowed_mentions: DiscordChannel.AllowedMentions?
        public var message_reference: DiscordChannel.Message.MessageReference?
        public var components: [Interaction.ActionRow]?
        public var sticker_ids: [String]?
        public var files: [RawFile]?
        public var attachments: [DiscordChannel.AttachmentSend]?
        public var flags: IntBitField<DiscordChannel.Message.Flag>?
        
        enum CodingKeys: String, CodingKey {
            case content
            case tts
            case embeds
            case allowed_mentions
            case message_reference
            case components
            case sticker_ids
            case attachments
            case flags
        }
        
        public init(content: String? = nil, nonce: StringOrInt? = nil, tts: Bool? = nil, embeds: [Embed]? = nil, allowed_mentions: DiscordChannel.AllowedMentions? = nil, message_reference: DiscordChannel.Message.MessageReference? = nil, components: [Interaction.ActionRow]? = nil, sticker_ids: [String]? = nil, files: [RawFile]? = nil, attachments: [DiscordChannel.AttachmentSend]? = nil, flags: [DiscordChannel.Message.Flag]? = nil) {
            self.content = content
            self.nonce = nonce
            self.tts = tts
            self.embeds = embeds
            self.allowed_mentions = allowed_mentions
            self.message_reference = message_reference
            self.components = components
            self.sticker_ids = sticker_ids
            self.files = files
            self.attachments = attachments
            self.flags = flags.map { .init($0) }
        }
        
        public func validate() throws {
            try validateElementCountDoesNotExceed(sticker_ids, max: 3, name: "sticker_ids")
            try validateCharacterCountDoesNotExceed(content, max: 2_000, name: "content")
            try validateCharacterCountDoesNotExceed(nonce?.asString, max: 25, name: "nonce")
            try allowed_mentions?.validate()
            try validateAtLeastOneIsNotEmpty(
                content?.isEmpty,
                embeds?.isEmpty,
                sticker_ids?.isEmpty,
                components?.isEmpty,
                files?.isEmpty,
                names: "content", "embeds", "sticker_ids", "components", "files"
            )
            try validateCombinedCharacterCountDoesNotExceed(
                embeds?.reduce(into: 0, { $0 += $1.contentLength }),
                max: 6_000,
                names: "embeds"
            )
            try validateOnlyContains(
                flags?.values,
                name: "flags",
                reason: "Can only contain 'suppressEmbeds'",
                where: { $0 == .suppressEmbeds }
            )
            for attachment in attachments ?? [] {
                try attachment.validate()
            }
            for embed in embeds ?? [] {
                try embed.validate()
            }
        }
    }
    
    /// https://discord.com/developers/docs/resources/channel#edit-message-jsonform-params
    public struct EditMessage: Sendable, Codable, MultipartEncodable, Validatable {
        public var content: String?
        public var embeds: [Embed]?
        public var flags: IntBitField<DiscordChannel.Message.Flag>?
        public var allowed_mentions: DiscordChannel.AllowedMentions?
        public var components: [Interaction.ActionRow]?
        public var files: [RawFile]?
        public var attachments: [DiscordChannel.AttachmentSend]?
        
        enum CodingKeys: String, CodingKey {
            case content
            case embeds
            case flags
            case allowed_mentions
            case components
            case attachments
        }
        
        public init(content: String? = nil, embeds: [Embed]? = nil, flags: [DiscordChannel.Message.Flag]? = nil, allowed_mentions: DiscordChannel.AllowedMentions? = nil, components: [Interaction.ActionRow]? = nil, files: [RawFile]? = nil, attachments: [DiscordChannel.AttachmentSend]? = nil) {
            self.content = content
            self.embeds = embeds
            self.flags = flags.map { .init($0) }
            self.allowed_mentions = allowed_mentions
            self.components = components
            self.files = files
            self.attachments = attachments
        }
        
        public func validate() throws {
            try validateCharacterCountDoesNotExceed(content, max: 2_000, name: "content")
            try validateCombinedCharacterCountDoesNotExceed(
                embeds?.reduce(into: 0, { $0 += $1.contentLength }),
                max: 6_000,
                names: "embeds"
            )
            try validateOnlyContains(
                flags?.values,
                name: "flags",
                reason: "Can only contain 'suppressEmbeds'",
                where: { $0 == .suppressEmbeds }
            )
            try allowed_mentions?.validate()
            for attachment in attachments ?? [] {
                try attachment.validate()
            }
            for embed in embeds ?? [] {
                try embed.validate()
            }
        }
    }
}
