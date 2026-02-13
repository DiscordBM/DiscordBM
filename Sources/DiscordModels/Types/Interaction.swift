import Foundation

/// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-structure
public struct Interaction: Sendable, Codable {

    public enum Error: Swift.Error, CustomStringConvertible {
        case optionNotFoundInCommand(name: String, command: ApplicationCommand)
        case optionNotFoundInOption(name: String, parentOption: ApplicationCommand.Option)
        case optionNotFoundInOptions(name: String, options: [ApplicationCommand.Option]?)

        case componentNotFoundInComponents(customId: String, components: [ActionRow.Component])
        case componentNotFoundInActionRow(customId: String, actionRow: ActionRow)
        case componentNotFoundInActionRows(customId: String, actionRows: [ActionRow])

        case componentWasNotOfKind(kind: String, component: ActionRow.Component)

        case dataWasNotOfKind(kind: String, data: Interaction.Data)

        public var description: String {
            switch self {
            case let .optionNotFoundInCommand(name, command):
                return "Interaction.Error.optionNotFoundInCommand(name: \(name), command: \(command))"
            case let .optionNotFoundInOption(name, parentOption):
                return "Interaction.Error.optionNotFoundInOption(name: \(name), parentOption: \(parentOption))"
            case let .optionNotFoundInOptions(name, options):
                return
                    "Interaction.Error.optionNotFoundInOption(name: \(name), options: \(String(describing: options)))"
            case let .componentNotFoundInComponents(customId, components):
                return
                    "Interaction.Error.componentNotFoundInComponents(customId: \(customId), components: \(components))"
            case let .componentNotFoundInActionRow(customId, actionRow):
                return "Interaction.Error.componentNotFoundInActionRow(customId: \(customId), actionRow: \(actionRow))"
            case let .componentNotFoundInActionRows(customId, actionRows):
                return
                    "Interaction.Error.componentNotFoundInActionRows(customId: \(customId), actionRows: \(actionRows))"
            case let .componentWasNotOfKind(kind, component):
                return "Interaction.Error.componentWasNotOfKind(kind: \(kind), component: \(component))"
            case let .dataWasNotOfKind(kind, data):
                return "Interaction.Error.dataWasNotOfKind(kind: \(kind), data: \(data))"
            }
        }
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-type
    @UnstableEnum<_Int_CompatibilityTypealias>
    public enum Kind: Sendable, Codable {
        case ping  // 1
        case applicationCommand  // 2
        case messageComponent  // 3
        case applicationCommandAutocomplete  // 4
        case modalSubmit  // 5
        case __undocumented(_Int_CompatibilityTypealias)
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-context-types
    @UnstableEnum<_Int_CompatibilityTypealias>
    public enum ContextKind: Sendable, Codable {
        case guild  // 0
        case botDm  // 1
        case privateChannel  // 2
        case __undocumented(_Int_CompatibilityTypealias)
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-application-command-data-structure
    public struct ApplicationCommand: Sendable, Codable {

        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-resolved-data-structure
        public struct ResolvedData: Sendable, Codable {

            /// https://docs.discord.com/developers/resources/channel#channel-object-channel-structure
            /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-resolved-data-structure
            public struct PartialChannel: Sendable, Codable {
                public var id: ChannelSnowflake
                public var type: DiscordChannel.Kind
                public var name: String?
                public var permissions: StringBitField<Permission>?
                public var last_message_id: MessageSnowflake?
                public var last_pin_timestamp: DiscordTimestamp?
                public var nsfw: Bool?
                public var parent_id: AnySnowflake?
                public var guild_id: GuildSnowflake?
                public var flags: IntBitField<DiscordChannel.Flag>?
                public var rate_limit_per_user: Int?
                public var topic: String?
                public var position: Int?
                public var thread_metadata: ThreadMetadata?
            }

            public var users: [UserSnowflake: DiscordUser]?
            public var members: [UserSnowflake: Guild.PartialMember]?
            public var roles: [RoleSnowflake: Role]?
            public var channels: [ChannelSnowflake: PartialChannel]?
            public var messages: [MessageSnowflake: DiscordChannel.PartialMessage]?
            public var attachments: [AttachmentSnowflake: DiscordChannel.Message.Attachment]?
        }

        /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-application-command-interaction-data-option-structure
        public struct Option: Sendable, Codable {
            public var name: String
            public var type: DiscordModels.ApplicationCommand.Option.Kind
            public var value: StringIntDoubleBool?
            public var options: [Option]?
            public var focused: Bool?

            /// Requires a `String` value or throws `StringIntDoubleBool.Error`/`OptionalError`.
            @inlinable
            public func requireString(
                file: String = #file,
                function: String = #function,
                line: UInt = #line
            ) throws -> String {
                try self.value
                    .requireValue(file: file, function: function, line: line)
                    .requireString()
            }

            /// Requires a `Int` value or throws `StringIntDoubleBool.Error`/`OptionalError`.
            @inlinable
            public func requireInt(
                file: String = #file,
                function: String = #function,
                line: UInt = #line
            ) throws -> _Int_CompatibilityTypealias {
                try self.value
                    .requireValue(file: file, function: function, line: line)
                    .requireInt()
            }

            /// Requires a `Double` value or throws `StringIntDoubleBool.Error`/`OptionalError`.
            @inlinable
            public func requireDouble(
                file: String = #file,
                function: String = #function,
                line: UInt = #line
            ) throws -> Double {
                try self.value
                    .requireValue(file: file, function: function, line: line)
                    .requireDouble()
            }

            /// Requires a `Bool` value or throws `StringIntDoubleBool.Error`/`OptionalError`.
            @inlinable
            public func requireBool(
                file: String = #file,
                function: String = #function,
                line: UInt = #line
            ) throws -> Bool {
                try self.value
                    .requireValue(file: file, function: function, line: line)
                    .requireBool()
            }

            /// Returns the option with the `name`, or `nil`.
            @inlinable
            public func option(named name: String) -> Option? {
                self.options?.first(where: { $0.name == name })
            }

