import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main
struct EntryPoint: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        UnstableEnum.self
    ]
}
