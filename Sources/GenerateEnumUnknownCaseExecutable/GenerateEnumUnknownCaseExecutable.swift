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
        
        let code = """
        enum NewEnum {
            case hello
        }
        """
        
        print("DOING IT!------------------------------------------------------------------")
        
        let data = Data(code.utf8)
        let write = fm.createFile(atPath: outputPath, contents: data)
        if !write {
            print("Failed to create/write to file at \(outputPath.debugDescription). Generated: \(code.debugDescription)")
        }
    }
    
    func parse(file: Data) {
        [UInt8](file).withUnsafeBufferPointer { pointer in
            let parsed = Parser.parse(
                source: pointer,
                maximumNestingLevel: nil,
                parseTransition: nil
            )
        }
    }
}

enum CodeGeneratorError: Error {
    case invalidArguments(Int)
    case invalidInput
}
