import Logging
import DiscordModels

extension LoggingSystem {
    /// Bootstraps the logging system to use `DiscordLogHandler`.
    /// After calling this function, all your `Logger`s will start using `DiscordLogHandler`.
    ///
    /// - NOTE: Be careful because `LoggingSystem.bootstrap` can only be called once.
    /// If you use libraries like Vapor, you would want to remove such lines where you call `LoggingSystem...` and replace it with this function.
    public static func bootstrapWithDiscordLogger(
        address: DiscordLogHandler.Address,
        level: Logger.Level = .info,
        metadataProvider: Logger.MetadataProvider? = nil,
        makeStdoutLogHandler: @escaping (String, Logger.MetadataProvider?) -> LogHandler
    ) {
        LoggingSystem.bootstrap({ label, metadataProvider in
            var handler = MultiplexLogHandler([
                makeStdoutLogHandler(label, metadataProvider),
                DiscordLogHandler(
                    label: label,
                    address: address,
                    level: level,
                    metadataProvider: metadataProvider
                )
            ])
            handler.logLevel = level
            return handler
        }, metadataProvider: metadataProvider)
    }
}