            /// Returns the option with the `name`, or throws `Interaction.Error`/`OptionalError`.
            @inlinable
            public func requireOption(
                named name: String,
                file: String = #file,
                function: String = #function,
                line: UInt = #line
            ) throws -> Option {
                let options = try self.options.requireValue(
                    file: file,
                    function: function,
                    line: line
                )
                if let option = options.first(where: { $0.name == name }) {
                    return option
                } else {
                    throw Error.optionNotFoundInOption(name: name, parentOption: self)
                }
            }
        }

        public var id: CommandSnowflake
        public var name: String
        public var type: Kind
        public var resolved: ResolvedData?
        public var options: [Option]?
        public var guild_id: GuildSnowflake?
        public var target_id: AnySnowflake?

        /// Returns the option with the `name`, or `nil`.
        @inlinable
        public func option(named name: String) -> Option? {
            self.options?.first(where: { $0.name == name })
        }

        /// Returns the option with the `name`, or throws `Interaction.Error`/`OptionalError`.
        @inlinable
        public func requireOption(
            named name: String,
            file: String = #file,
            function: String = #function,
            line: UInt = #line
        ) throws -> Option {
            let options = try self.options.requireValue(
                file: file,
                function: function,
                line: line
            )
            if let option = options.first(where: { $0.name == name }) {
                return option
            } else {
                throw Error.optionNotFoundInCommand(name: name, command: self)
            }
        }
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-message-component-data-structure
    public struct MessageComponent: Sendable, Codable {
        public var custom_id: String
        public var component_type: ActionRow.Kind
        public var values: [String]?
        public var resolved: Interaction.ApplicationCommand.ResolvedData?
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-modal-submit-data-structure
    public struct ModalSubmit: Sendable, Codable {
        public var custom_id: String
        public var components: [ActionRow]
        public var resolved: Interaction.ApplicationCommand.ResolvedData?
    }

    /// https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-data
    public enum Data: Sendable {
        case applicationCommand(ApplicationCommand)
        case messageComponent(MessageComponent)
        case modalSubmit(ModalSubmit)

        /// Requires an `ApplicationCommand` value or throws `Interaction.Error`.
        public func requireApplicationCommand() throws -> ApplicationCommand {
            switch self {
            case let .applicationCommand(applicationCommand):
                return applicationCommand
            default:
                throw Error.dataWasNotOfKind(kind: "applicationCommand", data: self)
            }
        }

        /// Requires a `MessageComponent` value or throws `Interaction.Error`.
        public func requireMessageComponent() throws -> MessageComponent {
            switch self {
            case let .messageComponent(messageComponent):
                return messageComponent
            default:
                throw Error.dataWasNotOfKind(kind: "messageComponent", data: self)
            }
        }

        /// Requires a `ModalSubmit` value or throws `Interaction.Error`.
        public func requireModalSubmit() throws -> ModalSubmit {
            switch self {
            case let .modalSubmit(modalSubmit):
                return modalSubmit
            default:
                throw Error.dataWasNotOfKind(kind: "modalSubmit", data: self)
            }
        }
    }

    public var id: InteractionSnowflake
    public var application_id: ApplicationSnowflake
    public var type: Kind
    public var data: Data?
    public var guild: PartialGuild?
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
    public var entitlements: [Entitlement]
    public var authorizing_integration_owners: [DiscordApplication.IntegrationKind: AnySnowflake]?
    public var context: ContextKind?
    public var attachment_size_limit: Int?

    @available(
        *,
        deprecated,
        message:
            "This property is not documented and will be removed in a future version of DiscordBM, unless it becomes documented. Will always be nil for now"
    )
    public var entitlement_sku_ids: [String]? = nil

    enum CodingKeys: CodingKey {
        case id
        case application_id
        case type
        case data
        case guild
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
        case entitlements
        case authorizing_integration_owners
        case context
        case attachment_size_limit
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
        case .__undocumented:
            self.data = nil
        }
        self.guild = try container.decodeIfPresent(PartialGuild.self, forKey: .guild)
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
        self.entitlements = try container.decode(
            [Entitlement].self,
            forKey: .entitlements
        )
        self.authorizing_integration_owners = try? container.decode(
            [DiscordApplication.IntegrationKind: AnySnowflake].self,
            forKey: .authorizing_integration_owners
        )
        self.context = try? container.decodeIfPresent(
            ContextKind.self,
            forKey: .context
        )
        self.attachment_size_limit = try container.decodeIfPresent(
            Int.self,
            forKey: .attachment_size_limit
        )
    }

    public func encode(to encoder: any Encoder) throws {
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
        try container.encodeIfPresent(self.guild, forKey: .guild)
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
        try container.encode(self.entitlements, forKey: .entitlements)
        try container.encodeIfPresent(self.attachment_size_limit, forKey: .attachment_size_limit)
    }
}

extension [Interaction.ApplicationCommand.Option] {
    /// Returns the option with the `name`, or `nil`.
    @inlinable
    public func option(named name: String) -> Interaction.ApplicationCommand.Option? {
        self.first(where: { $0.name == name })
    }

    /// Returns the option with the `name`, or throws `Interaction.Error`.
    @inlinable
    public func requireOption(named name: String) throws -> Interaction.ApplicationCommand.Option {
        if let option = self.first(where: { $0.name == name }) {
            return option
        } else {
            throw Interaction.Error.optionNotFoundInOptions(name: name, options: self)
        }
    }
}

/// https://discord.com/developers/docs/interactions/receiving-and-responding#message-interaction-object-message-interaction-structure
public struct MessageInteraction: Sendable, Codable {
    /// FIXME: This is an `InteractionSnowflake`.
    public var id: String
    /// The same as `id`, but with the correct type of `InteractionSnowflake`.
    /// FIXME: Remove when the type of `id` is corrected.
    public var interaction_id: InteractionSnowflake {
        get {
            InteractionSnowflake(self.id)
        }
        set {
            self.id = newValue.rawValue
        }
    }
    public var type: Interaction.Kind
    public var name: String
    public var user: DiscordUser
    public var member: Guild.PartialMember?
}

extension Interaction {
    /// https://discord.com/developers/docs/components/reference
    /// `ActionRow` is an attempt to simplify/beautify Discord's messy components.
    /// Anything inside `ActionRow` must not be used on its own for decoding/encoding purposes.
    /// For example you always need to use `[ActionRow]` instead of `[ActionRow.Component]`.
    public struct ActionRow: Sendable, Codable, ExpressibleByArrayLiteral, ValidatablePayload {

