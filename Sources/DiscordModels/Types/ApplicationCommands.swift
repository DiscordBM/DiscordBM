import Foundation

/// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-structure
public struct ApplicationCommand: Sendable, Codable {
    
    /// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-types
    public enum Kind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case chatInput = 1
        case user = 2
        case message = 3
    }
    
    /// https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-structure
    public struct Option: Sendable, Codable, ValidatablePayload {
        
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
            public var name_localizations: DiscordLocaleDict<String>?
            public var value: StringIntDoubleBool
            
            public var name_localized: String?
            
            public init(name: String, name_localizations: [DiscordLocale : String]? = nil, value: StringIntDoubleBool) {
                self.name = name
                self.name_localizations = .init(name_localizations)
                self.value = value
            }
        }
        
        public var type: Kind
        public var name: String
        public var name_localizations: DiscordLocaleDict<String>?
        public var description: String
        public var description_localizations: DiscordLocaleDict<String>?
        public var required: Bool?
        public var choices: [Choice]?
        public var options: [Option]?
        public var channel_types: [DiscordChannel.Kind]?
        public var min_value: IntOrDouble?
        public var max_value: IntOrDouble?
        public var min_length: Int?
        public var max_length: Int?
        public var autocomplete: Bool?
        
        public init(type: Kind, name: String, name_localizations: [DiscordLocale : String]? = nil, description: String, description_localizations: [DiscordLocale : String]? = nil, required: Bool? = nil, choices: [Choice]? = nil, options: [Option]? = nil, channel_types: [DiscordChannel.Kind]? = nil, min_value: IntOrDouble? = nil, max_value: IntOrDouble? = nil, min_length: Int? = nil, max_length: Int? = nil, autocomplete: Bool? = nil) {
            self.type = type
            self.name = name
            self.name_localizations = .init(name_localizations)
            self.description = description
            self.description_localizations = .init(description_localizations)
            self.required = required
            self.choices = choices
            self.options = options
            self.channel_types = channel_types == nil ? nil : .init(channel_types!)
            self.min_value = min_value
            self.max_value = max_value
            self.min_length = min_length
            self.max_length = max_length
            self.autocomplete = autocomplete
        }
        
        public func validate() -> [ValidationFailure] {
            validateNumberInRange(min_length, min: 0, max: 6_000, name: "min_length")
            validateNumberInRange(max_length, min: 0, max: 6_000, name: "max_length")
            validateElementCountDoesNotExceed(choices, max: 25, name: "choices")
            validateCharacterCountInRange(name, min: 1, max: 32, name: "name")
            validateCharacterCountInRange(description, min: 1, max: 100, name: "description")
            validateHasPrecondition(
                condition: autocomplete != nil,
                allowedIf: [.string, .integer, .number].contains(type),
                name: "autocomplete",
                reason: "'autocomplete' is only allowed if 'type' is 'string' or 'integer' or 'number'"
            )
            validateHasPrecondition(
                condition: autocomplete != nil,
                allowedIf: choices?.isEmpty != false,
                name: "autocomplete",
                reason: "'autocomplete' is only allowed if 'choices' is not present"
            )
            validateHasPrecondition(
                condition: (min_value != nil) || (max_value != nil),
                allowedIf: [.integer, .number].contains(type),
                name: "min_value+max_value",
                reason: "'min_value' or 'max_value' are only allowed if 'type' is 'integer' or 'number'"
            )
            validateHasPrecondition(
                condition: (min_length != nil) || (max_length != nil),
                allowedIf: type == .string,
                name: "min_length+max_length",
                reason: "'min_length' or 'max_length' are only allowed if 'type' is 'string'"
            )
            validateHasPrecondition(
                condition: choices?.isEmpty == false,
                allowedIf: [.string, .integer, .number].contains(type),
                name: "choices",
                reason: "'choices' is only allowed if 'type' is 'string' or 'integer' or 'number'"
            )
            options?.validate()
        }
    }
    
    public var id: String
    public var type: Kind?
    public var application_id: String
    public var guild_id: String?
    public var name: String
    public var name_localizations: DiscordLocaleDict<String>?
    public var name_localized: String? /// Only for endpoints like get-application-commands
    public var description: String
    public var description_localizations: DiscordLocaleDict<String>?
    public var description_localized: String? /// Only for endpoints like get-application-commands
    public var options: [Option]?
    public var default_member_permissions: StringBitField<Permission>?
    public var dm_permission: Bool?
    public var nsfw: Bool?
    public var version: String?
}

/// https://discord.com/developers/docs/topics/gateway-events#application-command-permissions-update
public struct GuildApplicationCommandPermissions: Sendable, Codable {
    
    /// https://discord.com/developers/docs/interactions/application-commands#application-command-permissions-object-application-command-permissions-structure
    public struct Permission: Sendable, Codable {
        
        /// https://discord.com/developers/docs/interactions/application-commands#application-command-permissions-object-application-command-permission-type
        public enum Kind: Int, Sendable, Codable {
            case role = 1
            case user = 2
            case channel = 3
        }
        
        public var type: Kind
        public var permission: Bool
        public var id: String
        
        public init(type: Kind, permission: Bool, id: String) {
            self.type = type
            self.permission = permission
            self.id = id
        }
        
        /// Read `helpAnchor` for help about each error case.
        public enum ConversionError: LocalizedError {
            case couldNotConvertToInteger(String)
            
            public var errorDescription: String? {
                switch self {
                case let .couldNotConvertToInteger(string):
                    return "couldNotConvertToInteger(\(string))"
                }
            }
            
            public var helpAnchor: String? {
                switch self {
                case let .couldNotConvertToInteger(string):
                    return "Couldn't convert \(string.debugDescription) to an integer"
                }
            }
        }
        
        public static func allChannels(
            inGuildWithId guildId: String,
            permission: Bool
        ) throws -> Self {
            guard let guildNumber = Int(guildId) else {
                throw ConversionError.couldNotConvertToInteger(guildId)
            }
            return self.init(type: .channel, permission: permission, id: "\(guildNumber - 1)")
        }
        
        public static func allMembers(
            inGuildWithId guildId: String,
            permission: Bool
        ) throws -> Self {
            self.init(type: .user, permission: permission, id: guildId)
        }
    }
    
    public var permissions: [Permission]
    public var id: String
    public var guild_id: String
    public var application_id: String
}
