import Foundation
import NIOFoundationCompat

/// REST API payloads.
///
/// These types only need to be `Encodable`,
/// unless we actually need them to be `Decodable` as well.
public enum Payloads {
    
    public struct CreateDM: Sendable, Encodable, ValidatablePayload {
        public var recipient_id: Snowflake<DiscordUser>
        
        @inlinable
        public init(recipient_id: Snowflake<DiscordUser>) {
            self.recipient_id = recipient_id
        }
        
        public func validate() -> [ValidationFailure] { }
    }
    
    /// An attachment object, but for sending.
    /// https://discord.com/developers/docs/resources/channel#attachment-object
    public struct AttachmentSend: Sendable, Encodable, ValidatablePayload {
        /// When sending, `id` is the index of this attachment in the `files` you provide.
        public var id: String
        public var filename: String?
        public var description: String?
        public var content_type: String?
        public var size: Int?
        public var url: String?
        public var proxy_url: String?
        public var height: Int?
        public var width: Int?
        public var ephemeral: Bool?
        
        /// `index` is the index of this attachment in the `files` you provide.
        public init(index: Int, filename: String? = nil, description: String? = nil, content_type: String? = nil, size: Int? = nil, url: String? = nil, proxy_url: String? = nil, height: Int? = nil, width: Int? = nil, ephemeral: Bool? = nil) {
            self.id = "\(index)"
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
        
        public func validate() -> [ValidationFailure] {
            validateCharacterCountDoesNotExceed(description, max: 1_024, name: "description")
        }
    }
    
    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object
    public struct InteractionResponse: Sendable, MultipartEncodable, ValidatablePayload {
        
        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-interaction-callback-type
        public enum Kind: Int, Sendable, Encodable, ToleratesIntDecodeMarker {
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
            /// Auto-complete result for application commands.
            case applicationCommandAutoCompleteResult = 8
            /// A modal.
            case modal = 9
        }

        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-messages
        public struct Message: Sendable, MultipartEncodable, ValidatablePayload {
            public var tts: Bool?
            public var content: String?
            public var embeds: [Embed]?
            public var allowedMentions: DiscordChannel.AllowedMentions?
            public var flags: IntBitField<DiscordChannel.Message.Flag>?
            public var components: [Interaction.ActionRow]?
            public var attachments: [AttachmentSend]?
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

            public init(tts: Bool? = nil, content: String? = nil, embeds: [Embed]? = nil, allowedMentions: DiscordChannel.AllowedMentions? = nil, flags: [DiscordChannel.Message.Flag]? = nil, components: [Interaction.ActionRow]? = nil, attachments: [AttachmentSend]? = nil, files: [RawFile]? = nil) {
                self.tts = tts
                self.content = content
                self.embeds = embeds
                self.allowedMentions = allowedMentions
                self.flags = flags.map { .init($0) }
                self.components = components
                self.attachments = attachments
                self.files = files
            }

            public func validate() -> [ValidationFailure] {
                validateElementCountDoesNotExceed(embeds, max: 10, name: "embeds")
                allowedMentions?.validate()
                validateOnlyContains(
                    flags?.values,
                    name: "flags",
                    reason: "Can only contain 'suppressEmbeds' and 'ephemeral'",
                    where: { [.suppressEmbeds, .ephemeral].contains($0) }
                )
                attachments?.validate()
                embeds?.validate()
            }
        }

        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-autocomplete
        public struct Autocomplete: Sendable, Encodable, ValidatablePayload {
            public var choices: [ApplicationCommand.Option.Choice]

            public init(choices: [ApplicationCommand.Option.Choice]) {
                self.choices = choices
            }

            public func validate() -> [ValidationFailure] {
                validateElementCountDoesNotExceed(choices, max: 25, name: "choices")
            }
        }

        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-modal
        public struct Modal: Sendable, Encodable, ValidatablePayload {
            public var custom_id: String
            public var title: String
            public var components: [Interaction.ActionRow]

            /// Discord docs says currently you can only send text-inputs.
            /// To send other types of components, use a normal message's `components`:
            /// `Payloads.InteractionResponse.Message(components: [...])`
            /// Respectively, you can't send a text-input using a normal message's `components`.
            public init(custom_id: String, title: String, textInputs: [Interaction.ActionRow.TextInput]) {
                self.custom_id = custom_id
                self.title = title
                self.components = textInputs.map { [.textInput($0)] }
            }

            public func validate() -> [ValidationFailure] {
                validateElementCountInRange(components, min: 1, max: 5, name: "components")
            }
        }

        /// A container for message flags.
        struct Flags: Sendable, Encodable, ValidatablePayload {
            var flags: IntBitField<DiscordChannel.Message.Flag>?

            init(isEphemeral: Bool) {
                self.flags = isEphemeral ? [.ephemeral] : nil
            }

            func validate() -> [ValidationFailure] { }
        }
        
        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-interaction-callback-data-structure
        internal enum CallbackData: Sendable, MultipartEncodable, ValidatablePayload {
            case message(Message)
            case autocomplete(Autocomplete)
            case modal(Modal)
            case flags(Flags)

            var files: [RawFile]? {
                switch self {
                case let .message(message):
                    return message.files
                case .autocomplete, .modal, .flags:
                    return nil
                }
            }

            func validate() -> [ValidationFailure] {
                switch self {
                case let .message(message):
                    message.validate()
                case let .autocomplete(autocomplete):
                    autocomplete.validate()
                case let .modal(modal):
                    modal.validate()
                case .flags:
                    /// For the result builder
                    Optional<ValidationFailure>.none
                }
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case let .message(message):
                    try container.encode(message)
                case let .autocomplete(autocomplete):
                    try container.encode(autocomplete)
                case let .modal(modal):
                    try container.encode(modal)
                case let .flags(flags):
                    try container.encode(flags)
                }
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case type
            case data
        }
        
