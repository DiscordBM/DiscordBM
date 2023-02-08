import DiscordModels
import DiscordClient
import Logging
import Foundation

public actor ReactToRoleHandler {
    
    public struct Configuration: Sendable, Codable, Equatable {
        public let id: UUID
        public let roleName: String
        public let roleUnicodeEmoji: String?
        public let roleColor: DiscordColor
        public let guildId: String
        public let channelId: String
        public let messageId: String
        public let reactions: [String]
        fileprivate(set) public var roleId: String?
        
        public static func == (lhs: Configuration, rhs: Configuration) -> Bool {
            lhs.roleName == rhs.roleName &&
            lhs.roleUnicodeEmoji == rhs.roleUnicodeEmoji &&
            lhs.guildId == rhs.guildId &&
            lhs.channelId == rhs.channelId &&
            lhs.messageId == rhs.messageId &&
            lhs.reactions == rhs.reactions
        }
    }
    
    public enum Error: Swift.Error {
        case roleDoesNotExist(id: String)
    }
    
    struct RequestHandler: Sendable {
        let cache: DiscordCache?
        let client: any DiscordClient
        let logger: Logger
        let guildId: String
        
        
        func getRole(id: String) async throws -> Role {
            if let cache = cache,
               cache.intents.contains(.guilds) {
                if let role = await cache.guilds[guildId]?.roles.first(where: { $0.id == id }) {
                    return role
                } else {
                    throw Error.roleDoesNotExist(id: id)
                }
            } else {
                if let role = try await client
                    .getGuildRoles(id: guildId)
                    .decode()
                    .first(where: { $0.id == id }) {
                    return role
                } else {
                    throw Error.roleDoesNotExist(id: id)
                }
            }
        }
        
        func getRoleIfExists(name: String, color: DiscordColor) async throws -> Role? {
            if let cache = cache,
               cache.intents.contains(.guilds) {
                if let role = await cache.guilds[guildId]?.roles.first(where: {
                    $0.name == name && $0.color == color
                }) {
                    return role
                } else {
                    return nil
                }
            } else {
                return try await client
                    .getGuildRoles(id: guildId)
                    .decode()
                    .first { $0.name == name && $0.color == color }
            }
        }
        
        func guildHasFeature(_ feature: Guild.Feature) async -> Bool {
            if let cache = cache {
               let guild = await cache.guilds[guildId]
                return guild?.features.contains(feature) ?? false
            } else {
                do {
                    return try await client
                        .getGuild(id: guildId)
                        .decode()
                        .features
                        .contains(feature)
                } catch {
                    logger.report(error: error)
                    return false
                }
            }
        }
    }
    
    var gatewayManager: any GatewayManager
    var client: any DiscordClient { gatewayManager.client }
    let requestHandler: RequestHandler
    var logger: Logger
    var configuration: Configuration
    
    let onRoleIdChanged: ((UUID, String?) -> Void)?
    let onLifecycleEnd: ((UUID) -> Void)?
    
    public init(
        gatewayManager: any GatewayManager,
        cache: DiscordCache?,
        configuration: Configuration,
        onRoleIdChanged: ((UUID, String?) -> Void)?,
        onLifecycleEnd: ((UUID) -> Void)?
    ) async {
        self.gatewayManager = gatewayManager
        self.logger = DiscordGlobalConfiguration.makeLogger("ReactToRole")
        logger[metadataKey: "id"] = "\(configuration.id.uuidString)"
        self.requestHandler = .init(
            cache: cache,
            client: gatewayManager.client,
            logger: logger,
            guildId: configuration.guildId
        )
        self.configuration = configuration
        self.onRoleIdChanged = onRoleIdChanged
        self.onLifecycleEnd = onLifecycleEnd
        self.reactToMessage()
    }
    
    public init(
        gatewayManager: any GatewayManager,
        cache: DiscordCache,
        configuration: Configuration,
        roleName: String,
        roleUnicodeEmoji: String,
        roleColor: DiscordColor,
        guildId: String,
        channelId: String,
        messageId: String,
        reactions: [String],
        onRoleIdChanged: ((UUID, String?) -> Void)? = nil,
        onLifecycleEnd: ((UUID) -> Void)? = nil
    ) async {
        self.gatewayManager = gatewayManager
        self.logger = DiscordGlobalConfiguration.makeLogger("ReactToRole")
        logger[metadataKey: "id"] = "\(configuration.id.uuidString)"
        self.requestHandler = .init(
            cache: cache,
            client: gatewayManager.client,
            logger: logger,
            guildId: guildId
        )
        self.configuration = .init(
            id: UUID(),
            roleName: roleName,
            roleUnicodeEmoji: roleUnicodeEmoji,
            roleColor: roleColor,
            guildId: guildId,
            channelId: channelId,
            messageId: messageId,
            reactions: reactions,
            roleId: nil
        )
        self.onRoleIdChanged = onRoleIdChanged
        self.onLifecycleEnd = onLifecycleEnd
        self.reactToMessage()
    }
    
    public init(
        gatewayManager: any GatewayManager,
        cache: DiscordCache,
        configuration: Configuration,
        guildId: String,
        channelId: String,
        messageId: String,
        reactions: [String],
        existingRoleId: String,
        onRoleIdChanged: ((UUID, String?) -> Void)? = nil,
        onLifecycleEnd: ((UUID) -> Void)? = nil
    ) async throws {
        self.gatewayManager = gatewayManager
        self.logger = DiscordGlobalConfiguration.makeLogger("ReactToRole")
        logger[metadataKey: "id"] = "\(configuration.id.uuidString)"
        self.requestHandler = .init(
            cache: cache,
            client: gatewayManager.client,
            logger: logger,
            guildId: guildId
        )
        let role = try await self.requestHandler.getRole(id: existingRoleId)
        self.configuration = .init(
            id: UUID(),
            roleName: role.name,
            roleUnicodeEmoji: role.unicode_emoji,
            roleColor: role.color,
            guildId: guildId,
            channelId: channelId,
            messageId: messageId,
            reactions: reactions,
            roleId: nil
        )
        self.onRoleIdChanged = onRoleIdChanged
        self.onLifecycleEnd = onLifecycleEnd
        self.reactToMessage()
    }
    
    func onGatewayEventPayload(_ data: Gateway.Event.Payload) {
        switch data {
        case let .messageReactionAdd(payload):
            self.onReactionAdd(payload)
        case let .messageReactionRemove(payload):
            self.onReactionRemove(payload)
        case let .guildRoleCreate(payload):
            self.onRoleCreate(payload)
        case let .guildRoleDelete(payload):
            self.onRoleDelete(payload)
        case let .messageDelete(payload):
            self.onMessageDelete(payload)
        case let .guildDelete(payload):
            self.onGuildDelete(payload)
        default: break
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.configuration.id)
    }
    
    func endLifecycle() {
        self.onRoleIdChanged?(self.configuration.id, nil)
        self.onLifecycleEnd?(self.configuration.id)
    }
    
    func onReactionAdd(_ reaction: Gateway.MessageReactionAdd) {
        if reaction.message_id == self.configuration.messageId,
           reaction.guild_id == self.configuration.guildId,
           let reactionName = reaction.emoji.name,
           self.configuration.reactions.contains(reactionName) {
            Task {
                await self.addRoleToMember(userId: reaction.user_id)
            }
        }
    }
    
    func onReactionRemove(_ reaction: Gateway.MessageReactionRemove) {
        if reaction.message_id == self.configuration.messageId,
           reaction.guild_id == self.configuration.guildId,
           let reactionName = reaction.emoji.name,
           self.configuration.reactions.contains(reactionName),
           self.configuration.roleId != nil {
            Task {
                await self.removeRoleFromMember(userId: reaction.user_id)
            }
        }
    }
    
    func onRoleCreate(_ role: Gateway.GuildRole) {
        if self.configuration.roleId == nil,
           role.guild_id == self.configuration.guildId,
           role.role.name == self.configuration.roleName {
            self.configuration.roleId = role.role.id
            self.onRoleIdChanged?(self.configuration.id, role.role.id)
        }
    }
    
    func onRoleDelete(_ role: Gateway.GuildRoleDelete) {
        if let roleId = self.configuration.roleId,
           role.guild_id == self.configuration.guildId,
           role.role_id == roleId {
            self.configuration.roleId = nil
            self.onRoleIdChanged?(self.configuration.id, nil)
        }
    }
    
    func onMessageDelete(_ message: Gateway.MessageDelete) {
        if message.id == self.configuration.messageId,
           message.channel_id == self.configuration.channelId,
           message.guild_id == self.configuration.guildId {
            self.endLifecycle()
        }
    }
    
    func onGuildDelete(_ guild: UnavailableGuild) {
        if guild.id == self.configuration.guildId {
            self.endLifecycle()
        }
    }
    
    func addRoleToMember(userId: String) async {
        guard userId != client.appId else { return }
        var _roleId = self.configuration.roleId
        if _roleId == nil {
            await self.setOrCreateRole()
            _roleId = self.configuration.roleId
        }
        guard let roleId = _roleId else {
            self.logger.warning("Can't get a role to grant the member", metadata: [
                "userId": .string(userId)
            ])
            return
        }
        do {
            try await client.addGuildMemberRole(
                guildId: self.configuration.guildId,
                userId: userId,
                roleId: roleId
            ).guardIsSuccessfulResponse()
        } catch {
            self.logger.report(error: error)
        }
    }
    
    func setOrCreateRole() async {
        do {
            if let role = try await requestHandler.getRoleIfExists(
                name: self.configuration.roleName,
                color: self.configuration.roleColor
            ) {
                self.configuration.roleId = role.id
                self.onRoleIdChanged?(self.configuration.id, role.id)
            } else {
                await createRole()
            }
        } catch {
            self.logger.report(error: error)
        }
    }
    
    func createRole() async {
        let hasFeature = await requestHandler.guildHasFeature(.roleIcons)
        let unicodeEmoji = hasFeature ? self.configuration.roleUnicodeEmoji : nil
        do {
            let result = try await client.createGuildRole(
                guildId: self.configuration.guildId,
                payload: .init(
                    name: self.configuration.roleName,
                    color: self.configuration.roleColor,
                    unicode_emoji: unicodeEmoji,
                    mentionable: true
                )
            )
            self.configuration.roleId = try result.decode().id
        } catch {
            self.logger.report(error: error)
        }
    }
    
    func removeRoleFromMember(userId: String) async {
        guard userId != client.appId,
              let roleId = self.configuration.roleId
        else { return }
        do {
            try await client.removeGuildMemberRole(
                guildId: self.configuration.guildId,
                userId: userId,
                roleId: roleId
            ).guardIsSuccessfulResponse()
        } catch {
            self.logger.report(error: error)
        }
    }
    
    func reactToMessage() {
        Task { [self] in
            let message: Gateway.MessageCreate
            do {
                message = try await client.getChannelMessage(
                    channelId: configuration.channelId,
                    messageId: configuration.messageId
                ).decode()
            } catch {
                self.logger.report(error: error)
                return
            }
            let me = message.reactions?.filter(\.me).map(\.emoji) ?? []
            let remaining = configuration.reactions.filter { reaction in
                !me.contains { emoji in
                    if let name = emoji.name {
                        if name == reaction {
                            return true
                        }
                        if let id = emoji.id, "\(name):\(id)" == reaction {
                            return true
                        }
                    }
                    return false
                }
            }
            for reaction in remaining {
                do {
                    try await client.addReaction(
                        channelId: self.configuration.channelId,
                        messageId: self.configuration.messageId,
                        emoji: reaction
                    ).guardIsSuccessfulResponse()
                } catch {
                    self.logger.report(error: error)
                }
            }
        }
    }
}

private extension Logger {
    func report(error: Error, function: String = #function, line: UInt = #line) {
        self.error("ReactToRoleHandler failed", metadata: [
            "error": "\(error)"
        ], function: function, line: line)
    }
}
