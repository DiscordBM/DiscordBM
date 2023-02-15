import DiscordHTTP
import DiscordUtils
import AsyncHTTPClient
import NIOCore
import Logging
import Foundation

/// The manager of sending logs to Discord.
public actor DiscordLogManager {
    
    public struct Configuration {
        
        public struct AliveNotice {
            let address: WebhookAddress
            let interval: TimeAmount?
            let message: String
            let color: DiscordColor
            let initialNoticeMentions: [String]
            
            /// - Parameters:
            ///   - address: The address to send the logs to.
            ///   - interval: The interval after which to send an alive notice. If set to nil, log-manager will only send 1 alive notice on startup.
            ///   - message: The message to accompany the notice.
            ///   - color: The color of the embed of alive notices.
            ///   - initialNoticeMention: The user/role to be mentioned on the first alive notice.
            ///   Useful to be notified of app-boots when you update your app or when it crashes.
            public init(
                address: WebhookAddress,
                interval: TimeAmount?,
                message: String = "Alive Notice!",
                color: DiscordColor = .blue,
                initialNoticeMention: Mention
            ) {
                self.address = address
                self.interval = interval
                self.message = message
                self.color = color
                self.initialNoticeMentions = initialNoticeMention.toMentionStrings()
            }
        }
        
        /// ID of a user or a role to be mentioned.
        public enum Mention {
            case user(String)
            case role(String)
            case combined([Mention])
            
            public static func combined(_ mentions: Mention...) -> Mention {
                .combined(mentions)
            }
            
            func toMentionStrings() -> [String] {
                switch self {
                case let .user(id):
                    return [DiscordUtils.userMention(id: id)]
                case let .role(id):
                    return [DiscordUtils.roleMention(id: id)]
                case let .combined(mentions):
                    return mentions.flatMap { $0.toMentionStrings() }
                }
            }
        }
        
        let frequency: TimeAmount
        let aliveNotice: AliveNotice?
        let mentions: [Logger.Level: [String]]
        let colors: [Logger.Level: DiscordColor]
        let excludeMetadata: Set<Logger.Level>
        let extraMetadata: Set<Logger.Level>
        let disabledLogLevels: Set<Logger.Level>
        let disabledInDebug: Bool
        let maxStoredLogsCount: Int
        
        /// - Parameters:
        ///   - frequency: The frequency of the log-sendings. e.g. if its set to 30s, logs will only be sent once-in-30s. Should not be lower than 10s, because of Discord rate-limits.
        ///   - aliveNotice: Configuration for sending "I am alive" messages every once in a while. Note that alive notices are delayed until it's been `interval`-time past last message.
        ///   e.g. `Logger(label: "Fallback", factory: StreamLogHandler.standardOutput(label:))`
        ///   - mentions: ID of users/roles to be mentioned for each log-level.
        ///   - colors: Color of the embeds to be used for each log-level.
        ///   - excludeMetadata: Excludes all metadata for these log-levels.
        ///   - extraMetadata: Will log `source`, `file`, `function` and `line` as well.
        ///   - disabledLogLevels: `Logger.Level`s to never be logged.
        ///   - disabledInDebug: Whether or not to disable logging in DEBUG.
        ///   - maxStoredLogsCount: If there are more logs than this count, the log manager will start removing the oldest un-sent logs to reduce memory consumption.
        public init(
            frequency: TimeAmount = .seconds(10),
            aliveNotice: AliveNotice? = nil,
            mentions: [Logger.Level: Mention] = [:],
            colors: [Logger.Level: DiscordColor] = [
                .critical: .purple,
                .error: .red,
                .warning: .orange,
                .trace: .brown,
                .debug: .yellow,
                .notice: .green,
                .info: .blue,
            ],
            excludeMetadata: Set<Logger.Level> = [],
            extraMetadata: Set<Logger.Level> = [],
            disabledLogLevels: Set<Logger.Level> = [],
            disabledInDebug: Bool = false,
            maxStoredLogsCount: Int = 1_000
        ) {
            self.frequency = frequency
            self.aliveNotice = aliveNotice
            self.mentions = mentions.mapValues { $0.toMentionStrings() }
            self.colors = colors
            self.excludeMetadata = excludeMetadata
            self.extraMetadata = extraMetadata
            self.disabledLogLevels = disabledLogLevels
            self.disabledInDebug = disabledInDebug
            self.maxStoredLogsCount = maxStoredLogsCount
        }
    }
    
    struct Log: CustomStringConvertible {
        let embed: Embed
        let level: Logger.Level?
        let isFirstAliveNotice: Bool
        
        var description: String {
            "DiscordLogManager.Log(" +
            "embed: \(embed), " +
            "level: \(level?.rawValue ?? "nil"), " +
            "isFirstAliveNotice: \(isFirstAliveNotice)" +
            ")"
        }
    }
    
    nonisolated let client: any DiscordClient
    nonisolated let configuration: Configuration
    
    private var logs: [WebhookAddress: [Log]] = [:]
    private var sendLogsTasks: [WebhookAddress: Task<Void, Never>] = [:]
    var fallbackLogger = Logger(label: "DBM.LogManager")
    
    private var aliveNoticeTask: Task<Void, Never>?
    
    public init(
        httpClient: HTTPClient,
        configuration: Configuration = Configuration()
    ) {
        /// Will only ever send requests to a webhook endpoint
        /// which doesn't need/use neither `token` nor `appId`.
        self.client = DefaultDiscordClient(httpClient: httpClient, token: "", appId: nil)
        self.configuration = configuration
        Task { [weak self] in await self?.startAliveNotices() }
    }
    
    public init(
        client: any DiscordClient,
        configuration: Configuration = Configuration()
    ) {
        self.client = client
        self.configuration = configuration
        Task { [weak self] in await self?.startAliveNotices() }
    }
    
    /// To use after logging-system's bootstrap
    /// Or if you want to change it to something else (do it after bootstrap or it'll be overridden)
    public func renewFallbackLogger(to new: Logger? = nil) {
        self.fallbackLogger = new ?? Logger(label: "DBM.LogManager")
    }
    
    func include(address: WebhookAddress, embed: Embed, level: Logger.Level) {
        self.include(address: address, embed: embed, level: level, isFirstAliveNotice: false)
    }
    
    private func include(
        address: WebhookAddress,
        embed: Embed,
        level: Logger.Level?,
        isFirstAliveNotice: Bool
    ) {
#if DEBUG
        if configuration.disabledInDebug { return }
#endif
        switch self.logs[address]?.isEmpty {
        case .none:
            self.logs[address] = []
            setUpSendLogsTask(address: address)
        case .some(true):
            setUpSendLogsTask(address: address)
        case .some(false): break
        }
        
        self.logs[address]!.append(.init(
            embed: embed,
            level: level,
            isFirstAliveNotice: isFirstAliveNotice
        ))
        
        if logs[address]!.count > configuration.maxStoredLogsCount {
            logs[address]!.removeFirst()
        }
    }
    
    private func startAliveNotices() {
#if DEBUG
        if configuration.disabledInDebug { return }
#endif
        if let aliveNotice = configuration.aliveNotice {
            self.sendAliveNotice(config: aliveNotice, isFirstNotice: true)
        }
        self.setUpAliveNotices()
    }
    
    private func setUpAliveNotices() {
#if DEBUG
        if configuration.disabledInDebug { return }
#endif
        if let aliveNotice = configuration.aliveNotice,
           let interval = aliveNotice.interval {
            let nanos = UInt64(interval.nanoseconds)
            
            @Sendable func send() async throws {
                try await Task.sleep(nanoseconds: nanos)
                await sendAliveNotice(config: aliveNotice, isFirstNotice: false)
                try await send()
            }
            
            aliveNoticeTask?.cancel()
            aliveNoticeTask = Task { try? await send() }
        }
    }
    
    private func sendAliveNotice(config: Configuration.AliveNotice, isFirstNotice: Bool) {
        self.include(
            address: config.address,
            embed: .init(
                title: config.message,
                timestamp: Date(),
                color: config.color
            ),
            level: nil,
            isFirstAliveNotice: isFirstNotice
        )
    }
    
    private func setUpSendLogsTask(address: WebhookAddress) {
#if DEBUG
        if configuration.disabledInDebug { return }
#endif
        let nanos = UInt64(configuration.frequency.nanoseconds)
        
        @Sendable func send() async throws {
            try await Task.sleep(nanoseconds: nanos)
            try await performLogSend(address: address)
            try await send()
        }
        
        sendLogsTasks[address]?.cancel()
        sendLogsTasks[address] = Task { try? await send() }
    }
    
    private func performLogSend(address: WebhookAddress) async throws {
        let logs = getMaxAmountOfLogsAndFlush(address: address)
        if self.logs[address]?.isEmpty != false {
            self.sendLogsTasks[address]?.cancel()
        }
        try await sendLogs(logs, address: address)
    }
    
    private func getMaxAmountOfLogsAndFlush(address: WebhookAddress) -> [Log] {
        var goodLogs = [Log]()
        goodLogs.reserveCapacity(min(self.logs.count, 10))
        
        guard var iterator = self.logs[address]?.makeIterator() else { return [] }
        
        func lengthSum() -> Int { goodLogs.map(\.embed.contentLength).reduce(into: 0, +=) }
        
        while goodLogs.count < 10,
              let log = iterator.next(),
              (lengthSum() + log.embed.contentLength) <= 6_000 {
            goodLogs.append(log)
        }
        
        self.logs[address] = Array(self.logs[address]?.dropFirst(goodLogs.count) ?? [])
        
        return goodLogs
    }
    
    private func sendLogs(_ logs: [Log], address: WebhookAddress) async throws {
        var logLevels = Set(logs.compactMap(\.level))
            .sorted(by: >)
            .compactMap({ configuration.mentions[$0] })
            .flatMap({ $0 })
        let wantsAliveNoticeMention = logs.contains(where: \.isFirstAliveNotice)
        let aliveNoticeMentions = wantsAliveNoticeMention ?
        (self.configuration.aliveNotice?.initialNoticeMentions ?? []) : []
        logLevels.append(contentsOf: aliveNoticeMentions)
        logLevels = Set(logLevels).sorted {
            logLevels.firstIndex(of: $0)! < logLevels.firstIndex(of: $1)!
        }
        let mentions = logLevels.joined(separator: " ")
        
        try await sendLogsToWebhook(
            content: mentions,
            embeds: logs.map(\.embed),
            address: address
        )
        
        self.setUpAliveNotices()
    }
    
    private func sendLogsToWebhook(
        content: String,
        embeds: [Embed],
        address: WebhookAddress
    ) async throws {
        let payload = RequestBody.ExecuteWebhook(
            content: content,
            embeds: embeds
        )
        let response = try await self.client.executeWebhookWithResponse(
            address: address,
            payload: payload
        )
        
        do {
            try response.guardIsSuccessfulResponse()
        } catch {
            logWarning("Received error from Discord after sending logs. This might be a library issue. Please report on https://github.com/MahdiBM/DiscordBM/issue with full context", metadata: ["error": "\(error)", "payload": "\(payload)"])
        }
    }
    
    private func logWarning(
        _ message: Logger.Message,
        metadata: Logger.Metadata? = nil,
        function: String = #function,
        line: UInt = #line
    ) {
        self.fallbackLogger.log(
            level: .warning,
            message,
            metadata: metadata,
            source: "DiscordBM",
            file: #fileID,
            function: function,
            line: line
        )
    }
    
#if DEBUG
    func _tests_getLogs() -> [WebhookAddress: [Log]] {
        self.logs
    }
    
    func _tests_getMaxAmountOfLogsAndFlush(address: WebhookAddress) -> [Log] {
        self.getMaxAmountOfLogsAndFlush(address: address)
    }
#endif
}