        public var type: Kind
        internal var data: CallbackData?
        public var files: [RawFile]? {
            data?.files
        }
        
        private init(type: Kind, data: CallbackData? = nil) {
            self.type = type
            self.data = data
        }

        public func validate() -> [ValidationFailure] {
            data?.validate()
        }

        /// Creates a response of type `Kind.pong`.
        public static var pong: Self {
            .init(type: .pong)
        }

        /// Creates a response of type `Kind.channelMessageWithSource`.
        public static func channelMessageWithSource(_ message: Message) -> Self {
            .init(type: .channelMessageWithSource, data: .message(message))
        }

        /// Creates a response of type `Kind.deferredChannelMessageWithSource`.
        /// The `.ephemeral` message flag needs to be set here on a deferred message.
        /// The main message's flags can't override this flag.
        /// Discord barely mentions this behavior here: https://discord.com/developers/docs/interactions/receiving-and-responding#create-followup-message
        public static func deferredChannelMessageWithSource(isEphemeral: Bool = false) -> Self {
            .init(
                type: .deferredChannelMessageWithSource,
                data: .flags(.init(isEphemeral: isEphemeral))
            )
        }

        /// Creates a response of type `Kind.deferredUpdateMessage`.
        /// The `.ephemeral` message flag needs to be set here on a deferred message.
        /// The main message's flags can't override this flag.
        /// Discord barely mentions this behavior here: https://discord.com/developers/docs/interactions/receiving-and-responding#create-followup-message
        public static func deferredUpdateMessage(isEphemeral: Bool = false) -> Self {
            .init(
                type: .deferredUpdateMessage,
                data: .flags(.init(isEphemeral: isEphemeral))
            )
        }

        /// Creates a response of type `Kind.updateMessage`.
        public static func updateMessage(_ message: Message) -> Self {
            .init(type: .updateMessage, data: .message(message))
        }

        /// Creates a response of type `Kind.applicationCommandAutoCompleteResult`.
        public static func autocompleteResult(_ result: Autocomplete) -> Self {
            .init(type: .applicationCommandAutoCompleteResult, data: .autocomplete(result))
        }

        /// Creates a response of type `Kind.modal`.
        public static func modal(_ modal: Modal) -> Self {
            .init(type: .modal, data: .modal(modal))
        }
    }

    public struct ImageData: Sendable, Codable {
        public var file: RawFile
        
        public init(file: RawFile) {
            self.file = file
        }
        
        public init(from decoder: Decoder) throws {
            let string = try String(from: decoder)
            guard let file = ImageData.decodeFromString(string) else {
                throw DecodingError.dataCorrupted(.init(
                    codingPath: decoder.codingPath,
                    debugDescription: "'\(string)' can't be base64 decoded into a file"
                ))
            }
            self.file = file
        }
        
        public func encode(to encoder: Encoder) throws {
            guard let string = self.encodeToString() else {
                throw EncodingError.invalidValue(
                    file, .init(
                        codingPath: encoder.codingPath,
                        debugDescription: "Can't base64 encode the file"
                    )
                )
            }
            var container = encoder.singleValueContainer()
            try container.encode(string)
        }
        
        static func decodeFromString(_ string: String) -> RawFile? {
            var filename: String?
            guard string.hasPrefix("data:") else {
                return nil
            }
            guard let semicolon = string.firstIndex(of: ";") else {
                return nil
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
                return nil
            }
            let encodedString = string[semicolon...].dropFirst(8)
            guard let data = Data(base64Encoded: String(encodedString)) else {
                return nil
            }
            return .init(data: .init(data: data), filename: filename ?? "unknown")
        }
        
        func encodeToString() -> String? {
            guard let type = file.type else { return nil }
            let data = Data(buffer: file.data, byteTransferStrategy: .noCopy)
            let encoded = data.base64EncodedString()
            return "data:\(type);base64,\(encoded)"
        }
    }
    
    /// https://discord.com/developers/docs/resources/guild#create-guild-role-json-params
    public struct CreateGuildRole: Sendable, Codable, ValidatablePayload {
        public var name: String?
        public var permissions: StringBitField<Permission>?
        public var color: DiscordColor?
        public var hoist: Bool?
        public var icon: ImageData?
        public var unicode_emoji: String?
        public var mentionable: Bool?
        
        /// `icon` and `unicode_emoji` require `roleIcons` guild feature,
        /// which most guild don't have.
        /// No fields are required. If you send an empty payload, you'll get a basic role
        /// with a name like "new role".
        public init(name: String? = nil, permissions: [Permission]? = nil, color: DiscordColor? = nil, hoist: Bool? = nil, icon: ImageData? = nil, unicode_emoji: String? = nil, mentionable: Bool? = nil) {
            self.name = name
            self.permissions = permissions.map { .init($0) }
            self.color = color
            self.hoist = hoist
            self.icon = icon
            self.unicode_emoji = unicode_emoji
            self.mentionable = mentionable
        }
        
        public func validate() -> [ValidationFailure] {
            validateCharacterCountDoesNotExceed(name, max: 1_000, name: "name")
        }
    }
    
    /// https://discord.com/developers/docs/resources/channel#create-message-jsonform-params
    public struct CreateMessage: Sendable, MultipartEncodable, ValidatablePayload {
        public var content: String?
        public var nonce: StringOrInt?
        public var tts: Bool?
        public var embeds: [Embed]?
        public var allowed_mentions: DiscordChannel.AllowedMentions?
        public var message_reference: DiscordChannel.Message.MessageReference?
        public var components: [Interaction.ActionRow]?
        public var sticker_ids: [String]?
        public var files: [RawFile]?
        public var attachments: [AttachmentSend]?
        public var flags: IntBitField<DiscordChannel.Message.Flag>?
        
