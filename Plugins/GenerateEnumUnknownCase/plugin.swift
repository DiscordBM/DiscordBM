import PackagePlugin
import Foundation

@main
struct GenerateEnumUnknownCasePlugin: BuildToolPlugin {
    
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let target = target as? SourceModuleTarget else { return [] }
        
        let dir = context.pluginWorkDirectory
        let outputDir = dir
        
        try FileManager.default.removeItem(atPath: dir.string)
        
        return try target.sourceFiles(withSuffix: "swift").flatMap { file -> [Command] in
            
            let output = outputDir.appending(["\(file.path.stem) +GEUCP.swift"])
            
            let tool = try context.tool(named: "GenerateEnumUnknownCaseExecutable")
            
            return [.buildCommand(
                displayName: "Generating \(output.string.dropFirst(20))",
                executable: tool.path,
                arguments: [file.path, output],
                inputFiles: [file.path],
                outputFiles: [output]
            )]
        }
    }
}
