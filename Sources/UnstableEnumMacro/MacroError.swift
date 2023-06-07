import SwiftDiagnostics

enum MacroError: String, Error {
    case isNotEnum
    case macroDoesNotHaveRequiredGenericArgument
    case unexpectedGenericArgument
    case rawValuesNotAcceptable
    case allEnumCasesWithIntTypeMustHaveACommentForValue
    case enumSeemsToHaveIntValuesButGenericArgumentSpecifiesString
    case intEnumMustOnlyHaveIntValues
    case valuesMustBeUnique
    case badEnumCaseTrailingTrivia
    case badEnumCaseComment
}

extension MacroError: DiagnosticMessage {
    var message: String {
        self.rawValue
    }

    var diagnosticID: SwiftDiagnostics.MessageID {
        .init(domain: "UnstableEnumMacro.MacroError", id: self.rawValue)
    }

    var severity: SwiftDiagnostics.DiagnosticSeverity {
        .error
    }
}
