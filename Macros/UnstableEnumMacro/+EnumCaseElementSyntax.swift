import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

extension [EnumCaseElementSyntax] {
    func makeCases(
        rawType: RawKind,
        context: some MacroExpansionContext
    ) -> (cases: [EnumCase], hasError: Bool) {
        let cases = self.compactMap {
            element -> EnumCase? in
            if let rawValue = element.rawValue {
                var modifiedElement = EnumCaseElementSyntax(element)!
                modifiedElement.rawValue = nil
                /// Can't use trailing trivia because it won't show up in the code
                modifiedElement.name = .identifier(
                    modifiedElement.name.text + " // \(rawValue.value)"
                )
                let diagnostic = Diagnostic(
                    node: Syntax(rawValue),
                    message: MacroError.rawValuesNotAcceptable,
                    fixIts: [.init(
                        message: FixMessage.useCommentsInstead,
                        changes: [.replace(
                            oldNode: Syntax(element),
                            newNode: Syntax(modifiedElement)
                        )]
                    )]
                )
                context.diagnose(diagnostic)
                return nil
            } else if element.trailingTrivia.pieces.isEmpty {
                if rawType == .Int {
                    let diagnostic = Diagnostic(
                        node: Syntax(element),
                        message: MacroError.allEnumCasesWithIntTypeMustHaveACommentForValue
                    )
                    context.diagnose(diagnostic)
                    return nil
                }
                return .init(
                    key: element.name.text,
                    value: element.name.text
                )
            } else {
                if element.trailingTrivia.pieces.count == 2,
                   element.trailingTrivia.pieces[0] == .spaces(1),
                   case let .lineComment(comment) = element.trailingTrivia.pieces[1] {
                    if comment.hasPrefix("// ") {
                        var value = String(comment.dropFirst(3))
                        let hasPrefix = value.hasPrefix(#"""#)
                        let hasSuffix = value.hasSuffix(#"""#)
                        if hasPrefix && hasSuffix {
                            value = String(value.dropFirst().dropLast())
                        } else if hasPrefix || hasSuffix {
                            let diagnostic = Diagnostic(
                                node: Syntax(element),
                                message: MacroError.inconsistentQuotesAroundComment
                            )
                            context.diagnose(diagnostic)
                            return nil
                        }
                        if value.allSatisfy(\.isWhitespace) {
                            let diagnostic = Diagnostic(
                                node: Syntax(element),
                                message: MacroError.emptyValuesAreNotAcceptable
                            )
                            context.diagnose(diagnostic)
                            return nil
                        }
                        return .init(
                            key: element.name.text,
                            value: value
                        )
                    } else {
                        let diagnostic = Diagnostic(
                            node: Syntax(element),
                            message: MacroError.badEnumCaseComment
                        )
                        context.diagnose(diagnostic)
                        return nil
                    }
                } else {
                    let diagnostic = Diagnostic(
                        node: Syntax(element),
                        message: MacroError.badEnumCaseTrailingTrivia
                    )
                    context.diagnose(diagnostic)
                    return nil
                }
            }
        }
        let hasError = self.count != cases.count
        return (cases, hasError)
    }
}
