import DiscordModels
import DiscordHTTP
import Logging
#if os(Linux)
@preconcurrency import Foundation
#else
import Foundation
#endif

/// Handles react-to-message-to-get-a-role.
public actor ReactToRoleHandler {
    
    /// This configuration must be codable-backward-compatible.
    public struct Configuration: Sendable, Codable {
        public let id: UUID
        public var createRole: Payloads.GuildRole
        public let guildId: GuildSnowflake
        public let channelId: ChannelSnowflake
        public let messageId: MessageSnowflake
        public let reactions: Set<Reaction>
        public let grantOnStart: Bool
        public fileprivate(set) var roleId: RoleSnowflake?
        
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
        ///     Discord's rate-limits of you app.
        ///   - roleId: The role-id, only if it's already been created.
        public init(
            id: UUID = UUID(),
            createRole: Payloads.GuildRole,
            guildId: GuildSnowflake,
            channelId: ChannelSnowflake,
            messageId: MessageSnowflake,
            reactions: Set<Reaction>,
            grantOnStart: Bool = false,
            roleId: RoleSnowflake? = nil
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
    
    /// Read `helpAnchor` for help about each error case.
    public enum Error: LocalizedError {
        case messageIsInaccessible(
            messageId: MessageSnowflake,
            channelId: ChannelSnowflake,
            previousError: Swift.Error
        )
        case roleIsInaccessible(id: RoleSnowflake, previousError: Swift.Error?)
        
        public var errorDescription: String? {
            switch self {
            case let .messageIsInaccessible(messageId, channelId, previousError):
                return "ReactToRoleHandler.Error.messageIsInaccessible(messageId: \(messageId), channelId: \(channelId), previousError: \(previousError))"
            case let .roleIsInaccessible(id, previousError):
                return "ReactToRoleHandler.Error.roleIsInaccessible(id: \(id), previousError: \(String(describing: previousError)))"
            }
        }
        
        public var helpAnchor: String? {
            switch self {
            case let .messageIsInaccessible(messageId, channelId, previousError):
                return "Can't access a message with id '\(messageId)' in channel '\(channelId)'. This could be because the message doesn't exist or the bot doesn't have enough permissions to see it. Previous error: \(previousError)"
            case let .roleIsInaccessible(id, previousError):
                return "Can't access a role with id '\(id)'. This could be because the role doesn't exist or the bot doesn't have enough permissions to see it. Previous error: \(String(describing: previousError))"
            }
        }
    }
    
    /// Handles the requests which can be done using either a cache (if available), or a client.
    struct RequestHandler: Sendable {
        let cache: DiscordCache?
        let client: any DiscordClient
        let logger: Logger
        let guildId: GuildSnowflake
        let guildMembersEnabled: Bool
        
        init(
            cache: DiscordCache?,
            client: any DiscordClient,
            logger: Logger,
            guildId: GuildSnowflake
        ) {
            self.cache = cache
            self.client = client
            self.logger = logger
            self.guildId = guildId
            self.guildMembersEnabled = cache?.requestMembers.isEnabled(for: guildId) ?? false
        }
        
        func cacheWithIntents(_ intents: Gateway.Intent...) -> DiscordCache? {
            if let cache,
               intents.allSatisfy({ cache.intents.contains($0) }) {
                return cache
            } else {
                return nil
            }
        }
        
        func getRole(id: RoleSnowflake) async throws -> Role {
            if let cache = cacheWithIntents(.guilds) {
                if let role = await cache.guilds[guildId]?.roles.first(where: { $0.id == id }) {
                    return role
                } else {
                    throw Error.roleIsInaccessible(id: id, previousError: nil)
                }
            } else {
                do {
                    if let role = try await client
                        .listGuildRoles(id: guildId)
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
        
        func getRoleIfExists(role: Payloads.GuildRole) async throws -> Role? {
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
                    .listGuildRoles(id: guildId)
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
        func memberHasRole(roleId: RoleSnowflake, userId: UserSnowflake) async -> Bool {
            if self.guildMembersEnabled,
               let cache = cacheWithIntents(.guilds, .guildMembers) {
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
    public enum State: Sendable {
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
    /// Used to remove role from members only if they have no remaining acceptable reaction
    /// the message. Also assign role only if this is their first acceptable reaction.
    var currentReactions: [Reaction: Set<UserSnowflake>] = [:]
    /// To avoid role-creation race-conditions
    var lockedCreatingRole = false
    private(set) public var state = State.created
    
    /// The configuration.
    ///
    /// For persistence, you should save the `configuration` somewhere (It's `Codable`),
    /// and reload it the next time you need it.
    /// Using `onConfigurationChanged` you can get notified when `configuration` changes.
    private(set) public var configuration: Configuration {
        didSet {
            if oldValue.hasChanges(comparedTo: self.configuration) {
                Task {
                    await self.onConfigurationChanged?(self.configuration)
                }
            }
        }
    }
    
    let onConfigurationChanged: ((Configuration) async -> Void)?
    let onLifecycleEnd: ((Configuration) async -> Void)?
    
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
        onConfigurationChanged: (@Sendable (Configuration) async -> Void)? = nil,
        onLifecycleEnd: (@Sendable (Configuration) async -> Void)? = nil
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
        Task {
            for await event in await gatewayManager.makeEventsStream() {
                self.handleEvent(event)
            }
        }
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
    ///   - grantOnStart: Grant the role to those who already reacted but don't have it,
    ///     on start. **NOTE**: Only recommended if you use a `DiscordCache` with `guilds` and
    ///     `guildMembers` intents enabled. Checking each member's roles requires an API request
    ///     and if you don't provide a cache, those API requests have a chance to overwhelm
    ///     Discord's rate-limits for you app.
    ///   - reactions: What reactions to get the role with.
    ///   - onConfigurationChanged: Hook for getting notified of configuration changes.
    ///   - onLifecycleEnd: Hook for getting notified when this handler no longer serves a purpose.
    ///     For example when the target message is deleted.
    public init(
        gatewayManager: any GatewayManager,
        cache: DiscordCache?,
        role: Payloads.GuildRole,
        guildId: GuildSnowflake,
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        grantOnStart: Bool = false,
        reactions: Set<Reaction>,
        onConfigurationChanged: (@Sendable (Configuration) async -> Void)? = nil,
        onLifecycleEnd: (@Sendable (Configuration) async -> Void)? = nil
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
            grantOnStart: grantOnStart,
            roleId: nil
        )
        self.onConfigurationChanged = onConfigurationChanged
        self.onLifecycleEnd = onLifecycleEnd
        Task {
            for await event in await gatewayManager.makeEventsStream() {
                self.handleEvent(event)
            }
        }
        try await self.verify_populateReactions_start_react()
    }
    
    /// - Parameters:
    ///   - gatewayManager: The `GatewayManager`/`bot` to listen for events from.
    ///   - cache: The `DiscordCache`. Preferred to have, but not necessary.
    ///   - existingRoleId: Existing role-id to assign.
    ///   - guildId: The guild id.
    ///   - channelId: The channel id where the message exists.
    ///   - messageId: The message id.
    ///   - grantOnStart: Grant the role to those who already reacted but don't have it,
    ///     on start. **NOTE**: Only recommended if you use a `DiscordCache` with `guilds` and
    ///     `guildMembers` intents enabled. Checking each member's roles requires an API request
    ///     and if you don't provide a cache, those API requests have a chance to overwhelm
    ///     Discord's rate-limits for you app.
    ///   - reactions: What reactions to get the role with.
    ///   - onConfigurationChanged: Hook for getting notified of configuration changes.
    ///   - onLifecycleEnd: Hook for getting notified when this handler no longer serves a purpose.
    ///     For example when the target message is deleted.
    public init(
        gatewayManager: any GatewayManager,
        cache: DiscordCache?,
        existingRoleId: RoleSnowflake,
        guildId: GuildSnowflake,
        channelId: ChannelSnowflake,
        messageId: MessageSnowflake,
        grantOnStart: Bool = false,
        reactions: Set<Reaction>,
        onConfigurationChanged: (@Sendable (Configuration) async -> Void)? = nil,
        onLifecycleEnd: (@Sendable (Configuration) async -> Void)? = nil
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
        let createRole = try await Payloads.GuildRole(
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
            grantOnStart: grantOnStart,
            roleId: role.id
        )
        self.onConfigurationChanged = onConfigurationChanged
        self.onLifecycleEnd = onLifecycleEnd
        Task {
            for await event in await gatewayManager.makeEventsStream() {
                self.handleEvent(event)
            }
        }
        try await self.verify_populateReactions_start_react()
    }
    
    private func handleEvent(_ event: Gateway.Event) {
        guard self.state == .running else { return }
        switch event.data {
        case let .messageReactionAdd(payload):
            self.onReactionAdd(payload)
        case let .messageReactionRemove(payload):
            self.onReactionRemove(payload)
        case let .messageReactionRemoveAll(payload):
            self.onReactionRemoveAll(payload)
        case let .messageReactionRemoveEmoji(payload):
            self.onReactionRemoveEmoji(payload)
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
    
    /// Stop responding to gateway events.
    public func stop() {
        self.state = .stopped
        self.currentReactions.removeAll()
    }
    
    /// Re-start responding to gateway events.
    public func restart() async throws {
        try await self.verify_populateReactions_start_react()
    }
    
    func endLifecycle() {
        self.state = .stopped
        self.currentReactions.removeAll()
        Task {
            await self.onLifecycleEnd?(self.configuration)
        }
    }
    
    func onReactionAdd(_ reaction: Gateway.MessageReactionAdd) {
        if reaction.message_id == self.configuration.messageId,
           reaction.channel_id == self.configuration.channelId,
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
           reaction.channel_id == self.configuration.channelId,
           reaction.guild_id == self.configuration.guildId,
           self.configuration.reactions.contains(where: { $0.is(reaction.emoji) }),
           self.configuration.roleId != nil {
            self.checkAndRemoveRoleFromUser(emoji: reaction.emoji, userId: reaction.user_id)
        }
    }
    
    func checkAndRemoveRoleFromUser(emoji: Emoji, userId: UserSnowflake) {
        Task {
            do {
                let emojiReaction = try Reaction(emoji: emoji)
                if let idx = self.currentReactions[emojiReaction]?
                    .firstIndex(of: userId) {
                    self.currentReactions[emojiReaction]?.remove(at: idx)
                }
                /// If there is no acceptable reaction remaining, remove the role from the user.
                if !currentReactions.values.contains(where: { $0.contains(userId) }) {
                    await self.removeRoleFromMember(userId: userId)
                }
            } catch {
                logger.report(error: error)
            }
        }
    }
    
    func onReactionRemoveAll(_ payload: Gateway.MessageReactionRemoveAll) {
        if payload.message_id == self.configuration.messageId,
           payload.channel_id == self.configuration.channelId,
           payload.guild_id == self.configuration.guildId {
            /// Doesn't remove roles
            self.currentReactions.removeAll()
        }
    }
    
    func onReactionRemoveEmoji(_ payload: Gateway.MessageReactionRemoveEmoji) {
        if payload.message_id == self.configuration.messageId,
           payload.channel_id == self.configuration.channelId,
           payload.guild_id == self.configuration.guildId {
            do {
                let reaction = try Reaction(emoji: payload.emoji)
                self.currentReactions.removeValue(forKey: reaction)
            } catch {
                logger.report(error: error)
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
    
    func getRoleId() async -> RoleSnowflake? {
        if let roleId = self.configuration.roleId {
            return roleId
        } else {
            await self.setOrCreateRole()
            return self.configuration.roleId
        }
    }
    
    func addRoleToMember(userId: UserSnowflake) async {
        guard userId.value != client.appId?.value else { return }
        guard let roleId = await getRoleId() else {
            self.logger.warning("Can't get a role to grant the member", metadata: [
                "userId": .string(userId.value)
            ])
            return
        }
        await self.addRoleToMember(roleId: roleId, userId: userId)
    }
    
    func addRoleToMember(roleId: RoleSnowflake, userId: UserSnowflake) async {
        do {
            try await client.addGuildMemberRole(
                guildId: self.configuration.guildId,
                userId: userId,
                roleId: roleId
            ).guardSuccess()
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
        guard !self.lockedCreatingRole else { return }
        self.lockedCreatingRole = true
        defer { self.lockedCreatingRole = false }
        
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
    
    func removeRoleFromMember(userId: UserSnowflake) async {
        guard userId.value != client.appId?.value,
              let roleId = self.configuration.roleId
        else { return }
        do {
            try await client.deleteGuildMemberRole(
                guildId: self.configuration.guildId,
                userId: userId,
                roleId: roleId
            ).guardSuccess()
        } catch {
            self.logger.report(error: error)
        }
    }
    
    func verify_populateReactions_start_react() async throws {
        /// Verify message exists
        let message: DiscordChannel.Message
        do {
            message = try await client.getMessage(
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
            let reactionsUsers = try await client.listMessageReactionsByEmoji(
                channelId: self.configuration.channelId,
                messageId: self.configuration.messageId,
                emoji: reaction
            ).decode()
            self.currentReactions[reaction] = Set(reactionsUsers.map(\.id))
        }
        /// Start taking action on Gateway events
        self.state = .running
        /// If members don't have the role, give it to them
        if configuration.grantOnStart,
           let roleId = await self.getRoleId() {
            let users = self.currentReactions.values
                .reduce(into: Set<UserSnowflake>(), { $0.formUnion($1) })
            for user in users {
                if await !requestHandler.memberHasRole(roleId: roleId, userId: user) {
                    await self.addRoleToMember(roleId: roleId, userId: user)
                }
            }
        }
        /// React to message
        let me = message.reactions?.filter(\.me).map(\.emoji) ?? []
        let remaining = configuration.reactions.filter { reaction in
            !me.contains(where: { reaction.is($0) })
        }
        for reaction in remaining {
            do {
                try await client.addMessageReaction(
                    channelId: self.configuration.channelId,
                    messageId: self.configuration.messageId,
                    emoji: reaction
                ).guardSuccess()
            } catch {
                self.logger.report(error: error)
            }
        }
    }
}

//MARK: + Logger
private extension Logger {
    func report(error: Error, function: String = #function, line: UInt = #line) {
        self.error("'ReactToRoleHandler' failed", metadata: [
            "error": .string("\(error)")
        ], function: function, line: line)
    }
}

//MARK: + GuildRole
private extension Payloads.GuildRole {
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
