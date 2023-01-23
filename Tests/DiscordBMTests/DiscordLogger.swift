@testable import DiscordLogger
import DiscordClient
import DiscordUtils
@testable import Logging
import NIOHTTP1
import XCTest

class DiscordLoggerTests: XCTestCase {
    
    let webhookUrl = "https://discord.com/api/webhooks/1066287437724266536/dSmCyqTEGP1lBnpWJAVU-CgQy4s3GRXpzKIeHs0ApHm62FngQZPn7kgaOyaiZe6E5wl_"
    private var client: FakeDiscordClient!
    
    override func setUp() {
        client = FakeDiscordClient()
        LoggingSystem.bootstrapInternal(StreamLogHandler.standardOutput(label:))
    }
    
    /// Tests that:
    /// * Works at all.
    /// * Multiple logs work.
    /// * Metadata works.
    /// * Embed colors work.
    /// * Log-level-roles work.
    /// * Logger only mentions a log's level role once.
    /// * Setting log-level works.
    func testWorks() async throws {
        DiscordGlobalConfiguration.logManager = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .seconds(1),
                fallbackLogger: Logger(label: "", factory: SwiftLogNoOpLogHandler.init),
                mentions: [
                    .trace: .role("33333333"),
                    .notice: .user("22222222"),
                    .warning: .user("22222222"),
                ],
                disabledInDebug: false
            )
        )
        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            address: try .webhook(.url(webhookUrl)),
            level: .trace,
            makeStdoutLogHandler: { _, _ in SwiftLogNoOpLogHandler() }
        )
        logger.log(level: .trace, "Testing!")
        /// To make sure logs arrive in order.
        try await Task.sleep(nanoseconds: 100_000_000)
        logger.log(level: .notice, "Testing! 2")
        /// To make sure logs arrive in order.
        try await Task.sleep(nanoseconds: 100_000_000)
        logger.log(level: .notice, "Testing! 3", metadata: ["1": "2"])
        /// To make sure logs arrive in order.
        try await Task.sleep(nanoseconds: 100_000_000)
        logger.log(level: .warning, "Testing! 4")
        
        let expectation = XCTestExpectation(description: "log")
        self.client.expectation = expectation
        wait(for: [expectation], timeout: 2)
        
        let anyPayload = self.client.payloads.first
        let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)
        XCTAssertEqual(payload.content, "<@22222222> <@&33333333>")
        
        let embeds = try XCTUnwrap(payload.embeds)
        if embeds.count != 4 {
            XCTFail("Expected 4 embeds, but found \(embeds.count): \(embeds)")
            return
        }
        
        do {
            let embed = embeds[0]
            XCTAssertEqual(embed.title, "Testing!")
            let now = Date().timeIntervalSince1970
            let timestamp = embed.timestamp?.date.timeIntervalSince1970 ?? 0
            XCTAssertTrue(((now-2)...(now+2)).contains(timestamp))
            XCTAssertEqual(embed.color?.value, DiscordColor.brown.value)
            XCTAssertEqual(embed.footer?.text, "test")
            XCTAssertEqual(embed.fields?.count, 0)
        }
        
        do {
            let embed = embeds[1]
            XCTAssertEqual(embed.title, "Testing! 2")
            let now = Date().timeIntervalSince1970
            let timestamp = embed.timestamp?.date.timeIntervalSince1970 ?? 0
            XCTAssertTrue(((now-2)...(now+2)).contains(timestamp))
            XCTAssertEqual(embed.color?.value, DiscordColor.green.value)
            XCTAssertEqual(embed.footer?.text, "test")
            XCTAssertEqual(embed.fields?.count, 0)
        }
        
        do {
            let embed = embeds[2]
            XCTAssertEqual(embed.title, "Testing! 3")
            let now = Date().timeIntervalSince1970
            let timestamp = embed.timestamp?.date.timeIntervalSince1970 ?? 0
            XCTAssertTrue(((now-2)...(now+2)).contains(timestamp))
            XCTAssertEqual(embed.color?.value, DiscordColor.green.value)
            XCTAssertEqual(embed.footer?.text, "test")
            let fields = try XCTUnwrap(embed.fields)
            XCTAssertEqual(fields.count, 1)
            
            let field = try XCTUnwrap(fields.first)
            XCTAssertEqual(field.name, "1")
            XCTAssertEqual(field.value, "2")
        }
        
        do {
            let embed = embeds[3]
            XCTAssertEqual(embed.title, "Testing! 4")
            let now = Date().timeIntervalSince1970
            let timestamp = embed.timestamp?.date.timeIntervalSince1970 ?? 0
            XCTAssertTrue(((now-2)...(now+2)).contains(timestamp))
            XCTAssertEqual(embed.color?.value, DiscordColor.orange.value)
            XCTAssertEqual(embed.footer?.text, "test")
        }
    }
    
    func testExcludeMetadata() async throws {
        DiscordGlobalConfiguration.logManager = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .milliseconds(100),
                fallbackLogger: Logger(label: "", factory: SwiftLogNoOpLogHandler.init),
                excludeMetadata: [.trace],
                disabledInDebug: false
            )
        )
        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            address: try .webhook(.url(webhookUrl)),
            level: .trace,
            makeStdoutLogHandler: { _, _ in SwiftLogNoOpLogHandler() }
        )
        logger.log(level: .trace, "Testing!", metadata: ["a": "b"])

        let expectation = XCTestExpectation(description: "log")
        self.client.expectation = expectation
        wait(for: [expectation], timeout: 2)

        let anyPayload = self.client.payloads.first
        let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)

        let embeds = try XCTUnwrap(payload.embeds)
        XCTAssertEqual(embeds.count, 1)

        let embed = try XCTUnwrap(embeds.first)
        XCTAssertEqual(embed.fields?.count ?? 0, 0)
    }

    func testDisabledLogLevels() async throws {
        DiscordGlobalConfiguration.logManager = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .milliseconds(100),
                fallbackLogger: Logger(label: "", factory: SwiftLogNoOpLogHandler.init),
                disabledLogLevels: [.debug],
                disabledInDebug: false
            )
        )
        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            address: try .webhook(.url(webhookUrl)),
            level: .debug,
            makeStdoutLogHandler: { _, _ in SwiftLogNoOpLogHandler() }
        )
        logger.log(level: .debug, "Testing!")
        logger.log(level: .info, "Testing! 2")

        let expectation = XCTestExpectation(description: "log")
        self.client.expectation = expectation
        wait(for: [expectation], timeout: 2)

        let anyPayload = self.client.payloads.first
        let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)

        let embeds = try XCTUnwrap(payload.embeds)
        XCTAssertEqual(embeds.count, 1)

        let embed = try XCTUnwrap(embeds.first)
        XCTAssertEqual(embed.title, "Testing! 2")
    }

    func testMaxStoredLogsCount() async throws {
        DiscordGlobalConfiguration.logManager = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .seconds(10),
                fallbackLogger: Logger(label: "", factory: SwiftLogNoOpLogHandler.init),
                disabledInDebug: false,
                maxStoredLogsCount: 100
            )
        )
        let address = try DiscordLogHandler.Address.webhook(.url(webhookUrl))
        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            address: address,
            level: .error,
            makeStdoutLogHandler: { _, _ in SwiftLogNoOpLogHandler() }
        )
        for idx in (0..<150) {
            /// To keep the order.
            try await Task.sleep(nanoseconds: 50_000_000)
            logger.log(level: .error, "Testing! \(idx)")
        }

        let logs = await DiscordGlobalConfiguration.logManager._tests_getLogs()
        let all = try XCTUnwrap(logs[address])

        XCTAssertEqual(all.count, 100)
        for (idx, one) in all.enumerated() {
            let title = try XCTUnwrap(one.embed.title)
            let number = Int(title.split(separator: " ").last!)!
            XCTAssertGreaterThan(number, idx + 35)
        }
    }

    func testDisabledInDebug() async throws {
        DiscordGlobalConfiguration.logManager = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .milliseconds(100),
                fallbackLogger: Logger(label: "", factory: SwiftLogNoOpLogHandler.init),
                disabledInDebug: true
            )
        )
        let address = try DiscordLogHandler.Address.webhook(.url(webhookUrl))
        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            address: address,
            level: .info,
            makeStdoutLogHandler: { _, _ in SwiftLogNoOpLogHandler() }
        )
        logger.log(level: .info, "Testing!")

        try await Task.sleep(nanoseconds: 2_000_000_000)

        XCTAssertEqual(self.client.payloads.count, 0)
    }

    func testExtraMetadata_noticeLevel() async throws {
        DiscordGlobalConfiguration.logManager = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .milliseconds(100),
                fallbackLogger: Logger(label: "", factory: SwiftLogNoOpLogHandler.init),
                extraMetadata: [.info],
                disabledInDebug: false
            )
        )
        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            address: try .webhook(.url(webhookUrl)),
            level: .info,
            makeStdoutLogHandler: { _, _ in SwiftLogNoOpLogHandler() }
        )
        logger.log(level: .info, "Testing!")

        let expectation = XCTestExpectation(description: "log")
        self.client.expectation = expectation
        wait(for: [expectation], timeout: 2)

        let anyPayload = self.client.payloads.first
        let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)

        let embeds = try XCTUnwrap(payload.embeds)
        XCTAssertEqual(embeds.count, 1)

        let embed = try XCTUnwrap(embeds.first)
        XCTAssertEqual(embed.title, "Testing!")
        let fields = try XCTUnwrap(embed.fields)
        XCTAssertEqual(fields.count, 4)
        XCTAssertEqual(fields[0].name, #"\_source"#)
        XCTAssertEqual(fields[0].value, "DiscordBMTests")
        XCTAssertEqual(fields[1].name, #"\_line"#)
        XCTAssertGreaterThan(Int(fields[1].value) ?? 0, 200)
        XCTAssertEqual(fields[2].name, #"\_function"#)
        XCTAssertEqual(fields[2].value, #"testExtraMetadata\_noticeLevel()"#)
        XCTAssertEqual(fields[3].name, #"\_file"#)
        XCTAssertEqual(fields[3].value, "DiscordBMTests/DiscordLogger.swift")
    }

    func testExtraMetadata_warningLevel() async throws {
        DiscordGlobalConfiguration.logManager = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .milliseconds(100),
                fallbackLogger: Logger(label: "", factory: SwiftLogNoOpLogHandler.init),
                extraMetadata: [.warning],
                disabledInDebug: false
            )
        )
        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            address: try .webhook(.url(webhookUrl)),
            level: .notice,
            makeStdoutLogHandler: { _, _ in SwiftLogNoOpLogHandler() }
        )
        logger.log(level: .warning, "Testing!")

        let expectation = XCTestExpectation(description: "log")
        self.client.expectation = expectation
        wait(for: [expectation], timeout: 2)

        let anyPayload = self.client.payloads.first
        let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)

        let embeds = try XCTUnwrap(payload.embeds)
        XCTAssertEqual(embeds.count, 1)

        let embed = try XCTUnwrap(embeds.first)
        XCTAssertEqual(embed.title, "Testing!")
        let fields = try XCTUnwrap(embed.fields)
        if fields.count != 4 {
            XCTFail("Expected 4 fields but found \(fields.count): \(fields)")
            return
        }
        XCTAssertEqual(fields[0].name, #"\_source"#)
        XCTAssertEqual(fields[0].value, "DiscordBMTests")
        XCTAssertEqual(fields[1].name, #"\_line"#)
        XCTAssertGreaterThan(Int(fields[1].value) ?? 0, 200)
        XCTAssertEqual(fields[2].name, #"\_function"#)
        XCTAssertEqual(fields[2].value, #"testExtraMetadata\_warningLevel()"#)
        XCTAssertEqual(fields[3].name, #"\_file"#)
        XCTAssertEqual(fields[3].value, "DiscordBMTests/DiscordLogger.swift")
    }

    func testAliveNotices() async throws {
        DiscordGlobalConfiguration.logManager = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .zero,
                fallbackLogger: Logger(label: "", factory: SwiftLogNoOpLogHandler.init),
                aliveNotice: .init(
                    address: try .webhook(.url(webhookUrl)),
                    interval: .seconds(6),
                    message: "Alive!",
                    color: .red,
                    initialNoticeMention: .role("99999999")
                ),
                disabledInDebug: false
            )
        )

        let start = Date().timeIntervalSince1970

        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            address: try .webhook(.url(webhookUrl)),
            level: .debug,
            makeStdoutLogHandler: { _, _ in SwiftLogNoOpLogHandler() }
        )

        try await Task.sleep(nanoseconds: 4_000_000_000)

        logger.log(level: .debug, "Testing!")

        try await Task.sleep(nanoseconds: 1_000_000_000)

        let expectation = XCTestExpectation(description: "log")
        self.client.expectation = expectation
        wait(for: [expectation], timeout: 10)

        let payloads = self.client.payloads
        if payloads.count != 3 {
            XCTFail("Expected 3 payloads, but found \(payloads.count): \(payloads)")
            return
        }

        let tolerance = 1.0

        do {
            let anyPayload = payloads[0]
            let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)
            XCTAssertEqual(payload.content, "<@&99999999> ")

            let embeds = try XCTUnwrap(payload.embeds)
            XCTAssertEqual(embeds.count, 1)

            let embed = try XCTUnwrap(embeds.first)
            XCTAssertEqual(embed.title, "Alive!")
            let timestamp = try XCTUnwrap(embed.timestamp?.date.timeIntervalSince1970)
            let range = (start-tolerance)...(start+tolerance)
            XCTAssertTrue(range.contains(timestamp), "\(range) did not contain \(timestamp)")
        }

        do {
            let anyPayload = payloads[1]
            let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)
            XCTAssertEqual(payload.content, "")

            let embeds = try XCTUnwrap(payload.embeds)
            XCTAssertEqual(embeds.count, 1)

            let embed = try XCTUnwrap(embeds.first)
            XCTAssertEqual(embed.title, "Testing!")
            let timestamp = try XCTUnwrap(embed.timestamp?.date.timeIntervalSince1970)
            let estimate = start + 4
            let range = (estimate-tolerance)...(estimate+tolerance)
            XCTAssertTrue(range.contains(timestamp), "\(range) did not contain \(timestamp)")
        }

        do {
            let anyPayload = payloads[2]
            let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)
            XCTAssertEqual(payload.content, "")

            let embeds = try XCTUnwrap(payload.embeds)
            XCTAssertEqual(embeds.count, 1)

            let embed = try XCTUnwrap(embeds.first)
            XCTAssertEqual(embed.title, "Alive!")
            let timestamp = try XCTUnwrap(embed.timestamp?.date.timeIntervalSince1970)
            let estimate = start + 10
            let range = (estimate-tolerance)...(estimate+tolerance)
            XCTAssertTrue(range.contains(timestamp), "\(range) did not contain \(timestamp)")
        }
    }

    func testFrequency() async throws {
        DiscordGlobalConfiguration.logManager = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .seconds(5),
                fallbackLogger: Logger(label: "", factory: SwiftLogNoOpLogHandler.init),
                disabledInDebug: false
            )
        )

        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            address: try .webhook(.url(webhookUrl)),
            level: .debug,
            makeStdoutLogHandler: { _, _ in SwiftLogNoOpLogHandler() }
        )

        do {
            logger.log(level: .critical, "Testing! 0")

            try await Task.sleep(nanoseconds: 1_150_000_000)

            logger.log(level: .critical, "Testing! 1")

            try await Task.sleep(nanoseconds: 1_150_000_000)

            logger.log(level: .critical, "Testing! 2")

            try await Task.sleep(nanoseconds: 1_150_000_000)

            logger.log(level: .critical, "Testing! 3")

            let expectation = XCTestExpectation(description: "log-1")
            self.client.expectation = expectation
            wait(for: [expectation], timeout: 3)

            let payloads = self.client.payloads
            /// Due to the `frequency`, we only should have 1 payload, which contains 4 embeds.
            XCTAssertEqual(payloads.count, 1)
            let anyPayload = payloads[0]
            let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)

            let embeds = try XCTUnwrap(payload.embeds)
            XCTAssertEqual(embeds.count, 4)

            for idx in 0..<4 {
                let title = try XCTUnwrap(embeds[idx].title)
                XCTAssertTrue(title.hasSuffix("\(idx)"), "\(title) did not have suffix \(idx)")
            }

            self.client.payloads = []
        }

        do {
            logger.log(level: .debug, "Testing! 4")

            try await Task.sleep(nanoseconds: 1_150_000_000)

            logger.log(level: .debug, "Testing! 5")

            try await Task.sleep(nanoseconds: 1_150_000_000)

            logger.log(level: .debug, "Testing! 6")

            try await Task.sleep(nanoseconds: 1_150_000_000)

            logger.log(level: .debug, "Testing! 7")

            let expectation = XCTestExpectation(description: "log-2")
            self.client.expectation = expectation
            wait(for: [expectation], timeout: 3)

            let payloads = self.client.payloads
            /// Due to the `frequency`, we only should have 1 payload, which contains 4 embeds.
            XCTAssertEqual(payloads.count, 1)
            let anyPayload = try XCTUnwrap(payloads.first)
            let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)

            let embeds = try XCTUnwrap(payload.embeds)
            XCTAssertEqual(embeds.count, 4)

            for idx in 0..<4 {
                let title = try XCTUnwrap(embeds[idx].title)
                let num = idx + 4
                XCTAssertTrue(title.hasSuffix("\(num)"), "\(title) did not have suffix \(num)")
            }
        }
    }

    func testBootstrap() async throws {
        DiscordGlobalConfiguration.logManager = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .milliseconds(100),
                fallbackLogger: Logger(label: "", factory: SwiftLogNoOpLogHandler.init),
                disabledInDebug: false
            )
        )
        LoggingSystem.bootstrapWithDiscordLogger(
            address: try .webhook(.url(webhookUrl)),
            level: .error,
            makeStdoutLogHandler: { _, _ in SwiftLogNoOpLogHandler() }
        )

        let logger = Logger(label: "test2")

        logger.log(level: .error, "Testing!")

        let expectation = XCTestExpectation(description: "log")
        self.client.expectation = expectation
        wait(for: [expectation], timeout: 2)

        let anyPayload = self.client.payloads.first
        let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)

        let embeds = try XCTUnwrap(payload.embeds)
        XCTAssertEqual(embeds.count, 1)

        let embed = try XCTUnwrap(embeds.first)
        XCTAssertEqual(embed.title, "Testing!")
    }
    
    /// Swift-Log needs to update `MultiplexLogHandler` to support metadata-providers first.
