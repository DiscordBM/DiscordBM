#if DEBUG
@testable import Logging
#else
import Logging
#endif
import DiscordModels
import DiscordUtils
import Foundation

public struct DiscordLogHandler: LogHandler {
    
    public enum Address: Hashable {
        case channel(id: String)
        case webhook(WebhookAddress)
    }
    
    /// The label of this log handler.
    public let label: String
    /// See `LogHandler.metadata`.
    public var metadata: Logger.Metadata
    /// See `LogHandler.metadataProvider`.
    public var metadataProvider: Logger.MetadataProvider?
    /// See `LogHandler.logLevel`.
    public var logLevel: Logger.Level
    /// The address to send the logs to.
    let address: Address
    /// `logManager` does the actual heavy-lifting and communicates with Discord.
    var logManager: DiscordLogManager { .shared }
    
    init(
        label: String,
        metadata: Logger.Metadata = [:],
        metadataProvider: Logger.MetadataProvider? = nil,
        logLevel: Logger.Level = .info,
        address: Address
    ) {
        self.label = label
        self.metadata = metadata
        self.metadataProvider = metadataProvider
        self.logLevel = logLevel
        self.address = address
    }
    
    /// Make a logger that logs to both the stdout and to Discord.
    public static func multiplexLogger(
        label: String,
        level: Logger.Level = .info,
        metadataProvider: Logger.MetadataProvider? = nil,
        address: Address,
        makeStdoutLogHandler: (String, Logger.MetadataProvider?) -> LogHandler
    ) -> Logger {
        Logger(label: label) { label in
            var handler = MultiplexLogHandler([
                makeStdoutLogHandler(label, metadataProvider),
                DiscordLogHandler(
                    label: label,
                    metadataProvider: metadataProvider,
                    logLevel: level,
                    address: address
                )
            ])
            handler.logLevel = level
            return handler
        }
    }
    
    /// Bootstraps the logging system to use `DiscordLogHandler`.
    /// After calling this function, all your `Logger`s will start using `DiscordLogHandler`.
    ///
    /// - NOTE: Be careful because `LoggingSystem.bootstrap` can only be called once.
    /// If you use libraries like Vapor, you would want to remove such lines where you call `LoggingSystem...` and replacing it with this function.
    public static func bootstrap(
        level: Logger.Level = .info,
        metadataProvider: Logger.MetadataProvider? = nil,
        address: Address,
        makeStdoutLogHandler: @escaping (String, Logger.MetadataProvider?) -> LogHandler
    ) {
#if DEBUG
        LoggingSystem.bootstrapInternal({ label, metadataProvider in
            var handler = MultiplexLogHandler([
                makeStdoutLogHandler(label, metadataProvider),
                DiscordLogHandler(
                    label: label,
                    metadataProvider: metadataProvider,
                    logLevel: level,
                    address: address
                )
            ])
            handler.logLevel = level
            return handler
        }, metadataProvider: metadataProvider)
#else
        LoggingSystem.bootstrap({ label, metadataProvider in
            var handler = MultiplexLogHandler([
                makeStdoutLogHandler(label, metadataProvider),
                DiscordLogHandler(
                    label: label,
                    metadataProvider: metadataProvider,
                    logLevel: level,
                    address: address
                )
            ])
            handler.logLevel = level
            return handler
        }, metadataProvider: metadataProvider)
#endif
    }
    
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { return metadata[key] }
        set(newValue) { self.metadata[key] = newValue }
    }
    
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        // FIXME: Delete this line when swift-log is updated with the fix, and pin swift-log.
        // https://github.com/apple/swift-log/pull/252
        if line == 180 && source == "Logging" && function == "metadataProvider" { return }
        
        let config = logManager.configuration
        
        if config.disabledLogLevels.contains(level) { return }
        
        var allMetadata: Logger.Metadata = [:]
        if !config.excludeMetadata.contains(level) {
            allMetadata = (metadata ?? [:])
                .merging(self.metadata, uniquingKeysWith: { a, _ in a })
                .merging(self.metadataProvider?.get() ?? [:], uniquingKeysWith: { a, _ in a })
            if config.extraMetadata.contains(level) {
                allMetadata.merge([
                    "_source": .string(source),
                    "_file": .string(file),
                    "_function": .string(function),
                    "_line": .stringConvertible(line),
                ], uniquingKeysWith: { a, _ in a })
            }
        }
        
        let embed = Embed(
            title: prepare("\(message)"),
            timestamp: Date(),
            color: config.colors[level],
            footer: .init(text: prepare(self.label).notEmpty(or: "no_label")),
            fields: Array(allMetadata.sorted(by: { $0.key > $1.key }).compactMap {
                key, value -> Embed.Field? in
                let value = "\(value)"
                if key.isEmpty || value.isEmpty { return nil }
                return .init(name: prepare(key), value: prepare(value))
            }.maxCount(25))
        )
        
        Task { await logManager.include(address: address, embed: embed, level: level) }
    }
    
    private func prepare(_ text: String) -> String {
        let escaped = DiscordUtils.escapingSpecialCharacters(text, forChannelType: .text)
        return String(escaped.unicodeScalars.maxCount(250))
    }
}

private extension Collection {
    func maxCount(_ count: Int) -> Self.SubSequence {
        let delta = (self.count - count)
        let dropCount = delta > 0 ? delta : 0
        return self.dropLast(Int(dropCount))
    }
}

private extension String {
    func notEmpty(or alternative: String) -> String {
        self.isEmpty ? alternative : self
    }
}
