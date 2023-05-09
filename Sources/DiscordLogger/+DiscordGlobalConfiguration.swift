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
            syncedInDebug {
                guard let logManager = ConfigurationStorage.shared.logManager else {
                    fatalError("You need to configure the log-manager before using 'DiscordLogHandler', using 'DiscordGlobalConfiguration.logManager = DiscordLogManager(...)'")
                }
                return logManager
            }
        }
        set {
            syncedInDebug {
                ConfigurationStorage.shared.logManager = newValue
            }
        }
    }
}

// MARK: To satisfy thread sanitizer in tests. Doesn't actually need any synchronizations.
#if DEBUG
private let queue = DispatchQueue(label: "DiscordBM.logManager")
#endif

private func syncedInDebug<T>(block: @Sendable () -> (T)) -> T {
#if DEBUG
    queue.sync {
        block()
    }
#else
    block()
#endif
}
