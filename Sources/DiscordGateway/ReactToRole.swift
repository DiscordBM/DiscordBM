import DiscordModels
import DiscordClient
import Logging
#if os(Linux)
@preconcurrency import Foundation
#else
import Foundation
#endif

public actor ReactToRoleHandler {
    
#warning("Swift 5.6 / 5.7 have different codable behaviors ?!")
    public enum Reaction: Sendable, Equatable, Codable {
        case unicodeEmoji(String)
        case guildEmoji(name: String, id: String)
        
        var urlPathDescription: String {
            switch self {
            case let .unicodeEmoji(emoji): return emoji
            case let .guildEmoji(name, id): return "\(name):\(id)"
            }
        }
        
        func `is`(_ emoji: PartialEmoji) -> Bool {
            switch self {
            case let .unicodeEmoji(unicode): return unicode == emoji.name
            case let .guildEmoji(_, id): return id == emoji.id
            }
        }
    }
    
    /// This configuration must be codable-backward-compatible.
    public struct Configuration: Sendable, Codable, Equatable {
        public let id: UUID
        public let roleName: String
        public let roleUnicodeEmoji: String?
        public let roleColor: DiscordColor
        public let guildId: String
        public let channelId: String
        public let messageId: String
        public let reactions: [Reaction]
        fileprivate(set) public var roleId: String?
        
        public init(
            id: UUID,
            roleName: String,
            roleUnicodeEmoji: String? = nil,
            roleColor: DiscordColor,
            guildId: String,
            channelId: String,
            messageId: String,
            reactions: [Reaction],
            roleId: String? = nil
        ) {
            self.id = id
            self.roleName = roleName
            self.roleUnicodeEmoji = roleUnicodeEmoji
            self.roleColor = roleColor
            self.guildId = guildId
            self.channelId = channelId
            self.messageId = messageId
            self.reactions = reactions
            self.roleId = roleId
        }
        
        func hasChanges(comparedTo other: Configuration) -> Bool {
            self.roleId != other.roleId
        }
        
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
        case messageIsInaccessible(messageId: String, channelId: String, previousError: Swift.Error)
        case roleIsInaccessible(id: String, previousError: Swift.Error?)
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
                    throw Error.roleIsInaccessible(id: id, previousError: nil)
                }
            } else {
                do {
                    if let role = try await client
                        .getGuildRoles(id: guildId)
                        .decode()
                        .first(where: { $0.id == id }) {
                        return role
                    } else {
                        throw Error.roleIsInaccessible(id: id, previousError: nil)
                    }
                } catch {
                    throw Error.roleIsInaccessible(id: id, previousError: error)
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
    
    let gatewayManager: any GatewayManager
    var client: any DiscordClient { gatewayManager.client }
    let requestHandler: RequestHandler
    var logger: Logger
    private(set) var configuration: Configuration {
        didSet {
            if oldValue.hasChanges(comparedTo: self.configuration) {
                self.onConfigurationChanged?(self.configuration)
            }
        }
    }
    
    let onConfigurationChanged: ((Configuration) -> Void)?
    let onLifecycleEnd: ((Configuration) -> Void)?
    
    public init(
        gatewayManager: any GatewayManager,
        cache: DiscordCache?,
        configuration: Configuration,
        onConfigurationChanged: ((Configuration) -> Void)? = nil,
        onLifecycleEnd: ((Configuration) -> Void)? = nil
    ) async throws {
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
        self.onConfigurationChanged = onConfigurationChanged
        self.onLifecycleEnd = onLifecycleEnd
        try await self.verifyAndReactToMessage()
    }
    
    public init(
        gatewayManager: any GatewayManager,
        cache: DiscordCache?,
        roleName: String,
        roleUnicodeEmoji: String? = nil,
        roleColor: DiscordColor,
        guildId: String,
        channelId: String,
        messageId: String,
        reactions: [Reaction],
        onConfigurationChanged: ((Configuration) -> Void)? = nil,
        onLifecycleEnd: ((Configuration) -> Void)? = nil
    ) async throws {
        self.gatewayManager = gatewayManager
        let id = UUID()
        self.logger = DiscordGlobalConfiguration.makeLogger("ReactToRole")
        logger[metadataKey: "id"] = "\(id.uuidString)"
        self.requestHandler = .init(
            cache: cache,
            client: gatewayManager.client,
            logger: logger,
            guildId: guildId
        )
        self.configuration = .init(
            id: id,
            roleName: roleName,
            roleUnicodeEmoji: roleUnicodeEmoji,
            roleColor: roleColor,
            guildId: guildId,
            channelId: channelId,
            messageId: messageId,
            reactions: reactions,
            roleId: nil
        )
        self.onConfigurationChanged = onConfigurationChanged
        self.onLifecycleEnd = onLifecycleEnd
        try await self.verifyAndReactToMessage()
    }
    
    public init(
        gatewayManager: any GatewayManager,
        cache: DiscordCache?,
        configuration: Configuration,
        guildId: String,
        channelId: String,
        messageId: String,
        reactions: [Reaction],
        existingRoleId: String,
        onConfigurationChanged: ((Configuration) -> Void)? = nil,
        onLifecycleEnd: ((Configuration) -> Void)? = nil
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
        self.onConfigurationChanged = onConfigurationChanged
        self.onLifecycleEnd = onLifecycleEnd
        try await self.verifyAndReactToMessage()
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
    
    func endLifecycle() {
        self.onLifecycleEnd?(self.configuration)
    }
    
    func onReactionAdd(_ reaction: Gateway.MessageReactionAdd) {
        if reaction.message_id == self.configuration.messageId,
           reaction.guild_id == self.configuration.guildId,
           self.configuration.reactions.contains(where: { $0.is(reaction.emoji) }) {
            Task {
                await self.addRoleToMember(userId: reaction.user_id)
            }
        }
    }
    
    func onReactionRemove(_ reaction: Gateway.MessageReactionRemove) {
        if reaction.message_id == self.configuration.messageId,
           reaction.guild_id == self.configuration.guildId,
           self.configuration.reactions.contains(where: { $0.is(reaction.emoji) }),
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
        }
    }
    
    func onRoleDelete(_ role: Gateway.GuildRoleDelete) {
        if let roleId = self.configuration.roleId,
           role.guild_id == self.configuration.guildId,
           role.role_id == roleId {
            self.configuration.roleId = nil
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
    
    func verifyAndReactToMessage() async throws {
        let message: Gateway.MessageCreate
        do {
            message = try await client.getChannelMessage(
                channelId: configuration.channelId,
                messageId: configuration.messageId
            ).decode()
        } catch {
            throw Error.messageIsInaccessible(
                messageId: configuration.messageId,
                channelId: configuration.channelId,
                previousError: error
            )
        }
        let me = message.reactions?.filter(\.me).map(\.emoji) ?? []
        let remaining = configuration.reactions.filter { reaction in
            !me.contains(where: { reaction.is($0) })
        }
        for reaction in remaining {
            do {
                try await client.createReaction(
                    channelId: self.configuration.channelId,
                    messageId: self.configuration.messageId,
                    emoji: reaction.urlPathDescription
                ).guardIsSuccessfulResponse()
            } catch {
                self.logger.report(error: error)
            }
        }
    }
}

private extension Logger {
    func report(error: Error, function: String = #function, line: UInt = #line) {
        self.error("'ReactToRoleHandler' failed", metadata: [
            "error": "\(error)"
        ], function: function, line: line)
    }
}
