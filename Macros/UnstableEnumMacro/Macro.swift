import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxMacros

private let doNotUseCase = "__DO_NOT_USE_THIS_CASE"

/// A macro to stabilize enums that might get more cases, to some extent.
/// The main goal is to not fail json decodings if Discord adds a new case.
///
/// This is supposed to be used with enums that are supposed to be raw-representable.
/// The macro accepts one and only one of these types as a generic argument:
/// `String`, `Int`, `UInt`. More types can be added on demand.
/// The generic argument represents the `RawValue` of a `RawRepresentable` type.
/// You can manually declare the raw value of a case, using a comment in front of it like so:
/// ```swift
/// case something // "actually nothing!"
/// case anything // still nothing!
///
/// case value12 // 12
/// ```
///
/// How it manipulates the code:
/// Adds `RawRepresentable` conformance where `RawValue` is the generic argument of the macro.
/// Adds a new `.unknown(RawValue)` case.
/// Adds a new `__DO_NOT_USE_THIS_CASE` case to discourage exhaustive switch statements
/// which can too easily result in code breakage.
/// If `Decodable`, adds a slightly-modified `init(from:)` initializer.
/// If `CaseIterable`, repairs the `static var allCases` requirement.
public struct UnstableEnum: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if declaration.hasError { return [] }

        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw MacroError.isNotEnum
        }
        let accessLevel = enumDecl.accessLevelModifier.map { "\($0) " } ?? ""

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

        let (cases, hasError) = makeCases(elements: elements, rawType: rawType, context: context)

        if hasError { return [] }


        /// Some validations

        let values = cases.map(\.value)

        if values.isEmpty { return [] }

        /// All values must be unique
        if Set(values).count != values.count {
            throw MacroError.valuesMustBeUnique
        }

        switch rawType {
        case .String:
            /// All values must be string
            if values.allSatisfy({ Int($0) != nil }) {
                throw MacroError.enumSeemsToHaveIntValuesButGenericArgumentSpecifiesString
            }
        case .Int, .UInt:
            /// All values must be integer
            if !values.allSatisfy({ Int($0.filter({ $0 != "_" })) != nil }) {
                throw MacroError.intEnumMustOnlyHaveIntValues
            }
        }


        var syntaxes: [DeclSyntax] = [
            DeclSyntax(makeUnknownEnumCase(rawType: rawType)),
            DeclSyntax(doNotUseCaseDeclaration),
            DeclSyntax(try makeRawValueVar(accessLevelModifier: accessLevel, rawType: rawType, cases: cases)),
            DeclSyntax(try makeInitializer(accessLevelModifier: accessLevel, rawType: rawType, cases: cases))
        ]

        let conformsToCaseIterable = enumDecl.inheritanceClause?.inheritedTypeCollection.contains {
            $0.typeName.as(SimpleTypeIdentifierSyntax.self)?.name.text == "CaseIterable"
        }

        if conformsToCaseIterable == true {
            let conformance = try makeCaseIterable(
                accessLevelModifier: accessLevel,
                enumIdentifier: enumDecl.identifier,
                cases: cases
            )
            syntaxes.append(DeclSyntax(conformance))
        }

        let conformsToDecodable = enumDecl.inheritanceClause?.inheritedTypeCollection.contains {
            let name = $0.typeName.as(SimpleTypeIdentifierSyntax.self)?.name.text
            return name == "Codable" || name == "Decodable"
        }

        if conformsToDecodable == true {
            guard let location: AbstractSourceLocation = context.location(of: node) else {
                throw MacroError.couldNotFindLocationOfNode
            }
            let decodableInit = try makeDecodableInitializer(
                accessLevelModifier: accessLevel,
                enumIdentifier: enumDecl.identifier,
                location: location,
                rawType: rawType,
                cases: cases
            )
            syntaxes.append(DeclSyntax(decodableInit))
        }

        return syntaxes
    }
}

extension UnstableEnum: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        if declaration.hasError { return [] }

        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw MacroError.isNotEnum
        }

        let syntax: DeclSyntax = """
        extension \(enumDecl.identifier): RawRepresentable, LosslessRawRepresentable { }
        """
        let ext = ExtensionDeclSyntax(syntax)!

        return [ext]
    }
}

private enum RawKind: String {
    case String, Int, UInt
}

struct EnumCase {
    let key: String
    let value: String
}

