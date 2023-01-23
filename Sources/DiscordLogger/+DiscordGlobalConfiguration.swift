import DiscordCore

extension DiscordGlobalConfiguration {
    private static var _logManager: DiscordLogManager?
    
    /// The manager of logging to Discord.
    /// You must initialize this, if you want to use `DiscordLogHandler`.
    public static var logManager: DiscordLogManager {
        get {
            guard let shared = _logManager else {
                fatalError("Need to configure the log-manager using 'DiscordLogManager.shared = DiscordLogManager(...)'")
            }
            return shared
        }
        set(newValue) { _logManager = newValue }
    }
}
