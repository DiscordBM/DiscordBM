import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxMacros

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
/// Adds a new `.undocumented(RawValue)` case.
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

        let (cases, hasError) = elements.makeCases(rawType: rawType, context: context)

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
            makeUnknownEnumCase(rawType: rawType),
            doNotUseCaseDeclaration,
            cases.makeRawValueVar(accessLevel: accessLevel, rawType: rawType),
            cases.makeInitializer(accessLevel: accessLevel, rawType: rawType)
        ]

        let conformsToCaseIterable = enumDecl.inheritanceClause?.inheritedTypeCollection.contains {
            $0.typeName.as(SimpleTypeIdentifierSyntax.self)?.name.text == "CaseIterable"
        }

        if conformsToCaseIterable == true {
            let conformance = cases.makeCaseIterable(
                accessLevel: accessLevel,
                enumIdentifier: enumDecl.identifier
            )
            syntaxes.append(conformance)
        }

        let conformsToDecodable = enumDecl.inheritanceClause?.inheritedTypeCollection.contains {
            let name = $0.typeName.as(SimpleTypeIdentifierSyntax.self)?.name.text
            return name == "Codable" || name == "Decodable"
        }

        if conformsToDecodable == true {
            guard let location: AbstractSourceLocation = context.location(of: node) else {
                throw MacroError.couldNotFindLocationOfNode
            }
            let decodableInit = cases.makeDecodableInitializer(
                accessLevel: accessLevel,
                enumIdentifier: enumDecl.identifier,
                location: location,
                rawType: rawType
            )
            syntaxes.append(decodableInit)
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

private func makeUnknownEnumCase(rawType: RawKind) -> DeclSyntax {
    """
    case undocumented(\(raw: rawType.rawValue))
    """
}

private let doNotUseCaseDeclaration: DeclSyntax = """
/// This case serves as a way of discouraging exhaustive switch statements
case \(raw: String.doNotUseCase)
"""

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