private func makeCases(
    elements: [EnumCaseElementSyntax],
    rawType: RawKind,
    context: some MacroExpansionContext
) -> (cases: [EnumCase], hasError: Bool) {
    let cases = elements.compactMap {
        element -> EnumCase? in
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
                key: element.identifier.text,
                value: element.identifier.text
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
                        key: element.identifier.text,
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
    let hasError = elements.count != cases.count
    return (cases, hasError)
}

private func makeExpression(rawType: RawKind, value: String) -> any ExprSyntaxProtocol {
    if rawType == .String {
        return StringLiteralExprSyntax(content: value)
    } else {
        let integerValue = value.filter({ !["_", #"""#].contains($0) })
        /// Should have been checked before that this is an `Int`
        return IntegerLiteralExprSyntax(integerLiteral: Int(integerValue)!)
    }
}

private func makeUnknownEnumCase(rawType: RawKind) -> EnumCaseDeclSyntax {
    EnumCaseDeclSyntax(
        elements: [
            EnumCaseElementSyntax(
                identifier: .identifier("unknown"),
                associatedValue: EnumCaseParameterClauseSyntax(
                    parameterList: [
                        EnumCaseParameterSyntax(
                            type: SimpleTypeIdentifierSyntax(
                                name: .identifier(rawType.rawValue)
                            )
                        )
                    ]
                )
            )
        ]
    )
}

private let doNotUseCaseDeclaration = EnumCaseDeclSyntax(DeclSyntax("""
    /// This case serves as a way of discouraging exhaustive switch statements
    case \(raw: doNotUseCase)
"""))!

private func makeRawValueVar(
    accessLevelModifier: String,
    rawType: RawKind,
    cases: [EnumCase]
) throws -> VariableDeclSyntax {
    func maybeQuoted(_ value: String) -> String {
        switch rawType {
        case .Int, .UInt:
            return value
        case .String:
            return #""\#(value)""#
        }
    }
    let cases = cases.map { enumCase in
        """
        case .\(enumCase.key):
            return \(maybeQuoted(enumCase.value))
        """
    }
    let syntax: DeclSyntax = #"""
    \#(raw: accessLevelModifier)var rawValue: \#(raw: rawType.rawValue) {
        switch self {
    \#(raw: cases.indented())
        case let .unknown(value):
            return value
        case .\#(raw: doNotUseCase):
            fatalError("Must not use the '\#(raw: doNotUseCase)' case. This case serves as a way of discouraging exhaustive switch statements")
        }
    }
    """#
    guard let decl = VariableDeclSyntax(syntax) else {
        throw MacroError.cannotUnwrapSyntax(type: VariableDeclSyntax.self)
    }
    return decl
}

private func makeInitializer(
    accessLevelModifier: String,
    rawType: RawKind,
    cases: [EnumCase]
) throws -> InitializerDeclSyntax {
    func maybeQuoted(_ value: String) -> String {
        switch rawType {
        case .Int, .UInt:
            return value
        case .String:
            return #""\#(value)""#
        }
    }
    let cases = cases.map { enumCase in
        """
        case \(maybeQuoted(enumCase.value)):
            self = .\(enumCase.key)
        """
    }
    let syntax: DeclSyntax = #"""
    \#(raw: accessLevelModifier)init?(rawValue: \#(raw: rawType.rawValue)) {
        switch rawValue {
    \#(raw: cases.indented())
        default:
            self = .unknown(rawValue)
        }
    }
    """#
    guard let decl = InitializerDeclSyntax(syntax) else {
        throw MacroError.cannotUnwrapSyntax(type: InitializerDeclSyntax.self)
    }
    return decl
}

func makeCaseIterable(
    accessLevelModifier: String,
    enumIdentifier: TokenSyntax,
    cases: [EnumCase]
) throws -> VariableDeclSyntax {
    let cases = cases.map { enumCase in
        ".\(enumCase.key),"
    }
    let syntax: DeclSyntax = """
    \(raw: accessLevelModifier)static var allCases: [\(enumIdentifier)] {
    [
    \(raw: cases.indented())
    ]
    }
    """
    guard let decl = VariableDeclSyntax(syntax) else {
        throw MacroError.cannotUnwrapSyntax(type: VariableDeclSyntax.self)
    }
    return decl
}

private func makeDecodableInitializer(
    accessLevelModifier: String,
    enumIdentifier: TokenSyntax,
    location: AbstractSourceLocation,
    rawType: RawKind,
    cases: [EnumCase]
) throws -> InitializerDeclSyntax {
    let syntax: DeclSyntax = #"""
    \#(raw: accessLevelModifier)init(from decoder: any Decoder) throws {
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
    guard let decl = InitializerDeclSyntax(syntax) else {
        throw MacroError.cannotUnwrapSyntax(type: InitializerDeclSyntax.self)
    }
    return decl
}

private extension AbstractSourceLocation {
    var description: String {
        let file = self.file.description.filter({ ![" ", #"""#].contains($0) })
        return "\(file):\(self.line.description)"
    }
}

private func + (lhs: [SwitchCaseSyntax], rhs: [SwitchCaseSyntax]) -> SwitchCaseListSyntax {
    var lhs = lhs
    for item in rhs {
        lhs.append(item)
    }
    return .init(lhs.map { .switchCase($0) })
}

private func + (lhs: ModifierListSyntax, rhs: [DeclModifierSyntax]) -> ModifierListSyntax {
    var lhs = lhs
    for item in rhs {
        var elements = Array(lhs)
        elements.append(item)
        lhs = .init(elements)
    }
    return lhs
}

private extension EnumDeclSyntax {
    var accessLevelModifier: String? {
        let accessLevelModifiers: [Keyword] = [.open, .public, .internal, .private, .fileprivate]
        for modifier in (self.modifiers ?? []) {
            guard let modifier = modifier.as(DeclModifierSyntax.self),
                  case let .keyword(keyword) = modifier.name.tokenKind else {
                continue
            }
            if accessLevelModifiers.contains(keyword) {
                return modifier.name.trimmedDescription
            }
        }
        return nil
    }
}

private extension String {
    func indented() -> String {
        self.split(
            separator: "\n",
            omittingEmptySubsequences: false
        ).map {
            "    \($0)"
        }.joined(separator: "\n")
    }
}

private extension Array<String> {
    func indented() -> String {
        self.map {
            $0.indented()
        }.joined(separator: "\n")
    }
}
