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
    public static var enableLoggingDuringDecode: Bool = false
    
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
