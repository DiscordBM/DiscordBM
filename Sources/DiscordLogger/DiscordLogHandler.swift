import Logging
import DiscordModels
import DiscordUtilities
import Foundation

public struct DiscordLogHandler: LogHandler {
    
    /// The label of this log handler.
    public let label: String
    /// The label prepared to be sent to Discord.
    let preparedLabel: String
    /// The address to send the logs to.
    let address: WebhookAddress
    /// See `LogHandler.metadata`.
    public var metadata: Logger.Metadata
    /// See `LogHandler.metadataProvider`.
    public var metadataProvider: Logger.MetadataProvider?
    /// See `LogHandler.logLevel`.
    public var logLevel: Logger.Level
    /// `logManager` does the actual heavy-lifting and communicates with Discord.
    var logManager: DiscordLogManager {
        DiscordGlobalConfiguration.logManager
    }
    
    init(
        label: String,
        address: WebhookAddress,
        level: Logger.Level = .info,
        metadataProvider: Logger.MetadataProvider? = nil
    ) {
        self.label = label
        self.preparedLabel = prepare(label, maxCount: 100)
        self.address = address
        self.logLevel = level
        self.metadata = [:]
        self.metadataProvider = metadataProvider
    }
    
    /// Make a logger that logs to both the a main place like stdout and also to Discord.
    public static func multiplexLogger(
        label: String,
        address: WebhookAddress,
        level: Logger.Level = .info,
        metadataProvider: Logger.MetadataProvider? = nil,
        makeMainLogHandler: (String, Logger.MetadataProvider?) -> any LogHandler
    ) -> Logger {
        Logger(label: label) { label in
            multiplexLogHandler(
                label: label,
                address: address,
                level: level,
                metadataProvider: metadataProvider,
                makeMainLogHandler: makeMainLogHandler
            )
        }
    }
    
    /// Make a log handler that logs to both the a main place like stdout and also to Discord.
    public static func multiplexLogHandler(
        label: String,
        address: WebhookAddress,
        level: Logger.Level = .info,
        metadataProvider: Logger.MetadataProvider? = nil,
        makeMainLogHandler: (String, Logger.MetadataProvider?) -> any LogHandler
    ) -> MultiplexLogHandler {
        var otherHandler = makeMainLogHandler(label, metadataProvider)
        otherHandler.logLevel = level
        let handler = MultiplexLogHandler([
            otherHandler,
            DiscordLogHandler(
                label: label,
                address: address,
                level: level,
                metadataProvider: metadataProvider
            )
        ])
        return handler
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
            title: prepare("\(message)", maxCount: 255),
            timestamp: Date(),
            color: config.colors[level],
            footer: .init(text: self.preparedLabel),
            fields: Array(allMetadata.sorted(by: { $0.key > $1.key })
                .map({ (key: $0.key, value: "\($0.value)") })
                .filter({ !($0.key.isEmpty || $0.value.isEmpty) })
                .maxCount(25)
                .map({ key, value in
                    Embed.Field(
                        name: prepare(key, maxCount: 25),
                        value: prepare(value, maxCount: 200)
                    )
                })
            )
        )
        
        Task { await logManager.include(address: address, embed: embed, level: level) }
    }
}

private func prepare(_ text: String, maxCount: Int) -> String {
    let escaped = DiscordUtils.escapingSpecialCharacters(text)
    return String(escaped.unicodeScalars.maxCount(maxCount))
}

private extension Collection {
    func maxCount(_ count: Int) -> Self.SubSequence {
        let delta = (self.count - count)
        let dropCount = delta > 0 ? delta : 0
        return self.dropLast(dropCount)
    }
}
