import Foundation
import SwiftSyntax
import SwiftParser

@main
struct GenerateEnumUnknownCaseExecutable {
    static func main() async throws {
        guard CommandLine.arguments.count == 3 else {
            throw CodeGeneratorError.invalidArguments(CommandLine.arguments.count)
        }
        // arguments[0] is the path to this command line tool
        let fm = FileManager.default
        let outputPath = CommandLine.arguments[2]
        guard let input = fm.contents(atPath: CommandLine.arguments[1]) else {
            throw CodeGeneratorError.invalidInput
        }
        parse(file: input)
        
        let code = """
        """
        
        print("DOING IT!------------------------------------------------------------------")
        
        let data = Data(code.utf8)
        let write = fm.createFile(atPath: outputPath, contents: data)
        if !write {
            print("Failed to create/write to file at \(outputPath.debugDescription). Generated: \(code.debugDescription)")
        }
    }
    
    static func parse(file: Data) {
        [UInt8](file).withUnsafeBufferPointer { pointer in
            let parsed = Parser.parse(
                source: pointer,
                maximumNestingLevel: nil,
                parseTransition: nil
            )
            
            parsed.statements.forEach({
//                print("Start", $0.firstToken, type(of: $0.firstToken), "END", separator: "\n")
                print("Start", $0.tokens(viewMode: .fixedUp).enums, "END", separator: "\n")
            })
        }
    }
}

extension TokenSequence {
    var enums: [TokenSyntax] {
        self.flatMap {
            if $0 == TokenSyntax.keyword(.enum) {
                return [$0]
            } else {
                return $0.tokens(viewMode: .fixedUp).
            }
        }
    }
}

enum CodeGeneratorError: Error {
    case invalidArguments(Int)
    case invalidInput
}
