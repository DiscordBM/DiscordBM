import DiscordModels

actor DiscordCache {
    
    let intents: Set<Gateway.Intent>?
    /// `[GuildID: Guild]`
    public var guilds: [String: Gateway.GuildCreate] = [:]
    /// Non-guild channels
    public var channels: [String: DiscordChannel] = [:]
    /// `[TargetID]: [AuditLog.Entry]]`
    /// A target id of `""` is used for entries that don't have a `target_id`.
    public var auditLogs: [String: [AuditLog.Entry]] = [:]
    
    init(gatewayManager: any GatewayManager, intents: Set<Gateway.Intent>?) async {
        self.intents = intents
        await gatewayManager.addEventHandler(handleEvent)
    }
    
    func handleEvent(_ event: Gateway.Event) {
        guard intentsAllowCaching(event: event) else { return }
        switch event.data {
        case .none, .heartbeat, .identify, .hello, .ready, .resume, .resumed, .invalidSession, .requestGuildMembers, .interactionCreate:
            break
        case let .guildCreate(guildCreate):
            self.guilds[guildCreate.id] = guildCreate
        case let .guildUpdate(guild):
            self.guilds[guild.id]?.update(with: guild)
        case let .guildDelete(guildDelete):
            self.guilds.removeValue(forKey: guildDelete.id)
        case let .channelCreate(channel), let .channelUpdate(channel):
            if let guildId = channel.guild_id {
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
                self.guilds[guildId]?.threads.append(channel)
            } else {
                self.channels[channel.id] = channel
            }
        case let .threadUpdate(channel):
            if let guildId = channel.guild_id {
                if let existingIndex = self.guilds[guildId]?.threads
                    .firstIndex(where: { $0.id == channel.id }) {
                    self.guilds[guildId]?.threads.remove(at: existingIndex)
                    self.guilds[guildId]?.threads.insert(channel, at: existingIndex)
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
                set { self.guilds[syncList.guild_id]  = newValue}
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
        case let .guildBanAdd(ban):
            if let idx = self.guilds[ban.guild_id]?.members
                .firstIndex(where: { $0.user?.id == ban.user.id }) {
                self.guilds[ban.guild_id]?.members.remove(at: idx)
            }
        case .guildBanRemove:
            /// Nothing to do?
            break
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
        case .guildIntegrationsUpdate:
            /// Nothing to do?
            break
        case let .guildMemberAdd(member):
            self.guilds[member.guild_id]?.members.append(.init(guildMemberAdd: member))
        case let .guildMemberRemove(member):
            if let idx = self.guilds[member.guild_id]?.members
                .firstIndex(where: { $0.user?.id == member.user.id }) {
                self.guilds[member.guild_id]?.members.remove(at: idx)
            }
        case let .guildMemberUpdate(member):
            if let idx = self.guilds[member.guild_id]?.members
                .firstIndex(where: { $0.user?.id == member.user.id }) {
                self.guilds[member.guild_id]?.members.remove(at: idx)
            }
            self.guilds[member.guild_id]?.members.append(.init(guildMemberAdd: member))
        case let .guildMembersChunk(chunk):
            self.guilds[chunk.guild_id]?.members.append(contentsOf: chunk.members)
            if let presences = chunk.presences {
                self.guilds[chunk.guild_id]?.presences.append(contentsOf: presences)
            }
        case let .guildRoleCreate(role):
            self.guilds[role.guild_id]?.roles.append(role.role)
        case let .guildRoleUpdate(role):
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
        case let .guildScheduledEventCreate(event):
            self.guilds[event.guild_id]?.guild_scheduled_events.append(event)
        case let .guildScheduledEventUpdate(event):
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
            if let idx = self.guilds[user.guild_id]?.guild_scheduled_events
                .firstIndex(where: { $0.id == user.guild_scheduled_event_id }) {
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
            }
        case let .guildScheduledEventUserRemove(user):
            if let idx = self.guilds[user.guild_id]?.guild_scheduled_events
                .firstIndex(where: { $0.id == user.guild_scheduled_event_id }) {
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
            }
        case .threadMembersUpdate, .applicationCommandPermissionsUpdate, .userUpdate, .voiceServerUpdate:
            /// FIXME: unhandled
            break
        case let .guildAuditLogEntryCreate(log):
            self.auditLogs[log.target_id ?? "", default: []].append(log)
//        case .integrationCreate(_):
//        case .integrationUpdate(_):
//        case .integrationDelete(_):
//        case .inviteCreate(_):
//        case .inviteDelete(_):
//        case .messageCreate(_):
//        case .messageUpdate(_):
//        case .messageDelete(_):
//        case .messageDeleteBulk(_):
//        case .messageReactionAdd(_):
//        case .messageReactionRemove(_):
//        case .messageReactionRemoveAll(_):
//        case .messageReactionRemoveEmoji(_):
//        case .presenceUpdate(_):
//        case .stageInstanceCreate(_):
//        case .stageInstanceDelete(_):
//        case .stageInstanceUpdate(_):
//        case .typingStart(_):
//        case .voiceStateUpdate(_):
//        case .webhooksUpdate(_):
//        case .autoModerationRuleCreate(_):
//        case .autoModerationRuleUpdate(_):
//        case .autoModerationRuleDelete(_):
//        case .autoModerationActionExecution(_):
        default: break; #warning("remove")
        }
    }
    
    private func intentsAllowCaching(event: Gateway.Event) -> Bool {
        guard let correspondingIntents = event.data?.correspondingIntents else {
            return false
        }
        guard let intents = intents else { return true }
        if correspondingIntents.isEmpty {
            return true
        } else if correspondingIntents.contains(where: { intents.contains($0) }) {
            return true
        } else {
            return false
        }
    }
}
