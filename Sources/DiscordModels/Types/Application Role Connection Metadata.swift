import Foundation

nonisolated(unsafe) private let iso8601DateFormatter = ISO8601DateFormatter()

/// https://docs.discord.com/developers/resources/application-role-connection-metadata#application-role-connection-metadata-object-application-role-connection-metadata-structure
public struct ApplicationRoleConnectionMetadata: Sendable, Codable, ValidatablePayload {

    /// https://docs.discord.com/developers/resources/application-role-connection-metadata#application-role-connection-metadata-object-application-role-connection-metadata-type
    @UnstableEnum<_Int_CompatibilityTypealias>
    public enum Kind: Sendable, Codable {
        case integerLessThanOrEqual  // 1
        case integerGreaterThanOrEqual  // 2
        case integerEqual  // 3
        case integerNotEqual  // 4
        case dateTimeLessThanOrEqual  // 5
        case dateTimeGreaterThanOrEqual  // 6
        case booleanEqual  // 7
        case booleanNotEqual  // 8
        case __undocumented(_Int_CompatibilityTypealias)
    }

    /// https://docs.discord.com/developers/resources/application-role-connection-metadata#application-role-connection-metadata-object-application-role-connection-metadata-type
    public enum Value: Sendable {
        case integer(Int)
        case dateTime(Date)
        case boolean(Bool)

        /// This case serves as a way of discouraging exhaustive switch statements
        case __DO_NOT_USE_THIS_CASE

        var stringValue: String {
            switch self {
            case let .integer(integer):
                return "\(integer)"
            case let .dateTime(date):
                return iso8601DateFormatter.string(from: date)
            case let .boolean(boolean):
                return boolean ? "1" : "0"
            case .__DO_NOT_USE_THIS_CASE:
                fatalError("If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used")
            }
        }
    }

    public var type: Kind
    public var key: String
    public var name: String
    public var name_localizations: DiscordLocaleDict<String>?
    public var description: String
    public var description_localizations: DiscordLocaleDict<String>?

    public init(
        type: Kind,
        key: String,
        name: String,
        name_localizations: [DiscordLocale: String]? = nil,
        description: String,
        description_localizations: [DiscordLocale: String]? = nil
    ) {
        self.type = type
        self.key = key
        self.name = name
        self.name_localizations = .init(name_localizations)
        self.description = description
        self.description_localizations = .init(description_localizations)
    }

    public func validate() -> [ValidationFailure] {
        validateApplicationRoleConnectionMetadataKey(key, name: "key")
        validateCharacterCountInRange(name, min: 1, max: 100, name: "name")
        validateCharacterCountInRange(description, min: 1, max: 200, name: "description")
    }
}
