import SwiftSyntax
import SwiftSyntaxMacros

extension [EnumCase] {
    func makeDecodableInitializer(
        accessLevel: String,
        enumIdentifier: TokenSyntax,
        location: AbstractSourceLocation,
        rawType: RawKind
    ) -> DeclSyntax {
        #"""
        \#(raw: accessLevel)init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(\#(raw: rawType.rawValue).self)
            self.init(rawValue: value)!
            #if DISCORDBM_ENABLE_LOGGING_DURING_DECODE
            if case let .unknown(value) = self {
                DiscordGlobalConfiguration.makeDecodeLogger("\#(raw: enumIdentifier.trimmedDescription)").warning(
                    "Found an unknown value",
                    metadata: [
                        "value": "\(value)",
                        "typeName": "\#(raw: enumIdentifier.trimmedDescription)",
                        "location": "\#(raw: location.description)",
                    ]
                )
            }
            #endif
        }
        """#
    }
}
