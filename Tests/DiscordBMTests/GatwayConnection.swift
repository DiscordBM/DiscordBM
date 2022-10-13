@testable import DiscordBM
import AsyncHTTPClient
import NIOPosix
import XCTest

class GatewayConnectionTests: XCTestCase {
    
    func testConnect() async throws {
        
        let elg = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(elg))
        defer {
            try! httpClient.syncShutdown()
            try! elg.syncShutdownGracefully()
        }
        
        let bot = BotGatewayManager(
            eventLoopGroup: elg,
            httpClient: httpClient,
            token: Constants.token,
            appId: Constants.appId,
            presence: .init(
                activities: [.init(name: "Testing!", type: .competing)],
                status: .invisible,
                afk: false
            ),
            intents: [.guilds, .guildBans, .guildEmojisAndStickers, .guildIntegrations, .guildWebhooks, .guildInvites, .guildVoiceStates, .guildMessages, .guildMessageReactions, .guildMessageTyping, .directMessages, .directMessageReactions, .directMessageTyping, .guildScheduledEvents, .autoModerationConfiguration, .autoModerationExecution, .guildMessages, .guildPresences, .messageContent]
        )
        
        let expectation = XCTestExpectation(description: "Connected")
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
        
        await bot.connect()
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(didHello)
        let ready = try XCTUnwrap(_ready)
        XCTAssertEqual(ready.v, DiscordGlobalConfiguration.apiVersion)
        XCTAssertEqual(ready.application.id, Constants.appId)
        XCTAssertFalse(ready.session_id.isEmpty)
        XCTAssertEqual(ready.session_type, "normal")
        XCTAssertEqual(ready.user.id, Constants.appId)
        XCTAssertEqual(ready.user.bot, true)
    }
}
