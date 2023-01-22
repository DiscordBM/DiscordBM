@testable import DiscordBM
@testable import Logging
import NIOHTTP1
import XCTest

class LoggerHandlerTests: XCTestCase {
    
    let webhookUrl = "https://discord.com/api/webhooks/1066287437724266536/dSmCyqTEGP1lBnpWJAVU-CgQy4s3GRXpzKIeHs0ApHm62FngQZPn7kgaOyaiZe6E5wl_"
    private var client: FakeDiscordClient!
    
    override func setUp() {
        client = FakeDiscordClient()
        DiscordLogManager.shared = nil
        LoggingSystem.bootstrapInternal({ StreamLogHandler.standardOutput(label: $0) })
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
        DiscordLogManager.shared = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .milliseconds(100),
                roleIds: [
                    .trace: "33333333",
                    .notice: "22222222"
                ],
                disabledInDebug: false
            )
        )
        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            level: .trace,
            address: .webhook(.url(webhookUrl)),
            stdoutLogHandler: SwiftLogNoOpLogHandler()
        )
        logger.log(level: .trace, "Testing!")
        logger.log(level: .notice, "Testing! 2")
        logger.log(level: .notice, "Testing! 3", metadata: ["1": "2"])
        
        let expectation = expectation(description: "log")
        self.client.expectation = expectation
        await waitForExpectations(timeout: 2)
        
        let anyPayload = self.client.payloads.first
        let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)
        XCTAssertEqual(payload.content, "<@&22222222> <@&33333333>")
        
        let embeds = try XCTUnwrap(payload.embeds)
        XCTAssertEqual(embeds.count, 3)
        
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
            
            let field = fields[0]
            XCTAssertEqual(field.name, "1")
            XCTAssertEqual(field.value, "2")
        }
    }
    
    func testExcludeMetadata() async throws {
        DiscordLogManager.shared = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .milliseconds(100),
                excludeMetadata: [.trace],
                disabledInDebug: false
            )
        )
        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            level: .trace,
            address: .webhook(.url(webhookUrl)),
            stdoutLogHandler: SwiftLogNoOpLogHandler()
        )
        logger.log(level: .trace, "Testing!", metadata: ["a": "b"])
        
        let expectation = expectation(description: "log")
        self.client.expectation = expectation
        await waitForExpectations(timeout: 2)
        
        let anyPayload = self.client.payloads.first
        let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)
        
        let embeds = try XCTUnwrap(payload.embeds)
        XCTAssertEqual(embeds.count, 1)
        
        let embed = try XCTUnwrap(embeds.first)
        XCTAssertEqual(embed.fields?.count ?? 0, 0)
    }
    
    func testDisabledLogLevels() async throws {
        DiscordLogManager.shared = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .milliseconds(100),
                disabledLogLevels: [.debug],
                disabledInDebug: false
            )
        )
        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            level: .debug,
            address: .webhook(.url(webhookUrl)),
            stdoutLogHandler: SwiftLogNoOpLogHandler()
        )
        logger.log(level: .debug, "Testing!")
        logger.log(level: .info, "Testing! 2")
        
        let expectation = expectation(description: "log")
        self.client.expectation = expectation
        await waitForExpectations(timeout: 2)
        
        let anyPayload = self.client.payloads.first
        let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)
        
        let embeds = try XCTUnwrap(payload.embeds)
        XCTAssertEqual(embeds.count, 1)
        
        let embed = try XCTUnwrap(embeds.first)
        XCTAssertEqual(embed.title, "Testing! 2")
    }
    
    func testMaxStoredLogsCount() async throws {
        DiscordLogManager.shared = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .milliseconds(100),
                disabledInDebug: false,
                maxStoredLogsCount: 100
            )
        )
        let address = DiscordLogHandler.Address.webhook(.url(webhookUrl))
        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            level: .error,
            address: address,
            stdoutLogHandler: SwiftLogNoOpLogHandler()
        )
        for idx in (0..<150) {
            logger.log(level: .error, "Testing! \(idx)")
        }
        
        let logs = await DiscordLogManager.shared!.tests_getLogs()
        let all = try XCTUnwrap(logs[address])
        
        XCTAssertEqual(all.count, 100)
        for (idx, one) in all.enumerated() {
            let title = try XCTUnwrap(one.embed.title)
            let number = Int(title.split(separator: " ").last!)!
            XCTAssertGreaterThan(number, idx + 35)
        }
    }
    
    func testDisabledInDebug() async throws {
        DiscordLogManager.shared = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .milliseconds(100),
                disabledInDebug: true
            )
        )
        let address = DiscordLogHandler.Address.webhook(.url(webhookUrl))
        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            level: .info,
            address: address,
            stdoutLogHandler: SwiftLogNoOpLogHandler()
        )
        logger.log(level: .info, "Testing!")
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        XCTAssertEqual(self.client.payloads.count, 0)
    }
    
    func testExtraMetadata() async throws {
        DiscordLogManager.shared = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .milliseconds(100),
                extraMetadata: [.info],
                disabledInDebug: false
            )
        )
        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            level: .info,
            address: .webhook(.url(webhookUrl)),
            stdoutLogHandler: SwiftLogNoOpLogHandler()
        )
        logger.log(level: .info, "Testing!")
        
        let expectation = expectation(description: "log")
        self.client.expectation = expectation
        await waitForExpectations(timeout: 2)
        
        let anyPayload = self.client.payloads.first
        let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)
        
        let embeds = try XCTUnwrap(payload.embeds)
        XCTAssertEqual(embeds.count, 1)
        
        let embed = try XCTUnwrap(embeds.first)
        XCTAssertEqual(embed.title, "Testing!")
        let fields = try XCTUnwrap(embed.fields)
        XCTAssertEqual(fields.count, 4)
        XCTAssertEqual(fields[0].name, "_source")
        XCTAssertEqual(fields[0].value, "DiscordBMTests")
        XCTAssertEqual(fields[1].name, "_line")
        XCTAssertGreaterThan(Int(fields[1].value) ?? 0, 200)
        XCTAssertEqual(fields[2].name, "_function")
        XCTAssertEqual(fields[2].value, "testExtraMetadata()")
        XCTAssertEqual(fields[3].name, "_file")
        XCTAssertEqual(fields[3].value, "DiscordBMTests/LogHandler.swift")
    }
    
    func testAliveNotices() async throws {
        DiscordLogManager.shared = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .zero,
                aliveNotice: .init(
                    address: .webhook(.url(webhookUrl)),
                    interval: .seconds(6),
                    message: "Alive!",
                    color: .red,
                    initialNoticeRoleId: "99999999"
                ),
                disabledInDebug: false
            )
        )
        
        let start = Date().timeIntervalSince1970
        
        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            level: .debug,
            address: .webhook(.url(webhookUrl)),
            stdoutLogHandler: SwiftLogNoOpLogHandler()
        )
        
        try await Task.sleep(nanoseconds: 4_000_000_000)
        
        logger.log(level: .debug, "Testing!")
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let expectation = expectation(description: "log")
        self.client.expectation = expectation
        await waitForExpectations(timeout: 10)
        
        let payloads = self.client.payloads
        if payloads.count != 3 {
            XCTFail("Expected 3 payloads, but found \(payloads)")
            return
        }
        
        let tolerance = 2.0
        
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
        DiscordLogManager.shared = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .seconds(5),
                disabledInDebug: false
            )
        )
        
        let logger = DiscordLogHandler.multiplexLogger(
            label: "test",
            level: .debug,
            address: .webhook(.url(webhookUrl)),
            stdoutLogHandler: SwiftLogNoOpLogHandler()
        )
        
        do {
            logger.log(level: .critical, "Testing! 0")
            
            try await Task.sleep(nanoseconds: 1_150_000_000)
            
            logger.log(level: .critical, "Testing! 1")
            
            try await Task.sleep(nanoseconds: 1_150_000_000)
            
            logger.log(level: .critical, "Testing! 2")
            
            try await Task.sleep(nanoseconds: 1_150_000_000)
            
            logger.log(level: .critical, "Testing! 3")
            
            let expectation = expectation(description: "log-1")
            self.client.expectation = expectation
            await waitForExpectations(timeout: 3)
            
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
            
            let expectation = expectation(description: "log-2")
            self.client.expectation = expectation
            await waitForExpectations(timeout: 3)
            
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
        DiscordLogManager.shared = DiscordLogManager(
            client: self.client,
            configuration: .init(
                frequency: .milliseconds(100),
                disabledInDebug: false
            )
        )
        DiscordLogHandler.bootstrap(
            label: "test",
            level: .error,
            address: .webhook(.url(webhookUrl)),
            stdoutLogHandler:  SwiftLogNoOpLogHandler()
        )
        
        let logger = Logger(label: "test2")
        
        logger.log(level: .error, "Testing!")
        
        let expectation = expectation(description: "log")
        self.client.expectation = expectation
        await waitForExpectations(timeout: 2)
        
        let anyPayload = self.client.payloads.first
        let payload = try XCTUnwrap(anyPayload as? RequestBody.ExecuteWebhook)
        
        let embeds = try XCTUnwrap(payload.embeds)
        XCTAssertEqual(embeds.count, 1)
        
        let embed = embeds[0]
        XCTAssertEqual(embed.title, "Testing!")
    }
}

private class FakeDiscordClient: DiscordClient {
    
    let appId: String? = "11111111"
    
    var expectation: XCTestExpectation?
    var payloads: [Any] = []
    
    func send(request: DiscordRequest) async throws -> DiscordHTTPResponse {
        fatalError()
    }
    
    func send<E: Validatable & Encodable>(
        request: DiscordRequest,
        payload: E
    ) async throws -> DiscordHTTPResponse {
        fatalError()
    }
    
    func sendMultipart<E: Validatable & MultipartEncodable>(
        request: DiscordRequest,
        payload: E
    ) async throws -> DiscordHTTPResponse {
        payloads.append(payload)
        expectation?.fulfill()
        expectation = nil
        return DiscordHTTPResponse(host: "discord.com", status: .ok, version: .http1_1)
    }
}
