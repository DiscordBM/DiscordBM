#if DEBUG
@testable import Logging
#else
import Logging
#endif
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
        logLevel: Logger.Level? = nil,
        address: Address? = nil
    ) {
        self.label = label
        self.metadata = metadata
        self.metadataProvider = metadataProvider
        self.logLevel = logLevel ?? DiscordLogManager.shared.configuration.defaultLogLevel ?? .info
        switch address {
        case .some(let address):
            self.address = address
        case .none:
            guard let defaultAddress = DiscordLogManager.shared.configuration.defaultAddress else {
                fatalError("Must either pass 'address', or set the 'defaultAddress' in 'DiscordLogManager.Configuration'")
            }
            self.address = defaultAddress
        }
    }
    
    /// Get a logger that logs to both the stdout and to Discord.
    /// Must set the `address` if you haven't passed the `defaultAddress` to `DiscordLogManager.Configuration`.
    /// Must set the `stdoutLogHandler` if you haven't passed the `defaultStdoutLogHandler` to `DiscordLogManager.Configuration`.
    public static func multiplexLogger(
        label: String,
        level: Logger.Level? = nil,
        metadataProvider: Logger.MetadataProvider? = nil,
        address: Address? = nil,
        stdoutLogHandler: LogHandler? = nil
    ) -> Logger {
        let config = DiscordLogManager.shared.configuration
        guard let stdoutLogHandler = stdoutLogHandler ?? config.makeDefaultLogHandler?(label) else {
            fatalError("Must either pass 'stdoutLogHandler', or set the 'defaultStdoutLogHandler' in 'DiscordLogManager.Configuration'")
        }
        return Logger(label: label) { label in
            var handler = MultiplexLogHandler([
                stdoutLogHandler,
                DiscordLogHandler(
                    label: label,
                    metadataProvider: metadataProvider,
                    logLevel: level,
                    address: address
                )
            ])
            if let level = level {
                handler.logLevel = level
            }
            return handler
        }
    }
    
    /// Bootstrap the logging system to use `DiscordLogHandler`.
    /// Must set the `address` if you haven't passed the `defaultAddress` to `DiscordLogManager.Configuration`.
    /// Must set the `stdoutLogHandler` if you haven't passed the `defaultStdoutLogHandler` to `DiscordLogManager.Configuration`.
    /// - NOTE: Be careful because `LoggingSystem.bootstrap` can only be called once.
    /// If you use libraries like Vapor, they already call the method once.
    public static func bootstrap(
        label: String,
        level: Logger.Level? = nil,
        metadataProvider: Logger.MetadataProvider? = nil,
        address: Address? = nil,
        stdoutLogHandler: LogHandler? = nil
    ) {
        let config = DiscordLogManager.shared.configuration
        guard let stdoutLogHandler = stdoutLogHandler ?? config.makeDefaultLogHandler?(label) else {
            fatalError("Must either pass 'stdoutLogHandler', or set the 'defaultStdoutLogHandler' in 'DiscordLogManager.Configuration'")
        }
#if DEBUG
        return LoggingSystem.bootstrapInternal({ label, metadataProvider in
            var handler = MultiplexLogHandler([
                stdoutLogHandler,
                DiscordLogHandler(
                    label: label,
                    metadataProvider: metadataProvider,
                    logLevel: level,
                    address: address
                )
            ])
            if let level = level {
                handler.logLevel = level
            }
            return handler
        }, metadataProvider: metadataProvider)
#else
        return LoggingSystem.bootstrap({ label, metadataProvider in
            var handler = MultiplexLogHandler([
                stdoutLogHandler,
                DiscordLogHandler(
                    label: label,
                    metadataProvider: metadataProvider,
                    logLevel: level,
                    address: address
                )
            ])
            if let level = level {
                handler.logLevel = level
            }
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
        let config = logManager.configuration
        
        if config.disabledLogLevels.contains(level) { return }
        
        var allMetadata: Logger.Metadata = [:]
        if !config.excludeMetadata.contains(level) {
            allMetadata = (metadata ?? [:])
                .merging(self.metadata, uniquingKeysWith: { a, _ in a })
                .merging(self.metadataProvider?.get() ?? [:], uniquingKeysWith: { a, _ in a })
            if config.extraMetadata.contains(logLevel) {
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
