@testable import DiscordGateway
import AsyncHTTPClient
import Atomics
import Logging
import Foundation
import XCTest

class GatewayConnectionTests: XCTestCase, @unchecked Sendable {

    var httpClient: HTTPClient!

    override func setUp() {
        DiscordGlobalConfiguration.makeLogger = {
            Logger(label: $0, factory: SwiftLogNoOpLogHandler.init)
        }
        self.httpClient = self.httpClient ?? HTTPClient(eventLoopGroupProvider: .createNew)
    }

    deinit {
        DiscordGlobalConfiguration.makeLogger = { Logger(label: $0) }
        try! httpClient.syncShutdown()
    }

    func testConnect() async throws {
        /// Make sure last tests don't affect this test's gateway connection
        try await Task.sleep(for: .seconds(5))

        let bot = await BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            token: Constants.token,
            presence: .init(
                activities: [.init(name: "Testing!", type: .competing)],
                status: .invisible,
                afk: false
            ),
            intents: Gateway.Intent.allCases
        )

        XCTAssertEqual(bot.client.appId?.rawValue, Constants.botId.rawValue)

        let expectation = Expectation(description: "Connected")

        let connectionInfo = ConnectionInfo()

        Task {
            for await event in await bot.makeEventsStream() {
                if case let .ready(ready) = event.data {
                    await connectionInfo.setReady(ready)
                    expectation.fulfill()
                } else if event.opcode == .hello {
                    await connectionInfo.setDidHello()
                } else if await connectionInfo.ready == nil {
                    expectation.fulfill()
                }
            }
        }

        Task {
            for await (error, buffer) in await bot.makeEventsParseFailureStream() {
                /// Parsing failures are not the end of the world.
                /// They might even be acceptable.
                /// However since we know this gateway manager won't do much more than
                /// the basic regular stuff like identify/ping-pong, it shouldn't throw
                /// parsing errors for those.
                XCTFail("Received parsing failure. Error: \(error), buffer: \(buffer), string-buffer: \(String(buffer: buffer))")
            }
        }

        /// To make sure these 2 `Task`s are triggered in order
        try await Task.sleep(for: .milliseconds(200))

        Task { await bot.connect() }

        await waitFulfillment(of: [expectation], timeout: 10)

        let didHello = await connectionInfo.didHello
        let _ready = await connectionInfo.ready
        XCTAssertTrue(didHello)
        let ready = try XCTUnwrap(_ready)
        XCTAssertEqual(ready.v, DiscordGlobalConfiguration.apiVersion)
        XCTAssertEqual(ready.application.id, Snowflake(Constants.botId))
        XCTAssertFalse(ready.session_id.isEmpty)
        XCTAssertEqual(ready.user.id, Constants.botId)
        XCTAssertEqual(ready.user.bot, true)