        /// https://discord.com/developers/docs/components/reference#component-object-component-types
        @UnstableEnum<_Int_CompatibilityTypealias>
        public enum Kind: Sendable, Codable {
            case actionRow  // 1
            case button  // 2
            case stringSelect  // 3
            case textInput  // 4
            case userSelect  // 5
            case roleSelect  // 6
            case mentionableSelect  // 7
            case channelSelect  // 8
            case section  // 9
            case textDisplay  // 10
            case thumbnail  // 11
            case mediaGallery  // 12
            case file  // 13
            case separator  // 14
            case container  // 17
            case label  // 18
            case fileUpload  // 19
            case radioGroup  // 21
            case checkboxGroup  // 22
            case checkbox  // 23
            case __undocumented(_Int_CompatibilityTypealias)
        }

        /// https://discord.com/developers/docs/components/reference#button
        public struct Button: Sendable, Codable, ValidatablePayload {

            /// https://discord.com/developers/docs/components/reference#button-button-styles
            @UnstableEnum<_Int_CompatibilityTypealias>
            public enum Style: Sendable, Codable {
                case primary  // 1
                case secondary  // 2
                case success  // 3
                case danger  // 4
                case link  // 5
                case premium  // 6
                case __undocumented(_Int_CompatibilityTypealias)
            }

            /// The same as ``Style``, but has no `link`.
            /// https://discord.com/developers/docs/components/reference#button-button-styles
            public enum NonLinkStyle: Sendable {
                case primary
                case secondary
                case success
                case danger
                case premium

                /// This case serves as a way of discouraging exhaustive switch statements
                case __DO_NOT_USE_THIS_CASE

                public func toStyle() -> Style {
                    switch self {
                    case .primary: return .primary
                    case .secondary: return .secondary
                    case .success: return .success
                    case .danger: return .danger
                    case .premium: return .premium
                    case .__DO_NOT_USE_THIS_CASE:
                        fatalError(
                            "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
                        )
                    }
                }

                public init?(style: Style) {
                    switch style {
                    case .primary: self = .primary
                    case .secondary: self = .secondary
                    case .success: self = .success
                    case .danger: self = .danger
                    case .premium: self = .premium
                    case .link: return nil
                    case .__undocumented: return nil
                    }
                }
            }

            public var id: Int?
            public var style: Style
            public var label: String?
            public var emoji: Emoji?
            public var custom_id: String?
            public var sku_id: SKUSnowflake?
            public var url: String?
            public var disabled: Bool?

            /// FIXME: Most button below don't need `sku_id`.

            /// Makes a non-link button.
            public init(
                id: Int? = nil,
                style: NonLinkStyle,
                label: String,
                custom_id: String,
                sku_id: SKUSnowflake? = nil,
                disabled: Bool? = nil
            ) {
                self.id = id
                self.style = style.toStyle()
                self.label = label
                self.emoji = nil
                self.custom_id = custom_id
                self.sku_id = sku_id
                self.url = nil
                self.disabled = disabled
            }

            /// Makes a non-link button.
            public init(
                id: Int? = nil,
                style: NonLinkStyle,
                emoji: Emoji,
                custom_id: String,
                sku_id: SKUSnowflake? = nil,
                disabled: Bool? = nil
            ) {
                self.id = id
                self.style = style.toStyle()
                self.label = nil
                self.emoji = emoji
                self.custom_id = custom_id
                self.sku_id = sku_id
                self.url = nil
                self.disabled = disabled
            }

            /// Makes a non-link button.
            public init(
                id: Int? = nil,
                style: NonLinkStyle,
                label: String,
                emoji: Emoji,
                custom_id: String,
                sku_id: SKUSnowflake? = nil,
                disabled: Bool? = nil
            ) {
                self.id = id
                self.style = style.toStyle()
                self.label = label
                self.emoji = emoji
                self.custom_id = custom_id
                self.sku_id = sku_id
                self.url = nil
                self.disabled = disabled
            }

            /// Makes a link button.
            public init(
                id: Int? = nil,
                label: String,
                url: String,
                sku_id: SKUSnowflake? = nil,
                disabled: Bool? = nil
            ) {
                self.id = id
                self.style = .link
                self.label = label
                self.emoji = nil
                self.custom_id = nil
                self.sku_id = sku_id
                self.url = url
                self.disabled = disabled
            }

            /// Makes a link button.
            public init(
                id: Int? = nil,
                emoji: Emoji,
                url: String,
                sku_id: SKUSnowflake? = nil,
                disabled: Bool? = nil
            ) {
                self.id = id
                self.style = .link
                self.label = nil
                self.emoji = emoji
                self.custom_id = nil
                self.sku_id = sku_id
                self.url = url
                self.disabled = disabled
            }

            /// Makes a link button.
            public init(
                id: Int? = nil,
                label: String,
                emoji: Emoji,
                url: String,
                sku_id: SKUSnowflake? = nil,
                disabled: Bool? = nil
            ) {
                self.id = id
                self.style = .link
                self.label = label
                self.emoji = emoji
                self.custom_id = nil
                self.sku_id = sku_id
                self.url = url
                self.disabled = disabled
            }

            /// Makes a premium button.
            public init(
                id: Int? = nil,
                sku_id: SKUSnowflake,
                disabled: Bool? = nil
            ) {
                self.id = id
                self.style = .premium
                self.label = nil
                self.emoji = nil
                self.custom_id = nil
                self.sku_id = sku_id
                self.url = nil
                self.disabled = disabled
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountDoesNotExceed(label, max: 80, name: "label")
                validateCharacterCountInRangeOrNil(custom_id, min: 1, max: 100, name: "custom_id")
                validateCharacterCountDoesNotExceed(url, max: 512, name: "url")
            }
        }

