import SwiftSyntax

extension [EnumCase] {
    func makeRawValueVar(
        accessLevel: String,
        rawType: RawKind
    ) -> DeclSyntax {
        let cases = self.map { enumCase in
            """
            case .\(enumCase.key):
                return \(enumCase.maybeQuotedValue(rawType: rawType))
            """
        }
        return #"""
        \#(raw: accessLevel)var rawValue: \#(raw: rawType.rawValue) {
            switch self {
        \#(raw: cases.indented())
            case let .undocumented(rawValue):
                return rawValue
            case .\#(raw: String.doNotUseCase):
                fatalError("Must not use the '\#(raw: String.doNotUseCase)' case. This case serves as a way of discouraging exhaustive switch statements")
            }
        }
        """#
    }
}