//    func testMetadataProviders() async throws {
//        DiscordGlobalConfiguration.logManager = DiscordLogManager(
//            client: self.client,
//            configuration: .init(
//                frequency: .milliseconds(100),
//                disabledInDebug: false
//            )
//        )
//        let simpleTraceIDMetadataProvider = Logger.MetadataProvider {
//            guard let traceID = TraceNamespace.simpleTraceID else {
//                return [:]
//            }
//            return ["simple-trace-id": .string(traceID)]
//        }
//        DiscordLogHandler.bootstrap(
//            label: "test",
//            metadataProvider: simpleTraceIDMetadataProvider,
//            address: .webhook(.url(webhookUrl)),
//            makeStdoutLogHandler: { _, _ in SwiftLogNoOpLogHandler() }
//        )
//
//        let logger = Logger(label: "test")
//
//        TraceNamespace.$simpleTraceID.withValue("1234-5678") {
//            logger.log(level: .info, "Testing!")
//        }
//
//        let expectation = XCTestExpectation(description: "log")
//        self.client.expectation = expectation
//        await waitForExpectations(timeout: 2)
//
//        let anyPayload = self.client.payloads.first
//        let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)
//
//        let embeds = try XCTUnwrap(payload.embeds)
//        XCTAssertEqual(embeds.count, 1)
//
//        let embed = embeds[0]
//        XCTAssertEqual(embed.title, "Testing!")
//    }
}

private class FakeDiscordClient: DiscordClient {
    
    let appId: String? = "11111111"
    
    var expectation: XCTestExpectation?
    var payloads: [Any] = []
    
    func send(request: DiscordHTTPRequest) async throws -> DiscordHTTPResponse {
        fatalError()
    }
    
    func send<E: Validatable & Encodable>(
        request: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordHTTPResponse {
        fatalError()
    }
    
    func sendMultipart<E: Validatable & MultipartEncodable>(
        request: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordHTTPResponse {
        payloads.append(payload)
        expectation?.fulfill()
        expectation = nil
        return DiscordHTTPResponse(host: "discord.com", status: .ok, version: .http1_1)
    }
}

private enum TraceNamespace {
    @TaskLocal static var simpleTraceID: String?
}
