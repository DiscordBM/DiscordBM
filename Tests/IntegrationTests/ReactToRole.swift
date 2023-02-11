import DiscordGateway
import AsyncHTTPClient
import Logging
import struct NIOCore.ByteBuffer
import XCTest

class ReactToRoleTests: XCTestCase {
    
    var httpClient: HTTPClient!
    var client: DefaultDiscordClient!
    
    override func setUp() {
        DiscordGlobalConfiguration.makeLogger = {
            Logger(label: $0, factory: SwiftLogNoOpLogHandler.init)
        }
        self.httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        self.client = DefaultDiscordClient(
            httpClient: httpClient,
            token: Constants.token,
            /// Intentionally wrong so reaction-handler can take action on its own reaction
            appId: "11111111"
        )
    }
    
    override func tearDown() {
        DiscordGlobalConfiguration.makeLogger = { Logger(label: $0) }
        try! httpClient.syncShutdown()
        self.client = nil
    }
    #warning("test for multiple reactions")
    #warning("test for when you already reacted but you don't have the role (enable 'configuration.grantOnStart' first)")
    func testWithCache() async throws {
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
        
        /// Make the reaction message
        let reactionMessageId = try await client.createMessage(
            channelId: Constants.reactionChannelId,
            payload: .init(content: "React-To-Role test message!")
        ).decode().id
        
        let reaction = try Reaction.unicodeEmoji("✅")
        let unacceptableReaction = try Reaction.unicodeEmoji("🐶")
        
        var lifecycleEnded = false
        var configurationChanged = false
        
        let _ = try await ReactToRoleHandler(
            gatewayManager: bot,
            cache: cache,
            role: .init(
                name: roleName,
                permissions: nil,
                color: .green,
                hoist: nil,
                icon: nil,
                unicode_emoji: nil,
                mentionable: nil
            ),
            guildId: Constants.guildId,
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            reactions: [reaction],
            onConfigurationChanged: { _ in configurationChanged = true },
            onLifecycleEnd: { _ in lifecycleEnded = true }
        )
        
        /// On `init`, handler will react to the message.
        /// Since I've intentionally set the app-id to a wrong app-id, the handler will
        /// try to take action on its own reaction, and give itself the role.
        
        /// To make sure the handler has enough time
        try await Task.sleep(nanoseconds: 5_000_000_000)
        
        /// Configuration must have been changed and populated with the role id
        XCTAssertEqual(configurationChanged, true)
        
        /// Verify reacted
        let reactionUsers = try await client.getReactions(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: reaction
        ).decode()
        
        XCTAssertEqual(reactionUsers.count, 1)
        
        let user = try XCTUnwrap(reactionUsers.first)
        XCTAssertEqual(user.id, Constants.botId)
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify assigned the role to itself
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Delete the reaction, check if role is removed
        try await client.deleteOwnReaction(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardIsSuccessfulResponse()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify doesn't have the role anymore
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Create an unrelated reaction, must not be granted the role
        try await client.createReaction(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: unacceptableReaction
        ).guardIsSuccessfulResponse()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify still doesn't have the role
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Lifecycle still not ended
        XCTAssertEqual(lifecycleEnded, false)
        
        /// Delete message
        try await client.deleteMessage(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId
        ).guardIsSuccessfulResponse()
        
        /// So the gateway event is sent and processed
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        /// After message is deleted, lifecycle is ended
        XCTAssertEqual(lifecycleEnded, true)
        
        await bot.disconnect()
        
        /// So it doesn't mess up the next tests' gateway connections
        try await Task.sleep(nanoseconds: 5_000_000_000)
    }
    
    func testNoCache() async throws {
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
        
        Task { await bot.connect() }
        wait(for: [expectation], timeout: 10)
        
        /// So cache is populated
        try await Task.sleep(nanoseconds: 5_000_000_000)
        
        let roleName = "test-reaction-role"
        let roleColor = DiscordColor.red
        let rolePermissions = [Permission.manageRoles]
        
        /// Remove roles with this name is there are any
        let guildRoles = await cache.guilds[Constants.guildId]?.roles ?? []
        for role in guildRoles.filter({ $0.name == roleName }) {
            try await client.deleteGuildRole(
                guildId: Constants.guildId,
                roleId: role.id,
                reason: "Tests cleanup"
            ).guardIsSuccessfulResponse()
        }
        
        /// Make the reaction message
        let reactionMessageId = try await client.createMessage(
            channelId: Constants.reactionChannelId,
            payload: .init(content: "React-To-Role test message!")
        ).decode().id
        
        let reaction = Reaction.guildEmoji(name: "dbm", id: "1073704788400820324")
        let unacceptableReaction = try Reaction.unicodeEmoji("🐶")
        
        var lifecycleEnded = false
        var configurationChanged = false
        
        let _ = try await ReactToRoleHandler(
            gatewayManager: bot,
            cache: nil,
            role: .init(
                name: roleName,
                permissions: rolePermissions,
                color: roleColor,
                hoist: nil,
                icon: nil,
                unicode_emoji: "🦁",
                mentionable: nil
            ),
            guildId: Constants.guildId,
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            reactions: [reaction],
            onConfigurationChanged: { _ in configurationChanged = true },
            onLifecycleEnd: { _ in lifecycleEnded = true }
        )
        
        /// On `init`, handler will react to the message.
        /// Since I've intentionally set the app-id to a wrong app-id, the handler will
        /// try to take action on its own reaction, and give itself the role.
        
        /// To make sure the handler has enough time
        try await Task.sleep(nanoseconds: 5_000_000_000)
        
        /// Configuration must have been changed and populated with the role id
        XCTAssertEqual(configurationChanged, true)
        
        /// Verify reacted
        let reactionUsers = try await client.getReactions(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: reaction
        ).decode()
        
        XCTAssertEqual(reactionUsers.count, 1)
        
        let user = try XCTUnwrap(reactionUsers.first)
        XCTAssertEqual(user.id, Constants.botId)
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify assigned the role to itself
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = try XCTUnwrap(roles.first(where: { $0.name == roleName }), "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
            
            /// Verify the role has the requested properties
            XCTAssertEqual(role.name, roleName)
            XCTAssertEqual(role.color, roleColor)
            XCTAssertEqual(Array(role.permissions.values), rolePermissions)
            XCTAssertNil(role.unicode_emoji)
        }
        
        /// Delete the reaction, check if role is removed
        try await client.deleteOwnReaction(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardIsSuccessfulResponse()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify doesn't have the role anymore
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Create an unrelated reaction, must not be granted the role
        try await client.createReaction(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: unacceptableReaction
        ).guardIsSuccessfulResponse()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify still doesn't have the role
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Lifecycle still not ended
        XCTAssertEqual(lifecycleEnded, false)
        
        /// Delete message
        try await client.deleteMessage(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId
        ).guardIsSuccessfulResponse()
        
        /// So the gateway event is sent and processed
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        /// After message is deleted, lifecycle is ended
        XCTAssertEqual(lifecycleEnded, true)
        
        await bot.disconnect()
        
        /// So it doesn't mess up the next tests' gateway connections
        try await Task.sleep(nanoseconds: 5_000_000_000)
    }
    
    func testInitializerAcceptingConfiguration() async throws {
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
        
        /// Make the reaction message
        let reactionMessageId = try await client.createMessage(
            channelId: Constants.reactionChannelId,
            payload: .init(content: "React-To-Role test message!")
        ).decode().id
        
        let reaction = try Reaction.unicodeEmoji("✅")
        let unacceptableReaction = try Reaction.unicodeEmoji("🐶")
        
        var lifecycleEnded = false
        var configurationChanged = false
        
        let _ = try await ReactToRoleHandler(
            gatewayManager: bot,
            cache: cache,
            configuration: .init(
                id: UUID(),
                createRole: .init(
                    name: roleName,
                    permissions: nil,
                    color: .green,
                    hoist: nil,
                    icon: nil,
                    unicode_emoji: nil,
                    mentionable: nil
                ),
                guildId: Constants.guildId,
                channelId: Constants.reactionChannelId,
                messageId: reactionMessageId,
                reactions: [reaction],
                roleId: nil
            ),
            onConfigurationChanged: { _ in configurationChanged = true },
            onLifecycleEnd: { _ in lifecycleEnded = true }
        )
        
        /// On `init`, handler will react to the message.
        /// Since I've intentionally set the app-id to a wrong app-id, the handler will
        /// try to take action on its own reaction, and give itself the role.
        
        /// To make sure the handler has enough time
        try await Task.sleep(nanoseconds: 5_000_000_000)
        
        /// Configuration must have been changed and populated with the role id
        XCTAssertEqual(configurationChanged, true)
        
        /// Verify reacted
        let reactionUsers = try await client.getReactions(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: reaction
        ).decode()
        
        XCTAssertEqual(reactionUsers.count, 1)
        
        let user = try XCTUnwrap(reactionUsers.first)
        XCTAssertEqual(user.id, Constants.botId)
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify assigned the role to itself
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Delete the reaction, check if role is removed
        try await client.deleteOwnReaction(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardIsSuccessfulResponse()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify doesn't have the role anymore
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Create an unrelated reaction, must not be granted the role
        try await client.createReaction(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: unacceptableReaction
        ).guardIsSuccessfulResponse()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify still doesn't have the role
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Lifecycle still not ended
        XCTAssertEqual(lifecycleEnded, false)
        
        /// Delete message
        try await client.deleteMessage(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId
        ).guardIsSuccessfulResponse()
        
        /// So the gateway event is sent and processed
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        /// After message is deleted, lifecycle is ended
        XCTAssertEqual(lifecycleEnded, true)
        
        await bot.disconnect()
        
        /// So it doesn't mess up the next tests' gateway connections
        try await Task.sleep(nanoseconds: 5_000_000_000)
    }
    
    func testInitializerWithExistingRole() async throws {
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
        
        /// Make the reaction message
        let reactionMessageId = try await client.createMessage(
            channelId: Constants.reactionChannelId,
            payload: .init(content: "React-To-Role test message!")
        ).decode().id
        
        let reaction = try Reaction.unicodeEmoji("✅")
        let unacceptableReaction = try Reaction.unicodeEmoji("🐶")
        
        var lifecycleEnded = false
        var configurationChanged = false
        
        let role = try await client.createGuildRole(
            guildId: Constants.guildId,
            payload: .init(
                name: roleName,
                permissions: nil,
                color: nil,
                hoist: nil,
                icon: nil,
                unicode_emoji: nil,
                mentionable: nil
            )
        ).decode()
        
        let _ = try await ReactToRoleHandler(
            gatewayManager: bot,
            cache: cache,
            existingRoleId: role.id,
            guildId: Constants.guildId,
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            reactions: [reaction],
            onConfigurationChanged: { _ in configurationChanged = true },
            onLifecycleEnd: { _ in lifecycleEnded = true }
        )
        
        /// On `init`, handler will react to the message.
        /// Since I've intentionally set the app-id to a wrong app-id, the handler will
        /// try to take action on its own reaction, and give itself the role.
        
        /// To make sure the handler has enough time
        try await Task.sleep(nanoseconds: 5_000_000_000)
        
        /// Configuration not must be changed because we already provided the role-id
        XCTAssertEqual(configurationChanged, false)
        
        /// Verify reacted
        let reactionUsers = try await client.getReactions(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: reaction
        ).decode()
        
        XCTAssertEqual(reactionUsers.count, 1)
        
        let user = try XCTUnwrap(reactionUsers.first)
        XCTAssertEqual(user.id, Constants.botId)
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify assigned the role to itself
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Delete the reaction, check if role is removed
        try await client.deleteOwnReaction(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardIsSuccessfulResponse()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify doesn't have the role anymore
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Create an unrelated reaction, must not be granted the role
        try await client.createReaction(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: unacceptableReaction
        ).guardIsSuccessfulResponse()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify still doesn't have the role
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Lifecycle still not ended
        XCTAssertEqual(lifecycleEnded, false)
        
        /// Delete message
        try await client.deleteMessage(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId
        ).guardIsSuccessfulResponse()
        
        /// So the gateway event is sent and processed
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        /// After message is deleted, lifecycle is ended
        XCTAssertEqual(lifecycleEnded, true)
        
        await bot.disconnect()
        
        /// So it doesn't mess up the next tests' gateway connections
        try await Task.sleep(nanoseconds: 5_000_000_000)
    }
    
    func testMessageIsInvalid() async throws {
        let bot = FakeGatewayManager(client: self.client)
        let cache = await DiscordCache(
            gatewayManager: bot,
            intents: .all,
            requestAllMembers: .enabledWithPresences
        )
        
        let invalidMessageId = "1073288867911100000"
        
        /// With cache
        do {
            let _ = try await ReactToRoleHandler(
                gatewayManager: bot,
                cache: cache,
                role: .init(
                    name: "test-reaction-role",
                    permissions: nil,
                    color: .green,
                    hoist: nil,
                    icon: nil,
                    unicode_emoji: nil,
                    mentionable: nil
                ),
                guildId: Constants.guildId,
                channelId: Constants.reactionChannelId,
                messageId: invalidMessageId,
                reactions: [.unicodeEmoji("😜")]
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
        
        /// With no cache
        do {
            let _ = try await ReactToRoleHandler(
                gatewayManager: bot,
                cache: nil,
                role: .init(
                    name: "test-reaction-role",
                    permissions: nil,
                    color: .green,
                    hoist: nil,
                    icon: nil,
                    unicode_emoji: nil,
                    mentionable: nil
                ),
                guildId: Constants.guildId,
                channelId: Constants.reactionChannelId,
                messageId: invalidMessageId,
                reactions: [.unicodeEmoji("😜")]
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
                XCTFail("Expected 'messageIsInaccessible' error, but got: \(error)")
            }
        }
    }
    
    func testStartAndStop() async throws {
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
        
        /// Make the reaction message
        let reactionMessageId = try await client.createMessage(
            channelId: Constants.reactionChannelId,
            payload: .init(content: "React-To-Role test message!")
        ).decode().id
        
        let reaction = try Reaction.unicodeEmoji("✅")
        
        var lifecycleEnded = false
        var configurationChanged = false
        
        let handler = try await ReactToRoleHandler(
            gatewayManager: bot,
            cache: cache,
            role: .init(
                name: roleName,
                permissions: nil,
                color: .green,
                hoist: nil,
                icon: nil,
                unicode_emoji: nil,
                mentionable: nil
            ),
            guildId: Constants.guildId,
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            reactions: [reaction],
            onConfigurationChanged: { _ in configurationChanged = true },
            onLifecycleEnd: { _ in lifecycleEnded = true }
        )
        
        /// On `init`, handler will react to the message.
        /// Since I've intentionally set the app-id to a wrong app-id, the handler will
        /// try to take action on its own reaction, and give itself the role.
        
        /// To make sure the handler has enough time
        try await Task.sleep(nanoseconds: 5_000_000_000)
        
        /// Configuration must have been changed and populated with the role id
        XCTAssertEqual(configurationChanged, true)
        
        /// Verify reacted
        let reactionUsers = try await client.getReactions(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: reaction
        ).decode()
        
        XCTAssertEqual(reactionUsers.count, 1)
        
        let user = try XCTUnwrap(reactionUsers.first)
        XCTAssertEqual(user.id, Constants.botId)
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify assigned the role to itself
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Delete the reaction, check if role is removed
        try await client.deleteOwnReaction(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardIsSuccessfulResponse()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify doesn't have the role anymore
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Stop
        await handler.stop()
        let stoppedState = await handler.state
        XCTAssertEqual(stoppedState, .stopped)
        
        /// Create the reaction again, must not be granted the role
        try await client.createReaction(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardIsSuccessfulResponse()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify still doesn't have the role
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Delete the reaction again
        try await client.deleteOwnReaction(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardIsSuccessfulResponse()
        
        /// Start
        try await handler.restart()
        let runningState = await handler.state
        XCTAssertEqual(runningState, .running)
        
        /// So the cache is updated with the new member info
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        do {
            /// Verify re-assigned the role to itself
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Lifecycle still not ended
        XCTAssertEqual(lifecycleEnded, false)
        
        /// Delete message
        try await client.deleteMessage(
            channelId: Constants.reactionChannelId,
            messageId: reactionMessageId
        ).guardIsSuccessfulResponse()
        
        /// So the gateway event is sent and processed
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        /// After message is deleted, lifecycle is ended
        XCTAssertEqual(lifecycleEnded, true)
        
        await bot.disconnect()
        
        /// So it doesn't mess up the next tests' gateway connections
        try await Task.sleep(nanoseconds: 5_000_000_000)
    }
    
    func makeBotAndCache(
        client: (any DiscordClient)? = nil
    ) async throws -> (any GatewayManager, DiscordCache) {
        let bot = BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            client: client ?? self.client,
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
        
        Task { await bot.connect() }
        wait(for: [expectation], timeout: 10)
        
        /// So cache is populated
        try await Task.sleep(nanoseconds: 5_000_000_000)
        
        return (bot, cache)
    }
    
    func debugDescription(_ roles: [Role]) -> String {
        "\(roles.map({ (id: $0.id, name: $0.name) }))"
    }
}

private actor FakeGatewayManager: GatewayManager {
    nonisolated let client: DiscordClient
    nonisolated let id: Int = 0
    nonisolated let state: GatewayState = .stopped
    func connect() async { }
    func requestGuildMembersChunk(payload: Gateway.RequestGuildMembers) async { }
    func updatePresence(payload: Gateway.Identify.Presence) async { }
    func updateVoiceState(payload: VoiceStateUpdate) async { }
    func addEventHandler(_ handler: @escaping (Gateway.Event) -> Void) async { }
    func addEventParseFailureHandler(_ handler: @escaping (Error, ByteBuffer) -> Void) async { }
    func disconnect() async { }
    
    init(client: DiscordClient) {
        self.client = client
    }
}
