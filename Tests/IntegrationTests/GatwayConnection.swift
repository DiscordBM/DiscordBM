@testable import DiscordGateway
import AsyncHTTPClient
import Atomics
import Logging
import XCTest

class GatewayConnectionTests: XCTestCase {
    
    var httpClient: HTTPClient!
    
    override func setUp() {
        DiscordGlobalConfiguration.makeLogger = {
            Logger(label: $0, factory: SwiftLogNoOpLogHandler.init)
        }
        self.httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
    }
    
    override func tearDown() async throws {
        DiscordGlobalConfiguration.makeLogger = { Logger(label: $0) }
        try await httpClient.shutdown()
    }
    
    func testConnect() async throws {
        
        let bot = BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            compression: false,
            token: Constants.token,
            appId: Constants.botId,
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
            for await event in await bot.makeEventStream() {
                if case let .ready(ready) = event.data {
                    await connectionInfo.setReady(ready)
                    expectation.fulfill()
                } else if event.opcode == .hello {
                    await connectionInfo.setDidHello()
                } else if await connectionInfo.ready == nil {
                    expectation.fulfill()
                }
            }

            await bot.connect()
        }

        await waitFulfill(for: [expectation], timeout: 10)
        
        let didHello = await connectionInfo.didHello
        let _ready = await connectionInfo.ready
        XCTAssertTrue(didHello)
        let ready = try XCTUnwrap(_ready)
        XCTAssertEqual(ready.v, DiscordGlobalConfiguration.apiVersion)
        XCTAssertEqual(ready.application.id, Constants.botId)
        XCTAssertFalse(ready.session_id.isEmpty)
        XCTAssertEqual(ready.user.id, Constants.botId)
        XCTAssertEqual(ready.user.bot, true)
        
        /// The bot should not disconnect for 10s.
        /// This is to make sure we aren't getting invalid-session-ed immediately.
        try await Task.sleep(nanoseconds: 10_000_000_000)
        
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 1)
        
        await bot.disconnect()
        
        /// Make sure it is disconnected
        try await Task.sleep(nanoseconds: 5_000_000_000)
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 2)
        XCTAssertEqual(bot.state, .stopped)
    }
    
    func testConnectWithCompression() async throws {
        
        let bot = BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            compression: true,
            token: Constants.token,
            appId: Constants.botId,
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
            for await event in await bot.makeEventStream() {
                if case let .ready(ready) = event.data {
                    await connectionInfo.setReady(ready)
                    expectation.fulfill()
                } else if event.opcode == .hello {
                    await connectionInfo.setDidHello()
                } else if await connectionInfo.ready == nil {
                    expectation.fulfill()
                }
            }

            await bot.connect()
        }

        await waitFulfill(for: [expectation], timeout: 10)
        
        let didHello = await connectionInfo.didHello
        let _ready = await connectionInfo.ready
        XCTAssertTrue(didHello)
        let ready = try XCTUnwrap(_ready)
        XCTAssertEqual(ready.v, DiscordGlobalConfiguration.apiVersion)
        XCTAssertEqual(ready.application.id, Constants.botId)
        XCTAssertFalse(ready.session_id.isEmpty)
        XCTAssertEqual(ready.user.id, Constants.botId)
        XCTAssertEqual(ready.user.bot, true)
        
        /// The bot should not disconnect for 10s.
        /// This is to make sure we aren't getting invalid-session-ed immediately.
        try await Task.sleep(nanoseconds: 10_000_000_000)
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 1)
        
        await bot.disconnect()
        
        /// Make sure it is disconnected
        try await Task.sleep(nanoseconds: 5_000_000_000)
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 2)
        XCTAssertEqual(bot.state, .stopped)
    }
    
    func testGatewayRequests() async throws {
        
        let bot = BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            compression: true,
            token: Constants.token,
            appId: Constants.botId,
            presence: .init(
                activities: [.init(name: "Testing!", type: .competing)],
                status: .invisible,
                afk: false
            ),
            intents: Gateway.Intent.allCases
        )
        
        let expectation = expectation(description: "Connected")

        Task {
            for await event in await bot.makeEventStream() {
                if case .ready = event.data {
                    expectation.fulfill()
                }
            }

            await bot.connect()
        }
        
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
        try await Task.sleep(nanoseconds: 10_000_000_000)
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 1)
        
        await bot.disconnect()
        
        /// Make sure it is disconnected
        try await Task.sleep(nanoseconds: 5_000_000_000)
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 2)
        XCTAssertEqual(bot.state, .stopped)
    }

    func testGatewayEventStream() async throws {
        let bot = BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            compression: false,
            token: Constants.token,
            appId: Constants.botId,
            presence: .init(
                activities: [.init(name: "Testing!", type: .competing)],
                status: .invisible,
                afk: false
            ),
            intents: Gateway.Intent.allCases
        )

        let expectation = expectation(description: "Connected")

        let connectionInfo = ConnectionInfo()

        let stream = await bot.makeEventStream()

        Task {
            for await event in stream {
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

        Task { await bot.connect() }
        await waitFulfill(for: [expectation], timeout: 10)

        let didHello = await connectionInfo.didHello
        let _ready = await connectionInfo.ready
        XCTAssertTrue(didHello)
        let ready = try XCTUnwrap(_ready)
        XCTAssertEqual(ready.v, DiscordGlobalConfiguration.apiVersion)
        XCTAssertEqual(ready.application.id, Constants.botId)
        XCTAssertFalse(ready.session_id.isEmpty)
        XCTAssertEqual(ready.user.id, Constants.botId)
        XCTAssertEqual(ready.user.bot, true)

        /// The bot should not disconnect for 10s.
        /// This is to make sure we aren't getting invalid-session-ed immediately.
        try await Task.sleep(nanoseconds: 10_000_000_000)

        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 1)

        await bot.disconnect()

        /// Make sure it is disconnected
        try await Task.sleep(nanoseconds: 5_000_000_000)
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