        enum CodingKeys: String, CodingKey {
            case content
            case nonce
            case tts
            case embeds
            case allowed_mentions
            case message_reference
            case components
            case sticker_ids
            case attachments
            case flags
        }
        
        public init(content: String? = nil, nonce: StringOrInt? = nil, tts: Bool? = nil, embeds: [Embed]? = nil, allowed_mentions: DiscordChannel.AllowedMentions? = nil, message_reference: DiscordChannel.Message.MessageReference? = nil, components: [Interaction.ActionRow]? = nil, sticker_ids: [String]? = nil, files: [RawFile]? = nil, attachments: [AttachmentSend]? = nil, flags: [DiscordChannel.Message.Flag]? = nil) {
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
        
        public func validate() -> [ValidationFailure] {
            validateElementCountDoesNotExceed(embeds, max: 10, name: "embeds")
            validateElementCountDoesNotExceed(sticker_ids, max: 3, name: "sticker_ids")
            validateCharacterCountDoesNotExceed(content, max: 2_000, name: "content")
            validateCharacterCountDoesNotExceed(nonce?.asString, max: 25, name: "nonce")
            allowed_mentions?.validate()
            validateAtLeastOneIsNotEmpty(
                content?.isEmpty,
                embeds?.isEmpty,
                sticker_ids?.isEmpty,
                components?.isEmpty,
                files?.isEmpty,
                names: "content", "embeds", "sticker_ids", "components", "files"
            )
            validateCombinedCharacterCountDoesNotExceed(
                embeds?.reduce(into: 0, { $0 += $1.contentLength }),
                max: 6_000,
                names: "embeds"
            )
            validateOnlyContains(
                flags?.values,
                name: "flags",
                reason: "Can only contain 'suppressEmbeds' or 'suppressNotifications'",
                where: { [.suppressEmbeds, .suppressNotifications].contains($0) }
            )
            attachments?.validate()
            embeds?.validate()
        }
    }
    
    /// https://discord.com/developers/docs/resources/channel#edit-message-jsonform-params
    public struct EditMessage: Sendable, MultipartEncodable, ValidatablePayload {
        public var content: String?
        public var embeds: [Embed]?
        public var flags: IntBitField<DiscordChannel.Message.Flag>?
        public var allowed_mentions: DiscordChannel.AllowedMentions?
        public var components: [Interaction.ActionRow]?
        public var files: [RawFile]?
        public var attachments: [AttachmentSend]?
        
        enum CodingKeys: String, CodingKey {
            case content
            case embeds
            case flags
            case allowed_mentions
            case components
            case attachments
        }
        
        public init(content: String? = nil, embeds: [Embed]? = nil, flags: [DiscordChannel.Message.Flag]? = nil, allowed_mentions: DiscordChannel.AllowedMentions? = nil, components: [Interaction.ActionRow]? = nil, files: [RawFile]? = nil, attachments: [AttachmentSend]? = nil) {
            self.content = content
            self.embeds = embeds
            self.flags = flags.map { .init($0) }
            self.allowed_mentions = allowed_mentions
            self.components = components
            self.files = files
            self.attachments = attachments
        }
        
        public func validate() -> [ValidationFailure] {
            validateElementCountDoesNotExceed(embeds, max: 10, name: "embeds")
            validateCharacterCountDoesNotExceed(content, max: 2_000, name: "content")
            validateCombinedCharacterCountDoesNotExceed(
                embeds?.reduce(into: 0, { $0 += $1.contentLength }),
                max: 6_000,
                names: "embeds"
            )
            validateOnlyContains(
                flags?.values,
                name: "flags",
                reason: "Can only contain 'suppressEmbeds'",
                where: { $0 == .suppressEmbeds }
            )
            allowed_mentions?.validate()
            attachments?.validate()
            embeds?.validate()
        }
    }
    
    /// https://discord.com/developers/docs/resources/webhook#execute-webhook-jsonform-params
    public struct ExecuteWebhook: Sendable, MultipartEncodable, ValidatablePayload {
        public var content: String?
        public var username: String?
        public var avatar_url: String?
        public var tts: Bool?
        public var embeds: [Embed]?
        public var allowed_mentions: DiscordChannel.AllowedMentions?
        public var components: [Interaction.ActionRow]?
        public var files: [RawFile]?
        public var attachments: [AttachmentSend]?
        public var flags: IntBitField<DiscordChannel.Message.Flag>?
        public var thread_name: String?
        
        enum CodingKeys: CodingKey {
            case content
            case username
            case avatar_url
            case tts
            case embeds
            case allowed_mentions
            case components
            case attachments
            case flags
            case thread_name
        }
        
        public init(content: String? = nil, username: String? = nil, avatar_url: String? = nil, tts: Bool? = nil, embeds: [Embed]? = nil, allowed_mentions: DiscordChannel.AllowedMentions? = nil, components: [Interaction.ActionRow]? = nil, files: [RawFile]? = nil, attachments: [AttachmentSend]? = nil, flags: IntBitField<DiscordChannel.Message.Flag>? = nil, thread_name: String? = nil) {
            self.content = content
            self.username = username
            self.avatar_url = avatar_url
            self.tts = tts
            self.embeds = embeds
            self.allowed_mentions = allowed_mentions
            self.components = components
            self.files = files
            self.attachments = attachments
            self.flags = flags
            self.thread_name = thread_name
        }
        
