import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct UnstableEnumMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw MacroError.isNotEnum
        }

        guard let name = node.attributeName.as(SimpleTypeIdentifierSyntax.self),
              let generic = name.genericArgumentClause,
              generic.arguments.count == 1,
              let genericTypeSyntax = generic.arguments.first?.argumentType,
              let genericType = genericTypeSyntax.as(SimpleTypeIdentifierSyntax.self)
        else {
            throw MacroError.macroDoesNotHaveRequiredGenericArgument
        }

        let rawType: RawKind
        switch genericType.name.text {
        case "String":
            rawType = .String
        case "Int":
            rawType = .Int
        default:
            throw MacroError.unexpectedGenericArgument
        }

        let members = enumDecl.memberBlock.members
        let caseDecls = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let elements = caseDecls.flatMap { $0.elements }

        var useDefaultCase = false

        var caseToRawValueTable: [(String, String)] = try elements.compactMap { element in
            if let rawValue = element.rawValue {
                var modifiedElement = EnumCaseElementSyntax(element)!
                modifiedElement.rawValue = nil
                /// Can't use trailing trivia because it won't show up in the code
                modifiedElement.identifier = .identifier(
                    modifiedElement.identifier.text + " // \(rawValue.value)"
                )
                let diagnostic = Diagnostic(
                    node: Syntax(rawValue),
                    message: MacroError.rawValuesNotAcceptable,
                    fixIts: [
                        .init(
                            message: FixMessage.useCommentsInstead,
                            changes: [.replace(
                                oldNode: Syntax(element),
                                newNode: Syntax(modifiedElement)
                            )]
                        )
                    ]
                )
                context.diagnose(diagnostic)
                useDefaultCase = true
                return nil
            } else if element.trailingTrivia.pieces.isEmpty {
                if rawType == .Int {
                    throw MacroError.allEnumCasesWithIntTypeMustHaveACommentForValue
                }
                return (element.identifier.text, element.identifier.text)
            } else {
                if element.trailingTrivia.pieces.count == 2,
                   element.trailingTrivia.pieces[0] == .spaces(1),
                   case let .lineComment(comment) = element.trailingTrivia.pieces[1] {
                    if comment.hasPrefix("// ") {
                        var value = String(comment.dropFirst(3))
                        if value.hasPrefix(#"""#) && value.hasSuffix(#"""#) {
                            value = String(value.dropFirst().dropLast())
                        }
                        return (element.identifier.text, value)
                    } else {
                        throw MacroError.badEnumCaseComment
                    }
                } else {
                    throw MacroError.badEnumCaseTrailingTrivia
                }
            }
        }

        /// Catching some programmer errors

        if caseToRawValueTable.isEmpty {
            return []
        }

        let values = caseToRawValueTable.map(\.1)

        if Set(values).count != values.count {
            throw MacroError.valuesMustBeUnique
        }

        switch rawType {
        case .String:
            if values.allSatisfy({ Int($0) != nil }) {
                throw MacroError.enumSeemsToHaveIntValuesButGenericArgumentSpecifiesString
            }
        case .Int:
            if !values.allSatisfy({ Int($0.filter({ $0 != "_" })) != nil }) {
                throw MacroError.intEnumMustOnlyHaveIntValues
            }
        }


        let unknownCase = EnumCaseDeclSyntax(elements: [.init(
            identifier: .identifier("unknown"),
            associatedValue: .init(parameterList: [
                .init(type: SimpleTypeIdentifierSyntax(
                    name: .identifier(rawType.rawValue))
                )
            ])
        )])

        let isPublic = enumDecl.modifiers?.contains(where: { $0.name.text == "public" }) == true
        let publicModifier = isPublic ? "public " : ""

        let rawValueVar = try VariableDeclSyntax(
            "\(raw: publicModifier)var rawValue: \(raw: rawType.rawValue)"
        ) {
            try SwitchExprSyntax("switch self") {
                for (key, value) in caseToRawValueTable {
                    let description = switch rawType {
                    case .String:
                        #""\#(value)""#
                    case .Int:
                        value
                    }
                    SwitchCaseSyntax(
                        """
                        case .\(raw: key):
                            return \(raw: description)
                        """
                    )
                }

                SwitchCaseSyntax(
                    """
                    case let .unknown(value):
                        return value
                    """
                )

                if useDefaultCase {
                    SwitchCaseSyntax(
                    """
                    default: return .init()
                    """
                    )
                }
            }
        }


        let initializer = try InitializerDeclSyntax(
            "\(raw: publicModifier)init? (rawValue: \(raw: rawType.rawValue))"
        ) {
            try SwitchExprSyntax("switch rawValue") {
                for (key, value) in caseToRawValueTable {
                    let description = switch rawType {
                    case .String:
                        #""\#(value)""#
                    case .Int:
                        value
                    }
                    SwitchCaseSyntax(
                        """
                        case \(raw: description):
                            self = .\(raw: key)
                        """
                    )
                }

                SwitchCaseSyntax(
                    """
                    default:
                        self = .unknown(rawValue)
                    """
                )
            }
        }

        return [DeclSyntax(unknownCase), DeclSyntax(rawValueVar), DeclSyntax(initializer)]
    }
}

enum RawKind: String {
    case String
    case Int
}
