import Logging

//MARK: - Internal DiscordGlobalConfiguration
extension DiscordGlobalConfiguration {
    static func makeDecodeLogger(_ label: String) -> Logger {
        if enableLoggingDuringDecode {
            var logger = DiscordGlobalConfiguration.makeLogger(label)
            logger[metadataKey: "explanation"] = "Please report this on https://github.com/MahdiBM/DiscordBM/issues if there are no similar issues, so we can keep DiscordBM up to date for the community. You can disable these logs by using 'DiscordGlobalConfiguration.enableLoggingDuringDecode = false'"
            return logger
        } else {
            return Logger(label: label, factory: SwiftLogNoOpLogHandler.init)
        }
    }
}
