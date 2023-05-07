import DiscordCore
#if DEBUG
import Foundation
#endif

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
            possiblySynced {
                guard let logManager = ConfigurationStorage.shared.logManager else {
                    fatalError("Need to configure the log-manager using 'DiscordGlobalConfiguration.logManager = DiscordLogManager(...)'")
                }
                return logManager
            }
        }
        set {
            possiblySynced {
                ConfigurationStorage.shared.logManager = newValue
            }
        }
    }
}

/// Mostly to satisfy thread sanitizer in tests
/// This realistically shouldn't need any synchronizations
private let queue = DispatchQueue(label: "DiscordBM.logManager")

private func possiblySynced<T>(block: () -> (T)) -> T {
#if DEBUG
    queue.sync {
        block()
    }
#else
    block()
#endif
}