        /// The bot should not disconnect for 120s.
        /// This is to make sure we aren't getting invalid-session-ed immediately.
        /// Also to check that ping-ponging works.
        try await Task.sleep(for: .seconds(120))
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 1)

        await bot.disconnect()

        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 2)
        XCTAssertEqual(bot.state, .stopped)
    }

    func connectWithShard(shard: IntPair) -> Expectation {
        let exp = Expectation(description: "ConnectForShard:\(shard)")

        Task {
            defer { exp.fulfill() }

            let bot = await BotGatewayManager(
                eventLoopGroup: self.httpClient.eventLoopGroup,
                httpClient: self.httpClient,
                token: Constants.token,
                shard: shard,
                presence: .init(
                    activities: [.init(name: "Testing!", type: .competing)],
                    status: .invisible,
                    afk: false
                ),
                intents: Gateway.Intent.allCases
            )

            let expectation = Expectation(description: "Connected:\(shard)")

            let connectionInfo = ConnectionInfo()

            Task {
                for await event in await bot.makeEventsStream() {
                    if case let .ready(ready) = event.data {
                        await connectionInfo.setReady(ready)
                        expectation.fulfill()
                    } else if event.opcode == .hello {
                        await connectionInfo.setDidHello()
                    } else if await connectionInfo.ready == nil {
                        expectation.fulfill()
                    }
                }
            }

            /// To make sure these 2 `Task`s are triggered in order
            try await Task.sleep(for: .milliseconds(200))

            Task { await bot.connect() }

            let timeout = Double((shard.first + 1) * 20)
            await waitFulfillment(of: [expectation], timeout: timeout)

            let didHello = await connectionInfo.didHello
            let _ready = await connectionInfo.ready
            XCTAssertTrue(didHello)
            let ready = try XCTUnwrap(_ready, "Shard \(shard)")
            XCTAssertEqual(ready.v, DiscordGlobalConfiguration.apiVersion)
            XCTAssertEqual(ready.application.id, Snowflake(Constants.botId))
            XCTAssertFalse(ready.session_id.isEmpty)
            XCTAssertEqual(ready.user.id, Constants.botId)
            XCTAssertEqual(ready.user.bot, true)

            /// The bot should not disconnect for 10s.
            /// This is to make sure we aren't getting invalid-session-ed immediately.
            try await Task.sleep(for: .seconds(10))
            XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 1)

            await bot.disconnect()

            /// Make sure it is disconnected
            try await Task.sleep(for: .seconds(5))
            XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 2)
            XCTAssertEqual(bot.state, .stopped)
        }

        return exp
    }

    func testUsingShards() async throws {
        /// Make sure last tests don't affect this test's gateway connection
        try await Task.sleep(for: .seconds(5))

        /// To make sure the calling the getBotGateway endpoint simultaneously
        /// doesn't make the first shard so slow that its test fails.
        ///
        /// Not a bad idea to do in a real app with too many shards, either. The reason why
        /// this helps is that the `DiscordClient` always caches the getBotGateway endpoint.
        try await DefaultDiscordClient(
            httpClient: httpClient,
            token: Constants.token
        ).getBotGateway().guardSuccess()

        /// Just to make sure it is initialized
        /// So thread sanitizer doesn't show a warning
        _ = ShardManager.shared

        let shardCount = 16

        var expectations = [Expectation]()

        for idx in (0..<shardCount) {
            expectations.append(
                connectWithShard(shard: .init(idx, shardCount))
            )
        }

        await waitFulfillment(of: expectations, timeout: Double(shardCount * 25))
    }

    func testGatewayStopsOnInvalidToken() async throws {
        /// Make sure last tests don't affect this test's gateway connection
        try await Task.sleep(for: .seconds(5))

        let criticalLogExpectation = Expectation(description: "criticalLogExpectation")
        let logHandler = TestingLogHandler(expectation: criticalLogExpectation)

        DiscordGlobalConfiguration.makeLogger = { label in
            Logger(label: label, factory: { _ in logHandler })
        }

        let bot = await BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            token: Constants.token.dropLast(4) + "aaaa",
            presence: .init(
                activities: [.init(name: "Testing!", type: .competing)],
                status: .invisible,
                afk: false
            ),
            intents: Gateway.Intent.allCases
        )

        let expectation = Expectation(description: "Connected")

        let didReceiveAnythingOtherThanHello = ManagedAtomic(false)

        Task {
            for await event in await bot.makeEventsStream() {
                if case .hello = event.data {
                    expectation.fulfill()
                } else {
                    didReceiveAnythingOtherThanHello.store(true, ordering: .relaxed)
                }
            }
        }

        /// To make sure these 2 `Task`s are triggered in order
        try await Task.sleep(for: .milliseconds(200))

        Task { await bot.connect() }

        await waitFulfillment(of: [expectation, criticalLogExpectation], timeout: 10)

        /// We sent an invalid token so Discord shouldn't even respond to us.
        XCTAssertFalse(didReceiveAnythingOtherThanHello.load(ordering: .relaxed))

        let messages = logHandler.getMessages()

        XCTAssertEqual(messages.count, 1)
        let first = try XCTUnwrap(messages.first)
        XCTAssertEqual(first, #"Will not reconnect because Discord does not allow it. Something is wrong. Your close code is 'authenticationFailed', check Discord docs at https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes and see what it means. Report at https://github.com/DiscordBM/DiscordBM/issues if you think this is a library issue"#)

        /// Wait 1s just incase.
        try await Task.sleep(for: .seconds(1))

        /// BotGatewayManager already "stopped" itself and increased the `connectionId`
        /// since token was invalid and Discord complains about that.
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 2)
        XCTAssertEqual(bot.state, .stopped)
    }

    func testGatewayRequests() async throws {
        /// Make sure last tests don't affect this test's gateway connection
        try await Task.sleep(for: .seconds(5))

        let bot = await BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            token: Constants.token,
            presence: .init(
                activities: [.init(name: "Testing!", type: .competing)],
                status: .invisible,
                afk: false
            ),
            intents: Gateway.Intent.allCases
        )

        let expectation = Expectation(description: "Connected")

        Task {
            for await event in await bot.makeEventsStream() {
                if case .ready = event.data {
                    expectation.fulfill()
                }
            }
        }

        /// To make sure these 2 `Task`s are triggered in order
        try await Task.sleep(for: .milliseconds(200))

        Task { await bot.connect() }

        await waitFulfillment(of: [expectation], timeout: 10)
        
        /// Didn't find a way to properly verify these functions.
        /// Here we just make the requests and make sure we aren't getting invalid-session-ed.
        await bot.requestGuildMembersChunk(payload: .init(
            guild_id: Constants.guildId
        ))
        await bot.updatePresence(payload: .init(
            activities: [.init(name: "New Testing!", type: .listening)],
            status: .online,
            afk: true
        ))
        await bot.updateVoiceState(payload: .init(
            guildId: Constants.guildId,
            selfMute: true,
            selfDeaf: false
        ))

        /// To make sure it doesn't mess up other connections,
        /// and to make sure we aren't getting invalid-session-ed.
        try await Task.sleep(for: .seconds(10))
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 1)

        await bot.disconnect()

        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 2)
        XCTAssertEqual(bot.state, .stopped)
    }
}

private actor ConnectionInfo {
    var ready: Gateway.Ready? = nil
    var didHello = false

    init() { }

    func setReady(_ ready: Gateway.Ready) {
        self.ready = ready
    }
    
    func setDidHello() {
        self.didHello = true
    }
}

/// Fulfills the expectation on the first log.
private class TestingLogHandler: @unchecked Sendable, LogHandler {
    var expectation: Expectation?
    let queue = DispatchQueue(label: "TestingLogHandler")

    private var messages: [String] = []

    var metadata: Logger.Metadata = [:]
    var logLevel: Logger.Level = .critical
    subscript(metadataKey _: String) -> Logger.Metadata.Value? {
        get { return nil }
        set { }
    }

    init(expectation: Expectation) {
        self.expectation = expectation
    }

    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        queue.sync {
            self.messages.append(message.description)
            self.expectation?.fulfill()
            self.expectation = nil
        }
    }

    func getMessages() -> [String] {
        queue.sync {
            self.messages
        }
    }
}
