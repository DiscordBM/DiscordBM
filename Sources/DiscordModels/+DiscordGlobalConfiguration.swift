import Logging

extension DiscordGlobalConfiguration {
    /// Global rate-limit for requests per second.
    /// 50 by default, but you can ask Discord for a raise.
    public static var globalRateLimit = 50
    /// Whether or not to perform validations for `DefaultDiscordClient` payloads, before sending.
    /// The library will throw a ``ValidationError`` if it finds anything invalid in the payload.
    /// This all works based on Discord docs' validation notes.
    public static var performClientSideValidations = true
    /// Log about sub-optimal situations during decode.
    /// For example if a type can't find a representation to decode a value to,
    /// and has to get rid of that value.
    /// Does not include decode errors.
    /// This is supposed to be only used by the library author. Enabling this flag is discouraged.
    static func makeDecodeLogger(_ label: String) -> Logger {
#if DISCORDBM_ENABLE_LOGGING_DURING_DECODE
            var logger = DiscordGlobalConfiguration.makeLogger(label)
            logger[metadataKey: "tag"] = "decode-logger"
            return logger
#else
            return Logger(label: label, factory: SwiftLogNoOpLogHandler.init)
#endif
    }
}
