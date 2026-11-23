import Foundation
import PackagePlugin

@main
struct GenerateAPIEndpoints: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "GenerateAPIEndpointsExec")
        let process = Process()
        process.executableURL = tool.url
        try process.run()
        process.waitUntilExit()
    }
}