        public func validate() -> [ValidationFailure] {
            validateElementCountDoesNotExceed(embeds, max: 10, name: "embeds")
            validateCharacterCountDoesNotExceed(content, max: 2_000, name: "content")
            validateAtLeastOneIsNotEmpty(
                content?.isEmpty, components?.isEmpty, files?.isEmpty, embeds?.isEmpty,
                names: "content", "components", "files", "embeds"
            )
            validateCombinedCharacterCountDoesNotExceed(
                embeds?.reduce(into: 0, { $0 += $1.contentLength }),
                max: 6_000,
                names: "embeds"
            )
            validateOnlyContains(
                flags?.values,
                name: "flags",
                reason: "Can only contain 'suppressEmbeds'",
                where: { $0 == .suppressEmbeds }
            )
            allowed_mentions?.validate()
            attachments?.validate()
            embeds?.validate()
        }
    }
    
    /// https://discord.com/developers/docs/resources/webhook#create-webhook-json-params
    public struct CreateWebhook: Sendable, Encodable, ValidatablePayload {
        public var name: String
        public var avatar: ImageData?
        
        public init(name: String, avatar: ImageData? = nil) {
            self.name = name
            self.avatar = avatar
        }
        
        public func validate() -> [ValidationFailure] {
            validateCharacterCountInRange(name, min: 1, max: 80, name: "name")
            validateCaseInsensitivelyDoesNotContain(
                name,
                name: "name",
                values: ["clyde", "discord"],
                reason: "name can't contain 'clyde' or 'discord' (case-insensitive)"
            )
        }
    }
    
    /// https://discord.com/developers/docs/resources/webhook#modify-webhook-with-token
    public struct ModifyWebhook: Sendable, Encodable, ValidatablePayload {
        public var name: String?
        public var avatar: ImageData?
        
        public init(name: String? = nil, avatar: ImageData? = nil) {
            self.name = name
            self.avatar = avatar
        }
        
        public func validate() -> [ValidationFailure] { }
    }
    
    /// https://discord.com/developers/docs/resources/webhook#modify-webhook-json-params
    public struct ModifyGuildWebhook: Sendable, Encodable, ValidatablePayload {
        public var name: String?
        public var avatar: ImageData?
        public var channel_id: Snowflake<DiscordChannel>?
        
        public init(name: String, avatar: ImageData? = nil, channel_id: Snowflake<DiscordChannel>? = nil) {
            self.name = name
            self.avatar = avatar
            self.channel_id = channel_id
        }
        
        public func validate() -> [ValidationFailure] { }
    }
    
    /// https://discord.com/developers/docs/resources/webhook#edit-webhook-message-jsonform-params
    public struct EditWebhookMessage: Sendable, MultipartEncodable, ValidatablePayload {
        public var content: String?
        public var embeds: [Embed]?
        public var allowed_mentions: DiscordChannel.AllowedMentions?
        public var components: [Interaction.ActionRow]?
        public var files: [RawFile]?
        public var attachments: [AttachmentSend]?
        
        enum CodingKeys: String, CodingKey {
            case content
            case embeds
            case allowed_mentions
            case components
            case attachments
        }
        
        public init(content: String? = nil, embeds: [Embed]? = nil, allowed_mentions: DiscordChannel.AllowedMentions? = nil, components: [Interaction.ActionRow]? = nil, files: [RawFile]? = nil, attachments: [AttachmentSend]? = nil) {
            self.content = content
            self.embeds = embeds
            self.allowed_mentions = allowed_mentions
            self.components = components
            self.files = files
            self.attachments = attachments
        }
        
        public func validate() -> [ValidationFailure] {
            validateElementCountDoesNotExceed(embeds, max: 10, name: "embeds")
            validateCharacterCountDoesNotExceed(content, max: 2_000, name: "content")
            validateCombinedCharacterCountDoesNotExceed(
                embeds?.reduce(into: 0, { $0 += $1.contentLength }),
                max: 6_000,
                names: "embeds"
            )
            allowed_mentions?.validate()
            attachments?.validate()
            embeds?.validate()
        }
    }
    
    public struct CreateThreadFromMessage: Sendable, Encodable, ValidatablePayload {
        public var name: String
        public var auto_archive_duration: DiscordChannel.AutoArchiveDuration?
        public var rate_limit_per_user: Int?
        
        public init(
            name: String,
            auto_archive_duration: DiscordChannel.AutoArchiveDuration? = nil,
            rate_limit_per_user: Int? = nil
        ) {
            self.name = name
            self.auto_archive_duration = auto_archive_duration
            self.rate_limit_per_user = rate_limit_per_user
        }
        
        public func validate() -> [ValidationFailure] {
            validateCharacterCountInRange(name, min: 1, max: 100, name: "name")
            validateNumberInRange(
                rate_limit_per_user,
                min: 0,
                max: 21_600,
                name: "rate_limit_per_user"
            )
        }
    }
    
    public struct CreateThreadWithoutMessage: Sendable, Encodable, ValidatablePayload {
        public var name: String
        public var auto_archive_duration: DiscordChannel.AutoArchiveDuration?
        public var type: ThreadKind
        public var invitable: Bool?
        public var rate_limit_per_user: Int?
        
        public init(
            name: String,
            auto_archive_duration: DiscordChannel.AutoArchiveDuration? = nil,
            type: ThreadKind,
            invitable: Bool? = nil,
            rate_limit_per_user: Int? = nil
        ) {
            self.name = name
            self.auto_archive_duration = auto_archive_duration
            self.type = type
            self.invitable = invitable
            self.rate_limit_per_user = rate_limit_per_user
        }
        
        public func validate() -> [ValidationFailure] {
            validateCharacterCountInRange(name, min: 1, max: 100, name: "name")
            validateNumberInRange(
                rate_limit_per_user,
                min: 0,
                max: 21_600,
                name: "rate_limit_per_user"
            )
        }
    }
    
    public struct CreateThreadInForumChannel: Sendable, Encodable, ValidatablePayload {
        