        /// https://discord.com/developers/docs/components/reference#string-select
        public struct StringSelectMenu: Sendable, Codable, ValidatablePayload {

            /// https://discord.com/developers/docs/components/reference#string-select-select-option-structure
            public struct Option: Sendable, Codable, ValidatablePayload {
                public var label: String
                public var value: String
                public var description: String?
                public var emoji: Emoji?
                public var `default`: Bool?

                public init(
                    label: String,
                    value: String,
                    description: String? = nil,
                    emoji: Emoji? = nil,
                    `default`: Bool? = nil
                ) {
                    self.label = label
                    self.value = value
                    self.description = description
                    self.emoji = emoji
                    self.`default` = `default`
                }

                public func validate() -> [ValidationFailure] {
                    validateCharacterCountDoesNotExceed(label, max: 100, name: "label")
                    validateCharacterCountDoesNotExceed(value, max: 100, name: "value")
                    validateCharacterCountDoesNotExceed(description, max: 100, name: "description")
                }
            }

            public var id: Int?
            public var custom_id: String
            public var options: [Option]
            public var placeholder: String?
            public var min_values: Int?
            public var max_values: Int?
            public var required: Bool?
            public var disabled: Bool?
            public var values: [String]?

            public init(
                id: Int? = nil,
                custom_id: String,
                options: [Option],
                placeholder: String? = nil,
                min_values: Int? = nil,
                max_values: Int? = nil,
                required: Bool? = nil,
                disabled: Bool? = nil
            ) {
                self.id = id
                self.custom_id = custom_id
                self.options = options
                self.placeholder = placeholder
                self.min_values = min_values
                self.max_values = max_values
                self.required = required
                self.disabled = disabled
                self.values = nil
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountInRange(custom_id, min: 1, max: 100, name: "custom_id")
                validateCharacterCountDoesNotExceed(placeholder, max: 150, name: "placeholder")
                validateNumberInRangeOrNil(min_values, min: 0, max: 25, name: "min_values")
                validateNumberInRangeOrNil(max_values, min: 1, max: 25, name: "max_values")
                validateElementCountDoesNotExceed(options, max: 25, name: "options")
                options.validate()
            }
        }

        /// https://discord.com/developers/docs/components/reference#user-select-select-default-value-structure
        public struct DefaultValue: Sendable, Codable {

            /// https://discord.com/developers/docs/components/reference#user-select-select-default-value-structure
            public enum Kind: String, Sendable, Codable {
                case user
                case role
                case channel
            }

            public var id: AnySnowflake
            public var type: Kind

            public init(id: UserSnowflake) {
                self.id = AnySnowflake(id)
                self.type = .user
            }

            public init(id: RoleSnowflake) {
                self.id = AnySnowflake(id)
                self.type = .role
            }

            public init(id: ChannelSnowflake) {
                self.id = AnySnowflake(id)
                self.type = .channel
            }
        }

        /// https://discord.com/developers/docs/components/reference#channel-select
        public struct ChannelSelectMenu: Sendable, Codable, ValidatablePayload {
            public var id: Int?
            public var custom_id: String
            public var channel_types: [DiscordChannel.Kind]?
            public var placeholder: String?
            public var default_values: [DefaultValue]?
            public var min_values: Int?
            public var max_values: Int?
            public var required: Bool?
            public var disabled: Bool?
            public var values: [String]?

            public init(
                id: Int? = nil,
                custom_id: String,
                channel_types: [DiscordChannel.Kind]? = nil,
                placeholder: String? = nil,
                default_values: [DefaultValue]? = nil,
                min_values: Int? = nil,
                max_values: Int? = nil,
                required: Bool? = nil,
                disabled: Bool? = nil
            ) {
                self.id = id
                self.custom_id = custom_id
                self.channel_types = channel_types
                self.placeholder = placeholder
                self.default_values = default_values
                self.min_values = min_values
                self.max_values = max_values
                self.required = required
                self.disabled = disabled
                self.values = nil
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountInRange(custom_id, min: 1, max: 100, name: "custom_id")
                validateCharacterCountDoesNotExceed(placeholder, max: 150, name: "placeholder")
                validateNumberInRangeOrNil(min_values, min: 0, max: 25, name: "min_values")
                validateNumberInRangeOrNil(max_values, min: 1, max: 25, name: "max_values")
                validateElementCountInRange(
                    default_values,
                    min: min_values ?? 0,
                    max: max_values ?? .max,
                    name: "default_values"
                )
            }
        }

        /// https://discord.com/developers/docs/components/reference#user-select
        public struct SelectMenu: Sendable, Codable, ValidatablePayload {
            public var id: Int?
            public var custom_id: String
            public var placeholder: String?
            public var default_values: [DefaultValue]?
            public var min_values: Int?
            public var max_values: Int?
            public var required: Bool?
            public var disabled: Bool?
            public var values: [String]?

            public init(
                id: Int? = nil,
                custom_id: String,
                placeholder: String? = nil,
                default_values: [DefaultValue]? = nil,
                min_values: Int? = nil,
                max_values: Int? = nil,
                required: Bool? = nil,
                disabled: Bool? = nil
            ) {
                self.id = id
                self.custom_id = custom_id
                self.placeholder = placeholder
                self.default_values = default_values
                self.min_values = min_values
                self.max_values = max_values
                self.required = required
                self.disabled = disabled
                self.values = nil
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountInRange(custom_id, min: 1, max: 100, name: "custom_id")
                validateCharacterCountDoesNotExceed(placeholder, max: 150, name: "placeholder")
                validateNumberInRangeOrNil(min_values, min: 0, max: 25, name: "min_values")
                validateNumberInRangeOrNil(max_values, min: 1, max: 25, name: "max_values")
                validateElementCountInRange(
                    default_values,
                    min: min_values ?? 0,
                    max: max_values ?? .max,
                    name: "default_values"
                )
            }
        }

