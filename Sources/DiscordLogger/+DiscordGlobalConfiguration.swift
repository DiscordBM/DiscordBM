import DiscordCore
import NIOConcurrencyHelpers

/// The point of this storage is to disable Sendable warnings when using
/// `-strict-concurrency=complete`
class ConfigurationStorage: @unchecked Sendable {
    var logManager: DiscordLogManager?
    
    static let shared = ConfigurationStorage()
}

extension DiscordGlobalConfiguration {
    /// The manager of logging to Discord.
    /// You must initialize this, if you want to use `DiscordLogHandler`.
    public static var logManager: DiscordLogManager {
        get {
            guard let logManager = ConfigurationStorage.shared.logManager else {
                fatalError("Need to configure the log-manager using 'DiscordGlobalConfiguration.logManager = DiscordLogManager(...)'")
            }
            return logManager
        }
        set {
            ConfigurationStorage.shared.logManager = newValue
        }
    }
}
