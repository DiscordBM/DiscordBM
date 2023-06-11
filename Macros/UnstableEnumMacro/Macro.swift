import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxBuilder
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
public struct UnstableEnumMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if declaration.hasError { return [] }

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

        let (cases, hasError) = makeCases(elements: elements, rawType: rawType, context: context)

        if hasError { return [] }


        /// Some validations

        let values = cases.map(\.1)

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


        let modifiers = enumDecl.modifiers

        var syntaxes: [DeclSyntax] = [
            DeclSyntax(makeUnknownEnumCase(rawType: rawType)),
            DeclSyntax(doNotUseCaseDeclaration),
            DeclSyntax(makeRawValueVar(modifiers: modifiers, rawType: rawType, cases: cases)),
            DeclSyntax(makeInitializer(modifiers: modifiers, rawType: rawType, cases: cases))
        ]

        let conformsToCaseIterable = enumDecl.inheritanceClause?.inheritedTypeCollection.contains {
            $0.typeName.as(SimpleTypeIdentifierSyntax.self)?.name.text == "CaseIterable"
        }

        if conformsToCaseIterable == true {
            let conformance = makeCaseIterable(
                modifiers: modifiers,
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
            let decodableInit = makeDecodableInitializer(
                modifiers: modifiers,
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
    case String, Int, UInt

    var isString: Bool {
        switch self {
        case .String:
            return true
        case .Int, .UInt:
            return false
        }
    }
}

private func makeCases(
    elements: [EnumCaseElementSyntax],
    rawType: RawKind,
    context: some MacroExpansionContext
) -> (cases: [(key: String, value: String)], hasError: Bool) {
    let cases = elements.compactMap {
        element -> (key: String, value: String)? in
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
            return (element.identifier.text, element.identifier.text)
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
                    if value.filter({ !$0.isWhitespace }).isEmpty {
                        let diagnostic = Diagnostic(
                            node: Syntax(element),
                            message: MacroError.emptyValuesAreNotAcceptable
                        )
                        context.diagnose(diagnostic)
                        return nil
                    }
                    return (element.identifier.text, value)
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
    if rawType.isString {
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

private let doNotUseCaseDeclaration = EnumCaseDeclSyntax(
    leadingTrivia: [
        .spaces(4),
        .docLineComment("/// This case serves as a way of discouraging exhaustive switch statements"),
        .newlines(1),
        .spaces(4),
    ],
    elements: [
        EnumCaseElementSyntax(
            identifier: .identifier(doNotUseCase)
        )
    ]
)

private func makeRawValueVar(
    modifiers: ModifierListSyntax?,
    rawType: RawKind,
    cases: [(String, String)]
) -> VariableDeclSyntax {
    VariableDeclSyntax(
        modifiers: modifiers,
        bindingKeyword: .keyword(.var),
        bindings: [
            PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(
                    identifier: .identifier("rawValue")
                ),
                typeAnnotation: TypeAnnotationSyntax(
                    type: SimpleTypeIdentifierSyntax(
                        name: .identifier(rawType.rawValue)
                    )
                ),
                accessor: .getter(CodeBlockSyntax(
                    statements: [
                        CodeBlockItemSyntax(
                            item: .expr(.init(fromProtocol: SwitchExprSyntax(
                                expression: IdentifierExprSyntax(
                                    identifier: .keyword(.`self`)
                                ),
                                cases: cases.map { key, value in
                                    SwitchCaseSyntax(
                                        label: .case(
                                            SwitchCaseLabelSyntax(
                                                caseItems: [
                                                    CaseItemSyntax(
                                                        pattern: ExpressionPatternSyntax(
                                                            expression: MemberAccessExprSyntax(
                                                                name: .identifier(key)
                                                            )
                                                        )
                                                    )
                                                ]
                                            )
                                        ),
                                        statements: [
                                            CodeBlockItemSyntax(
                                                item: .stmt(.init(fromProtocol: ReturnStmtSyntax(
                                                    expression: makeExpression(
                                                        rawType: rawType,
                                                        value: value
                                                    )
                                                )))
                                            )
                                        ]
                                    )
                                } + [
                                    SwitchCaseSyntax(
                                        label: .case(SwitchCaseLabelSyntax(
                                            caseItems: [
                                                CaseItemSyntax(
                                                    pattern: ValueBindingPatternSyntax(
                                                        bindingKeyword: .keyword(.let),
                                                        valuePattern: ExpressionPatternSyntax(
                                                            expression: FunctionCallExprSyntax(
                                                                calledExpression: MemberAccessExprSyntax(
                                                                    name: .identifier("unknown")
                                                                ),
                                                                leftParen: .leftParenToken(),
                                                                argumentList: [
                                                                    TupleExprElementSyntax(
                                                                        expression: UnresolvedPatternExprSyntax(
                                                                            pattern: IdentifierPatternSyntax(
                                                                                identifier: .identifier("value")
                                                                            )
                                                                        )
                                                                    )
                                                                ],
                                                                rightParen: .rightParenToken()
                                                            )
                                                        )
                                                    )
                                                )
                                            ]
                                        )),
                                        statements: [
                                            CodeBlockItemSyntax(
                                                item: .stmt(.init(
                                                    fromProtocol: ReturnStmtSyntax(
                                                        expression: IdentifierExprSyntax(
                                                            identifier: .identifier("value")
                                                        )
                                                    )
                                                ))
                                            )
                                        ]
                                    ),
                                    SwitchCaseSyntax(
                                        label: .case(
                                            SwitchCaseLabelSyntax(
                                                caseItems: [
                                                    CaseItemSyntax(
                                                        pattern: ExpressionPatternSyntax(
                                                            expression: MemberAccessExprSyntax(
                                                                name: .identifier(doNotUseCase)
                                                            )
                                                        )
                                                    )
                                                ]
                                            )
                                        ),
                                        statements: [
                                            CodeBlockItemSyntax(
                                                item: .expr(.init(fromProtocol: FunctionCallExprSyntax(
                                                    calledExpression: IdentifierExprSyntax(
                                                        identifier: .identifier("fatalError")
                                                    ),
                                                    leftParen: .leftParenToken(),
                                                    argumentList: [
                                                        .init(
                                                            expression: StringLiteralExprSyntax(
                                                                content: "Must not use the '\(doNotUseCase)' case. This case serves as a way of discouraging exhaustive switch statements"
                                                            )
                                                        )
                                                    ],
                                                    rightParen: .rightParenToken()
                                                )))
                                            )
                                        ]
                                    )
                                ]
                            )))
                        )
                    ]
                ))
            )
        ]
    )
}

private func makeInitializer(
    modifiers: ModifierListSyntax?,
    rawType: RawKind,
    cases: [(String, String)]
) -> InitializerDeclSyntax {
    InitializerDeclSyntax(
        modifiers: modifiers,
        optionalMark: .postfixQuestionMarkToken(),
        signature: FunctionSignatureSyntax(
            input: ParameterClauseSyntax(
                parameterList: [
                    FunctionParameterSyntax(
                        firstName: .identifier("rawValue"),
                        type: SimpleTypeIdentifierSyntax(
                            name: .identifier(rawType.rawValue)
                        )
                    )
                ]
            )
        ),
        body: CodeBlockSyntax(
            statements: [
                .init(item: .expr(.init(fromProtocol: SwitchExprSyntax(
                    expression: IdentifierExprSyntax(
                        identifier: .identifier("rawValue")
                    ),
                    cases: cases.map { key, value in
                        SwitchCaseSyntax(
                            label: .case(
                                SwitchCaseLabelSyntax(
                                    caseItems: [
                                        CaseItemSyntax(
                                            pattern: ExpressionPatternSyntax(
                                                expression: makeExpression(
                                                    rawType: rawType,
                                                    value: value
                                                )
                                            )
                                        )
                                    ]
                                )
                            ),
                            statements: [
                                CodeBlockItemSyntax(
                                    item: .expr(.init(fromProtocol: SequenceExprSyntax(
                                        elements: [
                                            IdentifierExprSyntax(identifier: .keyword(.`self`)),
                                            AssignmentExprSyntax(),
                                            MemberAccessExprSyntax(name: .identifier(key))
                                        ]
                                    )))
                                )
                            ]
                        )
                    } + [
                        SwitchCaseSyntax(
                            label: .default(SwitchDefaultLabelSyntax()),
                            statements: [
                                CodeBlockItemSyntax(
                                    item: .expr(.init(fromProtocol: SequenceExprSyntax(
                                        elements: [
                                            IdentifierExprSyntax(identifier: .keyword(.`self`)),
                                            AssignmentExprSyntax(),
                                            FunctionCallExprSyntax(
                                                calledExpression: MemberAccessExprSyntax(
                                                    name: .identifier("unknown")
                                                ),
                                                leftParen: .leftParenToken(),
                                                argumentList: [
                                                    TupleExprElementSyntax(
                                                        expression: IdentifierExprSyntax(
                                                            identifier: .identifier("rawValue")
                                                        )
                                                    )
                                                ],
                                                rightParen: .rightParenToken()
                                            )
                                        ]
                                    )))
                                )
                            ]
                        )
                    ]
                ))))
            ]
        )
    )
}

func makeCaseIterable(
    modifiers: ModifierListSyntax?,
    enumIdentifier: TokenSyntax,
    cases: [(String, String)]
) -> VariableDeclSyntax {
    VariableDeclSyntax(
        modifiers: (modifiers ?? []) + [DeclModifierSyntax(name: .keyword(.`static`))],
        bindingKeyword: .keyword(.`var`),
        bindings: [
            PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(
                    identifier: .identifier("allCases")
                ),
                typeAnnotation: TypeAnnotationSyntax(
                    type: ArrayTypeSyntax(
                        elementType: SimpleTypeIdentifierSyntax(
                            name: enumIdentifier
                        )
                    )
                ),
                accessor: .getter(CodeBlockSyntax(
                    statements: [
                        CodeBlockItemSyntax(
                            item: .expr(.init(fromProtocol: ArrayExprSyntax(
                                elements: ArrayElementListSyntax(cases.map { key, _ in
                                    ArrayElementSyntax(
                                        expression: MemberAccessExprSyntax(
                                            name: .identifier(key)
                                        ),
                                        trailingComma: .commaToken()
                                    )
                                })
                            )))
                        )
                    ]
                ))
            )
        ]
    )
}

private func makeDecodableInitializer(
    modifiers: ModifierListSyntax?,
    enumIdentifier: TokenSyntax,
    location: AbstractSourceLocation,
    rawType: RawKind,
    cases: [(String, String)]
) -> InitializerDeclSyntax {
    InitializerDeclSyntax(
        modifiers: modifiers,
        signature: FunctionSignatureSyntax(
            input: ParameterClauseSyntax(
                parameterList: [
                    FunctionParameterSyntax(
                        firstName: .identifier("from"),
                        secondName: .identifier("decoder"),
                        type: ConstrainedSugarTypeSyntax(
                            someOrAnySpecifier: .keyword(.`any`),
                            baseType: SimpleTypeIdentifierSyntax(
                                name: .identifier("Decoder")
                            )
                        )
                    )
                ]
            ),
            effectSpecifiers: FunctionEffectSpecifiersSyntax(
                throwsSpecifier: .keyword(.`throws`)
            )
        ),
        body: CodeBlockSyntax(
            statements: [
                CodeBlockItemSyntax(
                    item: .expr(.init(fromProtocol: TryExprSyntax(
                        expression: ForcedValueExprSyntax(
                            expression: FunctionCallExprSyntax(
                                calledExpression: MemberAccessExprSyntax(
                                    base: IdentifierExprSyntax(
                                        identifier: .keyword(.`self`)
                                    ),
                                    name: .keyword(.`init`)
                                ),
                                leftParen: .leftParenToken(),
                                argumentList: [
                                    TupleExprElementSyntax(
                                        label: .identifier("rawValue"),
                                        colon: .colonToken(),
                                        expression: FunctionCallExprSyntax(
                                            calledExpression: IdentifierExprSyntax(
                                                identifier: .identifier(rawType.rawValue)
                                            ),
                                            leftParen: .leftParenToken(),
                                            argumentList: [
                                                TupleExprElementSyntax(
                                                    label: .identifier("from"),
                                                    colon: .colonToken(),
                                                    expression: IdentifierExprSyntax(
                                                        identifier: .identifier("decoder")
                                                    )
                                                )
                                            ],
                                            rightParen: .rightParenToken()
                                        )
                                    )
                                ],
                                rightParen: .rightParenToken()
                            ),
                            exclamationMark: .exclamationMarkToken()
                        )
                    )))
                ),
                CodeBlockItemSyntax(
                    item: .decl(.init(fromProtocol: IfConfigDeclSyntax(
                        clauses: [
                            IfConfigClauseSyntax(
                                poundKeyword: .poundIfKeyword(),
                                condition: IdentifierExprSyntax(
                                    identifier: .identifier("DISCORDBM_ENABLE_LOGGING_DURING_DECODE")
                                ),
                                elements: IfConfigClauseSyntax.Elements.statements([
                                    CodeBlockItemSyntax(
                                        item: .stmt(.init(fromProtocol: ExpressionStmtSyntax(
                                            expression: IfExprSyntax(
                                                conditions: makeDecodableInitConditions(),
                                                body: makeDecodableInitBody(
                                                    enumIdentifier: enumIdentifier,
                                                    location: location,
                                                    rawType: rawType,
                                                    cases: cases
                                                )
                                            )
                                        )))
                                    )
                                ])
                            )
                        ]
                    )))
                )
            ]
        )
    )
}

private func makeDecodableInitConditions() -> ConditionElementListSyntax {
    [ConditionElementSyntax(
        condition: .matchingPattern(MatchingPatternConditionSyntax(
            caseKeyword: .keyword(.`case`),
            pattern: ValueBindingPatternSyntax(
                bindingKeyword: .keyword(.let),
                valuePattern: ExpressionPatternSyntax(
                    expression: FunctionCallExprSyntax(
                        calledExpression: MemberAccessExprSyntax(
                            name: .identifier("unknown")
                        ),
                        leftParen: .leftParenToken(),
                        argumentList: [
                            TupleExprElementSyntax(
                                expression: UnresolvedPatternExprSyntax(
                                    pattern: IdentifierPatternSyntax(
                                        identifier: .identifier("value")
                                    )
                                )
                            )
                        ],
                        rightParen: .rightParenToken()
                    )
                )
            ),
            initializer: InitializerClauseSyntax(
                value: IdentifierExprSyntax(
                    identifier: .keyword(.`self`)
                )
            )
        ))
    )]
}

private func makeDecodableInitBody(
    enumIdentifier: TokenSyntax,
    location: AbstractSourceLocation,
    rawType: RawKind,
    cases: [(String, String)]
) -> CodeBlockSyntax {
    CodeBlockSyntax(
        statements: [
            CodeBlockItemSyntax(
                item: .expr(.init(fromProtocol: FunctionCallExprSyntax(
                    calledExpression: MemberAccessExprSyntax(
                        base: FunctionCallExprSyntax(
                            calledExpression: MemberAccessExprSyntax(
                                base: IdentifierExprSyntax(
                                    identifier: .identifier("DiscordGlobalConfiguration")
                                ),
                                name: .identifier("makeDecodeLogger")
                            ),
                            leftParen: .leftParenToken(),
                            argumentList: [
                                TupleExprElementSyntax(
                                    expression: StringLiteralExprSyntax(
                                        content: enumIdentifier.text
                                    )
                                )
                            ],
                            rightParen: .rightParenToken()
                        ),
                        name: .identifier("warning")
                    ),
                    leftParen: .leftParenToken(),
                    argumentList: [
                        TupleExprElementSyntax(
                            expression: StringLiteralExprSyntax(
                                content: "Found an unknown value"
                            ),
                            trailingComma: .commaToken()
                        ),
                        TupleExprElementSyntax(
                            label: .identifier("metadata"),
                            colon: .colonToken(),
                            expression: DictionaryExprSyntax(
                                content: DictionaryExprSyntax.Content.elements([
                                    DictionaryElementSyntax(
                                        keyExpression: StringLiteralExprSyntax(
                                            content: "value"
                                        ),
                                        valueExpression: StringLiteralExprSyntax(
                                            openQuote: .stringQuoteToken(),
                                            segments: [
                                                .expressionSegment(ExpressionSegmentSyntax(
                                                    expressions: [
                                                        TupleExprElementSyntax(
                                                            expression: IdentifierExprSyntax(
                                                                identifier: .identifier("value")
                                                            )
                                                        )
                                                    ]
                                                ))
                                            ],
                                            closeQuote: .stringQuoteToken()
                                        ),
                                        trailingComma: .commaToken()
                                    ),
                                    DictionaryElementSyntax(
                                        keyExpression: StringLiteralExprSyntax(
                                            content: "typeName"
                                        ),
                                        valueExpression: StringLiteralExprSyntax(
                                            content: enumIdentifier.text
                                        ),
                                        trailingComma: .commaToken()
                                    ),
                                    DictionaryElementSyntax(
                                        keyExpression: StringLiteralExprSyntax(
                                            content: "location"
                                        ),
                                        valueExpression: StringLiteralExprSyntax(
                                            content: location.description
                                        )
                                    )
                                ])
                            )
                        )
                    ],
                    rightParen: .rightParenToken()
                )))
            )
        ]
    )
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
        lhs = lhs.appending(item)
    }
    return lhs
}
