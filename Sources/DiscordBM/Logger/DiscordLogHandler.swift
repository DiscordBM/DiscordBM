import Logging
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
    
    public init(
        label: String,
        metadata: Logger.Metadata = [:],
        logLevel: Logger.Level = .info,
        address: Address
    ) {
        self.label = label
        self.metadata = metadata
        self.logLevel = logLevel
        self.address = address
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
            if !config.excludeMetadata.contains(level) {
                allMetadata = (metadata ?? [:])
                    .merging(self.metadata, uniquingKeysWith: { (a, _) in a })
                    .merging(self.metadataProvider?.get() ?? [:], uniquingKeysWith: { (a, _) in a })
            }
            if let extraMetadata = config.extraMetadata[logLevel], !extraMetadata.isEmpty {
                allMetadata.reserveCapacity(allMetadata.count + extraMetadata.count)
                for extra in config.extraMetadata[logLevel] ?? [] {
                    switch extra {
                    case .source:
                        allMetadata["_source"] = .string(source)
                    case .file:
                        allMetadata["_file"] = .string(file)
                    case .function:
                        allMetadata["_function"] = .string(function)
                    case .line:
                        allMetadata["_line"] = .stringConvertible(line)
                    }
                }
            }
        }
        
        let embed = Embed(
            title: maxCounted("\(message)"),
            timestamp: Date(),
            color: config.colors[level],
            footer: .init(text: maxCounted(self.label).notEmpty(or: "no_label")),
            fields: allMetadata.maxCount(25).compactMap { key, value -> Embed.Field? in
                let value = "\(value)"
                if key.isEmpty || value.isEmpty { return nil }
                return .init(name: maxCounted(key), value: maxCounted(value))
            }
        )
        
        Task { await logManager.include(address: address, embed: embed, level: level) }
    }
    
    private func maxCounted(_ string: String) -> String {
        String(string.unicodeScalars.maxCount(250))
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
