@testable import DiscordGateway
import AsyncHTTPClient
import Atomics
import Logging
import Foundation
import XCTest

class GatewayConnectionTests: XCTestCase {
    
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
        
        let bot = BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            compression: false,
            token: Constants.token,
            appId: Snowflake(Constants.botId),
            presence: .init(
                activities: [.init(name: "Testing!", type: .competing)],
                status: .invisible,
                afk: false
            ),
            intents: Gateway.Intent.allCases
        )
        
        let expectation = expectation(description: "Connected")
        
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

        await waitFulfill(for: [expectation], timeout: 10)
        
        let didHello = await connectionInfo.didHello
        let _ready = await connectionInfo.ready
        XCTAssertTrue(didHello)
        let ready = try XCTUnwrap(_ready)
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
    
    func testConnectWithCompression() async throws {
        
        let bot = BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            compression: true,
            token: Constants.token,
            appId: Snowflake(Constants.botId),
            presence: .init(
                activities: [.init(name: "Testing!", type: .competing)],
                status: .invisible,
                afk: false
            ),
            intents: Gateway.Intent.allCases
        )
        
        let expectation = expectation(description: "Connected")
        
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

        await waitFulfill(for: [expectation], timeout: 10)
        
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
        
        /// Make sure it is disconnected
        try await Task.sleep(for: .seconds(5))
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 2)
        XCTAssertEqual(bot.state, .stopped)
    }

    func connectWithShard(shard: IntPair) -> XCTestExpectation {
        let exp = expectation(description: "ConnectForShard:\(shard)")

        Task {
            let bot = BotGatewayManager(
                eventLoopGroup: self.httpClient.eventLoopGroup,
                httpClient: self.httpClient,
                compression: true,
                token: Constants.token,
                appId: Snowflake(Constants.botId),
                shard: shard,
                presence: .init(
                    activities: [.init(name: "Testing!", type: .competing)],
                    status: .invisible,
                    afk: false
                ),
                intents: Gateway.Intent.allCases
            )

            let expectation = expectation(description: "Connected:\(shard)")

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

            let extraTimeForShard = Double(shard.first * 10)
            await waitFulfill(for: [expectation], timeout: 10 + extraTimeForShard)

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
            
            exp.fulfill()
        }

        return exp
    }

    func testUsingShards() async throws {
        let shardCount = 16

        var expectations = [XCTestExpectation]()

        for idx in (0..<shardCount) {
            let exp = connectWithShard(shard: .init(idx, shardCount))
            expectations.append(exp)
        }

        await waitFulfill(for: expectations, timeout: Double(shardCount * 25))
    }

    func testGatewayStopsOnInvalidToken() async throws {
        let criticalLogExpectation = XCTestExpectation(description: "criticalLogExpectation")
        let logHandler = TestingLogHandler(expectation: criticalLogExpectation)

        DiscordGlobalConfiguration.makeLogger = { label in
            Logger(label: label, factory: { _ in logHandler })
        }

        let bot = BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            compression: false,
            token: Constants.token.dropLast(4) + "aaaa",
            appId: Snowflake(Constants.botId),
            presence: .init(
                activities: [.init(name: "Testing!", type: .competing)],
                status: .invisible,
                afk: false
            ),
            intents: Gateway.Intent.allCases
        )

        let expectation = expectation(description: "Connected")

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

        await waitFulfill(for: [expectation, criticalLogExpectation], timeout: 10)

        /// We sent an invalid token so Discord shouldn't even respond to us.
        XCTAssertFalse(didReceiveAnythingOtherThanHello.load(ordering: .relaxed))

        let messages = logHandler.getMessages()

        XCTAssertEqual(messages.count, 1)
        let first = try XCTUnwrap(messages.first)
        XCTAssertEqual(first, #"Will not reconnect because Discord does not allow it. Something is wrong. Your close code is 'authenticationFailed', check Discord docs at https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes and see what it means. Report at https://github.com/MahdiBM/DiscordBM/issues if you think this is a library issue"#)

        /// Wait 1s just incase.
        try await Task.sleep(for: .seconds(1))

        /// BotGatewayManager already "stopped" itself and increased the `connectionId`
        /// since token was invalid and Discord complains about that.
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 2)
        XCTAssertEqual(bot.state, .stopped)
    }

    func testGatewayRequests() async throws {
        
        let bot = BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            compression: true,
            token: Constants.token,
            appId: Snowflake(Constants.botId),
            presence: .init(
                activities: [.init(name: "Testing!", type: .competing)],
                status: .invisible,
                afk: false
            ),
            intents: Gateway.Intent.allCases
        )
        
        let expectation = expectation(description: "Connected")

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

        await waitFulfill(for: [expectation], timeout: 10)
        
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
        
        /// Make sure it is disconnected
        try await Task.sleep(for: .seconds(5))
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

/// This is just to have the compiler check and make sure the `GatewayEventHandler` protocol
/// doesn't have any other no-default requirements other than `let event`.
private struct EventHandler: GatewayEventHandler {
    let event: Gateway.Event
}

/// Fulfills the expectation on the first log.
private class TestingLogHandler: @unchecked Sendable, LogHandler {
    var expectation: XCTestExpectation?
    let queue = DispatchQueue(label: "TestingLogHandler")

    private var messages: [String] = []

    var metadata: Logger.Metadata = [:]
    var logLevel: Logger.Level = .critical
    subscript(metadataKey _: String) -> Logger.Metadata.Value? {
        get { return nil }
        set { }
    }

    init(expectation: XCTestExpectation) {
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