        /// https://discord.com/developers/docs/resources/channel#start-thread-in-forum-channel-forum-thread-message-params-object
        public struct ForumMessage: Sendable, MultipartEncodable, ValidatablePayload {
            public var content: String?
            public var embeds: [Embed]?
            public var allowed_mentions: DiscordChannel.AllowedMentions?
            public var components: [Interaction.ActionRow]?
            public var sticker_ids: [String]?
            public var files: [RawFile]?
            public var attachments: [AttachmentSend]?
            public var flags: IntBitField<DiscordChannel.Message.Flag>?
            
            enum CodingKeys: String, CodingKey {
                case content
                case embeds
                case allowed_mentions
                case components
                case sticker_ids
                case attachments
                case flags
            }
            
            public init(content: String? = nil, embeds: [Embed]? = nil, allowed_mentions: DiscordChannel.AllowedMentions? = nil, components: [Interaction.ActionRow]? = nil, sticker_ids: [String]? = nil, files: [RawFile]? = nil, attachments: [AttachmentSend]? = nil, flags: [DiscordChannel.Message.Flag]? = nil) {
                self.content = content
                self.embeds = embeds
                self.allowed_mentions = allowed_mentions
                self.components = components
                self.sticker_ids = sticker_ids
                self.files = files
                self.attachments = attachments
                self.flags = flags.map { .init($0) }
            }
            
            public func validate() -> [ValidationFailure] {
                validateElementCountDoesNotExceed(embeds, max: 10, name: "embeds")
                validateElementCountDoesNotExceed(sticker_ids, max: 3, name: "sticker_ids")
                validateCharacterCountDoesNotExceed(content, max: 2_000, name: "content")
                allowed_mentions?.validate()
                validateAtLeastOneIsNotEmpty(
                    content?.isEmpty,
                    embeds?.isEmpty,
                    sticker_ids?.isEmpty,
                    components?.isEmpty,
                    files?.isEmpty,
                    names: "content", "embeds", "sticker_ids", "components", "files"
                )
                validateCombinedCharacterCountDoesNotExceed(
                    embeds?.reduce(into: 0, { $0 += $1.contentLength }),
                    max: 6_000,
                    names: "embeds"
                )
                validateOnlyContains(
                    flags?.values,
                    name: "flags",
                    reason: "Can only contain 'suppressEmbeds' or 'suppressNotifications'",
                    where: { [.suppressEmbeds, .suppressNotifications].contains($0) }
                )
                attachments?.validate()
                embeds?.validate()
            }
        }
        
        public var name: String
        public var auto_archive_duration: DiscordChannel.AutoArchiveDuration?
        public var rate_limit_per_user: Int?
        public var message: ForumMessage
        public var applied_tags: [String]?
        
        public init(
            name: String,
            auto_archive_duration: DiscordChannel.AutoArchiveDuration? = nil,
            rate_limit_per_user: Int? = nil,
            message: ForumMessage,
            applied_tags: [String]? = nil
        ) {
            self.name = name
            self.auto_archive_duration = auto_archive_duration
            self.rate_limit_per_user = rate_limit_per_user
            self.message = message
            self.applied_tags = applied_tags
        }
        
        public func validate() -> [ValidationFailure] {
            validateCharacterCountInRange(name, min: 1, max: 100, name: "name")
            validateNumberInRange(
                rate_limit_per_user,
                min: 0,
                max: 21_600,
                name: "rate_limit_per_user"
            )
            self.message.validate()
        }
    }
    
    public struct ApplicationCommandCreate: Sendable, Encodable, ValidatablePayload {
        public var name: String
        public var name_localizations: DiscordLocaleDict<String>?
        public var description: String?
        public var description_localizations: DiscordLocaleDict<String>?
        public var options: [ApplicationCommand.Option]?
        public var default_member_permissions: StringBitField<Permission>?
        public var dm_permission: Bool?
        public var type: ApplicationCommand.Kind?
        public var nsfw: Bool?
        
        public init(name: String, name_localizations: [DiscordLocale: String]? = nil, description: String? = nil, description_localizations: [DiscordLocale: String]? = nil, options: [ApplicationCommand.Option]? = nil, default_member_permissions: [Permission]? = nil, dm_permission: Bool? = nil, type: ApplicationCommand.Kind? = nil, nsfw: Bool? = nil) {
            self.name = name
            self.name_localizations = .init(name_localizations)
            self.description = description
            self.description_localizations = .init(description_localizations)
            self.options = options
            self.default_member_permissions = default_member_permissions.map({ .init($0) })
            self.dm_permission = dm_permission
            self.type = type
            self.nsfw = nsfw
        }
        
        public func validate() -> [ValidationFailure] {
            validateHasPrecondition(
                condition: options.containsAnything,
                allowedIf: (type ?? .chatInput) == .chatInput,
                name: "options",
                reason: "'options' is only allowed if 'type' is 'chatInput'"
            )
            validateHasPrecondition(
                condition: description.containsAnything
                || (description_localizations?.values).containsAnything,
                allowedIf: (type ?? .chatInput) == .chatInput,
                name: "description+description_localizations",
                reason: "'description' or 'description_localizations' are only allowed if 'type' is 'chatInput'"
            )
            validateElementCountDoesNotExceed(options, max: 25, name: "options")
            validateCharacterCountInRange(name, min: 1, max: 32, name: "name")
            validateCharacterCountDoesNotExceed(description, max: 100, name: "description")
            for (_, value) in name_localizations?.values ?? [:] {
                validateCharacterCountInRange(value, min: 1, max: 32, name: "name_localizations.name")
            }
            for (_, value) in description_localizations?.values ?? [:] {
                validateCharacterCountInRange(value, min: 1, max: 32, name: "description_localizations.name")
            }
            options?.validate()
        }
    }
    
