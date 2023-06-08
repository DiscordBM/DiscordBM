import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// A to stabilize enums that might get more cases, to some extent.
/// The main goal is to not fail json decodings if Discord adds a new case.
///
/// This is supposed to be used with enums that are supposed to be raw-representable.
/// The macro accepts one and only one of these types as a generic argument:
/// `String`, `Int`, `UInt`. More types can be added on demand.
/// The generic argument represents the `RawValue` of a `RawRepresentable` type.
///
/// How it manipulates the code:
/// Adds a new `.unknown(<Type>)` case where Type is the generic argument of the macro.
/// Adds `RawRepresentable` conformance where `RawValue` is the generic argument of the macro.
/// If `Decodable`, adds a slightly-modified `init(from:)` initializer.
/// If `CaseIterable`, repairs the `static var allCases` requirement.
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

        guard let rawType = RawKind(rawValue: genericType.name.text) else {
            throw MacroError.unexpectedGenericArgument
        }

        let members = enumDecl.memberBlock.members
        let caseDecls = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let elements = caseDecls.flatMap { $0.elements }

        var useDefaultCase = false

        let caseToRawValueTable: [(String, String)] = try elements.compactMap { element in
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

        let values = caseToRawValueTable.map(\.1)

        if values.isEmpty {
            return []
        }

        if Set(values).count != values.count {
            throw MacroError.valuesMustBeUnique
        }

        switch rawType {
        case .String:
            if values.allSatisfy({ Int($0) != nil }) {
                throw MacroError.enumSeemsToHaveIntValuesButGenericArgumentSpecifiesString
            }
        case .Int, .UInt:
            if !values.allSatisfy({ Int($0.filter({ $0 != "_" })) != nil }) {
                throw MacroError.intEnumMustOnlyHaveIntValues
            }
        }


        let isPublic = enumDecl.modifiers?.contains(where: { $0.name.text == "public" }) == true
        let publicModifier = isPublic ? "public " : ""

        var decodableSyntaxContainer = [DeclSyntax]()

        let conformsToDecodable = enumDecl.inheritanceClause?.inheritedTypeCollection.contains {
            let name = $0.typeName.as(SimpleTypeIdentifierSyntax.self)?.name.text
            return name == "Codable" || name == "Decodable"
        }

        if conformsToDecodable == true {
            let location: AbstractSourceLocation? = context.location(of: node)
            let decodableInit: DeclSyntax = #"""
            \#(raw: publicModifier)init(from decoder: any Decoder) throws {
                try self.init(rawValue: \#(raw: rawType)(from: decoder))!
                #if DISCORDBM_ENABLE_LOGGING_DURING_DECODE
                if case let .unknown(value) = self {
                    DiscordGlobalConfiguration.makeDecodeLogger("\#(enumDecl.identifier)").warning(
                        "Found an unknown value", metadata: [
                            "value": "\(value)",
                            "typeName": "\#(enumDecl.identifier)",
                            "location": "\#(raw: location?.description ?? "nil")"
                        ]
                    )
                }
                #endif
            }
            """#
            decodableSyntaxContainer.append(decodableInit)
        }

        let unknownCase = EnumCaseDeclSyntax(elements: [.init(
            identifier: .identifier("unknown"),
            associatedValue: .init(parameterList: [
                .init(type: SimpleTypeIdentifierSyntax(
                    name: .identifier(rawType.rawValue))
                )
            ])
        )])

        let rawValueVar = try VariableDeclSyntax(
            "\(raw: publicModifier)var rawValue: \(raw: rawType.rawValue)"
        ) {
            try SwitchExprSyntax("switch self") {
                for (key, value) in caseToRawValueTable {
                    let description = switch rawType {
                    case .String:
                        #""\#(value)""#
                    case .Int, .UInt:
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
                    case .Int, .UInt:
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

        var caseIterableSyntaxContainer = [DeclSyntax]()

        let conformsToCaseIterable = enumDecl.inheritanceClause?.inheritedTypeCollection.contains {
            $0.typeName.as(SimpleTypeIdentifierSyntax.self)?.name.text == "CaseIterable"
        }

        if conformsToCaseIterable == true {
            let cases = caseToRawValueTable.map(\.0).map { ".\($0)" }.joined(separator: ",\n")
            let caseIterableConformance: DeclSyntax = """
            \(raw: publicModifier)static var allCases: [\(enumDecl.identifier)] {
                [
                    \(raw: cases)
                ]
            }
            """
            caseIterableSyntaxContainer.append(caseIterableConformance)
        }

        return [
            DeclSyntax(unknownCase),
            DeclSyntax(rawValueVar),
            DeclSyntax(initializer)
        ] + caseIterableSyntaxContainer + decodableSyntaxContainer
    }
}

extension UnstableEnumMacro: ConformanceMacro {
    public static func expansion<Declaration: DeclGroupSyntax, Context: MacroExpansionContext>(
        of node: AttributeSyntax,
        providingConformancesOf declaration: Declaration,
        in context: Context
    ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        /// Always add a new ``RawRepresentable`` conformance.
        return [("RawRepresentable", nil)]
    }
}

private enum RawKind: String {
    case String
    case Int
    case UInt
}

private extension AbstractSourceLocation {
    var description: String {
        let file = self.file.description.filter({ ![" ", #"""#].contains($0) })
        return "\(file):\(self.line.description)"
    }
}
