@testable import DiscordGateway
import AsyncHTTPClient
import Logging
import struct NIOCore.ByteBuffer
import XCTest

class ReactToRoleTests: XCTestCase {
    
    var httpClient: HTTPClient!
    var client: DefaultDiscordClient!
    let roleName = "test-reaction-role"
    
    override func setUp() async throws {
        self.httpClient = self.httpClient ?? HTTPClient(eventLoopGroupProvider: .createNew)
        self.client = await DefaultDiscordClient(
            httpClient: httpClient,
            token: Constants.token,
            /// Intentionally wrong so reaction-handler can take action on its own reaction
            appId: "11111111",
            /// For not failing tests
            configuration: .init(retryPolicy: .init(backoff: .basedOnHeaders(maxAllowed: 10)))
        )
        /// Remove roles with this name if there are any
        let guildRoles = try await client
            .listGuildRoles(id: Constants.guildId)
            .decode()
        for role in guildRoles.filter({ $0.name == roleName }) {
            try await client.deleteGuildRole(
                guildId: Constants.guildId,
                roleId: role.id,
                reason: "Tests cleanup"
            ).guardSuccess()
        }
    }
    
    deinit {
        try! httpClient.syncShutdown()
    }
    
    func testWithCache() async throws {
        let (bot, cache) = try await makeBotAndCache()
        
        /// Make the reaction message
        let reactionMessageId = try await client.createMessage(
            channelId: Constants.Channels.reaction.id,
            payload: .init(content: "React-To-Role test message!")
        ).decode().id
        
        let reaction = try Reaction.unicodeEmoji("✅")
        let unacceptableReaction = try Reaction.unicodeEmoji("🐶")
        
        let hookInfo = HookInfo()
        
        let _ = try await ReactToRoleHandler(
            gatewayManager: bot,
            cache: cache,
            role: .init(
                name: roleName,
                color: .green
            ),
            guildId: Constants.guildId,
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            reactions: [reaction],
            onConfigurationChanged: { _ in Task { await hookInfo.setConfigurationChanged() } },
            onLifecycleEnd: { _ in Task { await hookInfo.setLifecycleEnded() } }
        )
        
        /// On `init`, handler will react to the message.
        /// Since I've intentionally set the app-id to a wrong app-id, the handler will
        /// try to take action on its own reaction, and give itself the role.
        
        /// To make sure the handler has enough time
        try await Task.sleep(for: .seconds(5))
        
        /// Configuration must have been changed and populated with the role id
        do {
            let configurationChanged = await hookInfo.configurationChanged
            XCTAssertEqual(configurationChanged, true)
        }
        
        /// Verify reacted
        let reactionUsers = try await client.listMessageReactionsByEmoji(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction
        ).decode()
        
        XCTAssertEqual(reactionUsers.count, 1)
        
        let user = try XCTUnwrap(reactionUsers.first)
        XCTAssertEqual(user.id, Constants.botId)
        
        /// So the cache is updated with the new member info
        try await Task.sleep(for: .seconds(2))
        
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
        try await client.deleteOwnMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardSuccess()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(for: .seconds(2))
        
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
        try await client.addMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: unacceptableReaction
        ).guardSuccess()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify still doesn't have the role
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Wait for the property below to be updated if needed
        try await Task.sleep(for: .seconds(1))
        
        /// Lifecycle still not ended
        do {
            let lifecycleEnded = await hookInfo.lifecycleEnded
            XCTAssertEqual(lifecycleEnded, false)
        }
        
        /// Delete message
        try await client.deleteMessage(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId
        ).guardSuccess()
        
        /// So the gateway event is sent and processed
        try await Task.sleep(for: .seconds(2))
        
        /// After message is deleted, lifecycle is ended
        do {
            let lifecycleEnded = await hookInfo.lifecycleEnded
            XCTAssertEqual(lifecycleEnded, true)
        }
        
