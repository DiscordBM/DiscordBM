@testable import DiscordGateway
import AsyncHTTPClient
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
    
    override func tearDown() {
        DiscordGlobalConfiguration.makeLogger = { Logger(label: $0) }
        try! httpClient.syncShutdown()
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
            intents: [.guilds, .guildModeration, .guildEmojisAndStickers, .guildIntegrations, .guildWebhooks, .guildInvites, .guildVoiceStates, .guildMessages, .guildMessageReactions, .guildMessageTyping, .directMessages, .directMessageReactions, .directMessageTyping, .guildScheduledEvents, .autoModerationConfiguration, .autoModerationExecution, .guildMessages, .guildPresences, .messageContent]
        )
        
        let expectation = expectation(description: "Connected")
        
        var _ready: Gateway.Ready?
        var didHello = false
        
        await bot.addEventHandler { event in
            if case let .ready(ready) = event.data {
                _ready = ready
                expectation.fulfill()
            } else if event.opcode == .hello {
                didHello = true
            } else if _ready == nil {
                expectation.fulfill()
            }
        }
        
        Task { await bot.connect() }
        wait(for: [expectation], timeout: 10)
        
        XCTAssertTrue(didHello)
        let ready = try XCTUnwrap(_ready)
        XCTAssertEqual(ready.v, DiscordGlobalConfiguration.apiVersion)
        XCTAssertEqual(ready.application.id, Constants.botId)
        XCTAssertFalse(ready.session_id.isEmpty)
        XCTAssertEqual(ready.user.id, Constants.botId)
        XCTAssertEqual(ready.user.bot, true)
        
        /// The bot should not disconnect for 10s.
        /// This is to make sure we are not getting invalid-session-ed immediately.
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
            intents: [.guilds, .guildModeration, .guildEmojisAndStickers, .guildIntegrations, .guildWebhooks, .guildInvites, .guildVoiceStates, .guildMessages, .guildMessageReactions, .guildMessageTyping, .directMessages, .directMessageReactions, .directMessageTyping, .guildScheduledEvents, .autoModerationConfiguration, .autoModerationExecution, .guildMessages, .guildPresences, .messageContent]
        )
        
        let expectation = expectation(description: "Connected")
        
        var _ready: Gateway.Ready?
        var didHello = false
        
        await bot.addEventHandler { event in
            if case let .ready(ready) = event.data {
                _ready = ready
                expectation.fulfill()
            } else if event.opcode == .hello {
                didHello = true
            } else if _ready == nil {
                expectation.fulfill()
            }
        }
        
        Task { await bot.connect() }
        wait(for: [expectation], timeout: 10)
        
        XCTAssertTrue(didHello)
        let ready = try XCTUnwrap(_ready)
        XCTAssertEqual(ready.v, DiscordGlobalConfiguration.apiVersion)
        XCTAssertEqual(ready.application.id, Constants.botId)
        XCTAssertFalse(ready.session_id.isEmpty)
        XCTAssertEqual(ready.user.id, Constants.botId)
        XCTAssertEqual(ready.user.bot, true)
        
        /// The bot should not disconnect for 10s.
        /// This is to make sure we are not getting invalid-session-ed immediately.
        try await Task.sleep(nanoseconds: 10_000_000_000)
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 1)
        
        await bot.disconnect()
        
        /// Make sure it is disconnected
        try await Task.sleep(nanoseconds: 5_000_000_000)
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 2)
        XCTAssertEqual(bot.state, .stopped)
    }
    
    func testConnectGatewayRequests() async throws {
        
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
            intents: [.guilds, .guildModeration, .guildEmojisAndStickers, .guildIntegrations, .guildWebhooks, .guildInvites, .guildVoiceStates, .guildMessages, .guildMessageReactions, .guildMessageTyping, .directMessages, .directMessageReactions, .directMessageTyping, .guildScheduledEvents, .autoModerationConfiguration, .autoModerationExecution, .guildMessages, .guildPresences, .messageContent]
        )
        
        let expectation = expectation(description: "Connected")
        
        await bot.addEventHandler { event in
            if case .ready = event.data {
                expectation.fulfill()
            }
        }
        
        Task { await bot.connect() }
        wait(for: [expectation], timeout: 10)
        
        /// Didn't find a way to properly verify these functions.
        /// Here we just make the requests and make sure we don't get invalid-session-ed.
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
        /// and to make sure we don't get invalid-session-ed.
        try await Task.sleep(nanoseconds: 10_000_000_000)
        
        await bot.disconnect()
        
        /// Make sure it is disconnected
        try await Task.sleep(nanoseconds: 5_000_000_000)
        XCTAssertEqual(bot.connectionId.load(ordering: .relaxed), 2)
        XCTAssertEqual(bot.state, .stopped)
    }
}
