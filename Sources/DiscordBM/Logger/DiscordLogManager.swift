import NIOCore
import Logging
import Atomics
import Foundation

/// The manager of sending logs to Discord.
public actor DiscordLogManager {
    
    public typealias Address = DiscordLogHandler.Address
    
    public struct Configuration {
        
        public struct AliveNotice {
            let address: Address
            let interval: TimeAmount
            let message: String
            let color: DiscordColor
            let initialNoticeRole: String
            
            /// - Parameters:
            ///   - address: The address to send the logs to.
            ///   - interval: The interval after which to send an alive notice.
            ///   - message: The message to accompany the notice.
            ///   - initialNoticeRoleId: The role to be mentioned on the first alive notice.
            ///   Useful to be notified of app-boots when you update your app or when it crashes.
            public init(
                address: Address,
                interval: TimeAmount = .hours(1),
                message: String = "Alive Notice!",
                color: DiscordColor = .blue,
                initialNoticeRoleId: String
            ) {
                self.address = address
                self.interval = interval
                self.message = message
                self.color = color
                self.initialNoticeRole = DiscordUtils.roleMention(id: initialNoticeRoleId)
            }
        }
        
        let frequency: TimeAmount
        let defaultAddress: Address?
        let defaultStdoutLogHandler: LogHandler?
        let aliveNotice: AliveNotice?
        let roles: [Logger.Level: String]
        let colors: [Logger.Level: DiscordColor]
        let excludeMetadata: Set<Logger.Level>
        let extraMetadata: Set<Logger.Level>
        let disabledLogLevels: Set<Logger.Level>
        let disabledInDebug: Bool
        let maxStoredLogsCount: Int
        
        /// - Parameters:
        ///   - frequency: The frequency of the log-sendings. e.g. if its set to 30s, logs will only be sent once-in-30s. Should not be lower than 10s, because of Discord rate-limits.
        ///   - defaultAddress: The default address that `DiscordLogHandler` will use.
        ///   - aliveNotice: Configuration for sending "I am alive" messages every once in a while. Note that alive notices are delayed until it's been `interval`-time past last message.
        ///   - fallbackLogHandler: The log handler to use when `DiscordLogger` errors. You should use a log handler that logs to stdout.
        ///   - roleIds: Id of roles to be mentioned for each log-level.
        ///   - colors: Color of the embeds to be used for each log-level.
        ///   - excludeMetadata: Excludes all metadata for these log-levels.
        ///   - extraMetadata: Will log `source`, `file`, `function` and `line` as well.
        ///   - disabledLogLevels: `Logger.Level`s to never be logged.
        ///   - disabledInDebug: Whether or not to disable logging in DEBUG.
        ///   - maxStoredLogsCount: If there are more logs than this count, the log manager will start removing the oldest un-sent logs to prevent memory leaks.
        public init(
            frequency: TimeAmount = .seconds(30),
            defaultAddress: Address?, /// Avoiding `= nil` to encourage setting it.
            defaultStdoutLogHandler: LogHandler?, /// Avoiding `= nil` to encourage setting it.
            aliveNotice: AliveNotice? = nil,
            fallbackLogHandler: LogHandler? = nil,
            roleIds: [Logger.Level: String] = [:],
            colors: [Logger.Level: DiscordColor] = [
                .critical: .purple,
                .error: .red,
                .warning: .orange,
                .trace: .brown,
                .debug: .yellow,
                .notice: .green,
                .info: .blue,
            ],
            excludeMetadata: Set<Logger.Level> = [.trace],
            extraMetadata: Set<Logger.Level> = [],
            disabledLogLevels: Set<Logger.Level> = [],
            disabledInDebug: Bool = true,
            maxStoredLogsCount: Int = 1_000
        ) {
            self.frequency = frequency
            self.defaultAddress = defaultAddress
            self.defaultStdoutLogHandler = defaultStdoutLogHandler
            self.aliveNotice = aliveNotice
            self.roles = roleIds.mapValues {
                DiscordUtils.roleMention(id: $0)
            }
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
    
    private var logs: [Address: [Log]] = [:]
    private var sendLogsTasks: [Address: Task<Void, Never>] = [:]
    
    private var aliveNoticeTask: Task<Void, Never>?
    
    public init(
        client: any DiscordClient,
        configuration: Configuration
    ) {
        self.client = client
        self.configuration = configuration
        Task { await self.startAliveNotices() }
    }
    
    private static var _shared: DiscordLogManager?
    public static var shared: DiscordLogManager {
        get {
            guard let shared = DiscordLogManager._shared else {
                fatalError("Need to configure the log-manager using 'DiscordLogManager.shared = DiscordLogManager(...)'")
            }
            return shared
        }
        set(newValue) { self._shared = newValue }
    }
    
    func include(address: Address, embed: Embed, level: Logger.Level) {
        self.include(address: address, embed: embed, level: level, isFirstAliveNotice: false)
    }
    
    private func include(
        address: Address,
        embed: Embed,
        level: Logger.Level?,
        isFirstAliveNotice: Bool
    ) {
#if DEBUG
        if configuration.disabledInDebug { return }
#endif
        if self.logs[address]?.isEmpty != false {
            setUpSendLogsTask(address: address)
        }
        self.logs[address, default: []].append(.init(
            embed: embed,
            level: level,
            isFirstAliveNotice: isFirstAliveNotice
        ))
        
        let count = logs[address]!.count
        if count > configuration.maxStoredLogsCount {
            logs[address]! = Array(logs[address]!.dropFirst(
                count - configuration.maxStoredLogsCount
            ))
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
        if let aliveNotice = configuration.aliveNotice {
            let nanos = UInt64(aliveNotice.interval.nanoseconds)
            
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
    
    private func setUpSendLogsTask(address: Address) {
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
    
    private func performLogSend(address: Address) async throws {
        let logs = getMaxAmountOfLogsAndFlush(address: address)
        try await sendLogs(logs, address: address)
        if self.logs[address]?.isEmpty != false {
            self.sendLogsTasks[address]?.cancel()
        }
    }
    
    private func getMaxAmountOfLogsAndFlush(address: Address) -> [Log] {
        var goodLogs = [Log]()
        goodLogs.reserveCapacity(min(self.logs.count, 10))
        
        guard var iterator = self.logs[address]?.makeIterator() else { return [] }
        
        while goodLogs.count < 10,
              let log = iterator.next(),
              (goodLogs.map(\.embed.contentLength).reduce(into: 0, +=) + log.embed.contentLength) < 6_000
        {
            goodLogs.append(log)
        }
        
        /// Will get stuck if the first log is alone more than the limit length.
        if goodLogs.isEmpty, (self.logs[address]?.first?.embed.contentLength ?? 0) > 6_000 {
            let first = self.logs[address]!.removeFirst()
            logWarning("First log alone is more than the limit length. This will not cause much problems but it is a library issue. Please report on https://github.com/MahdiBM/DiscordBM/issue with full context",
                       metadata: ["log": "\(first)"])
            return self.getMaxAmountOfLogsAndFlush(address: address)
        }
        
        self.logs[address] = Array(self.logs[address]?.dropFirst(goodLogs.count) ?? [])
        
        return goodLogs
    }
    
    private func sendLogs(_ logs: [Log], address: Address) async throws {
        var logLevels = Set(logs.compactMap(\.level))
            .sorted(by: >)
            .compactMap({ configuration.roles[$0] })
        logLevels = Set(logLevels).sorted {
            logLevels.firstIndex(of: $0)! < logLevels.firstIndex(of: $1)!
        }
        let wantsAliveNoticeMention = logs.contains(where: \.isFirstAliveNotice)
        let aliveNoticeMention = wantsAliveNoticeMention ?
        (configuration.aliveNotice.map({ "\($0.initialNoticeRole) " }) ?? "") : ""
        let mentions = aliveNoticeMention + logLevels.joined(separator: " ")
        
        let embeds = logs.map(\.embed)
        
        switch address {
        case .channel(let id):
            try await sendLogsToChannel(content: mentions, embeds: embeds, id: id)
        case .webhook(let address):
            try await sendLogsToWebhook(content: mentions, embeds: embeds, address: address)
        }
        
        self.setUpAliveNotices()
    }
    
    private func sendLogsToChannel(
        content: String,
        embeds: [Embed],
        id: String
    ) async throws {
        let payload = RequestBody.CreateMessage(
            content: content,
            embeds: embeds
        )
        let response = try await self.client.createMessage(channelId: id, payload: payload)
        
        do {
            try response.guardIsSuccessfulResponse()
        } catch {
            logWarning("Received error from Discord after sending logs. This is a library issue. Please report on https://github.com/MahdiBM/DiscordBM/issue with full context",
                       metadata: ["error": "\(error)", "payload": "\(payload)"])
        }
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
            logWarning("Received error from Discord after sending logs. This is a library issue. Please report on https://github.com/MahdiBM/DiscordBM/issue with full context",
                       metadata: ["error": "\(error)", "payload": "\(payload)"])
        }
    }
    
    private func logWarning(
        _ message: Logger.Message,
        metadata: Logger.Metadata? = nil,
        function: String = #function,
        line: UInt = #line
    ) {
        self.configuration.defaultStdoutLogHandler?.log(
            level: .warning,
            message: message,
            metadata: metadata,
            source: "DiscordBM",
            file: #filePath,
            function: function,
            line: line
        )
    }
    
#if DEBUG
    func tests_getLogs() -> [Address: [Log]] {
        self.logs
    }
#endif
}