        /// https://discord.com/developers/docs/components/reference#text-input
        public struct TextInput: Sendable, Codable, ValidatablePayload {

            /// https://discord.com/developers/docs/components/reference#text-input-text-input-styles
            @UnstableEnum<_Int_CompatibilityTypealias>
            public enum Style: Sendable, Codable {
                case short  // 1
                case paragraph  // 2
                case __undocumented(_Int_CompatibilityTypealias)
            }

            public var id: Int?
            public var custom_id: String
            public var style: Style?
            public var label: String?
            public var min_length: Int?
            public var max_length: Int?
            public var required: Bool?
            public var value: String?
            public var placeholder: String?

            public init(
                id: Int? = nil,
                custom_id: String,
                style: Style? = nil,
                label: String? = nil,
                min_length: Int? = nil,
                max_length: Int? = nil,
                required: Bool? = nil,
                value: String? = nil,
                placeholder: String? = nil
            ) {
                self.id = id
                self.custom_id = custom_id
                self.style = style
                self.label = label
                self.min_length = min_length
                self.max_length = max_length
                self.required = required
                self.value = value
                self.placeholder = placeholder
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountInRange(custom_id, min: 1, max: 100, name: "custom_id")
                validateCharacterCountDoesNotExceed(label, max: 45, name: "label")
                validateNumberInRangeOrNil(min_length, min: 0, max: 4_000, name: "min_length")
                validateNumberInRangeOrNil(max_length, min: 1, max: 4_000, name: "max_length")
                validateCharacterCountDoesNotExceed(value, max: 4_000, name: "value")
                validateCharacterCountDoesNotExceed(placeholder, max: 100, name: "placeholder")
            }
        }

        /// https://discord.com/developers/docs/components/reference#section
        public struct Section: Sendable, Codable, ValidatablePayload {
            public var id: Int?
            public var components: [Component]
            public var accessory: Component

            public init(
                id: Int? = nil,
                components: [Component],
                accessory: Component
            ) {
                self.id = id
                self.components = components
                self.accessory = accessory
            }

            public func validate() -> [ValidationFailure] {
                validateElementCountInRange(components, min: 1, max: 3, name: "components")
                components.validate()
                accessory.validate()
            }
        }

        /// https://discord.com/developers/docs/components/reference#text-display
        public struct TextDisplay: Sendable, Codable, ValidatablePayload {
            public var id: Int?
            public var content: String

            public init(id: Int? = nil, content: String) {
                self.id = id
                self.content = content
            }

            public func validate() -> [ValidationFailure] {}
        }

        /// https://discord.com/developers/docs/components/reference#unfurled-media-item
        public struct UnfurledMediaItem: Sendable, Codable {
            public var url: String
            public var proxy_url: String?
            public var height: Int?
            public var width: Int?
            public var content_type: String?
            public var attachment_id: AttachmentSnowflake?

            public init(
                url: String,
                proxy_url: String? = nil,
                height: Int? = nil,
                width: Int? = nil,
                content_type: String? = nil,
                attachment_id: AttachmentSnowflake? = nil
            ) {
                self.url = url
                self.proxy_url = proxy_url
                self.height = height
                self.width = width
                self.content_type = content_type
                self.attachment_id = attachment_id
            }
        }

        /// https://discord.com/developers/docs/components/reference#thumbnail
        public struct Thumbnail: Sendable, Codable, ValidatablePayload {
            public var id: Int?
            public var media: UnfurledMediaItem
            public var description: String?
            public var spoiler: Bool?

            public init(
                id: Int? = nil,
                media: UnfurledMediaItem,
                description: String? = nil,
                spoiler: Bool? = nil
            ) {
                self.id = id
                self.media = media
                self.description = description
                self.spoiler = spoiler
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountDoesNotExceed(description, max: 1_024, name: "description")
            }
        }

        /// https://discord.com/developers/docs/components/reference#media-gallery
        public struct MediaGallery: Sendable, Codable, ValidatablePayload {

            /// https://discord.com/developers/docs/components/reference#media-gallery-media-gallery-item-structure
            public struct Item: Sendable, Codable, ValidatablePayload {
                public var media: UnfurledMediaItem
                public var description: String?
                public var spoiler: Bool?

                public init(
                    media: UnfurledMediaItem,
                    description: String? = nil,
                    spoiler: Bool? = nil
                ) {
                    self.media = media
                    self.description = description
                    self.spoiler = spoiler
                }

                public func validate() -> [ValidationFailure] {
                    validateCharacterCountDoesNotExceed(description, max: 1_024, name: "description")
                }
            }

            public var id: Int?
            public var items: [Item]

            public init(id: Int? = nil, items: [Item]) {
                self.id = id
                self.items = items
            }

            public func validate() -> [ValidationFailure] {
                validateElementCountInRange(items, min: 1, max: 10, name: "items")
                items.validate()
            }
        }

        /// https://discord.com/developers/docs/components/reference#file
        public struct File: Sendable, Codable, ValidatablePayload {
            public var id: Int?
            public var file: UnfurledMediaItem
            public var spoiler: Bool?
            public var name: String?
            public var size: Int?

            public init(
                id: Int? = nil,
                file: UnfurledMediaItem,
                spoiler: Bool? = nil
            ) {
                self.id = id
                self.file = file
                self.spoiler = spoiler
                self.name = nil
                self.size = nil
            }

            public func validate() -> [ValidationFailure] {}
        }

        /// https://discord.com/developers/docs/components/reference#separator
        public struct Separator: Sendable, Codable, ValidatablePayload {

            /// https://discord.com/developers/docs/components/reference#separator
            @UnstableEnum<_Int_CompatibilityTypealias>
            public enum Spacing: Sendable, Codable {
                case small  // 1
                case large  // 2
                case __undocumented(_Int_CompatibilityTypealias)
            }

            public var id: Int?
            public var divider: Bool?
            public var spacing: Spacing?

            public init(id: Int? = nil, divider: Bool? = nil, spacing: Spacing? = nil) {
                self.id = id
                self.divider = divider
                self.spacing = spacing
            }