        await bot.disconnect()
    }
    
    func testNoCache() async throws {
        let (bot, cache) = try await makeBotAndCache()
        
        let roleColor = DiscordColor.red
        let rolePermissions = [Permission.manageRoles]
        
        /// Make the reaction message
        let reactionMessageId = try await client.createMessage(
            channelId: Constants.Channels.reaction.id,
            payload: .init(content: "React-To-Role test message!")
        ).decode().id
        
        let reaction = Reaction.guildEmoji(name: "dbm", id: "1073704788400820324")
        let unacceptableReaction = try Reaction.unicodeEmoji("🐶")
        
        let hookInfo = HookInfo()
        
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
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            reactions: [reaction],
            onConfigurationChanged: { _ in Task { await hookInfo.setConfigurationChanged() } },
            onLifecycleEnd: { _ in Task { await hookInfo.setLifecycleEnded() } }
        )
        
        /// On `init`, handler will react to the message.
        /// Since I've intentionally set the app-id to a wrong app-id, the handler will
        /// try to take action on its own reaction, and give itself the role.
        
        /// To make sure the handler has enough time
        try await Task.sleep(for: .seconds(5))
        
        /// Configuration must have been changed and populated with the role id
        do {
            let configurationChanged = await hookInfo.configurationChanged
            XCTAssertEqual(configurationChanged, true)
        }
        
        /// Verify reacted
        let reactionUsers = try await client.listMessageReactionsByEmoji(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction
        ).decode()
        
        XCTAssertEqual(reactionUsers.count, 1)
        
        let user = try XCTUnwrap(reactionUsers.first)
        XCTAssertEqual(user.id, Constants.botId)
        
        /// So the cache is updated with the new member info
        try await Task.sleep(for: .seconds(2))
        
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
        try await client.deleteOwnMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardSuccess()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(for: .seconds(2))
        
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
        try await client.addMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: unacceptableReaction
        ).guardSuccess()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify still doesn't have the role
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Wait for the property below to be updated if needed
        try await Task.sleep(for: .seconds(1))
        
        /// Lifecycle still not ended
        do {
            let lifecycleEnded = await hookInfo.lifecycleEnded
            XCTAssertEqual(lifecycleEnded, false)
        }
        
        /// Delete message
        try await client.deleteMessage(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId
        ).guardSuccess()
        
        /// So the gateway event is sent and processed
        try await Task.sleep(for: .seconds(2))
        
        /// After message is deleted, lifecycle is ended
        do {
            let lifecycleEnded = await hookInfo.lifecycleEnded
            XCTAssertEqual(lifecycleEnded, true)
        }
        
        await bot.disconnect()
    }
    
    func testMultipleReactions() async throws {
        let (bot, cache) = try await makeBotAndCache()
        
        /// Make the reaction message
        let reactionMessageId = try await client.createMessage(
            channelId: Constants.Channels.reaction.id,
            payload: .init(content: "React-To-Role test message!")
        ).decode().id
        
        let reaction1 = try Reaction.unicodeEmoji("✅")
        let reaction2 = try Reaction.unicodeEmoji("🐶")
        
        let handler = try await ReactToRoleHandler(
            gatewayManager: bot,
            cache: cache,
            role: .init(
                name: roleName,
                permissions: nil,
                color: .purple,
                hoist: nil,
                icon: nil,
                unicode_emoji: nil,
                mentionable: nil
            ),
            guildId: Constants.guildId,
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            reactions: [reaction1, reaction2]
        )
        
        /// On `init`, handler will react to the message.
        /// Since I've intentionally set the app-id to a wrong app-id, the handler will
        /// try to take action on its own reaction, and give itself the role.
        
        /// To make sure the handler has enough time
        try await Task.sleep(for: .seconds(5))
        
        do {
            /// Verify reacted to `reaction1`
            let reactionUsers = try await client.listMessageReactionsByEmoji(
                channelId: Constants.Channels.reaction.id,
                messageId: reactionMessageId,
                emoji: reaction1
            ).decode()
            
            XCTAssertEqual(reactionUsers.count, 1)
            
            let user = try XCTUnwrap(reactionUsers.first)
            XCTAssertEqual(user.id, Constants.botId)
        }
        
        do {
            /// Verify reacted to `reaction2`
            let reactionUsers = try await client.listMessageReactionsByEmoji(
                channelId: Constants.Channels.reaction.id,
                messageId: reactionMessageId,
                emoji: reaction2
            ).decode()
            
            XCTAssertEqual(reactionUsers.count, 1)
            
            let user = try XCTUnwrap(reactionUsers.first)
            XCTAssertEqual(user.id, Constants.botId)
        }
        
        do {
            /// Verify assigned the role to itself
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        try await client.deleteOwnMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction1
        ).guardSuccess()
        
        /// To make sure cache receives the events
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify still has the role although 1 of the 2 reactions has been removed
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        try await client.deleteAllMessageReactions(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId
        ).guardSuccess()
        
        /// To make sure cache receives the events
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify still has the role
            /// Because on "delete all reactions" the handler doesn't remove any roles
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        let _roleId = await handler.configuration.roleId
        let roleId = try XCTUnwrap(_roleId)
        
        try await client.deleteGuildMemberRole(
            guildId: Constants.guildId,
            userId: Constants.botId,
            roleId: roleId
        ).guardSuccess()
        
        /// To make sure cache receives the events
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify does not have the role anymore
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        try await client.addMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction2
        ).guardSuccess()
        
        /// To make sure cache receives the events
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify has the role again because reacted again
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        try await client.addMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction1
        ).guardSuccess()
        
        /// To make sure cache receives the events
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify still has the role
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        try await client.deleteAllMessageReactionsByEmoji(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction1
        ).guardSuccess()
        
        /// To make sure cache receives the events
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify still has the role
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        try await client.deleteOwnMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction2
        ).guardSuccess()
        
        /// To make sure cache receives the events
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify does not have the role anymore because both reactions removed
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        try await client.deleteMessage(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId
        ).guardSuccess()
        
        await bot.disconnect()
    }
    
    func testGrantOnStart() async throws {
        let (bot, cache) = try await makeBotAndCache()
        
        /// Make the reaction message
        let reactionMessageId = try await client.createMessage(
            channelId: Constants.Channels.reaction.id,
            payload: .init(content: "React-To-Role test message!")
        ).decode().id
        
        let reaction = try Reaction.unicodeEmoji("✅")
        
        let handler = try await ReactToRoleHandler(
            gatewayManager: bot,
            cache: cache,
            role: .init(
                name: roleName,
                permissions: nil,
                color: .purple,
                hoist: nil,
                icon: nil,
                unicode_emoji: nil,
                mentionable: nil
            ),
            guildId: Constants.guildId,
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            grantOnStart: true,
            reactions: [reaction]
        )
        
        /// On `init`, handler will react to the message.
        /// Since I've intentionally set the app-id to a wrong app-id, the handler will
        /// try to take action on its own reaction, and give itself the role.
        
        /// To make sure the handler has enough time
        try await Task.sleep(for: .seconds(5))
        
        do {
            /// Verify reacted
            let reactionUsers = try await client.listMessageReactionsByEmoji(
                channelId: Constants.Channels.reaction.id,
                messageId: reactionMessageId,
                emoji: reaction
            ).decode()
            
            XCTAssertEqual(reactionUsers.count, 1)
            
            let user = try XCTUnwrap(reactionUsers.first)
            XCTAssertEqual(user.id, Constants.botId)
        }
        
        do {
            /// Verify assigned the role to itself
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        try await client.deleteOwnMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardSuccess()
        
        /// To make sure cache receives the events
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify doesn't have the role anymore
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        await handler.stop()
        let stoppedState = await handler.state
        XCTAssertEqual(stoppedState, .stopped)
        
        try await client.addMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardSuccess()
        
        // To make sure cache receives the events
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify still doesn't have the role because the handler is stopped
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        try await handler.restart()
        let runningState = await handler.state
        XCTAssertEqual(runningState, .running)
        
        // To make sure cache receives the events
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify has the role now, although the reaction was there even when handler restarted
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        try await client.deleteMessage(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId
        ).guardSuccess()
        
        await bot.disconnect()
    }
    
    func testInitializerAcceptingConfiguration() async throws {
        let (bot, cache) = try await makeBotAndCache()
        
        /// Make the reaction message
        let reactionMessageId = try await client.createMessage(
            channelId: Constants.Channels.reaction.id,
            payload: .init(content: "React-To-Role test message!")
        ).decode().id
        
        let reaction = try Reaction.unicodeEmoji("✅")
        let unacceptableReaction = try Reaction.unicodeEmoji("🐶")
        
        let hookInfo = HookInfo()
        
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
                channelId: Constants.Channels.reaction.id,
                messageId: reactionMessageId,
                reactions: [reaction],
                roleId: nil
            ),
            onConfigurationChanged: { _ in Task { await hookInfo.setConfigurationChanged() } },
            onLifecycleEnd: { _ in Task { await hookInfo.setLifecycleEnded() } }
        )
        
        /// On `init`, handler will react to the message.
        /// Since I've intentionally set the app-id to a wrong app-id, the handler will
        /// try to take action on its own reaction, and give itself the role.
        
        /// To make sure the handler has enough time
        try await Task.sleep(for: .seconds(5))
        
        /// Configuration must have been changed and populated with the role id
        do {
            let configurationChanged = await hookInfo.configurationChanged
            XCTAssertEqual(configurationChanged, true)
        }
        
        /// Verify reacted
        let reactionUsers = try await client.listMessageReactionsByEmoji(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction
        ).decode()
        
        XCTAssertEqual(reactionUsers.count, 1)
        
        let user = try XCTUnwrap(reactionUsers.first)
        XCTAssertEqual(user.id, Constants.botId)
        
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
        try await client.deleteOwnMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardSuccess()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(for: .seconds(2))
        
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
        try await client.addMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: unacceptableReaction
        ).guardSuccess()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify still doesn't have the role
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Wait for the property below to be updated if needed
        try await Task.sleep(for: .seconds(1))
        
        /// Lifecycle still not ended
        do {
            let lifecycleEnded = await hookInfo.lifecycleEnded
            XCTAssertEqual(lifecycleEnded, false)
        }
        
        /// Delete message
        try await client.deleteMessage(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId
        ).guardSuccess()
        
        /// So the gateway event is sent and processed
        try await Task.sleep(for: .seconds(2))
        
        /// After message is deleted, lifecycle is ended
        do {
            let lifecycleEnded = await hookInfo.lifecycleEnded
            XCTAssertEqual(lifecycleEnded, true)
        }
        
        await bot.disconnect()
    }
    
    func testInitializerWithExistingRole() async throws {
        let (bot, cache) = try await makeBotAndCache()
        
        /// Make the reaction message
        let reactionMessageId = try await client.createMessage(
            channelId: Constants.Channels.reaction.id,
            payload: .init(content: "React-To-Role test message!")
        ).decode().id
        
        let reaction = try Reaction.unicodeEmoji("✅")
        let unacceptableReaction = try Reaction.unicodeEmoji("🐶")
        
        let hookInfo = HookInfo()
        
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
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            reactions: [reaction],
            onConfigurationChanged: { _ in Task { await hookInfo.setConfigurationChanged() } },
            onLifecycleEnd: { _ in Task { await hookInfo.setLifecycleEnded() } }
        )
        
        /// On `init`, handler will react to the message.
        /// Since I've intentionally set the app-id to a wrong app-id, the handler will
        /// try to take action on its own reaction, and give itself the role.
        
        /// To make sure the handler has enough time
        try await Task.sleep(for: .seconds(5))
        
        /// Configuration not must be changed because we already provided the role-id
        do {
            let configurationChanged = await hookInfo.configurationChanged
            XCTAssertEqual(configurationChanged, false)
        }
        
        /// Verify reacted
        let reactionUsers = try await client.listMessageReactionsByEmoji(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction
        ).decode()
        
        XCTAssertEqual(reactionUsers.count, 1)
        
        let user = try XCTUnwrap(reactionUsers.first)
        XCTAssertEqual(user.id, Constants.botId)
        
        /// So the cache is updated with the new member info
        try await Task.sleep(for: .seconds(2))
        
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
        try await client.deleteOwnMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardSuccess()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(for: .seconds(2))
        
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
        try await client.addMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: unacceptableReaction
        ).guardSuccess()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify still doesn't have the role
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNil(role, "\(member.roles) contained '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Wait for the property below to be updated if needed
        try await Task.sleep(for: .seconds(1))
        
        /// Lifecycle still not ended
        do {
            let lifecycleEnded = await hookInfo.lifecycleEnded
            XCTAssertEqual(lifecycleEnded, false)
        }
        
        /// Delete message
        try await client.deleteMessage(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId
        ).guardSuccess()
        
        /// So the gateway event is sent and processed
        try await Task.sleep(for: .seconds(2))
        
        /// After message is deleted, lifecycle is ended
        do {
            let lifecycleEnded = await hookInfo.lifecycleEnded
            XCTAssertEqual(lifecycleEnded, true)
        }
        
        await bot.disconnect()
    }
    
    func testMessageIsInvalid() async throws {
        let bot = FakeGatewayManager(client: self.client)
        let cache = await DiscordCache(
            gatewayManager: bot,
            intents: .all,
            requestAllMembers: .enabledWithPresences
        )

        let invalidMessageId: MessageSnowflake = "1073288867911100000"
        
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
                channelId: Constants.Channels.reaction.id,
                messageId: invalidMessageId,
                reactions: [.unicodeEmoji("😜")]
            )
            XCTFail("Handler must have failed")
        } catch {
            switch error as? ReactToRoleHandler.Error {
            case .messageIsInaccessible(
                messageId: invalidMessageId,
                channelId: Constants.Channels.reaction.id,
                previousError: DiscordHTTPError.badStatusCode(_)):
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
                channelId: Constants.Channels.reaction.id,
                messageId: invalidMessageId,
                reactions: [.unicodeEmoji("😜")]
            )
            XCTFail("Handler must have failed")
        } catch {
            switch error as? ReactToRoleHandler.Error {
            case .messageIsInaccessible(
                messageId: invalidMessageId,
                channelId: Constants.Channels.reaction.id,
                previousError: DiscordHTTPError.badStatusCode(_)):
                break /// Expected error
            default:
                XCTFail("Expected 'messageIsInaccessible' error, but got: \(error)")
            }
        }
    }
    
    func testStartAndStop() async throws {
        let (bot, cache) = try await makeBotAndCache()
        
        /// Make the reaction message
        let reactionMessageId = try await client.createMessage(
            channelId: Constants.Channels.reaction.id,
            payload: .init(content: "React-To-Role test message!")
        ).decode().id
        
        let reaction = try Reaction.unicodeEmoji("✅")
        
        let hookInfo = HookInfo()
        
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
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            reactions: [reaction],
            onConfigurationChanged: { _ in Task { await hookInfo.setConfigurationChanged() } },
            onLifecycleEnd: { _ in Task { await hookInfo.setLifecycleEnded() } }
        )
        
        /// On `init`, handler will react to the message.
        /// Since I've intentionally set the app-id to a wrong app-id, the handler will
        /// try to take action on its own reaction, and give itself the role.
        
        /// To make sure the handler has enough time
        try await Task.sleep(for: .seconds(5))
        
        /// Configuration must have been changed and populated with the role id
        do {
            let configurationChanged = await hookInfo.configurationChanged
            XCTAssertEqual(configurationChanged, true)
        }
        
        /// Verify reacted
        let reactionUsers = try await client.listMessageReactionsByEmoji(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction
        ).decode()
        
        XCTAssertEqual(reactionUsers.count, 1)
        
        let user = try XCTUnwrap(reactionUsers.first)
        XCTAssertEqual(user.id, Constants.botId)
        
        /// So the cache is updated with the new member info
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify assigned the role to itself
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: {
                $0.user?.id == Constants.botId
            }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Delete the reaction, check if role is removed
        try await client.deleteOwnMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardSuccess()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(for: .seconds(2))
        
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
        try await client.addMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardSuccess()
        
        /// So the cache is updated with the new member info
        try await Task.sleep(for: .seconds(2))
        
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
        try await client.deleteOwnMessageReaction(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId,
            emoji: reaction
        ).guardSuccess()
        
        /// Start
        try await handler.restart()
        let runningState = await handler.state
        XCTAssertEqual(runningState, .running)
        
        /// So the cache is updated with the new member info
        try await Task.sleep(for: .seconds(2))
        
        do {
            /// Verify re-assigned the role to itself
            let _guild = await cache.guilds[Constants.guildId]
            let guild = try XCTUnwrap(_guild)
            let member = try XCTUnwrap(guild.members.first(where: { $0.user?.id == Constants.botId }))
            let roles = guild.roles.filter({ member.roles.contains($0.id) })
            let role = roles.first(where: { $0.name == roleName })
            XCTAssertNotNil(role, "\(member.roles) did not contain '\(roleName)' role. Member roles: \(debugDescription(roles)), all roles: \(debugDescription(guild.roles))")
        }
        
        /// Wait for the property below to be updated if needed
        try await Task.sleep(for: .seconds(1))
        
        /// Lifecycle still not ended
        do {
            let lifecycleEnded = await hookInfo.lifecycleEnded
            XCTAssertEqual(lifecycleEnded, false)
        }
        
        /// Delete message
        try await client.deleteMessage(
            channelId: Constants.Channels.reaction.id,
            messageId: reactionMessageId
        ).guardSuccess()
        
        /// So the gateway event is sent and processed
        try await Task.sleep(for: .seconds(2))
        
        /// After message is deleted, lifecycle is ended
        do {
            let lifecycleEnded = await hookInfo.lifecycleEnded
            XCTAssertEqual(lifecycleEnded, true)
        }
        
        await bot.disconnect()
    }
    
    func makeBotAndCache(
        client: (any DiscordClient)? = nil
    ) async throws -> (any GatewayManager, DiscordCache) {
        /// Make sure last tests don't affect this test's gateway connection
        try await Task.sleep(for: .seconds(5))

        let bot = BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            client: client ?? self.client,
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

        let cache = await DiscordCache(
            gatewayManager: bot,
            intents: .all,
            requestAllMembers: .enabledWithPresences
        )

        /// One unrelated test.
        /// This tests that `DiscordCache` correctly populates `guildMembersGatewayManager`.
        let _guildMembersGatewayManager = await cache.guildMembersGatewayManager
        let guildMembersGatewayManager = try XCTUnwrap(_guildMembersGatewayManager)
        XCTAssertEqual(
            ObjectIdentifier(guildMembersGatewayManager),
            ObjectIdentifier(bot)
        )
        
        let expectation = Expectation(description: "Connected")

        Task {
            for await event in await bot.makeEventsStream() {
                if case .ready = event.data {
                    expectation.fulfill()
                }
            }
        }

        /// To make sure these 2 are triggered in order
        try await Task.sleep(for: .milliseconds(200))

        bot.connect()

        await waitFulfillment(of: [expectation], timeout: 10)
        
        /// So cache is populated
        try await Task.sleep(for: .seconds(5))
        
        return (bot, cache)
    }
    
    func debugDescription(_ roles: [Role]) -> String {
        "\(roles.map({ (id: $0.id, name: $0.name) }))"
    }
}

private actor FakeGatewayManager: GatewayManager {
    nonisolated let client: any DiscordClient
    nonisolated let id: UInt = 0
    nonisolated let state: GatewayState = .stopped
    nonisolated let identifyPayload: Gateway.Identify = .init(token: "", intents: [])
    nonisolated func connect() { }
    func requestGuildMembersChunk(payload: Gateway.RequestGuildMembers) async { }
    func updatePresence(payload: Gateway.Identify.Presence) async { }
    func updateVoiceState(payload: VoiceStateUpdate) async { }
    func makeEventsStream() async -> AsyncStream<Gateway.Event> {
        AsyncStream<Gateway.Event> { _ in }
    }
    func makeEventsParseFailureStream() async -> AsyncStream<(any Error, ByteBuffer)> {
        AsyncStream<(any Error, ByteBuffer)> { _ in }
    }
    func disconnect() async { }
    
    init(client: any DiscordClient) {
        self.client = client
    }
}

private actor HookInfo {
    var configurationChanged = false
    var lifecycleEnded = false
    
    func setConfigurationChanged() {
        self.configurationChanged = true
    }
    
    func setLifecycleEnded() {
        self.lifecycleEnded = true
    }
}
