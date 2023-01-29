import DiscordModels

/// Caches Gateway events.
@dynamicMemberLookup
public actor DiscordCache {
    
    public struct RequestMembersConfiguration: Sendable, Codable {
        public let requestPresences: Bool
        
        /// Requests members but doesn't request member presences.
        public static var enabled: RequestMembersConfiguration {
            .init(requestPresences: false)
        }
        
        /// Requests member presences as well.
        public static var enabledWithPresence: RequestMembersConfiguration {
            .init(requestPresences: true)
        }
    }
    
    public struct Storage: Sendable, Codable {
        
        public struct InviteID: Sendable, Codable, Hashable {
            public var guildId: String?
            public var channelId: String
            
            public init(guildId: String? = nil, channelId: String) {
                self.guildId = guildId
                self.channelId = channelId
            }
        }
        
        /// `[GuildID: Guild]`
        public var guilds: [String: Gateway.GuildCreate] = [:]
        /// Non-guild channels
        public var channels: [String: DiscordChannel] = [:]
        /// `[TargetID]: [AuditLog.Entry]]`
        /// A target id of `""` is used for entries that don't have a `target_id`.
        public var auditLogs: [String: [AuditLog.Entry]] = [:]
        /// `[GuildID: [Integration]]`
        public var integrations: [String: [Integration]] = [:]
        /// `[GuildID: [Gateway.InviteCreate]]`
        public var invites: [InviteID: [Gateway.InviteCreate]] = [:]
        /// `[ChannelID: [Gateway.InviteCreate]]`
        public var messages: [String: [Gateway.MessageCreate]] = [:]
        /// `[GuildID: [AutoModerationRule]]`
        public var autoModerationRules: [String: [AutoModerationRule]] = [:]
        /// `[GuildID: [AutoModerationActionExecution]]`
        public var autoModerationExecutions: [String: [AutoModerationActionExecution]] = [:]
        /// `[CommandID (or ApplicationID): GuildApplicationCommandPermissions]`
        public var applicationCommandPermissions: [String: GuildApplicationCommandPermissions] = [:]
        /// The current bot user.
        public var botUser: DiscordUser?
        
        public init() { }
    }
    
    /// The gateway manager that this `DiscordCache` instance caches from.
    let gatewayManager: any GatewayManager
    /// The intents for which the events should be cached. `nil` if all events should be cached.
    let intents: Set<Gateway.Intent>?
    /// When a guild has too many members, Discord won't send all the members in
    /// `.guildCreate` event, and you need to manually request them if you want.
    let requestMembersConfiguration: RequestMembersConfiguration?
    /// The storage of cached stuff.
    public var storage: Storage
    
    public subscript<T>(dynamicMember path: WritableKeyPath<Storage, T>) -> T {
        get { self.storage[keyPath: path] }
        set { self.storage[keyPath: path] = newValue }
    }
    
    /// - Parameters:
    ///   - intents: The intents for which the events will cached.
    ///    `nil` if all events should be cached.
    
    /// - Parameters:
    ///   - gatewayManager: The gateway manager that this `DiscordCache` instance caches from.
    ///   - intents: The intents for which the events should be cached. `nil` if all events should be cached.
    ///   - requestAllMembers: When a guild has too many members, Discord won't send all the members in the `.guildCreate` event, and you need to manually request them if you want.
    ///   - storage: The storage of cached stuff. You usually don't need to provide this parameter.
    public init(
        gatewayManager: any GatewayManager,
        intents: Set<Gateway.Intent>?,
        requestAllMembers: RequestMembersConfiguration,
        storage: Storage = Storage()
    ) async {
        self.gatewayManager = gatewayManager
        self.intents = intents
        self.requestMembersConfiguration = requestAllMembers
        self.storage = storage
        await gatewayManager.addEventHandler(handleEvent)
    }
    
    private func handleEvent(_ event: Gateway.Event) {
        guard intentsAllowCaching(event: event) else { return }
        switch event.data {
        case .none, .heartbeat, .identify, .hello, .ready, .resume, .resumed, .invalidSession, .requestGuildMembers, .interactionCreate:
            break
        case let .guildCreate(guildCreate):
            self.guilds[guildCreate.id] = guildCreate
            if let config = requestMembersConfiguration {
                Task {
                    await gatewayManager.requestGuildMembersChunk(payload: .init(
                        guild_id: guildCreate.id,
                        query: "",
                        limit: 0,
                        presences: config.requestPresences,
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
                }
                self.guilds[guildId]?.threads.append(channel)
            } else {
                self.channels[channel.id] = channel
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
            let parentsOfRemovedThreads = syncList.channel_ids?
                .filter({ !allParents.contains($0) }) ?? []
            guild?.threads.removeAll {
                guard let parentId = $0.parent_id else { return false }
                return parentsOfRemovedThreads.contains(parentId)
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
                        self.guilds[update.guild_id]!.threads[idx].threadMembers?.removeAll {
                            guard let id = $0.member.user?.id ?? $0.user_id else { return false }
                            return removed.contains(id)
                        }
                    }
                    if let added = update.added_members {
                        self.guilds[update.guild_id]!.threads[idx].threadMembers?
                            .append(contentsOf: added)
                    }
                }
            }
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
            if let idx = self.guilds[user.guild_id]?.guild_scheduled_events[idx]
                .user_ids?.firstIndex(where: { $0 == user.user_id }) {
                self.guilds[user.guild_id]?.guild_scheduled_events[idx]
                    .user_ids?.remove(at: idx)
            }
            if self.guilds[user.guild_id]?.guild_scheduled_events[idx].user_count == nil {
                self.guilds[user.guild_id]?.guild_scheduled_events[idx].user_count = 0
            } else {
                self.guilds[user.guild_id]!.guild_scheduled_events[idx].user_count! -= 1
            }
        case let .guildAuditLogEntryCreate(log):
            self.auditLogs[log.target_id ?? "", default: []].append(log)
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
            self.messages[message.channel_id, default: []].append(message)
        case let .messageUpdate(message):
            if let idx = self.messages[message.channel_id]?
                .firstIndex(where: { $0.id == message.id }) {
                self.messages[message.channel_id]?.remove(at: idx)
            }
            if let idx = self.messages[message.channel_id]?
                .firstIndex(where: { $0.id == message.id }) {
                self.messages[message.channel_id]?[idx].update(with: message)
            }
        case let .messageDelete(message):
            if let idx = self.messages[message.channel_id]?
                .firstIndex(where: { $0.id == message.id }) {
                self.messages[message.channel_id]?.remove(at: idx)
            }
        case let .messageDeleteBulk(bulkDelete):
            self.messages[bulkDelete.channel_id]?.removeAll {
                bulkDelete.ids.contains($0.id)
            }
        case let .messageReactionAdd(reaction):
            if let idx = self.messages[reaction.channel_id]?
                .firstIndex(where: { $0.id == reaction.message_id }) {
                if let index = self.messages[reaction.channel_id]?[idx].reactions?
                    .firstIndex(where: { $0.emoji == reaction.emoji }) {
                    self.messages[reaction.channel_id]![idx].reactions![index].count += 1
                } else {
                    self.messages[reaction.channel_id]![idx].reactions?.append(.init(
                        count: 1,
                        me: false,
                        emoji: reaction.emoji
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
        }
    }
    
    private func intentsAllowCaching(event: Gateway.Event) -> Bool {
        guard let intents = intents else { return true }
        guard let correspondingIntents = event.data?.correspondingIntents else {
            return false
        }
        if correspondingIntents.isEmpty {
            return true
        } else if correspondingIntents.contains(where: { intents.contains($0) }) {
            return true
        } else {
            return false
        }
    }
}

private func == (lhs: PartialEmoji, rhs: PartialEmoji) -> Bool {
    lhs.id == rhs.id && lhs.name == rhs.name
}
