import SwiftSyntax

extension [EnumCase] {
    func makeDescriptionVar(
        accessLevel: String,
        rawType: RawKind
    ) -> DeclSyntax {
        let cases = self.map { enumCase in
            let value =
                if rawType == .String {
                    "\(enumCase.value)"
                } else {
                    "\(enumCase.value)[\(enumCase.key)]"
                }
            return """
                case .\(enumCase.key):
                    return "\(value)"
                """
        }
        return #"""
            \#(raw: accessLevel)var description: String {
                switch self {
            \#(raw: cases.indented())
                case let .__undocumented(rawValue):
                    return "\(rawValue)[__undocumented]"
                }
            }
            """#
    }
}