    public struct ApplicationCommandEdit: Sendable, Encodable, ValidatablePayload {
        public var name: String?
        public var name_localizations: DiscordLocaleDict<String>?
        public var description: String?
        public var description_localizations: DiscordLocaleDict<String>?
        public var options: [ApplicationCommand.Option]?
        public var default_member_permissions: StringBitField<Permission>?
        public var dm_permission: Bool?
        public var nsfw: Bool?
        
        public init(name: String? = nil, name_localizations: [DiscordLocale: String]? = nil, description: String? = nil, description_localizations: [DiscordLocale: String]? = nil, options: [ApplicationCommand.Option]? = nil, default_member_permissions: [Permission]? = nil, dm_permission: Bool? = nil, nsfw: Bool? = nil) {
            self.name = name
            self.name_localizations = .init(name_localizations)
            self.description = description
            self.description_localizations = .init(description_localizations)
            self.options = options
            self.default_member_permissions = default_member_permissions.map({ .init($0) })
            self.dm_permission = dm_permission
            self.nsfw = nsfw
        }
        
        public func validate() -> [ValidationFailure] {
            validateElementCountDoesNotExceed(options, max: 25, name: "options")
            validateCharacterCountInRange(name, min: 1, max: 32, name: "name")
            validateCharacterCountDoesNotExceed(description, max: 100, name: "description")
            for (_, value) in name_localizations?.values ?? [:] {
                validateCharacterCountInRange(value, min: 1, max: 32, name: "name_localizations.name")
            }
            for (_, value) in description_localizations?.values ?? [:] {
                validateCharacterCountInRange(value, min: 1, max: 32, name: "description_localizations.name")
            }
            options?.validate()
        }
    }
    
    public struct EditApplicationCommandPermissions: Sendable, Encodable, ValidatablePayload {
        public var permissions: [GuildApplicationCommandPermissions.Permission]
        
        public init(permissions: [GuildApplicationCommandPermissions.Permission]) {
            self.permissions = permissions
        }
        
        public func validate() -> [ValidationFailure] { }
    }

    /// https://discord.com/developers/docs/resources/channel#modify-channel-json-params-group-dm
    public struct ModifyGroupDMChannel: Sendable, Encodable, ValidatablePayload {
        public var name: String?
        public var icon: ImageData?

        init(name: String? = nil, icon: ImageData? = nil) {
            self.name = name
            self.icon = icon
        }

        public func validate() -> [ValidationFailure] {
            validateCharacterCountInRangeOrNil(name, min: 1, max: 100, name: "name")
        }
    }

    /// https://discord.com/developers/docs/resources/channel#overwrite-object
    public struct PartialChannelOverwrite: Sendable, Encodable {

        /// https://discord.com/developers/docs/resources/channel#overwrite-object
        public enum Kind: Int, Sendable, Encodable, ToleratesIntDecodeMarker {
            case role = 0
            case member = 1
        }

        public var id: AnySnowflake
        public var type: Kind
        public var allow: StringBitField<Permission>?
        public var deny: StringBitField<Permission>?

        public init(id: AnySnowflake, type: Kind, allow: [Permission]? = nil, deny: [Permission]? = nil) {
            self.id = id
            self.type = type
            self.allow = allow.map { .init($0) }
            self.deny = deny.map { .init($0) }
        }
    }

    /// https://discord.com/developers/docs/resources/channel#forum-tag-object-forum-tag-structure
    public struct PartialForumTag: Sendable, Encodable {
        public var id: Snowflake<DiscordChannel.ForumTag>?
        public var name: String
        public var moderated: Bool?
        public var emoji_id: Snowflake<PartialEmoji>?
        public var emoji_name: String?

        public init(id: Snowflake<DiscordChannel.ForumTag>? = nil, name: String, moderated: Bool? = nil, emoji_id: Snowflake<PartialEmoji>? = nil, emoji_name: String? = nil) {
            self.id = id
            self.name = name
            self.moderated = moderated
            self.emoji_id = emoji_id
            self.emoji_name = emoji_name
        }
    }

    /// https://discord.com/developers/docs/resources/channel#modify-channel-json-params-guild-channel
    public struct ModifyGuildChannel: Sendable, Encodable, ValidatablePayload {
        public var name: String?
        public var type: DiscordChannel.Kind?
        public var position: Int?
        public var topic: String?
        public var nsfw: Bool?
        public var rate_limit_per_user: Int?
        public var bitrate: Int?
        public var user_limit: Int?
        public var permission_overwrites: [PartialChannelOverwrite]?
        public var parent_id: AnySnowflake?
        public var rtc_region: String?
        public var video_quality_mode: DiscordChannel.VideoQualityMode?
        public var default_auto_archive_duration: DiscordChannel.AutoArchiveDuration?
        public var flags: IntBitField<DiscordChannel.Flag>?
        public var available_tags: [PartialForumTag]?
        public var default_reaction_emoji: DiscordChannel.DefaultReaction?
        public var default_thread_rate_limit_per_user: Int?
        public var default_sort_order: DiscordChannel.SortOrder?
        public var default_forum_layout: DiscordChannel.ForumLayout?

