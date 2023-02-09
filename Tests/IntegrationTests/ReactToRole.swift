import DiscordGateway
import AsyncHTTPClient
import Logging
import XCTest

class ReactToRoleTests: XCTestCase {
    
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
    
    func test() async throws {
        let client = DefaultDiscordClient(
            httpClient: httpClient,
            token: Constants.token,
            appId: "11111111" /// Intentionally wrong
        )
        let bot = BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            client: client,
            compression: true,
            identifyPayload: .init(
                token: Constants.token,
                presence: .init(
                    activities: [.init(name: "Testing!", type: .competing)],
                    status: .invisible,
                    afk: false
                ),
                intents: [.guilds, .guildModeration, .guildEmojisAndStickers, .guildIntegrations, .guildWebhooks, .guildInvites, .guildVoiceStates, .guildMessages, .guildMessageReactions, .guildMessageTyping, .directMessages, .directMessageReactions, .directMessageTyping, .guildScheduledEvents, .autoModerationConfiguration, .autoModerationExecution, .guildMessages, .guildPresences, .messageContent]
            )
        )
        
        let expectation = expectation(description: "Connected")
        
        await bot.addEventHandler { event in
            if case .ready = event.data {
                expectation.fulfill()
            }
            #warning("remove")
            if case .guildCreate = event.data { } else {
                print(event)
            }
        }
        
        let cache = await DiscordCache(
            gatewayManager: bot,
            intents: .all,
            requestAllMembers: .enabledWithPresences
        )
        
        Task { await bot.connect() }
        wait(for: [expectation], timeout: 10)
        
        let handler = try await ReactToRoleHandler(
            gatewayManager: bot,
            cache: cache,
            roleName: "test-reaction-role",
            roleUnicodeEmoji: nil,
            roleColor: .green,
            guildId: Constants.guildId,
            channelId: Constants.reactionChannelId,
            messageId: Constants.reactionMessageId,
            reactions: [.unicodeEmoji("✅")]
        )
        
        try await Task.sleep(nanoseconds: 5_000_000_000)
    }
}
