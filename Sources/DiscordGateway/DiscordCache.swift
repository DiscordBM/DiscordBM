import DiscordModels
import Foundation
import OrderedCollections

/// Caches Gateway events.
@dynamicMemberLookup
public actor DiscordCache {
    
    public enum SnowflakeChoice<Tag>: Sendable, ExpressibleByArrayLiteral {
        case all
        case none
        case some(Set<Snowflake<Tag>>)
        
        public init(arrayLiteral elements: Snowflake<Tag>...) {
            self = .some(Set(elements))
        }
        
        public init<S>(_ elements: S) where S: Sequence, S.Element == String {
            let guildIds = elements.map(Snowflake<Tag>.init)
            self = .some(Set(guildIds))
        }
        
        public func contains(_ value: Snowflake<Tag>) -> Bool {
            switch self {
            case .all: return true
            case .none: return false
            case let .some(values): return values.contains(value)
            }
        }
    }
    
    public enum Intents: Sendable, ExpressibleByArrayLiteral {
        case all
        case some(Set<Gateway.Intent>)
        
        public init(arrayLiteral elements: Gateway.Intent...) {
            self = .some(Set(elements))
        }
        
        public init<S>(_ elements: S) where S: Sequence, S.Element == Gateway.Intent {
            self = .some(.init(elements))
        }
    }
    
    public enum RequestMembers: Sendable {
        case disabled
        /// Only requests members.
        case enabled(guilds: SnowflakeChoice<Guild> = .all)
        /// Requests all members as well as their presences.
        case enabledWithPresences(guilds: SnowflakeChoice<Guild> = .all)
        
        public static var enabled: RequestMembers { .enabled() }
        
        public static var enabledWithPresences: RequestMembers { .enabledWithPresences() }
        
        public func isEnabled(for guildId: GuildSnowflake) -> Bool {
            switch self {
            case .disabled: return false
            case let .enabled(guilds), let .enabledWithPresences(guilds):
                return guilds.contains(guildId)
            }
        }
        
        public func wantsPresences(for guildId: GuildSnowflake) -> Bool {
            switch self {
            case .disabled, .enabled: return false
            case let .enabledWithPresences(guilds):
                return guilds.contains(guildId)
            }
        }
    }
    
    public enum MessageCachingPolicy: Sendable {
        
        /// `Channels` is for channels that don't belong to a guild.
        
        /// Caches messages, replaces edited messages with the new message,
        /// removes deleted messages from storage.
        case normal(
            guilds: SnowflakeChoice<Guild> = .all,
            channels: SnowflakeChoice<DiscordChannel> = .all
        )
        /// Caches messages, replaces edited messages with the new message,
        /// moves deleted messages to another property of the storage.
        case saveDeleted(
            guilds: SnowflakeChoice<Guild> = .all,
            channels: SnowflakeChoice<DiscordChannel> = .all
        )
        /// Caches messages, replaces edited messages with the new message but moves old messages
        /// to another property of the storage, removes deleted messages from storage.
        case saveEditHistory(
            guilds: SnowflakeChoice<Guild> = .all,
            channels: SnowflakeChoice<DiscordChannel> = .all
        )
        /// Caches messages, replaces edited messages with the new message but moves old messages
        /// to another property of the storage, moves deleted messages to another property of
        /// the storage.
        case saveEditHistoryAndDeleted(
            guilds: SnowflakeChoice<Guild> = .all,
            channels: SnowflakeChoice<DiscordChannel> = .all
        )
        
        public static var normal: MessageCachingPolicy { .normal() }
        
        public static var saveDeleted: MessageCachingPolicy { .saveDeleted() }
        
        public static var saveEditHistory: MessageCachingPolicy { .saveEditHistory() }
        
        public static var saveEditHistoryAndDeleted: MessageCachingPolicy {
            .saveEditHistoryAndDeleted()
        }
        
        func shouldSave(
            guildId: GuildSnowflake?,
            channelId: ChannelSnowflake
        ) -> Bool {
            switch self {
            case let .normal(guilds, channels),
                let .saveDeleted(guilds, channels),
                let .saveEditHistory(guilds, channels),
                let .saveEditHistoryAndDeleted(guilds, channels):
                let guildContains = guildId.map { guilds.contains($0) } ?? false
                return guildContains || channels.contains(channelId)
            }
        }
        
        func shouldSaveDeleted(
            guildId: GuildSnowflake?,
            channelId: ChannelSnowflake
        ) -> Bool {
            switch self {
            case let .saveDeleted(guilds, channels),
                let .saveEditHistoryAndDeleted(guilds, channels):
                let guildContains = guildId.map { guilds.contains($0) } ?? false
                return guildContains || channels.contains(channelId)
            case .normal, .saveEditHistory: return false
            }
        }
        
        func shouldSaveHistory(
            guildId: GuildSnowflake?,
            channelId: ChannelSnowflake
        ) -> Bool {
            switch self {
            case let .saveEditHistory(guilds, channels),
                let .saveEditHistoryAndDeleted(guilds, channels):
                let guildContains = guildId.map { guilds.contains($0) } ?? false
                return  guildContains || channels.contains(channelId)
            case .normal, .saveDeleted: return false
            }
        }
    }
    
    /// Keeps the storage from using too much memory. Removes the oldest items.
    ///
    /// Note: The limit policy is applied with a small tolerance, so you can't count on
    /// the limits being applied right-away. Realistically this should not matter anyway,
    /// as the point of this is to just preserve memory.
    public enum ItemsLimit: @unchecked Sendable {
        
        /// `guilds`, `channels` and `botUser` are intentionally excluded.
        /// For `guilds` and `channels`, Discord only sends a limited amount that are related
        /// to your Gateway/shard. And `botUser` isn't a collection.
        public enum Path: Sendable {
            case auditLogs
            case integrations
            case invites
            case messages
            case editedMessages
            case deletedMessages
            case autoModerationRules
            case autoModerationExecutions
            case applicationCommandPermissions
            case messagePollVotes
        }
        
        case disabled
        case constant(Int)
        case custom([Path: Int])
        
        public static let `default` = ItemsLimit.constant(100_000)
        
        func limit(for path: Path) -> Int? {
            switch self {
            case .disabled:
                return nil
            case let .constant(limit):
                return limit
            case let .custom(custom):
                return custom[path]
            }
        }
        
        func calculateCheckForLimitEvery() -> Int {
            switch self {
            case .disabled: return 1 /// Doesn't matter
            case let .constant(limit):
                let powed = pow(1/2, Double(limit))
                return max(10, Int(powed))
            case let .custom(custom):
                guard let minimum = custom.map(\.value).min() else {
                    fatalError("It's meaningless for 'ItemsLimit.custom' to be empty. Please use `ItemsLimit.disabled` instead")
                }
                let powed = pow(1/2, Double(minimum))
                return max(10, Int(powed))
            }
        }
    }
    
    /// The assumption is users might want to encode/decode contents of this storage using Codable.
    /// So this storage should be codable-backward-compatible.
    public struct Storage: @unchecked Sendable, Codable {
        
        public struct InviteID: Sendable, Codable, Hashable {
            public var guildId: GuildSnowflake?
            public var channelId: ChannelSnowflake
            
            public init(guildId: GuildSnowflake? = nil, channelId: ChannelSnowflake) {
                self.guildId = guildId
                self.channelId = channelId
            }
        }
        
        /// Using `OrderedDictionary` for those which can be affected by the `ItemsLimit`
        /// so we can remove the oldest items.
        
        /// `[GuildID: Guild]`
        public var guilds: [GuildSnowflake: Gateway.GuildCreate] = [:]
        /// `[ChannelID: Channel]`
        /// Non-guild channels.
        public var channels: [ChannelSnowflake: DiscordChannel] = [:]
        /// `[GuildID or TargetID or ""]: [Entry]]`
        /// `""` is used for entries that don't have a `guild_id`/`target_id`, if any.
        public var auditLogs: OrderedDictionary<AnySnowflake, [AuditLog.Entry]> = [:]
        /// `[GuildID: [Integration]]`
        public var integrations: OrderedDictionary<GuildSnowflake, [Integration]> = [:]
        /// `[InviteID: [Invite]]`
        public var invites: OrderedDictionary<InviteID, [Gateway.InviteCreate]> = [:]
        /// `[ChannelID: [Message]]`
        public var messages: OrderedDictionary<ChannelSnowflake, [Gateway.MessageCreate]> = [:]
        /// `[ChannelID: [MessageID: [EditedMessage]]]`
        /// It's `[EditedMessage]` because it will keep all edited versions of a message.
        /// This does not keep the most recent message, which is available in `messages`.
        public var editedMessages: OrderedDictionary<ChannelSnowflake, [MessageSnowflake: [Gateway.MessageCreate]]> = [:]
        /// `[ChannelID: [MessageID: [DeletedMessage]]]`
        /// It's `[DeletedMessage]` because it might have the edited versions of the message too.
        public var deletedMessages: OrderedDictionary<ChannelSnowflake, [MessageSnowflake: [Gateway.MessageCreate]]> = [:]
        /// `[GuildID: [Rule]]`
        public var autoModerationRules: OrderedDictionary<GuildSnowflake, [AutoModerationRule]> = [:]
        /// `[GuildID: [ActionExecution]]`
        public var autoModerationExecutions: OrderedDictionary<GuildSnowflake, [AutoModerationActionExecution]> = [:]
        /// `[CommandID (or ApplicationID): Permissions]`
        public var applicationCommandPermissions: OrderedDictionary<AnySnowflake, GuildApplicationCommandPermissions> = [:]
        /// `[EntitlementID: Entitlement]`
        public var entitlements: OrderedDictionary<EntitlementSnowflake, Entitlement> = [:]
        /// `[ChannelSnowflake: [MessageSnowflake: [MessagePollVote]]`
        public var messagePollVotes: OrderedDictionary<ChannelSnowflake, [MessageSnowflake: [Gateway.MessagePollVote]]> = [:]
        /// The current bot-application.
        public var application: PartialApplication?
        /// The current bot user.
        public var botUser: DiscordUser?

        public init(
            guilds: [GuildSnowflake: Gateway.GuildCreate] = [:],
            channels: [ChannelSnowflake: DiscordChannel] = [:],
            auditLogs: OrderedDictionary<AnySnowflake, [AuditLog.Entry]> = [:],
            integrations: OrderedDictionary<GuildSnowflake, [Integration]> = [:],
            invites: OrderedDictionary<InviteID, [Gateway.InviteCreate]> = [:],
            messages: OrderedDictionary<ChannelSnowflake, [Gateway.MessageCreate]> = [:],
            editedMessages: OrderedDictionary<ChannelSnowflake, [MessageSnowflake: [Gateway.MessageCreate]]> = [:],
            deletedMessages: OrderedDictionary<ChannelSnowflake, [MessageSnowflake: [Gateway.MessageCreate]]> = [:],
            autoModerationRules: OrderedDictionary<GuildSnowflake, [AutoModerationRule]> = [:],
            autoModerationExecutions: OrderedDictionary<GuildSnowflake, [AutoModerationActionExecution]> = [:],
            applicationCommandPermissions: OrderedDictionary<AnySnowflake, GuildApplicationCommandPermissions> = [:],
            entitlements: OrderedDictionary<EntitlementSnowflake, Entitlement> = [:],
            application: PartialApplication? = nil,
            botUser: DiscordUser? = nil
        ) {
            self.guilds = guilds
            self.channels = channels
            self.auditLogs = auditLogs
            self.integrations = integrations
            self.invites = invites
            self.messages = messages
            self.editedMessages = editedMessages
            self.deletedMessages = deletedMessages
            self.autoModerationRules = autoModerationRules
            self.autoModerationExecutions = autoModerationExecutions
            self.applicationCommandPermissions = applicationCommandPermissions
            self.entitlements = entitlements
            self.application = application
            self.botUser = botUser
        }
    }
    
    /// The gateway manager that this `DiscordCache` instance caches from.
    let gatewayManager: any GatewayManager
    /// What intents to cache their related Gateway events.
    /// This does not affect what events you receive from Discord.
    /// The intents you enter here must have been enabled in your `GatewayManager`.
    /// With `.all`, all events will be cached.
    public let intents: Set<Gateway.Intent>
    /// In big guilds/servers, Discord only sends your own member/presence info by default.
    /// You need to request the rest of the members, which is what this parameter specifies.
    /// Must have `guildMembers` and `guildPresences` intents enabled depending on what you want.
    public let requestMembers: RequestMembers
    /// How to cache messages.
    public let messageCachingPolicy: MessageCachingPolicy
    /// Keeps the storage from using too much memory. Removes the oldest items.
    public let itemsLimit: ItemsLimit
    /// Counter for hitting the items limit.
    private var itemsLimitCounter = 0
    /// How often to check and enforce the limit above.
    private let checkForLimitEvery: Int
    /// The storage of cached stuff.
    public var storage: Storage {
        didSet { checkItemsLimit() }
    }
    
    /// Utility to access `Storage`.
    public subscript<T: Sendable>(dynamicMember path: WritableKeyPath<Storage, T>) -> T {
        get { self.storage[keyPath: path] }
        set { self.storage[keyPath: path] = newValue }
    }
    
    /// - Parameters:
    ///   - gatewayManager: The gateway manager that this `DiscordCache` instance caches from.
    ///   - intents: What intents to cache their related Gateway events.
    ///     This does not affect what events you receive from Discord.
    ///     The intents you enter here must have been enabled in your `GatewayManager`.
    ///   - requestAllMembers: In big guilds/servers, Discord only sends your own member/presence
    ///     info by default. You need to request the rest of the members, which is what this
    ///     parameter specifies. Must have `guildMembers` and `guildPresences` intents enabled
    ///     depending on what you want.
    ///   - messageCachingPolicy: How to cache messages.
    ///   - itemsLimit: Keeps the storage from using too much memory. Removes the oldest items.
    ///   - storage: The storage of cached stuff. You usually don't need to provide this parameter.
    public init(
        gatewayManager: any GatewayManager,
        intents: Intents,
        requestAllMembers: RequestMembers,
        messageCachingPolicy: MessageCachingPolicy = .normal,
        itemsLimit: ItemsLimit = .default,
        storage: Storage = Storage()
    ) async {
        self.gatewayManager = gatewayManager
        self.intents = Set<Gateway.Intent>()
        self.requestMembers = requestAllMembers
        self.messageCachingPolicy = messageCachingPolicy
        self.itemsLimit = itemsLimit
        self.checkForLimitEvery = itemsLimit.calculateCheckForLimitEvery()
        self.storage = storage

        Task {
            for await event in await gatewayManager.events {
                self.handleEvent(event)
            }
        }
    }
    
    private func handleEvent(_ event: Gateway.Event) {
        guard intentsAllowCaching(event: event) else { return }
        switch event.data {
        case .none, .heartbeat, .identify, .hello, .resume, .resumed, .invalidSession, .requestGuildMembers, .requestPresenceUpdate, .requestVoiceStateUpdate, .interactionCreate:
            break
        case let .ready(ready):
            self.application = ready.application
            self.botUser = ready.user
        case let .guildCreate(guildCreate):
            self.guilds[guildCreate.id] = guildCreate
            if requestMembers.isEnabled(for: guildCreate.id) {
                Task {
                    await gatewayManager.requestGuildMembersChunk(payload: .init(
                        guild_id: guildCreate.id,
                        query: "",
                        limit: 0,
                        presences: requestMembers.wantsPresences(for: guildCreate.id),
                        user_ids: nil,
                        nonce: nil
                    ))
                }
            }
        case let .guildUpdate(guild):
            self.guilds[guild.id]?.update(with: guild)
        case let .guildDelete(guildDelete):
            self.guilds.removeValue(forKey: guildDelete.id)
        case let .channelCreate(channel), let .channelUpdate(channel):
            if let guildId = channel.guild_id {
                if let index = self.guilds[guildId]?.channels
                    .firstIndex(where: { $0.id == channel.id }) {
                    self.guilds[guildId]?.channels.remove(at: index)
                }
                self.guilds[guildId]?.channels.append(channel)
            } else {
                self.channels[channel.id] = channel
            }
        case let .channelDelete(channel):
            if let guildId = channel.guild_id {
                if let index = self.guilds[guildId]?.channels
                    .firstIndex(where: { $0.id == channel.id }) {
                    self.guilds[guildId]?.channels.remove(at: index)
                }
            } else {
                self.channels.removeValue(forKey: channel.id)
            }
        case let .channelPinsUpdate(pinsUpdate):
            if let guildId = pinsUpdate.guild_id {
                if let index = self.guilds[guildId]?.channels
                    .firstIndex(where: { $0.id == pinsUpdate.channel_id }) {
                    self.guilds[guildId]!.channels[index]
                        .last_pin_timestamp = pinsUpdate.last_pin_timestamp
                }
            } else {
                self.channels[pinsUpdate.channel_id]?
                    .last_pin_timestamp = pinsUpdate.last_pin_timestamp
            }
        case let .threadCreate(channel):
            if let guildId = channel.guild_id {
                if let existingIndex = self.guilds[guildId]?.threads
                    .firstIndex(where: { $0.id == channel.id }) {
                    self.guilds[guildId]?.threads[existingIndex] = channel
                    /// Update `last_message_id` of forums on thread-create.
                    /// https://discord.com/developers/docs/topics/threads#forum-channel-fields
                    if channel.type == .guildForum,
                       let parentId = channel.parent_id,
                       let forumIdx = self.guilds[guildId]?.channels
                        .firstIndex(where: { $0.id == parentId }) {
                        self.guilds[guildId]?.channels[forumIdx].last_message_id = .init(channel.id)
                    }
                } else {
                    self.guilds[guildId]?.threads.append(channel)
                }
            } else {
                self.channels[channel.id] = channel
                /// Update `last_message_id` of forums on thread-create.
                /// https://discord.com/developers/docs/topics/threads#forum-channel-fields
                if channel.type == .guildForum,
                   let parentId = channel.parent_id {
                    self.channels[Snowflake(parentId)]?.last_message_id = .init(channel.id)
                }
            }
        case let .threadUpdate(channel):
            if let guildId = channel.guild_id {
                if let existingIndex = self.guilds[guildId]?.threads
                    .firstIndex(where: { $0.id == channel.id }) {
                    self.guilds[guildId]?.threads[existingIndex] = channel
                }
            } else {
                self.channels[channel.id] = channel
            }
        case let .threadDelete(threadDelete):
            if let guildId = threadDelete.guild_id {
                if let existingIndex = self.guilds[guildId]?.threads
                    .firstIndex(where: { $0.id == threadDelete.id }) {
                    self.guilds[guildId]?.threads.remove(at: existingIndex)
                }
            } else {
                self.channels.removeValue(forKey: threadDelete.id)
            }
        case let .threadSyncList(syncList):
            var guild: Gateway.GuildCreate? {
                get { self.guilds[syncList.guild_id] }
                set { self.guilds[syncList.guild_id] = newValue}
            }
            /// Remove unavailable threads
            let allParents = Set(syncList.threads.compactMap(\.parent_id))
            let parentsOfRemovedThreads = syncList.channel_ids?.filter { channelId in
                !allParents.contains(where: { $0 == channelId })
            } ?? []
            guild?.threads.removeAll {
                guard let parentId = $0.parent_id else { return false }
                return parentsOfRemovedThreads.contains(where: { $0 == parentId })
            }
            /// Append the new threads
            guild?.threads.append(contentsOf: syncList.threads)
            /// Refresh thread members
            for member in syncList.members {
                if let idx = guild?.threads.firstIndex(where: { $0.id == member.id }) {
                    guild?.threads[idx].member = member
                }
            }
        case let .threadMemberUpdate(threadMember):
            if let idx = self.guilds[threadMember.guild_id]?.threads
                .firstIndex(where: { $0.id == threadMember.id }) {
                self.guilds[threadMember.guild_id]?.threads[idx].member = .init(
                    threadMemberUpdate: threadMember
                )
            }
        case let .threadMembersUpdate(update):
            if let idx = self.guilds[update.guild_id]?.threads
                .firstIndex(where: { $0.id == update.id }) {
                self.guilds[update.guild_id]!.threads[idx].member_count = update.member_count
                if self.guilds[update.guild_id]!.threads[idx].threadMembers == nil {
                    if let added = update.added_members {
                        self.guilds[update.guild_id]!.threads[idx].threadMembers = added
                    }
                } else {
                    if let removed = update.removed_member_ids {
                        self.guilds[update.guild_id]!.threads[idx].threadMembers!.removeAll {
                            guard let id = $0.member.user?.id ?? $0.user_id else { return false }
                            return removed.contains(id)
                        }
                    }
                    if let added = update.added_members {
                        self.guilds[update.guild_id]!.threads[idx].threadMembers!
                            .append(contentsOf: added)
                    }
                }
            }
        case let .entitlementCreate(entitlement),
            let .entitlementUpdate(entitlement):
            self.entitlements[entitlement.id] = entitlement
        case let .entitlementDelete(entitlement):
            self.entitlements.removeValue(forKey: entitlement.id)
        case let .guildBanAdd(ban):
            if let idx = self.guilds[ban.guild_id]?.members
                .firstIndex(where: { $0.user?.id == ban.user.id }) {
                self.guilds[ban.guild_id]?.members.remove(at: idx)
            }
        case .guildBanRemove: break /// Nothing to do?
        case let .guildEmojisUpdate(update):
            for emoji in update.emojis {
                if let idx = self.guilds[update.guild_id]?.emojis
                    .firstIndex(where: { $0.id == emoji.id }) {
                    self.guilds[update.guild_id]?.emojis[idx] = emoji
                } else {
                    self.guilds[update.guild_id]?.emojis.append(emoji)
                }
            }
        case let .guildStickersUpdate(update):
            if self.guilds[update.guild_id]?.stickers == nil {
                self.guilds[update.guild_id]?.stickers = []
            }
            for sticker in update.stickers {
                if let idx = self.guilds[update.guild_id]?.stickers?
                    .firstIndex(where: { $0.id == sticker.id }) {
                    self.guilds[update.guild_id]?.stickers?[idx] = sticker
                } else {
                    self.guilds[update.guild_id]?.stickers?.append(sticker)
                }
            }
        case .guildIntegrationsUpdate: break /// Nothing to do?
        case let .guildMemberAdd(member), let .guildMemberUpdate(member):
            if let idx = self.guilds[member.guild_id]?.members
                .firstIndex(where: { $0.user?.id == member.user.id }) {
                self.guilds[member.guild_id]?.members.remove(at: idx)
            }
            self.guilds[member.guild_id]?.members.append(.init(guildMemberAdd: member))
        case let .guildMemberRemove(member):
            if let idx = self.guilds[member.guild_id]?.members
                .firstIndex(where: { $0.user?.id == member.user.id }) {
                self.guilds[member.guild_id]?.members.remove(at: idx)
            }
        case let .guildMembersChunk(chunk):
            let userIds = chunk.members.compactMap(\.user?.id)
            self.guilds[chunk.guild_id]?.members.removeAll {
                guard let id = $0.user?.id else { return false }
                return userIds.contains(id)
            }
            self.guilds[chunk.guild_id]?.members.append(contentsOf: chunk.members)
            if let presences = chunk.presences {
                self.guilds[chunk.guild_id]?.presences.removeAll {
                    guard let id = $0.user?.id else { return false }
                    return userIds.contains(id)
                }
                self.guilds[chunk.guild_id]?.presences.append(contentsOf: presences)
            }
        case let .guildRoleCreate(role), let .guildRoleUpdate(role):
            if let idx = self.guilds[role.guild_id]?.roles
                .firstIndex(where: { $0.id == role.role.id }) {
                self.guilds[role.guild_id]?.roles.remove(at: idx)
            }
            self.guilds[role.guild_id]?.roles.append(role.role)
        case let .guildRoleDelete(role):
            if let idx = self.guilds[role.guild_id]?.roles
                .firstIndex(where: { $0.id == role.role_id }) {
                self.guilds[role.guild_id]?.roles.remove(at: idx)
            }
        case let .guildScheduledEventCreate(event), let .guildScheduledEventUpdate(event):
            if let idx = self.guilds[event.guild_id]?.guild_scheduled_events
                .firstIndex(where: { $0.id == event.id }) {
                self.guilds[event.guild_id]?.guild_scheduled_events.remove(at: idx)
            }
            self.guilds[event.guild_id]?.guild_scheduled_events.append(event)
        case let .guildScheduledEventDelete(event):
            if let idx = self.guilds[event.guild_id]?.guild_scheduled_events
                .firstIndex(where: { $0.id == event.id }) {
                self.guilds[event.guild_id]?.guild_scheduled_events.remove(at: idx)
            }
        case let .guildScheduledEventUserAdd(user):
            guard let idx = self.guilds[user.guild_id]?.guild_scheduled_events
                .firstIndex(where: { $0.id == user.guild_scheduled_event_id })
            else { break }
            if self.guilds[user.guild_id]?.guild_scheduled_events[idx].user_ids == nil {
                self.guilds[user.guild_id]?.guild_scheduled_events[idx]
                    .user_ids = [user.user_id]
            } else {
                self.guilds[user.guild_id]?.guild_scheduled_events[idx]
                    .user_ids?.append(user.user_id)
            }
            if self.guilds[user.guild_id]?.guild_scheduled_events[idx].user_count == nil {
                self.guilds[user.guild_id]?.guild_scheduled_events[idx].user_count = 1
            } else {
                self.guilds[user.guild_id]!.guild_scheduled_events[idx].user_count! += 1
            }
        case let .guildScheduledEventUserRemove(user):
            guard let idx = self.guilds[user.guild_id]?.guild_scheduled_events
                .firstIndex(where: { $0.id == user.guild_scheduled_event_id })
            else { break }
            if let ind = self.guilds[user.guild_id]?.guild_scheduled_events[idx]
                .user_ids?.firstIndex(where: { $0 == user.user_id }) {
                self.guilds[user.guild_id]?.guild_scheduled_events[idx]
                    .user_ids?.remove(at: ind)
            }
            if self.guilds[user.guild_id]?.guild_scheduled_events[idx].user_count == nil {
                self.guilds[user.guild_id]?.guild_scheduled_events[idx].user_count = 0
            } else {
                self.guilds[user.guild_id]!.guild_scheduled_events[idx].user_count! -= 1
            }
        case let .guildAuditLogEntryCreate(log):
            let guildId = log.guild_id.map(AnySnowflake.init)
            let targetId = log.target_id.map(AnySnowflake.init)
            self.auditLogs[guildId ?? targetId ?? AnySnowflake(""), default: []].append(log)
        case let .integrationCreate(integration), let .integrationUpdate(integration):
            if let idx = self.integrations[integration.guild_id]?
                .firstIndex(where: { $0.id == integration.id }) {
                self.integrations[integration.guild_id]?.remove(at: idx)
            }
            self.integrations[integration.guild_id, default: []].append(
                .init(integrationCreate: integration)
            )
        case let .integrationDelete(integration):
            if let idx = self.integrations[integration.guild_id]?
                .firstIndex(where: { $0.id == integration.id }) {
                self.integrations[integration.guild_id]?.remove(at: idx)
            }
        case let .inviteCreate(invite):
            let id = Storage.InviteID(guildId: invite.guild_id, channelId: invite.channel_id)
            self.invites[id, default: []].append(invite)
        case let .inviteDelete(invite):
            let id = Storage.InviteID(guildId: invite.guild_id, channelId: invite.channel_id)
            self.invites.removeValue(forKey: id)
        case let .messageCreate(message):
            if messageCachingPolicy.shouldSave(
                guildId: message.guild_id,
                channelId: message.channel_id
            ) {
                self.messages[message.channel_id, default: []].append(message)
            }
            if let guildId = message.guild_id {
                if let channelIdx = self.guilds[guildId]?.channels
                    .firstIndex(where: { $0.id == message.channel_id }) {
                    self.guilds[guildId]?.channels[channelIdx].last_message_id = message.id
                } else if let threadIdx = self.guilds[guildId]?.threads
                    .firstIndex(where: { $0.id == message.channel_id }) {
                    self.guilds[guildId]?.threads[threadIdx].last_message_id = message.id
                }
            } else {
                self.channels[message.channel_id]?.last_message_id = message.id
            }
        case let .messageUpdate(message):
            if let idx = self.messages[message.channel_id]?
                .firstIndex(where: { $0.id == message.id }) {
                self.messages[message.channel_id]![idx].update(with: message)
                if messageCachingPolicy.shouldSaveHistory(
                    guildId: message.guild_id,
                    channelId: message.channel_id
                ) {
                    self.editedMessages[message.channel_id, default: [:]][message.id, default: []].append(
                        self.messages[message.channel_id]![idx]
                    )
                }
            }
        case let .messageDelete(message):
            if let idx = self.messages[message.channel_id]?
                .firstIndex(where: { $0.id == message.id }) {
                let deleted = self.messages[message.channel_id]?.remove(at: idx)
                if messageCachingPolicy.shouldSaveDeleted(
                    guildId: message.guild_id,
                    channelId: message.channel_id
                ),
                   let deleted {
                    if messageCachingPolicy.shouldSaveHistory(
                        guildId: message.guild_id,
                        channelId: message.channel_id
                    ) {
                        let history = self.editedMessages[message.channel_id]?[message.id] ?? []
                        self.deletedMessages[message.channel_id, default: [:]][message.id, default: []].append(
                            contentsOf: history
                        )
                    }
                    self.deletedMessages[message.channel_id, default: [:]][message.id, default: []].append(
                        deleted
                    )
                }
                self.editedMessages[message.channel_id]?.removeValue(forKey: message.id)
            }
        case let .messageDeleteBulk(bulkDelete):
            self.messages[bulkDelete.channel_id]?.removeAll { message in
                let shouldBeRemoved = bulkDelete.ids.contains(message.id)
                if shouldBeRemoved {
                    if messageCachingPolicy.shouldSaveDeleted(
                        guildId: message.guild_id,
                        channelId: message.channel_id
                    ) {
                        if messageCachingPolicy.shouldSaveHistory(
                            guildId: message.guild_id,
                            channelId: message.channel_id
                        ) {
                            let history = self.editedMessages[message.channel_id]?[message.id] ?? []
                            self.deletedMessages[message.channel_id, default: [:]][message.id, default: []].append(
                                contentsOf: history
                            )
                        }
                        self.deletedMessages[message.channel_id, default: [:]][message.id, default: []].append(
                            message
                        )
                    }
                    self.editedMessages[message.channel_id]?.removeValue(forKey: message.id)
                }
                return shouldBeRemoved
            }
        case let .messageReactionAdd(reaction):
            if let idx = self.messages[reaction.channel_id]?
                .firstIndex(where: { $0.id == reaction.message_id }) {
                let me = reaction.user_id == self.botUser?.id
                let isBurst = reaction.type == .super
                if let index = self.messages[reaction.channel_id]![idx].reactions?
                    .firstIndex(where: { $0.emoji == reaction.emoji }) {
                    self.messages[reaction.channel_id]![idx].reactions![index].count += 1
                    if isBurst {
                        self.messages[reaction.channel_id]![idx].reactions![index].count_details.burst += 1
                    } else {
                        self.messages[reaction.channel_id]![idx].reactions![index].count_details.normal += 1
                    }
                } else {
                    self.messages[reaction.channel_id]![idx].reactions =
                    self.messages[reaction.channel_id]![idx].reactions ?? []
                    self.messages[reaction.channel_id]![idx].reactions!.append(.init(
                        count: 1,
                        count_details: .init(
                            burst: isBurst ? 1 : 0,
                            normal: isBurst ? 0 : 1
                        ),
                        me: me,
                        me_burst: reaction.type == .super && me,
                        emoji: reaction.emoji,
                        burst_colors: []
                    ))
                }
            }
        case let .messageReactionRemove(reaction):
            if let idx = self.messages[reaction.channel_id]?
                .firstIndex(where: { $0.id == reaction.message_id }) {
                if let index = self.messages[reaction.channel_id]?[idx].reactions?
                    .firstIndex(where: { $0.emoji == reaction.emoji }) {
                    if self.messages[reaction.channel_id]![idx].reactions![index].count == 1 {
                        self.messages[reaction.channel_id]?[idx].reactions?.remove(at: index)
                    } else {
                        self.messages[reaction.channel_id]![idx].reactions![index].count -= 1
                    }
                }
            }
        case let .messageReactionRemoveAll(reaction):
            if let idx = self.messages[reaction.channel_id]?
                .firstIndex(where: { $0.id == reaction.message_id }) {
                self.messages[reaction.channel_id]?[idx].reactions = []
            }
        case let .messageReactionRemoveEmoji(reaction):
            if let idx = self.messages[reaction.channel_id]?
                .firstIndex(where: { $0.id == reaction.message_id }) {
                if let index = self.messages[reaction.channel_id]?[idx].reactions?
                    .firstIndex(where: { $0.emoji == reaction.emoji }) {
                    self.messages[reaction.channel_id]?[idx].reactions?.remove(at: index)
                }
            }
        case let .presenceUpdate(presence):
            if let idx = self.guilds[presence.guild_id]?.presences
                .firstIndex(where: { $0.user?.id == presence.user.id }) {
                self.guilds[presence.guild_id]?.presences[idx].update(with: presence)
            } else {
                self.guilds[presence.guild_id]?.presences.append(.init(presenceUpdate: presence))
            }
        case let .stageInstanceCreate(stage), let .stageInstanceUpdate(stage):
            if let idx = self.guilds[stage.guild_id]?.stage_instances
                .firstIndex(where: { $0.id == stage.id }) {
                self.guilds[stage.guild_id]?.stage_instances[idx] = stage
            } else {
                self.guilds[stage.guild_id]?.stage_instances.append(stage)
            }
        case let .stageInstanceDelete(stage):
            if let idx = self.guilds[stage.guild_id]?.stage_instances
                .firstIndex(where: { $0.id == stage.id }) {
                self.guilds[stage.guild_id]?.stage_instances.remove(at: idx)
            }
        case .typingStart: break /// Nothing to do?
        case let .userUpdate(user):
            self.botUser = user
        case let .voiceStateUpdate(state):
            if let idx = self.guilds[state.guild_id]?.voice_states
                .firstIndex(where: { $0.session_id == state.session_id }) {
                self.guilds[state.guild_id]?.voice_states[idx] = .init(voiceState: state)
            } else {
                self.guilds[state.guild_id]?.voice_states.append(.init(voiceState: state))
            }
        case .voiceServerUpdate: break /// Nothing to do?
        case .webhooksUpdate: break /// Nothing to do?
        case let .autoModerationRuleCreate(autoMod), let .autoModerationRuleUpdate(autoMod):
            if let idx = self.autoModerationRules[autoMod.guild_id]?
                .firstIndex(where: { $0.id == autoMod.id }) {
                self.autoModerationRules[autoMod.guild_id]![idx] = autoMod
            } else {
                self.autoModerationRules[autoMod.guild_id, default: []].append(autoMod)
            }
        case let .autoModerationRuleDelete(autoMod):
            if let idx = self.autoModerationRules[autoMod.guild_id]?
                .firstIndex(where: { $0.id == autoMod.id }) {
                self.autoModerationRules[autoMod.guild_id]?.remove(at: idx)
            }
        case let .autoModerationActionExecution(execution):
            self.autoModerationExecutions[execution.guild_id, default: []].append(execution)
        case let .applicationCommandPermissionsUpdate(update):
            self.applicationCommandPermissions[update.id] = update
        case let .messagePollVoteAdd(vote),
            let .messagePollVoteRemove(vote):
            self.messagePollVotes[vote.channel_id, default: [:]][vote.message_id, default: []].append(vote)
        case .__undocumented:
            break
        }
    }
    
    private func intentsAllowCaching(event: Gateway.Event) -> Bool {
        guard let data = event.data else { return false }
        return true
    }
    
    private func checkItemsLimit() {
        if case .disabled = itemsLimit { return }
        itemsLimitCounter &+= 1
        if itemsLimitCounter % checkForLimitEvery == 0 {
            switch itemsLimit {
            case .disabled: return
            case let .constant(constant):
                guard constant > 0 else { return }

                if self.auditLogs.count > constant {
                    let extra = self.auditLogs.count - constant
                    self.auditLogs.removeSubrange(0..<extra)
                }
                if self.integrations.count > constant {
                    let extra = self.integrations.count - constant
                    self.integrations.removeSubrange(0..<extra)
                }
                if self.invites.count > constant {
                    let extra = self.invites.count - constant
                    self.invites.removeSubrange(0..<extra)
                }
                if self.messages.count > constant {
                    let extra = self.messages.count - constant
                    self.messages.removeSubrange(0..<extra)
                }
                if self.editedMessages.count > constant {
                    let extra = self.editedMessages.count - constant
                    self.editedMessages.removeSubrange(0..<extra)
                }
                if self.deletedMessages.count > constant {
                    let extra = self.deletedMessages.count - constant
                    self.deletedMessages.removeSubrange(0..<extra)
                }
                if self.autoModerationRules.count > constant {
                    let extra = self.autoModerationRules.count - constant
                    self.autoModerationRules.removeSubrange(0..<extra)
                }
                if self.autoModerationExecutions.count > constant {
                    let extra = self.autoModerationExecutions.count - constant
                    self.autoModerationExecutions.removeSubrange(0..<extra)
                }
                if self.applicationCommandPermissions.count > constant {
                    let extra = self.applicationCommandPermissions.count - constant
                    self.applicationCommandPermissions.removeSubrange(0..<extra)
                }
                if self.messagePollVotes.count > constant {
                    let extra = self.messagePollVotes.count - constant
                    self.messagePollVotes.removeSubrange(0..<extra)
                }
            case let .custom(custom):
                if let limit = custom[.auditLogs],
                   self.auditLogs.count > limit {
                    let extra = self.auditLogs.count - limit
                    self.auditLogs.removeSubrange(0..<extra)
                }
                if let limit = custom[.integrations],
                   self.integrations.count > limit {
                    let extra = self.integrations.count - limit
                    self.integrations.removeSubrange(0..<extra)
                }
                if let limit = custom[.invites],
                   self.invites.count > limit {
                    let extra = self.invites.count - limit
                    self.invites.removeSubrange(0..<extra)
                }
                if let limit = custom[.messages],
                   self.messages.count > limit {
                    let extra = self.messages.count - limit
                    self.messages.removeSubrange(0..<extra)
                }
                if let limit = custom[.editedMessages],
                   self.editedMessages.count > limit {
                    let extra = self.editedMessages.count - limit
                    self.editedMessages.removeSubrange(0..<extra)
                }
                if let limit = custom[.deletedMessages],
                   self.deletedMessages.count > limit {
                    let extra = self.deletedMessages.count - limit
                    self.deletedMessages.removeSubrange(0..<extra)
                }
                if let limit = custom[.autoModerationRules],
                   self.autoModerationRules.count > limit {
                    let extra = self.autoModerationRules.count - limit
                    self.autoModerationRules.removeSubrange(0..<extra)
                }
                if let limit = custom[.autoModerationExecutions],
                   self.autoModerationExecutions.count > limit {
                    let extra = self.autoModerationExecutions.count - limit
                    self.autoModerationExecutions.removeSubrange(0..<extra)
                }
                if let limit = custom[.applicationCommandPermissions],
                   self.applicationCommandPermissions.count > limit {
                    let extra = self.applicationCommandPermissions.count - limit
                    self.applicationCommandPermissions.removeSubrange(0..<extra)
                }
                if let limit = custom[.messagePollVotes],
                   self.messagePollVotes.count > limit {
                    let extra = self.messagePollVotes.count - limit
                    self.messagePollVotes.removeSubrange(0..<extra)
                }
            }
        }
    }

    
#if DEBUG
    func _tests_modifyStorage(_ block: @Sendable (inout Storage) -> Void) {
        block(&self.storage)
    }
#endif
}

private func == (lhs: Emoji, rhs: Emoji) -> Bool {
    lhs.id == rhs.id && lhs.name == rhs.name
}

//MARK: - WritableKeyPath + Sendable
extension WritableKeyPath: @unchecked Sendable where Root: Sendable, Value: Sendable { }
