import DiscordModels
import Logging
import Foundation

public actor ReactToRoleHandler {
    
    public struct Configuration: Sendable, Codable, Equatable {
        public let id: UUID
        public let roleName: String
        public let roleUnicodeEmoji: String?
        public let roleColor: DiscordColor?
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
    
    var gatewayManager: any GatewayManager
    var cache: DiscordCache
    var logger: Logger
    var configuration: Configuration
    
    let onRoleIdChanged: ((UUID, String?) -> Void)?
    let onLifecycleEnd: ((UUID) -> Void)?
    
    public init(
        gatewayManager: any GatewayManager,
        cache: DiscordCache,
        configuration: Configuration,
        onRoleIdChanged: ((UUID, String?) -> Void)?,
        onLifecycleEnd: ((UUID) -> Void)?
    ) async {
        self.gatewayManager = gatewayManager
        self.cache = cache
        self.logger = DiscordGlobalConfiguration.makeLogger("ReactToRole")
        logger[metadataKey: "id"] = "\(configuration.id.uuidString)"
        self.configuration = configuration
        self.onRoleIdChanged = onRoleIdChanged
        self.onLifecycleEnd = onLifecycleEnd
    }
    
    public init(
        gatewayManager: any GatewayManager,
        cache: DiscordCache,
        configuration: Configuration,
        roleName: String,
        roleUnicodeEmoji: String,
        roleColor: DiscordColor? = nil,
        guildId: String,
        channelId: String,
        messageId: String,
        reactions: [String],
        preferredRoleId: String? = nil,
        onRoleIdChanged: ((UUID, String?) -> Void)? = nil,
        onLifecycleEnd: ((UUID) -> Void)? = nil
    ) async {
        self.gatewayManager = gatewayManager
        self.cache = cache
        self.logger = DiscordGlobalConfiguration.makeLogger("ReactToRole")
        logger[metadataKey: "id"] = "\(configuration.id.uuidString)"
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
        if let preferredRoleId,
           await cache.guilds[guildId]?
            .roles.contains(where: { $0.id == preferredRoleId }) == true {
            self.configuration.roleId = preferredRoleId
        }
        self.onRoleIdChanged = onRoleIdChanged
        self.onLifecycleEnd = onLifecycleEnd
        for reaction in reactions {
            self.reactToMessage(emoji: reaction)
        }
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
        guard userId != gatewayManager.client.appId else { return }
        var _roleId: String? = nil
        if let __roleId = self.configuration.roleId {
            _roleId = __roleId
        } else {
            await self.setOrCreateRole()
            if let __roleId = self.configuration.roleId {
                _roleId = __roleId
            }
        }
        guard let roleId = _roleId else {
            self.logger.warning("Can't get a role to grant the member")
            return
        }
        do {
            try await gatewayManager.client.addGuildMemberRole(
                guildId: self.configuration.guildId,
                userId: userId,
                roleId: roleId
            ).guardIsSuccessfulResponse()
        } catch {
            self.logger.report(error: error)
        }
    }
    
    func setOrCreateRole() async {
        if let role = await cache.guilds[self.configuration.guildId]?.roles.first(
            where: { $0.name == self.configuration.roleName }
        ) {
            self.configuration.roleId = role.id
            self.onRoleIdChanged?(self.configuration.id, role.id)
        } else {
            await createRole()
        }
    }
    
    func createRole() async {
        let hasFeature = await cache.guilds[self.configuration.guildId]?.features.contains(.roleIcons) == true
        let unicodeEmoji = hasFeature ? self.configuration.roleUnicodeEmoji : nil
        do {
            let result = try await gatewayManager.client.createGuildRole(
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
        guard userId != gatewayManager.client.appId,
              let roleId = self.configuration.roleId
        else { return }
        do {
            try await gatewayManager.client.removeGuildMemberRole(
                guildId: self.configuration.guildId,
                userId: userId,
                roleId: roleId
            ).guardIsSuccessfulResponse()
        } catch {
            self.logger.report(error: error)
        }
    }
    
    func reactToMessage(emoji: String) {
        Task {
            do {
                try await gatewayManager.client.addReaction(
                    channelId: self.configuration.channelId,
                    messageId: self.configuration.messageId,
                    emoji: emoji
                ).guardIsSuccessfulResponse()
            } catch {
                self.logger.report(error: error)
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
