import PackagePlugin
import Foundation

@main
struct GenerateEnumUnknownCasePlugin: BuildToolPlugin {
    
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let target = target as? SourceModuleTarget else {
            return []
        }
        
        let fm = FileManager.default
        let dir = context.pluginWorkDirectory
        print(dir, fm.fileExists(atPath: dir.string))
        let outputDir = dir.appending(["GenerateEnumUnknownCase"])
        try fm.createDirectory(atPath: outputDir.string, withIntermediateDirectories: true)
        
        var isFirst = true
        for file in target.sourceFiles(withSuffix: "swift") {
            guard isFirst else { break }
            isFirst = false
            let base = file.path.stem
            let output = outputDir.appending(["\(base) + EnumPlugin.swift"]).string
            
            let generated = """
            public struct NewType: Codable {
                var value: String
            }
            """
            let data = Data(generated.utf8)
            print(output, fm.createFile(atPath: output, contents: data))
        }
        
        return []
    }
}