        public init(name: String? = nil, type: DiscordChannel.Kind? = nil, position: Int? = nil, topic: String? = nil, nsfw: Bool? = nil, rate_limit_per_user: Int? = nil, bitrate: Int? = nil, user_limit: Int? = nil, permission_overwrites: [PartialChannelOverwrite]? = nil, parent_id: AnySnowflake? = nil, rtc_region: String? = nil, video_quality_mode: DiscordChannel.VideoQualityMode? = nil, default_auto_archive_duration: DiscordChannel.AutoArchiveDuration? = nil, flags: [DiscordChannel.Flag]? = nil, available_tags: [PartialForumTag]? = nil, default_reaction_emoji: DiscordChannel.DefaultReaction? = nil, default_thread_rate_limit_per_user: Int? = nil, default_sort_order: DiscordChannel.SortOrder? = nil, default_forum_layout: DiscordChannel.ForumLayout? = nil) {
            self.name = name
            self.type = type
            self.position = position
            self.topic = topic
            self.nsfw = nsfw
            self.rate_limit_per_user = rate_limit_per_user
            self.bitrate = bitrate
            self.user_limit = user_limit
            self.permission_overwrites = permission_overwrites
            self.parent_id = parent_id
            self.rtc_region = rtc_region
            self.video_quality_mode = video_quality_mode
            self.default_auto_archive_duration = default_auto_archive_duration
            self.flags = flags.map { .init($0) }
            self.available_tags = available_tags
            self.default_reaction_emoji = default_reaction_emoji
            self.default_thread_rate_limit_per_user = default_thread_rate_limit_per_user
            self.default_sort_order = default_sort_order
            self.default_forum_layout = default_forum_layout
        }

        public func validate() -> [ValidationFailure] {
            validateCharacterCountInRangeOrNil(name, min: 1, max: 100, name: "name")
            validateCharacterCountDoesNotExceed(topic, max: 4_096, name: "topic")
            validateNumberInRange(
                rate_limit_per_user,
                min: 0,
                max: 21_600,
                name: "rate_limit_per_user"
            )
            validateNumberInRange(bitrate, min: 8_000, max: 384_000, name: "bitrate")
            validateNumberInRange(user_limit, min: 0, max: 10_000, name: "user_limit")
            validateOnlyContains(
                flags?.values,
                name: "flags",
                reason: "Can only contain 'requireTag'",
                where: { .requireTag == $0 }
            )
            validateElementCountDoesNotExceed(available_tags, max: 20, name: "available_tags")
        }
    }

    /// https://discord.com/developers/docs/resources/channel#modify-channel-json-params-thread
    public struct ModifyThreadChannel: Sendable, Encodable, ValidatablePayload {
        public var name: String?
        public var archived: Bool?
        public var auto_archive_duration: DiscordChannel.AutoArchiveDuration?
        public var locked: Bool?
        public var invitable: Bool?
        public var rate_limit_per_user: Int?
        public var flags: IntBitField<DiscordChannel.Flag>?
        public var applied_tags: [PartialForumTag]?

        public init(name: String? = nil, archived: Bool? = nil, auto_archive_duration: DiscordChannel.AutoArchiveDuration? = nil, locked: Bool? = nil, invitable: Bool? = nil, rate_limit_per_user: Int? = nil, flags: [DiscordChannel.Flag]? = nil, applied_tags: [PartialForumTag]? = nil) {
            self.name = name
            self.archived = archived
            self.auto_archive_duration = auto_archive_duration
            self.locked = locked
            self.invitable = invitable
            self.rate_limit_per_user = rate_limit_per_user
            self.flags = flags.map { .init($0) }
            self.applied_tags = applied_tags
        }

        public func validate() -> [ValidationFailure] {
            validateCharacterCountInRangeOrNil(name, min: 1, max: 100, name: "name")
            validateNumberInRange(
                rate_limit_per_user,
                min: 0,
                max: 21_600,
                name: "rate_limit_per_user"
            )
            validateOnlyContains(
                flags?.values,
                name: "flags",
                reason: "Can only contain 'pinned'",
                where: { .pinned == $0 }
            )
            validateElementCountDoesNotExceed(applied_tags, max: 5, name: "applied_tags")
        }
    }

    /// https://discord.com/developers/docs/resources/guild#create-guild-channel-json-params
    public struct CreateGuildChannel: Sendable, Encodable, ValidatablePayload {
        public var name: String
        public var type: DiscordChannel.Kind?
        public var position: Int?
        public var topic: String?
        public var nsfw: Bool?
        public var rate_limit_per_user: Int?
        public var bitrate: Int?
        public var user_limit: Int?
        public var permission_overwrites: [PartialChannelOverwrite]?
        public var parent_id: AnySnowflake?
        public var rtc_region: String?
        public var video_quality_mode: DiscordChannel.VideoQualityMode?
        public var default_auto_archive_duration: DiscordChannel.AutoArchiveDuration?
        public var available_tags: [PartialForumTag]?
        public var default_reaction_emoji: DiscordChannel.DefaultReaction?
        public var default_sort_order: DiscordChannel.SortOrder?

        public init(name: String, type: DiscordChannel.Kind? = nil, position: Int? = nil, topic: String? = nil, nsfw: Bool? = nil, rate_limit_per_user: Int? = nil, bitrate: Int? = nil, user_limit: Int? = nil, permission_overwrites: [PartialChannelOverwrite]? = nil, parent_id: AnySnowflake? = nil, rtc_region: String? = nil, video_quality_mode: DiscordChannel.VideoQualityMode? = nil, default_auto_archive_duration: DiscordChannel.AutoArchiveDuration? = nil, flags: [DiscordChannel.Flag]? = nil, available_tags: [PartialForumTag]? = nil, default_reaction_emoji: DiscordChannel.DefaultReaction? = nil, default_thread_rate_limit_per_user: Int? = nil, default_sort_order: DiscordChannel.SortOrder? = nil, default_forum_layout: DiscordChannel.ForumLayout? = nil) {
            self.name = name
            self.type = type
            self.position = position
            self.topic = topic
            self.nsfw = nsfw
            self.rate_limit_per_user = rate_limit_per_user
            self.bitrate = bitrate
            self.user_limit = user_limit
            self.permission_overwrites = permission_overwrites
            self.parent_id = parent_id
            self.rtc_region = rtc_region
            self.video_quality_mode = video_quality_mode
            self.default_auto_archive_duration = default_auto_archive_duration
            self.available_tags = available_tags
            self.default_reaction_emoji = default_reaction_emoji
            self.default_sort_order = default_sort_order
        }

