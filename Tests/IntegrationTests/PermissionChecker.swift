import DiscordBM
import AsyncHTTPClient
import Logging
import XCTest

class PermissionChecker: XCTestCase {
    
    var httpClient: HTTPClient!
    
    override func setUp() {
        DiscordGlobalConfiguration.makeLogger = {
            Logger(label: $0, factory: SwiftLogNoOpLogHandler.init)
        }
        self.httpClient = self.httpClient ?? HTTPClient(eventLoopGroupProvider: .createNew)
    }
    
    override func tearDown() async throws {
        DiscordGlobalConfiguration.makeLogger = { Logger(label: $0) }
    }

    deinit {
        try! httpClient.syncShutdown()
    }
    
    /// Checks to see if the permission checker functions work properly.
    func testCheckPermissions() async throws {
        
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
        
        let cache = await DiscordCache(
            gatewayManager: bot,
            intents: .all,
            requestAllMembers: .enabled
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

        /// For cache to get populated
        try await Task.sleep(for: .seconds(5))
        
        let _guild = await cache.guilds[Constants.guildId]
        let guild = try XCTUnwrap(_guild)
        
        /// The bot is `administrator` in the server.
        XCTAssertTrue(guild.userHasGuildPermission(
            userId: Snowflake(Constants.botId),
            permission: .administrator
        ))
        /// The bot does not have `manageEvents` perm, but is `administrator`,
        /// so in practice has the perm.
        XCTAssertTrue(guild.userHasGuildPermission(
            userId: Snowflake(Constants.botId),
            permission: .manageEvents
        ))
        /// The account does not have the perm at all.
        XCTAssertFalse(guild.userHasGuildPermission(
            userId: Constants.secondAccountId,
            permission: .manageRoles
        ))
        /// The account has the perm but doesn't have `viewChannel`,
        /// so in practice doesn't have the perm.
        XCTAssertFalse(guild.userHasPermissions(
            userId: Constants.secondAccountId,
            channelId: Constants.perm1ChannelId,
            permissions: [.manageChannels]
        ))
        /// The account has the perm.
        XCTAssertTrue(guild.userHasPermissions(
            userId: Constants.secondAccountId,
            channelId: Constants.perm2ChannelId,
            permissions: [.viewChannel]
        ))
        /// The account doesn't have the perm.
        XCTAssertFalse(guild.userHasPermissions(
            userId: Constants.secondAccountId,
            channelId: Constants.perm2ChannelId,
            permissions: [.sendMessages]
        ))
        /// The account doesn't has the perm but doesn't have the `sendMessages` perm,
        ///  which blocks this specific perm in practice.
        XCTAssertFalse(guild.userHasPermissions(
            userId: Constants.secondAccountId,
            channelId: Constants.perm2ChannelId,
            permissions: [.embedLinks]
        ))
        /// The account has all the permissions.
        XCTAssertTrue(guild.userHasPermissions(
            userId: Constants.secondAccountId,
            channelId: Constants.perm3ChannelId,
            permissions: [.viewChannel, .manageChannels, .createInstantInvite, .useExternalStickers]
        ))
        /// The account has all the permissions but one.
        XCTAssertFalse(guild.userHasPermissions(
            userId: Constants.secondAccountId,
            channelId: Constants.perm3ChannelId,
            permissions: [.viewChannel, .manageChannels, .sendTtsMessages, .useExternalStickers]
        ))
        /// The account has the permission thanks to a member-perm-overwrite.
        XCTAssertTrue(guild.userHasPermissions(
            userId: Constants.secondAccountId,
            channelId: Constants.perm3ChannelId,
            permissions: [.useExternalEmojis]
        ))
        /// The account has the perm in the guild, doesn't have it based on role-overwrite
        /// in the channel, but still has it based on member-overwrite in the channel.
        XCTAssertTrue(guild.userHasGuildPermission(
            userId: Constants.secondAccountId,
            permission: .manageWebhooks
        ))
        XCTAssertTrue(guild.userHasPermissions(
            userId: Constants.secondAccountId,
            channelId: Constants.perm3ChannelId,
            permissions: [.manageWebhooks]
        ))
        /// The account has the perm in the guild, and has it based on role-overwrite
        /// in the channel, but doesn't have it based on member-overwrite in the channel.
        XCTAssertTrue(guild.userHasGuildPermission(
            userId: Constants.secondAccountId,
            permission: .manageThreads
        ))
        XCTAssertFalse(guild.userHasPermissions(
            userId: Constants.secondAccountId,
            channelId: Constants.perm3ChannelId,
            permissions: [.manageThreads]
        ))
        
        await bot.disconnect()
        
        /// Wait 5 seconds to make sure it doesn't mess up the next tests due to Discord limits.
        try await Task.sleep(for: .seconds(5))
    }
}
