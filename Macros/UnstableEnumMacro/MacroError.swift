import SwiftDiagnostics

enum MacroError: Error {
    case isNotEnum
    case macroDoesNotHaveRequiredGenericArgument
    case unexpectedGenericArgument
    case rawValuesNotAcceptable
    case inconsistentQuotesAroundComment
    case emptyValuesAreNotAcceptable
    case allEnumCasesWithIntTypeMustHaveACommentForValue
    case enumSeemsToHaveIntValuesButGenericArgumentSpecifiesString
    case intEnumMustOnlyHaveIntValues
    case valuesMustBeUnique
    case badEnumCaseTrailingTrivia
    case badEnumCaseComment
    case couldNotFindLocationOfNode
    case cannotUnwrapSyntax(type: Any.Type, line: UInt = #line)

    var rawValue: String {
        switch self {
        case .isNotEnum:
            return "isNotEnum"
        case .macroDoesNotHaveRequiredGenericArgument:
            return "macroDoesNotHaveRequiredGenericArgument"
        case .unexpectedGenericArgument:
            return "unexpectedGenericArgument"
        case .rawValuesNotAcceptable:
            return "rawValuesNotAcceptable"
        case .inconsistentQuotesAroundComment:
            return "inconsistentQuotesAroundComment"
        case .emptyValuesAreNotAcceptable:
            return "emptyValuesAreNotAcceptable"
        case .allEnumCasesWithIntTypeMustHaveACommentForValue:
            return "allEnumCasesWithIntTypeMustHaveACommentForValue"
        case .enumSeemsToHaveIntValuesButGenericArgumentSpecifiesString:
            return "enumSeemsToHaveIntValuesButGenericArgumentSpecifiesString"
        case .intEnumMustOnlyHaveIntValues:
            return "intEnumMustOnlyHaveIntValues"
        case .valuesMustBeUnique:
            return "valuesMustBeUnique"
        case .badEnumCaseTrailingTrivia:
            return "badEnumCaseTrailingTrivia"
        case .badEnumCaseComment:
            return "badEnumCaseComment"
        case .couldNotFindLocationOfNode:
            return "couldNotFindLocationOfNode"
        case let .cannotUnwrapSyntax(type, line):
            return "cannotUnwrapSyntax(type: \(type), line: \(line))"
        }
    }
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
