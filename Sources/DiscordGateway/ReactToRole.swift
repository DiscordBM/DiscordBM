import DiscordModels
import DiscordClient
import Logging
#if os(Linux)
@preconcurrency import Foundation
#else
import Foundation
#endif

/// Handles react-to-a-message-to-get-a-role.
public actor ReactToRoleHandler {
    
    /// This configuration must be codable-backward-compatible.
    public struct Configuration: Sendable, Codable {
        public let id: UUID
        public var createRole: RequestBody.CreateGuildRole
        public let guildId: String
        public let channelId: String
        public let messageId: String
        public let reactions: [Reaction]
        public let grantOnStart: Bool
        fileprivate(set) public var roleId: String?
        
        /// - Parameters:
        ///   - id: The unique id of this configuration.
        ///   - createRole: The role-creation payload.
        ///   - guildId: The guild-id of the message.
        ///   - channelId: The channel-id of the message.
        ///   - messageId: The message-id.
        ///   - reactions: The reactions to grant the role for.
        ///   - grantOnStart: Grant the role to those who already reacted but don't have it,
        ///     on start. **NOTE**: Only recommended if you use a `DiscordCache` with `guilds` and
        ///     `guildMembers` intents enabled. Checking each member's roles requires an API request
        ///     and if you don't provide a cache, those API requests have a chance to overwhelm
        ///     Discord's rate-limits for you app.
        ///   - roleId: The role-id, only if it's already been created.
        public init(
            id: UUID,
            createRole: RequestBody.CreateGuildRole,
            guildId: String,
            channelId: String,
            messageId: String,
            reactions: [Reaction],
            grantOnStart: Bool = false,
            roleId: String? = nil
        ) {
            self.id = id
            self.createRole = createRole
            self.guildId = guildId
            self.channelId = channelId
            self.messageId = messageId
            self.reactions = reactions
            self.grantOnStart = grantOnStart
            self.roleId = roleId
        }
        
        func hasChanges(comparedTo other: Configuration) -> Bool {
            self.roleId != other.roleId ||
            self.createRole != other.createRole
        }
    }
    
    public enum Error: Swift.Error {
        case messageIsInaccessible(messageId: String, channelId: String, previousError: Swift.Error)
        case roleIsInaccessible(id: String, previousError: Swift.Error?)
    }
    
    /// Handles the requests which can be done using either a cache (if available), or a client.
    struct RequestHandler: Sendable {
        let cache: DiscordCache?
        let client: any DiscordClient
        let logger: Logger
        let guildId: String
        
        func cacheWithIntents(_ intents: Gateway.Intent...) -> DiscordCache? {
            if let cache = cache,
               intents.allSatisfy({ cache.intents.contains($0) }) {
                return cache
            } else {
                return nil
            }
        }
        
        func getRole(id: String) async throws -> Role {
            if let cache = cacheWithIntents(.guilds) {
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
        
        func getRoleIfExists(role: RequestBody.CreateGuildRole) async throws -> Role? {
            if let cache = cacheWithIntents(.guilds) {
                if let role = await cache.guilds[guildId]?.roles.first(where: {
                    $0.name == role.name &&
                    $0.color == role.color &&
                    $0.permissions.values.sorted(by: { $0.rawValue > $1.rawValue })
                    == (role.permissions?.values ?? []).sorted(by: { $0.rawValue > $1.rawValue })
                }) {
                    return role
                } else {
                    return nil
                }
            } else {
                return try await client
                    .getGuildRoles(id: guildId)
                    .decode()
                    .first {
                        $0.name == role.name &&
                        $0.color == role.color &&
                        $0.permissions.values.sorted(by: { $0.rawValue > $1.rawValue })
                        == (role.permissions?.values ?? []).sorted(by: { $0.rawValue > $1.rawValue })
                    }
            }
        }
        
        func guildHasFeature(_ feature: Guild.Feature) async -> Bool {
            if let cache = cacheWithIntents(.guilds) {
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
        
        /// Defaults to `true` if it can't know.
        func memberHasRole(roleId: String, userId: String) async -> Bool {
            if let cache = cacheWithIntents(.guilds, .guildMembers) {
                let guild = await cache.guilds[guildId]
                return guild?.members
                    .first(where: { $0.user?.id == userId })?
                    .roles
                    .contains(roleId) ?? true
            } else {
                do {
                    return try await client.getGuildMember(guildId: guildId, userId: userId)
                        .decode()
                        .roles
                        .contains(roleId)
                } catch {
                    logger.report(error: error)
                    return true
                }
            }
        }
    }
    
    /// The state of a `ReactToRoleHandler`.
    public enum State {
        /// The instance have just been created
        case created
        /// Completely working
        case running
        /// Stopped working
        case stopped
    }
    
    let gatewayManager: any GatewayManager
    var client: any DiscordClient { gatewayManager.client }
    let requestHandler: RequestHandler
    var logger: Logger
    /// `[Reaction: Set<UserID>]`
    /// Used to remove role from members only if they have no remaining acceptable reaction
    /// the message. Also assign role only if this is their first acceptable reaction.
    var currentReactions: [Reaction: Set<String>] = [:]
    private(set) public var state = State.created
    
    /// The configuration.
    ///
    /// For persistence, you should save the `configuration` somewhere (It's `Codable`),
    /// and reload it the next time you need it.
    /// Using `onConfigurationChanged` you can get notified when `configuration` changes.
    private(set) public var configuration: Configuration {
        didSet {
            if oldValue.hasChanges(comparedTo: self.configuration) {
                self.onConfigurationChanged?(self.configuration)
            }
        }
    }
    
    let onConfigurationChanged: ((Configuration) -> Void)?
    let onLifecycleEnd: ((Configuration) -> Void)?
    
    /// - Parameters:
    ///   - gatewayManager: The `GatewayManager`/`bot` to listen for events from.
    ///   - cache: The `DiscordCache`. Preferred to have, but not necessary.
    ///   - configuration: The configuration.
    ///   - onConfigurationChanged: Hook for getting notified of configuration changes.
    ///   - onLifecycleEnd: Hook for getting notified when this handler no longer serves a purpose.
    ///     For example when the target message is deleted.
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
        await gatewayManager.addEventHandler(self.handleEvent)
        try await self.verify_populateReactions_start_react()
    }
    
    /// Note: The role will be created only if a role matching the
    /// name, color and permissions doesn't exist.
    ///
    /// - Parameters:
    ///   - gatewayManager: The `GatewayManager`/`bot` to listen for events from.
    ///   - cache: The `DiscordCache`. Preferred to have, but not necessary.
    ///   - roleName: The name of the role you want to be assigned.
    ///   - roleUnicodeEmoji: The role-emoji. Only affects guilds with the `roleIcons` feature.
    ///   - roleColor: The color of the role.
    ///   - rolePermissions: The permissions the role should have.
    ///   - guildId: The guild id.
    ///   - channelId: The channel id where the message exists.
    ///   - messageId: The message id.
    ///   - reactions: What reactions to get the role with.
    ///   - onConfigurationChanged: Hook for getting notified of configuration changes.
    ///   - onLifecycleEnd: Hook for getting notified when this handler no longer serves a purpose.
    ///     For example when the target message is deleted.
    public init(
        gatewayManager: any GatewayManager,
        cache: DiscordCache?,
        role: RequestBody.CreateGuildRole,
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
            createRole: role,
            guildId: guildId,
            channelId: channelId,
            messageId: messageId,
            reactions: reactions,
            roleId: nil
        )
        self.onConfigurationChanged = onConfigurationChanged
        self.onLifecycleEnd = onLifecycleEnd
        await gatewayManager.addEventHandler(self.handleEvent)
        try await self.verify_populateReactions_start_react()
    }
    
    /// - Parameters:
    ///   - gatewayManager: The `GatewayManager`/`bot` to listen for events from.
    ///   - cache: The `DiscordCache`. Preferred to have, but not necessary.
    ///   - existingRoleId: Existing role-id to assign.
    ///   - guildId: The guild id.
    ///   - channelId: The channel id where the message exists.
    ///   - messageId: The message id.
    ///   - reactions: What reactions to get the role with.
    ///   - onConfigurationChanged: Hook for getting notified of configuration changes.
    ///   - onLifecycleEnd: Hook for getting notified when this handler no longer serves a purpose.
    ///     For example when the target message is deleted.
    public init(
        gatewayManager: any GatewayManager,
        cache: DiscordCache?,
        existingRoleId: String,
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
        let role = try await self.requestHandler.getRole(id: existingRoleId)
        let createRole = try await RequestBody.CreateGuildRole(
            role: role,
            client: gatewayManager.client
        )
        self.configuration = .init(
            id: id,
            createRole: createRole,
            guildId: guildId,
            channelId: channelId,
            messageId: messageId,
            reactions: reactions,
            roleId: role.id
        )
        self.onConfigurationChanged = onConfigurationChanged
        self.onLifecycleEnd = onLifecycleEnd
        await gatewayManager.addEventHandler(self.handleEvent)
        try await self.verify_populateReactions_start_react()
    }
    
    /// Stop responding to gateway events.
    public func stop() {
        self.state = .stopped
    }
    
    /// Re-start responding to gateway events.
    public func restart() async throws {
        try await self.verify_populateReactions_start_react()
    }
    
    private func handleEvent(_ event: Gateway.Event) {
        guard state == .running else { return }
        switch event.data {
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
        self.state = .stopped
        self.onLifecycleEnd?(self.configuration)
    }
    
    func onReactionAdd(_ reaction: Gateway.MessageReactionAdd) {
        if reaction.message_id == self.configuration.messageId,
           reaction.guild_id == self.configuration.guildId,
           self.configuration.reactions.contains(where: { $0.is(reaction.emoji) }) {
            Task {
                do {
                    let emojiReaction = try Reaction(emoji: reaction.emoji)
                    let alreadyReacted = self.currentReactions.values
                        .contains(where: { $0.contains(reaction.user_id) })
                    self.currentReactions[emojiReaction, default: []].insert(reaction.user_id)
                    if !alreadyReacted {
                        await self.addRoleToMember(userId: reaction.user_id)
                    }
                } catch {
                    logger.report(error: error)
                }
            }
        }
    }
    
    func onReactionRemove(_ reaction: Gateway.MessageReactionRemove) {
        if reaction.message_id == self.configuration.messageId,
           reaction.guild_id == self.configuration.guildId,
           self.configuration.reactions.contains(where: { $0.is(reaction.emoji) }),
           self.configuration.roleId != nil {
            Task {
                do {
                    let emojiReaction = try Reaction(emoji: reaction.emoji)
                    if let idx = self.currentReactions[emojiReaction]?
                        .firstIndex(of: reaction.user_id) {
                        self.currentReactions[emojiReaction]?.remove(at: idx)
                    }
                    /// If there is no acceptable reaction remaining, remove the role from the user.
                    if !currentReactions.values.contains(where: { $0.contains(reaction.user_id) }) {
                        await self.removeRoleFromMember(userId: reaction.user_id)
                    }
                } catch {
                    logger.report(error: error)
                }
            }
        }
    }
    
    func onRoleCreate(_ role: Gateway.GuildRole) {
        if self.configuration.roleId == nil,
           role.guild_id == self.configuration.guildId,
           role.role.name == self.configuration.createRole.name {
            Task {
                do {
                    self.configuration.createRole = try await .init(
                        role: role.role,
                        client: client
                    )
                    self.configuration.roleId = role.role.id
                } catch {
                    logger.report(error: error)
                }
            }
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
    
    func getRoleId() async -> String? {
        var roleId = self.configuration.roleId
        if roleId == nil {
            await self.setOrCreateRole()
            roleId = self.configuration.roleId
        }
        return roleId
    }
    
    func addRoleToMember(userId: String) async {
        guard userId != client.appId else { return }
        guard let roleId = await getRoleId() else {
            self.logger.warning("Can't get a role to grant the member", metadata: [
                "userId": .string(userId)
            ])
            return
        }
        await self.addRoleToMember(roleId: roleId, userId: userId)
    }
    
    func addRoleToMember(roleId: String, userId: String) async {
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
                role: self.configuration.createRole
            ) {
                self.configuration.createRole = try await .init(
                    role: role,
                    client: client
                )
                self.configuration.roleId = role.id
            } else {
                await createRole()
            }
        } catch {
            self.logger.report(error: error)
        }
    }
    
    func createRole() async {
        var role = self.configuration.createRole
        if await !requestHandler.guildHasFeature(.roleIcons) {
            role.unicode_emoji = nil
            role.icon = nil
        }
        do {
            let role = try await client.createGuildRole(
                guildId: self.configuration.guildId,
                payload: role
            ).decode()
            self.configuration.createRole = try await .init(
                role: role,
                client: client
            )
            self.configuration.roleId = role.id
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
    
    func verify_populateReactions_start_react() async throws {
        /// Verify message exists
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
        /// Populate reactions
        for reaction in self.configuration.reactions {
            let reactionsUsers = try await client.getReactions(
                channelId: self.configuration.channelId,
                messageId: self.configuration.messageId,
                emoji: reaction
            ).decode()
            self.currentReactions[reaction] = Set(reactionsUsers.map(\.id))
        }
        /// Start taking action on Gateway events
        self.state = .running
        /// React to message
        let me = message.reactions?.filter(\.me).map(\.emoji) ?? []
        let remaining = configuration.reactions.filter { reaction in
            !me.contains(where: { reaction.is($0) })
        }
        for reaction in remaining {
            do {
                try await client.createReaction(
                    channelId: self.configuration.channelId,
                    messageId: self.configuration.messageId,
                    emoji: reaction
                ).guardIsSuccessfulResponse()
            } catch {
                self.logger.report(error: error)
            }
        }
        /// If members don't have the role, give it to them
        if configuration.grantOnStart,
            let roleId = await getRoleId() {
            let users = self.currentReactions.values
                .reduce(into: Set<String>(), { $0.formUnion($1) })
            for user in users {
                if await !requestHandler.memberHasRole(roleId: roleId, userId: user) {
                    await self.addRoleToMember(roleId: roleId, userId: user)
                }
            }
        }
    }
}

//MARK: + Logger
private extension Logger {
    func report(error: Error, function: String = #function, line: UInt = #line) {
        self.error("'ReactToRoleHandler' failed", metadata: [
            "error": "\(error)"
        ], function: function, line: line)
    }
}

//MARK: + CreateGuildRole
private extension RequestBody.CreateGuildRole {
    init(role: Role, client: any DiscordClient) async throws {
        self = .init(
            name: role.name,
            permissions: Array(role.permissions.values),
            color: role.color,
            hoist: role.hoist,
            icon: nil,
            unicode_emoji: role.unicode_emoji,
            mentionable: role.mentionable
        )
        if let icon = role.icon {
            let file = try await client.getCDNRoleIcon(
                roleId: role.id,
                icon: icon
            ).getFile()
            self.icon = .init(file: file)
        }
    }
    
    static func != (lhs: Self, rhs: Self) -> Bool {
        !(lhs.name == rhs.name &&
          (lhs.permissions?.values ?? []).sorted(by: { $0.rawValue > $1.rawValue })
          == (rhs.permissions?.values ?? []).sorted(by: { $0.rawValue > $1.rawValue }) &&
          lhs.color == rhs.color &&
          lhs.hoist == rhs.hoist &&
          lhs.icon?.file.data == rhs.icon?.file.data &&
          lhs.icon?.file.filename == rhs.icon?.file.filename &&
          lhs.unicode_emoji == rhs.unicode_emoji &&
          lhs.mentionable == rhs.mentionable)
    }
}