            public func validate() -> [ValidationFailure] {}
        }

        /// https://discord.com/developers/docs/components/reference#container
        public struct Container: Sendable, Codable, ValidatablePayload {
            public var id: Int?
            public var components: [Component]
            public var accent_color: DiscordColor?
            public var spoiler: Bool?

            public init(
                id: Int? = nil,
                components: [Component],
                accent_color: DiscordColor? = nil,
                spoiler: Bool? = nil
            ) {
                self.id = id
                self.components = components
                self.accent_color = accent_color
                self.spoiler = spoiler
            }

            public func validate() -> [ValidationFailure] {
                components.validate()
            }
        }

        /// https://discord.com/developers/docs/components/reference#label
        public struct Label: Sendable, Codable, ValidatablePayload {
            public var id: Int?
            public var label: String
            public var description: String?
            public var component: Component

            public init(
                id: Int? = nil,
                label: String,
                description: String? = nil,
                component: Component
            ) {
                self.id = id
                self.label = label
                self.description = description
                self.component = component
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountDoesNotExceed(label, max: 45, name: "label")
                validateCharacterCountDoesNotExceed(description, max: 100, name: "description")
                component.validate()
            }
        }

        /// https://discord.com/developers/docs/components/reference#file-upload
        public struct FileUpload: Sendable, Codable, ValidatablePayload {
            public var id: Int?
            public var custom_id: String
            public var min_values: Int?
            public var max_values: Int?
            public var required: Bool?
            public var values: [String]?

            public init(
                id: Int? = nil,
                custom_id: String,
                min_values: Int? = nil,
                max_values: Int? = nil,
                required: Bool? = nil
            ) {
                self.id = id
                self.custom_id = custom_id
                self.min_values = min_values
                self.max_values = max_values
                self.required = required
                self.values = nil
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountInRange(custom_id, min: 1, max: 100, name: "custom_id")
                validateNumberInRangeOrNil(min_values, min: 0, max: 10, name: "min_values")
                validateNumberInRangeOrNil(max_values, min: 1, max: 10, name: "max_values")
            }
        }

        /// https://discord.com/developers/docs/components/reference#radio-group
        public struct RadioGroup: Sendable, Codable, ValidatablePayload {

            /// https://discord.com/developers/docs/components/reference#radio-group-option-structure
            public struct Option: Sendable, Codable, ValidatablePayload {
                public var value: String
                public var label: String
                public var description: String?
                public var `default`: Bool?

                public init(
                    value: String,
                    label: String,
                    description: String? = nil,
                    `default`: Bool? = nil
                ) {
                    self.value = value
                    self.label = label
                    self.description = description
                    self.`default` = `default`
                }

                public func validate() -> [ValidationFailure] {
                    validateCharacterCountDoesNotExceed(value, max: 100, name: "value")
                    validateCharacterCountDoesNotExceed(label, max: 100, name: "label")
                    validateCharacterCountDoesNotExceed(description, max: 100, name: "description")
                }
            }

            public var id: Int?
            public var custom_id: String
            public var options: [Option]?
            public var required: Bool?
            public var value: String?

            public init(
                id: Int? = nil,
                custom_id: String,
                options: [Option],
                required: Bool? = nil
            ) {
                self.id = id
                self.custom_id = custom_id
                self.options = options
                self.required = required
                self.value = nil
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountInRange(custom_id, min: 1, max: 100, name: "custom_id")
                validateElementCountInRange(options, min: 2, max: 10, name: "options")
                validateCharacterCountDoesNotExceed(value, max: 100, name: "value")
                options?.validate()
            }
        }

        /// https://discord.com/developers/docs/components/reference#checkbox-group
        public struct CheckboxGroup: Sendable, Codable, ValidatablePayload {

            /// https://discord.com/developers/docs/components/reference#checkbox-group-option-structure
            public struct Option: Sendable, Codable, ValidatablePayload {
                public var value: String
                public var label: String
                public var description: String?
                public var `default`: Bool?

                public init(
                    value: String,
                    label: String,
                    description: String? = nil,
                    `default`: Bool? = nil
                ) {
                    self.value = value
                    self.label = label
                    self.description = description
                    self.`default` = `default`
                }

                public func validate() -> [ValidationFailure] {
                    validateCharacterCountDoesNotExceed(value, max: 100, name: "value")
                    validateCharacterCountDoesNotExceed(label, max: 100, name: "label")
                    validateCharacterCountDoesNotExceed(description, max: 100, name: "description")
                }
            }

            public var id: Int?
            public var custom_id: String
            public var options: [Option]?
            public var min_values: Int?
            public var max_values: Int?
            public var required: Bool?
            public var values: [String]?

            public init(
                id: Int? = nil,
                custom_id: String,
                options: [Option],
                min_values: Int? = nil,
                max_values: Int? = nil,
                required: Bool? = nil
            ) {
                self.id = id
                self.custom_id = custom_id
                self.options = options
                self.min_values = min_values
                self.max_values = max_values
                self.required = required
                self.values = nil
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountInRange(custom_id, min: 1, max: 100, name: "custom_id")
                validateElementCountInRange(options, min: 1, max: 10, name: "options")
                validateNumberInRangeOrNil(min_values, min: 0, max: 10, name: "min_values")
                validateNumberInRangeOrNil(max_values, min: 1, max: 10, name: "max_values")
                validateHasPrecondition(
                    condition: min_values == 0,
                    allowedIf: required == false,
                    name: "required",
                    reason: "`required` must be `false` when `min_values` is `0`"
                )
                options?.validate()
            }
        }

        /// https://discord.com/developers/docs/components/reference#checkbox
        public struct Checkbox: Sendable, Codable, ValidatablePayload {
            public var id: Int?
            public var custom_id: String
            public var `default`: Bool?
            public var value: Bool?

            public init(
                id: Int? = nil,
                custom_id: String,
                `default`: Bool? = nil
            ) {
                self.id = id
                self.custom_id = custom_id
                self.`default` = `default`
                self.value = nil
            }

