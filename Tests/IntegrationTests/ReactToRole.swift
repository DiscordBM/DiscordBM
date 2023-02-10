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
    
    /// Don't want to make too many gateway connections, so testing everything in one function
    func testEverything() async throws {
        let client = DefaultDiscordClient(
            httpClient: httpClient,
            token: Constants.token,
            /// Intentionally wrong so reaction-handler can take action on its own reaction
            appId: "11111111"
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
                intents: Gateway.Intent.allCases
            )
        )
        
        let expectation = expectation(description: "Connected")
        
        await bot.addEventHandler { event in
            if case .ready = event.data {
                expectation.fulfill()
            }
        }
        
        let cache = await DiscordCache(
            gatewayManager: bot,
            intents: .all,
            requestAllMembers: .enabledWithPresences
        )
        
        /// Perform reactions-cleanup before starting
        try await client.deleteAllReactions(
            channelId: Constants.reactionChannelId,
            messageId: Constants.reactionMessageId
        ).guardIsSuccessfulResponse()
        
        Task { await bot.connect() }
        wait(for: [expectation], timeout: 10)
        
        /// So cache is populated
        try await Task.sleep(nanoseconds: 5_000_000_000)
        
        let roleName = "test-reaction-role"
        
        /// Remove roles with this name is there are any
        let guildRoles = await cache.guilds[Constants.guildId]?.roles ?? []
        for role in guildRoles.filter({ $0.name == roleName }) {
            try await client.deleteGuildRole(
                guildId: Constants.guildId,
                roleId: role.id,
                reason: "Tests cleanup"
            ).guardIsSuccessfulResponse()
        }
        
        let reaction = try Reaction.unicodeEmoji("✅")
        
        let handler1 = try await ReactToRoleHandler(
            gatewayManager: bot,
            cache: cache,
            roleName: roleName,
            roleUnicodeEmoji: nil,
            roleColor: .green,
            guildId: Constants.guildId,
            channelId: Constants.reactionChannelId,
            messageId: Constants.reactionMessageId,
            reactions: [reaction]
        )
        
        /// On init, handler will react to the message.
        /// Since I've intentionally set the app-id to a wrong app-id, the handler will
        /// try to take action on its own reaction, and give itself the role.
        
        /// To make sure the handler has enough time
        try await Task.sleep(nanoseconds: 5_000_000_000)
        
        /// Verify reacted
        let reactionUsers = try await client.getReactions(
            channelId: Constants.reactionChannelId,
            messageId: Constants.reactionMessageId,
            emoji: reaction
        ).decode()
        
        XCTAssertEqual(reactionUsers.count, 1)
        
        let user = try XCTUnwrap(reactionUsers.first)
        XCTAssertEqual(user.id, Constants.botId)
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        /// Verify assigned the role to itself
        let _guild = await cache.guilds[Constants.guildId]
        let guild = try XCTUnwrap(_guild)
        let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
        let roles = guild.roles.filter({ member.roles.contains($0.id) })
        let role = roles.first(where: { $0.name == roleName })
        func debugDescription(_ roles: [Role]) -> String {
            "\(roles.map({ (id: $0.id, name: $0.name) }))"
        }
        XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        
        // MARK: - Test handler throws error when message doesn't exist
        
        let invalidMessageId = "1073288867911100000"
        do {
            let handler2 = try await ReactToRoleHandler(
                gatewayManager: bot,
                cache: cache,
                roleName: "test-reaction-role",
                roleUnicodeEmoji: nil,
                roleColor: .green,
                guildId: Constants.guildId,
                channelId: Constants.reactionChannelId,
                messageId: invalidMessageId,
                reactions: [reaction]
            )
            XCTFail("Handler must have failed")
        } catch {
            switch error as? ReactToRoleHandler.Error {
            case .messageIsInaccessible(
                messageId: invalidMessageId,
                channelId: Constants.reactionChannelId,
                previousError: DiscordClientError.badStatusCode(_)):
                break /// Expected error
            default:
                XCTFail("Unexpected error by handler: \(error)")
            }
        }
        
        await bot.disconnect()
        
        try await Task.sleep(nanoseconds: 5_000_000_000)
    }
    
    func testEverythingWithoutCache() async throws {
        let client = DefaultDiscordClient(
            httpClient: httpClient,
            token: Constants.token,
            /// Intentionally wrong so reaction-handler can take action on its own reaction
            appId: "11111111"
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
                intents: Gateway.Intent.allCases
            )
        )
        
        let expectation = expectation(description: "Connected")
        
        await bot.addEventHandler { event in
            if case .ready = event.data {
                expectation.fulfill()
            }
        }
        
        let cache = await DiscordCache(
            gatewayManager: bot,
            intents: .all,
            requestAllMembers: .enabledWithPresences
        )
        
        /// Perform reactions-cleanup before starting
        try await client.deleteAllReactions(
            channelId: Constants.reactionChannelId,
            messageId: Constants.reactionMessageId
        ).guardIsSuccessfulResponse()
        
        Task { await bot.connect() }
        wait(for: [expectation], timeout: 10)
        
        /// So cache is populated
        try await Task.sleep(nanoseconds: 5_000_000_000)
        
        let roleName = "test-reaction-role"
        
        /// Remove roles with this name is there are any
        let guildRoles = await cache.guilds[Constants.guildId]?.roles ?? []
        for role in guildRoles.filter({ $0.name == roleName }) {
            try await client.deleteGuildRole(
                guildId: Constants.guildId,
                roleId: role.id,
                reason: "Tests cleanup"
            ).guardIsSuccessfulResponse()
        }
        
        let reaction = try Reaction.unicodeEmoji("✅")
        
        let handler1 = try await ReactToRoleHandler(
            gatewayManager: bot,
            cache: nil,
            roleName: roleName,
            roleUnicodeEmoji: nil,
            roleColor: .green,
            guildId: Constants.guildId,
            channelId: Constants.reactionChannelId,
            messageId: Constants.reactionMessageId,
            reactions: [reaction]
        )
        
        /// On init, handler will react to the message.
        /// Since I've intentionally set the app-id to a wrong app-id, the handler will
        /// try to take action on its own reaction, and give itself the role.
        
        /// To make sure the handler has enough time
        try await Task.sleep(nanoseconds: 5_000_000_000)
        
        /// Verify reacted
        let reactionUsers = try await client.getReactions(
            channelId: Constants.reactionChannelId,
            messageId: Constants.reactionMessageId,
            emoji: reaction
        ).decode()
        
        XCTAssertEqual(reactionUsers.count, 1)
        
        let user = try XCTUnwrap(reactionUsers.first)
        XCTAssertEqual(user.id, Constants.botId)
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        /// Verify assigned the role to itself
        let _guild = await cache.guilds[Constants.guildId]
        let guild = try XCTUnwrap(_guild)
        let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
        let roles = guild.roles.filter({ member.roles.contains($0.id) })
        let role = roles.first(where: { $0.name == roleName })
        func debugDescription(_ roles: [Role]) -> String {
            "\(roles.map({ (id: $0.id, name: $0.name) }))"
        }
        XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        
        // MARK: - Test handler throws error when message doesn't exist
        
        let invalidMessageId = "1073288867911100000"
        do {
            let handler2 = try await ReactToRoleHandler(
                gatewayManager: bot,
                cache: nil,
                roleName: "test-reaction-role",
                roleUnicodeEmoji: nil,
                roleColor: .green,
                guildId: Constants.guildId,
                channelId: Constants.reactionChannelId,
                messageId: invalidMessageId,
                reactions: [reaction]
            )
            XCTFail("Handler must have failed")
        } catch {
            switch error as? ReactToRoleHandler.Error {
            case .messageIsInaccessible(
                messageId: invalidMessageId,
                channelId: Constants.reactionChannelId,
                previousError: DiscordClientError.badStatusCode(_)):
                break /// Expected error
            default:
                XCTFail("Unexpected error by handler: \(error)")
            }
        }
        
        await bot.disconnect()
        
        try await Task.sleep(nanoseconds: 5_000_000_000)
    }
}