        public func validate() -> [ValidationFailure] {
            validateCharacterCountInRange(name, min: 1, max: 100, name: "name")
            validateCharacterCountDoesNotExceed(topic, max: 4_096, name: "topic")
            validateNumberInRange(
                rate_limit_per_user,
                min: 0,
                max: 21_600,
                name: "rate_limit_per_user"
            )
            validateNumberInRange(bitrate, min: 8_000, max: 384_000, name: "bitrate")
            validateNumberInRange(user_limit, min: 0, max: 10_000, name: "user_limit")
            validateElementCountDoesNotExceed(available_tags, max: 20, name: "available_tags")
        }
    }

    public struct CreateGuild: Sendable, Encodable, ValidatablePayload {
        public var name: String
        public var icon: ImageData?
        public var verification_level: Guild.VerificationLevel?
        public var default_message_notifications: Guild.DefaultMessageNotificationLevel?
        public var explicit_content_filter: Guild.ExplicitContentFilterLevel?
        public var roles: [Role]?
        public var channels: [DiscordChannel]?
        public var afk_channel_id: Snowflake<DiscordChannel>?
        public var afk_timeout: Guild.AFKTimeout?
        public var system_channel_id: Snowflake<DiscordChannel>?
        public var system_channel_flags: IntBitField<Guild.SystemChannelFlag>?

        public init(name: String, icon: ImageData? = nil, verification_level: Guild.VerificationLevel? = nil, default_message_notifications: Guild.DefaultMessageNotificationLevel? = nil, explicit_content_filter: Guild.ExplicitContentFilterLevel? = nil, roles: [Role]? = nil, channels: [DiscordChannel]? = nil, afk_channel_id: Snowflake<DiscordChannel>? = nil, afk_timeout: Guild.AFKTimeout? = nil, system_channel_id: Snowflake<DiscordChannel>? = nil, system_channel_flags: [Guild.SystemChannelFlag]? = nil) {
            self.name = name
            self.icon = icon
            self.verification_level = verification_level
            self.default_message_notifications = default_message_notifications
            self.explicit_content_filter = explicit_content_filter
            self.roles = roles
            self.channels = channels
            self.afk_channel_id = afk_channel_id
            self.afk_timeout = afk_timeout
            self.system_channel_id = system_channel_id
            self.system_channel_flags = system_channel_flags.map { .init($0) }
        }

        public func validate() -> [ValidationFailure] {
            validateCharacterCountInRange(name, min: 2, max: 100, name: "name")
        }
    }

    public struct ModifyGuild: Sendable, Encodable, ValidatablePayload {
        public var name: String?
        public var verification_level: Guild.VerificationLevel?
        public var default_message_notifications: Guild.DefaultMessageNotificationLevel?
        public var explicit_content_filter: Guild.ExplicitContentFilterLevel?
        public var afk_channel_id: Snowflake<DiscordChannel>?
        public var afk_timeout: Guild.AFKTimeout?
        public var icon: ImageData?
        public var owner_id: Snowflake<DiscordUser>?
        public var splash: ImageData?
        public var discovery_splash: ImageData?
        public var banner: ImageData?
        public var system_channel_id: Snowflake<DiscordChannel>?
        public var system_channel_flags: IntBitField<Guild.SystemChannelFlag>?
        public var rules_channel_id: Snowflake<DiscordChannel>?
        public var public_updates_channel_id: Snowflake<DiscordChannel>?
        public var preferred_locale: DiscordLocale?
        public var features: [Guild.Feature]?
        public var description: String?
        public var premium_progress_bar_enabled: Bool?

        public init(name: String? = nil, verification_level: Guild.VerificationLevel? = nil, default_message_notifications: Guild.DefaultMessageNotificationLevel? = nil, explicit_content_filter: Guild.ExplicitContentFilterLevel? = nil, afk_channel_id: Snowflake<DiscordChannel>? = nil, afk_timeout: Guild.AFKTimeout? = nil, icon: ImageData? = nil, owner_id: Snowflake<DiscordUser>? = nil, splash: ImageData? = nil, discovery_splash: ImageData? = nil, banner: ImageData? = nil, system_channel_id: Snowflake<DiscordChannel>? = nil, system_channel_flags: [Guild.SystemChannelFlag]? = nil, rules_channel_id: Snowflake<DiscordChannel>? = nil, public_updates_channel_id: Snowflake<DiscordChannel>? = nil, preferred_locale: DiscordLocale? = nil, features: [Guild.Feature]? = nil, description: String? = nil, premium_progress_bar_enabled: Bool? = nil) {
            self.name = name
            self.verification_level = verification_level
            self.default_message_notifications = default_message_notifications
            self.explicit_content_filter = explicit_content_filter
            self.afk_channel_id = afk_channel_id
            self.afk_timeout = afk_timeout
            self.icon = icon
            self.owner_id = owner_id
            self.splash = splash
            self.discovery_splash = discovery_splash
            self.banner = banner
            self.system_channel_id = system_channel_id
            self.system_channel_flags = system_channel_flags.map { .init($0) }
            self.rules_channel_id = rules_channel_id
            self.public_updates_channel_id = public_updates_channel_id
            self.preferred_locale = preferred_locale
            self.features = features
            self.description = description
            self.premium_progress_bar_enabled = premium_progress_bar_enabled
        }

        public func validate() -> [ValidationFailure] {
            validateCharacterCountInRange(name, min: 2, max: 100, name: "name")
        }
    }
}