            public func validate() -> [ValidationFailure] {
                validateCharacterCountInRange(custom_id, min: 1, max: 100, name: "custom_id")
            }
        }

        /// FIXME: In a future major version, `Component` might want to also contain the `id` field which
        /// all its sub-types have and Discord documents it as so.

        public enum Component: Sendable, Codable, ValidatablePayload {
            case button(Button)
            case stringSelect(StringSelectMenu)
            case textInput(TextInput)
            case userSelect(SelectMenu)
            case roleSelect(SelectMenu)
            case mentionableSelect(SelectMenu)
            case channelSelect(ChannelSelectMenu)
            indirect case section(Section)
            case textDisplay(TextDisplay)
            case thumbnail(Thumbnail)
            case mediaGallery(MediaGallery)
            case file(File)
            case separator(Separator)
            case container(Container)
            indirect case label(Label)
            case fileUpload(FileUpload)
            case radioGroup(RadioGroup)
            case checkboxGroup(CheckboxGroup)
            case checkbox(Checkbox)
            case __undocumented

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
                case let .radioGroup(value):
                    return value.custom_id
                case let .checkboxGroup(value):
                    return value.custom_id
                case let .checkbox(value):
                    return value.custom_id
                case .section, .textDisplay, .thumbnail, .mediaGallery, .file,
                    .separator, .container, .label, .fileUpload, .__undocumented:
                    return nil
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
                case .section:
                    self = try .section(.init(from: decoder))
                case .textDisplay:
                    self = try .textDisplay(.init(from: decoder))
                case .thumbnail:
                    self = try .thumbnail(.init(from: decoder))
                case .mediaGallery:
                    self = try .mediaGallery(.init(from: decoder))
                case .file:
                    self = try .file(.init(from: decoder))
                case .separator:
                    self = try .separator(.init(from: decoder))
                case .container:
                    self = try .container(.init(from: decoder))
                case .label:
                    self = try .label(.init(from: decoder))
                case .fileUpload:
                    self = try .fileUpload(.init(from: decoder))
                case .radioGroup:
                    self = try .radioGroup(.init(from: decoder))
                case .checkboxGroup:
                    self = try .checkboxGroup(.init(from: decoder))
                case .checkbox:
                    self = try .checkbox(.init(from: decoder))
                case .__undocumented:
                    self = .__undocumented
                }
            }

            public func encode(to encoder: any Encoder) throws {
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
                case let .section(section):
                    try container.encode(Kind.section, forKey: .type)
                    try section.encode(to: encoder)
                case let .textDisplay(textDisplay):
                    try container.encode(Kind.textDisplay, forKey: .type)
                    try textDisplay.encode(to: encoder)
                case let .thumbnail(thumbnail):
                    try container.encode(Kind.thumbnail, forKey: .type)
                    try thumbnail.encode(to: encoder)
                case let .mediaGallery(mediaGallery):
                    try container.encode(Kind.mediaGallery, forKey: .type)
                    try mediaGallery.encode(to: encoder)
                case let .file(file):
                    try container.encode(Kind.file, forKey: .type)
                    try file.encode(to: encoder)
                case let .separator(separator):
                    try container.encode(Kind.separator, forKey: .type)
                    try separator.encode(to: encoder)
                case let .container(containerValue):
                    try container.encode(Kind.container, forKey: .type)
                    try containerValue.encode(to: encoder)
                case let .label(label):
                    try container.encode(Kind.label, forKey: .type)
                    try label.encode(to: encoder)
                case let .fileUpload(fileUpload):
                    try container.encode(Kind.fileUpload, forKey: .type)
                    try fileUpload.encode(to: encoder)
                case let .radioGroup(radioGroup):
                    try container.encode(Kind.radioGroup, forKey: .type)
                    try radioGroup.encode(to: encoder)
                case let .checkboxGroup(checkboxGroup):
                    try container.encode(Kind.checkboxGroup, forKey: .type)
                    try checkboxGroup.encode(to: encoder)
                case let .checkbox(checkbox):
                    try container.encode(Kind.checkbox, forKey: .type)
                    try checkbox.encode(to: encoder)
                case .__undocumented:
                    break
                }
            }

            /// Returns the associated value if the component case is `button`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireButton() throws -> Button {
                switch self {
                case let .button(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "button", component: self)
                }
            }

            /// Returns the associated value if the component case is `stringSelect`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireStringSelect() throws -> StringSelectMenu {
                switch self {
                case let .stringSelect(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "stringSelect", component: self)
                }
            }

            /// Returns the associated value if the component case is `textInput`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireTextInput() throws -> TextInput {
                switch self {
                case let .textInput(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "textInput", component: self)
                }
            }

