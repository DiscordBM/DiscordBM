import UnstableEnumMacro
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

class UnstableEnumMacroTests: XCTestCase {
    
    /// TODO: test **conformance** macro expansion too
    /// `assertMacroExpansion` seems to not to do that
    
    let macros: [String: any Macro.Type] = [
        "UnstableEnum": UnstableEnum.self
    ]
    
    func testStringEnum() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum MyEnum: RawRepresentable {
                case a
                case b // bb
            }
            """,
            expandedSource: """
            
            enum MyEnum: RawRepresentable {
                case a
                case b // bb
                case unknown(String)
                /// This case serves as a way of discouraging exhaustive switch statements
                case __DO_NOT_USE_THIS_CASE
                var rawValue: String {
                    switch self {
                    case .a:
                        return "a"
                    case .b:
                        return "bb"
                    case let .unknown(value):
                        return value
                    case .__DO_NOT_USE_THIS_CASE:
                        fatalError("Must not use the '__DO_NOT_USE_THIS_CASE' case. This case serves as a way of discouraging exhaustive switch statements")
                    }
                }
                init?(rawValue: String) {
                    switch rawValue {
                    case "a":
                        self = .a
                    case "bb":
                        self = .b
                    default:
                        self = .unknown(rawValue)
                    }
                }
            }
            """,
            macros: macros
        )
        
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum MyEnum {
                case a
                case b // bb
            }
            """,
            expandedSource: """
            
            enum MyEnum {
                case a
                case b // bb
                case unknown(String)
                /// This case serves as a way of discouraging exhaustive switch statements
                case __DO_NOT_USE_THIS_CASE
                var rawValue: String {
                    switch self {
                    case .a:
                        return "a"
                    case .b:
                        return "bb"
                    case let .unknown(value):
                        return value
                    case .__DO_NOT_USE_THIS_CASE:
                        fatalError("Must not use the '__DO_NOT_USE_THIS_CASE' case. This case serves as a way of discouraging exhaustive switch statements")
                    }
                }
                init?(rawValue: String) {
                    switch rawValue {
                    case "a":
                        self = .a
                    case "bb":
                        self = .b
                    default:
                        self = .unknown(rawValue)
                    }
                }
            }
            """,
            macros: macros
        )
        
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum MyEnum: RawRepresentable {
                case a // "oo"
                case b // "bb"
            }
            """,
            expandedSource: """
            
            enum MyEnum: RawRepresentable {
                case a // "oo"
                case b // "bb"
                case unknown(String)
                /// This case serves as a way of discouraging exhaustive switch statements
                case __DO_NOT_USE_THIS_CASE
                var rawValue: String {
                    switch self {
                    case .a:
                        return "oo"
                    case .b:
                        return "bb"
                    case let .unknown(value):
                        return value
                    case .__DO_NOT_USE_THIS_CASE:
                        fatalError("Must not use the '__DO_NOT_USE_THIS_CASE' case. This case serves as a way of discouraging exhaustive switch statements")
                    }
                }
                init?(rawValue: String) {
                    switch rawValue {
                    case "oo":
                        self = .a
                    case "bb":
                        self = .b
                    default:
                        self = .unknown(rawValue)
                    }
                }
            }
            """,
            macros: macros
        )
    }
    
    func testIntEnum() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<Int>
            enum MyEnum: RawRepresentable {
                case a // 1
                case b // 5
            }
            """,
            expandedSource: """
            
            enum MyEnum: RawRepresentable {
                case a // 1
                case b // 5
                case unknown(Int)
                /// This case serves as a way of discouraging exhaustive switch statements
                case __DO_NOT_USE_THIS_CASE
                var rawValue: Int {
                    switch self {
                    case .a:
                        return 1
                    case .b:
                        return 5
                    case let .unknown(value):
                        return value
                    case .__DO_NOT_USE_THIS_CASE:
                        fatalError("Must not use the '__DO_NOT_USE_THIS_CASE' case. This case serves as a way of discouraging exhaustive switch statements")
                    }
                }
                init?(rawValue: Int) {
                    switch rawValue {
                    case 1:
                        self = .a
                    case 5:
                        self = .b
                    default:
                        self = .unknown(rawValue)
                    }
                }
            }
            """,
            macros: macros
        )
    }
    
    func testDecodableEnum() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<Int>
            enum MyEnum: RawRepresentable, Codable {
                case a // 1
                case b // 5
            }
            """,
            expandedSource: #"""
            
            enum MyEnum: RawRepresentable, Codable {
                case a // 1
                case b // 5
                case unknown(Int)
                /// This case serves as a way of discouraging exhaustive switch statements
                case __DO_NOT_USE_THIS_CASE
                var rawValue: Int {
                    switch self {
                    case .a:
                        return 1
                    case .b:
                        return 5
                    case let .unknown(value):
                        return value
                    case .__DO_NOT_USE_THIS_CASE:
                        fatalError("Must not use the '__DO_NOT_USE_THIS_CASE' case. This case serves as a way of discouraging exhaustive switch statements")
                    }
                }
                init?(rawValue: Int) {
                    switch rawValue {
                    case 1:
                        self = .a
                    case 5:
                        self = .b
                    default:
                        self = .unknown(rawValue)
                    }
                }
                init(from decoder: any Decoder) throws {
                    try self.init(rawValue: Int(from: decoder))!
                    #if DISCORDBM_ENABLE_LOGGING_DURING_DECODE
                    if case let .unknown(value) = self {
                        DiscordGlobalConfiguration.makeDecodeLogger("MyEnum").warning("Found an unknown value", metadata: ["value": "\(value)", "typeName": "MyEnum", "location": "TestModule/test.swift:1"])
                    }
                    #endif
                }
            }
            """#,
            macros: macros
        )
        
        assertMacroExpansion(
            """
            @UnstableEnum<Int>
            enum MyEnum: RawRepresentable, Decodable, SomethingElse {
                case a // 1
                case b // 5
            }
            """,
            expandedSource: #"""
            
            enum MyEnum: RawRepresentable, Decodable, SomethingElse {
                case a // 1
                case b // 5
                case unknown(Int)
                /// This case serves as a way of discouraging exhaustive switch statements
                case __DO_NOT_USE_THIS_CASE
                var rawValue: Int {
                    switch self {
                    case .a:
                        return 1
                    case .b:
                        return 5
                    case let .unknown(value):
                        return value
                    case .__DO_NOT_USE_THIS_CASE:
                        fatalError("Must not use the '__DO_NOT_USE_THIS_CASE' case. This case serves as a way of discouraging exhaustive switch statements")
                    }
                }
                init?(rawValue: Int) {
                    switch rawValue {
                    case 1:
                        self = .a
                    case 5:
                        self = .b
                    default:
                        self = .unknown(rawValue)
                    }
                }
                init(from decoder: any Decoder) throws {
                    try self.init(rawValue: Int(from: decoder))!
                    #if DISCORDBM_ENABLE_LOGGING_DURING_DECODE
                    if case let .unknown(value) = self {
                        DiscordGlobalConfiguration.makeDecodeLogger("MyEnum").warning("Found an unknown value", metadata: ["value": "\(value)", "typeName": "MyEnum", "location": "TestModule/test.swift:1"])
                    }
                    #endif
                }
            }
            """#,
            macros: macros
        )
    }
    
    func testCaseIterableEnum() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum StringEnum: RawRepresentable, CaseIterable {
                case a
                case b
            }
            """,
            expandedSource: #"""
            
            enum StringEnum: RawRepresentable, CaseIterable {
                case a
                case b
                case unknown(String)
                /// This case serves as a way of discouraging exhaustive switch statements
                case __DO_NOT_USE_THIS_CASE
                var rawValue: String {
                    switch self {
                    case .a:
                        return "a"
                    case .b:
                        return "b"
                    case let .unknown(value):
                        return value
                    case .__DO_NOT_USE_THIS_CASE:
                        fatalError("Must not use the '__DO_NOT_USE_THIS_CASE' case. This case serves as a way of discouraging exhaustive switch statements")
                    }
                }
                init?(rawValue: String) {
                    switch rawValue {
                    case "a":
                        self = .a
                    case "b":
                        self = .b
                    default:
                        self = .unknown(rawValue)
                    }
                }
                static var allCases: [StringEnum] {
                    [.a, .b,]
                }
            }
            """#,
            macros: macros
        )
    }
    
    func testKeepsPublicAccessModifier() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            public enum MyEnum: RawRepresentable {
                case a
                case b // bb
            }
            """,
            expandedSource: """
            
            public enum MyEnum: RawRepresentable {
                case a
                case b // bb
                case unknown(String)
                /// This case serves as a way of discouraging exhaustive switch statements
                case __DO_NOT_USE_THIS_CASE
                public var rawValue: String {
                    switch self {
                    case .a:
                        return "a"
                    case .b:
                        return "bb"
                    case let .unknown(value):
                        return value
                    case .__DO_NOT_USE_THIS_CASE:
                        fatalError("Must not use the '__DO_NOT_USE_THIS_CASE' case. This case serves as a way of discouraging exhaustive switch statements")
                    }
                }
                public init?(rawValue: String) {
                    switch rawValue {
                    case "a":
                        self = .a
                    case "bb":
                        self = .b
                    default:
                        self = .unknown(rawValue)
                    }
                }
            }
            """,
            macros: macros
        )
    }
    
    func testBadIntEnum() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<Int>
            enum MyEnum: RawRepresentable {
                case a // 1
                case b
            }
            """,
            expandedSource: """
            
            enum MyEnum: RawRepresentable {
                case a // 1
                case b
            }
            """,
            diagnostics: [.init(
                message: "allEnumCasesWithIntTypeMustHaveACommentForValue",
                line: 4,
                column: 10
            )],
            macros: macros
        )
    }
    
    func testProgrammerErrorWrongArgumentType() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<Int>
            enum MyEnum: RawRepresentable {
                case a // bb
                case b // 1
            }
            """,
            expandedSource: """
            
            enum MyEnum: RawRepresentable {
                case a // bb
                case b // 1
            }
            """,
            diagnostics: [.init(
                message: "intEnumMustOnlyHaveIntValues",
                line: 1,
                column: 1
            )],
            macros: macros
        )
        
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum MyEnum: RawRepresentable {
                case a // 2
                case b // 1
            }
            """,
            expandedSource: """
            
            enum MyEnum: RawRepresentable {
                case a // 2
                case b // 1
            }
            """,
            diagnostics: [.init(
                message: "enumSeemsToHaveIntValuesButGenericArgumentSpecifiesString",
                line: 1,
                column: 1
            )],
            macros: macros
        )
    }
    
    func testInconsistentQuotes() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum MyEnum: RawRepresentable {
                case a // a
                case b // "1
            }
            """,
            expandedSource: """
            
            enum MyEnum: RawRepresentable {
                case a // a
                case b // "1
            }
            """,
            diagnostics: [.init(
                message: "inconsistentQuotesAroundComment",
                line: 4,
                column: 10
            )],
            macros: macros
        )
    }
    
    func testValuesNotUnique() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum MyEnum: RawRepresentable {
                case a // 1
                case b // 1
            }
            """,
            expandedSource: """
            
            enum MyEnum: RawRepresentable {
                case a // 1
                case b // 1
            }
            """,
            diagnostics: [.init(
                message: "valuesMustBeUnique",
                line: 1,
                column: 1
            )],
            macros: macros
        )
    }
    
    func testNoRawValues() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum MyEnum: RawRepresentable {
                case a = "g"
                case b = "gg"
            }
            """,
            expandedSource: """
            
            enum MyEnum: RawRepresentable {
                case a = "g"
                case b = "gg"
            }
            """,
            diagnostics: [
                .init(
                    message: "rawValuesNotAcceptable",
                    line: 3,
                    column: 12,
                    fixIts: [.init(message: "useCommentsInstead")]
                ),
                .init(
                    message: "rawValuesNotAcceptable",
                    line: 4,
                    column: 12,
                    fixIts: [.init(message: "useCommentsInstead")]
                )
            ],
            macros: macros
        )
    }
}