            /// Returns the associated value if the component case is `userSelect`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireUserSelect() throws -> SelectMenu {
                switch self {
                case let .userSelect(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "userSelect", component: self)
                }
            }

            /// Returns the associated value if the component case is `roleSelect`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireRoleSelect() throws -> SelectMenu {
                switch self {
                case let .roleSelect(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "roleSelect", component: self)
                }
            }

            /// Returns the associated value if the component case is `mentionableSelect`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireMentionableSelect() throws -> SelectMenu {
                switch self {
                case let .mentionableSelect(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "mentionableSelect", component: self)
                }
            }

            /// Returns the associated value if the component case is `channelSelect`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireChannelSelect() throws -> ChannelSelectMenu {
                switch self {
                case let .channelSelect(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "channelSelect", component: self)
                }
            }

            /// Returns the associated value if the component case is `section`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireSection() throws -> Section {
                switch self {
                case let .section(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "section", component: self)
                }
            }

            /// Returns the associated value if the component case is `textDisplay`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireTextDisplay() throws -> TextDisplay {
                switch self {
                case let .textDisplay(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "textDisplay", component: self)
                }
            }

            /// Returns the associated value if the component case is `thumbnail`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireThumbnail() throws -> Thumbnail {
                switch self {
                case let .thumbnail(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "thumbnail", component: self)
                }
            }

            /// Returns the associated value if the component case is `mediaGallery`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireMediaGallery() throws -> MediaGallery {
                switch self {
                case let .mediaGallery(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "mediaGallery", component: self)
                }
            }

            /// Returns the associated value if the component case is `file`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireFile() throws -> File {
                switch self {
                case let .file(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "file", component: self)
                }
            }

            /// Returns the associated value if the component case is `separator`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireSeparator() throws -> Separator {
                switch self {
                case let .separator(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "separator", component: self)
                }
            }

            /// Returns the associated value if the component case is `container`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireContainer() throws -> Container {
                switch self {
                case let .container(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "container", component: self)
                }
            }

            /// Returns the associated value if the component case is `label`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireLabel() throws -> Label {
                switch self {
                case let .label(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "label", component: self)
                }
            }

            /// Returns the associated value if the component case is `fileUpload`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireFileUpload() throws -> FileUpload {
                switch self {
                case let .fileUpload(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "fileUpload", component: self)
                }
            }

            /// Returns the associated value if the component case is `radioGroup`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireRadioGroup() throws -> RadioGroup {
                switch self {
                case let .radioGroup(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "radioGroup", component: self)
                }
            }

            /// Returns the associated value if the component case is `checkboxGroup`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireCheckboxGroup() throws -> CheckboxGroup {
                switch self {
                case let .checkboxGroup(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "checkboxGroup", component: self)
                }
            }

            /// Returns the associated value if the component case is `checkbox`
            /// or throws `Interaction.Error.componentWasNotOfKind`.
            @inlinable
            public func requireCheckbox() throws -> Checkbox {
                switch self {
                case let .checkbox(value):
                    return value
                default:
                    throw Error.componentWasNotOfKind(kind: "checkbox", component: self)
                }
            }

            public func validate() -> [ValidationFailure] {
                switch self {
                case .button(let button):
                    button.validate()
                case .stringSelect(let stringSelectMenu):
                    stringSelectMenu.validate()
                case .textInput(let textInput):
                    textInput.validate()
                case .userSelect(let selectMenu):
                    selectMenu.validate()
                case .roleSelect(let selectMenu):
                    selectMenu.validate()
                case .mentionableSelect(let selectMenu):
                    selectMenu.validate()
                case .channelSelect(let channelSelectMenu):
                    channelSelectMenu.validate()
                case .section(let section):
                    section.validate()
                case .textDisplay(let textDisplay):
                    textDisplay.validate()
                case .thumbnail(let thumbnail):
                    thumbnail.validate()
                case .mediaGallery(let mediaGallery):
                    mediaGallery.validate()
                case .file(let file):
                    file.validate()
                case .separator(let separator):
                    separator.validate()
                case .container(let containerValue):
                    containerValue.validate()
                case .label(let label):
                    label.validate()
                case .fileUpload(let fileUpload):
                    fileUpload.validate()
                case .radioGroup(let radioGroup):
                    radioGroup.validate()
                case .checkboxGroup(let checkboxGroup):
                    checkboxGroup.validate()
                case .checkbox(let checkbox):
                    checkbox.validate()
                case .__undocumented:
                    Optional<ValidationFailure>.none
                }
            }
        }

        public var components: [Component]

        public enum CodingError: Swift.Error, CustomStringConvertible {
            /// This component kind was not expected here. This is a library decoding issue, please report at: https://github.com/DiscordBM/DiscordBM/issues.
            case unexpectedComponentKind(Kind)
            /// I thought action-row is supposed to only appear at top-level as a container for other components. This is a library decoding issue, please report at: https://github.com/DiscordBM/DiscordBM/issues.
            case actionRowIsSupposedToOnlyAppearAtTopLevel

            public var description: String {
                switch self {
                case let .unexpectedComponentKind(kind):
                    return "Interaction.ActionRow.CodingError.unexpectedComponentKind(\(kind))"
                case .actionRowIsSupposedToOnlyAppearAtTopLevel:
                    return "Interaction.ActionRow.CodingError.actionRowIsSupposedToOnlyAppearAtTopLevel"
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

        public func encode(to encoder: any Encoder) throws {
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

        /// Returns the component with the `customId`, or `nil`.
        @inlinable
        public func component(customId: String) -> Component? {
            self.components.first(where: { $0.customId == customId })
        }

        /// Returns the component with the `customId`, or throws `Interaction.Error`.
        @inlinable
        public func requireComponent(customId: String) throws -> Component {
            if let component = self.components.first(where: { $0.customId == customId }) {
                return component
            } else {
                throw Error.componentNotFoundInActionRow(customId: customId, actionRow: self)
            }
        }

        public func validate() -> [ValidationFailure] {
            components.validate()
        }
    }
}

extension [Interaction.ActionRow] {
    /// Returns the component with the `customId`, or `nil`.
    @inlinable
    public func component(customId: String) -> Interaction.ActionRow.Component? {
        self.flatMap(\.components).first(where: { $0.customId == customId })
    }

    /// Returns the component with the `customId`, or throws `Interaction.Error`.
    @inlinable
    public func requireComponent(customId: String) throws -> Interaction.ActionRow.Component {
        if let component = self.flatMap(\.components).first(where: { $0.customId == customId }) {
            return component
        } else {
            throw Interaction.Error.componentNotFoundInActionRows(
                customId: customId,
                actionRows: self
            )
        }
    }
}

extension [Interaction.ActionRow.Component] {
    /// Returns the component with the `customId`, or `nil`.
    @inlinable
    public func component(customId: String) -> Interaction.ActionRow.Component? {
        self.first(where: { $0.customId == customId })
    }

    /// Returns the component with the `customId`, or throws `Interaction.Error`.
    @inlinable
    public func requireComponent(customId: String) throws -> Interaction.ActionRow.Component {
        if let component = self.first(where: { $0.customId == customId }) {
            return component
        } else {
            throw Interaction.Error.componentNotFoundInComponents(
                customId: customId,
                components: self
            )
        }
    }
}
