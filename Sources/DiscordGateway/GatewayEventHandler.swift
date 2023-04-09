import DiscordModels

/// Convenience protocol for handling gateway payloads.
///
/// Create a type that conforms to `GatewayEventHandler`:
/// ```
/// struct EventHandler: GatewayEventHandler {
///     let event: Gateway.Event
///
///     func onMessageCreate(_ payload: Gateway.MessageCreate) async {
///         /// Do what you want
///     }
///
///     func onInteractionCreate(_ payload: Interaction) async {
///         /// Do what you want
///     }
///
///     /// Use other functions you'd like ...
/// }
/// ```
///
/// Make sure to actually use the type:
/// ```
/// let bot: any GatewayManager = YOUR_GATEWAY_MANAGER
///
/// await bot.addEventHandler { event in
///     EventHandler(event: event).handle()
/// }
/// ```
public protocol GatewayEventHandler: Sendable {
    var event: Gateway.Event { get }
    
    /// To be executed before handling events.
    /// If returns `false`, the event won't be passed to the functions below anymore.
    func onEventHandlerStart() async -> Bool
    
    func onChannelCreate(_ payload: DiscordChannel) async
    func onChannelUpdate(_ payload: DiscordChannel) async
    func onChannelDelete(_ payload: DiscordChannel) async
    func onChannelPinsUpdate(_ payload: Gateway.ChannelPinsUpdate) async
    func onThreadCreate(_ payload: DiscordChannel) async
    func onThreadUpdate(_ payload: DiscordChannel) async
    func onThreadDelete(_ payload: Gateway.ThreadDelete) async
    func onThreadSyncList(_ payload: Gateway.ThreadListSync) async
    func onThreadMemberUpdate(_ payload: Gateway.ThreadMemberUpdate) async
    func onThreadMembersUpdate(_ payload: Gateway.ThreadMembersUpdate) async
    func onGuildCreate(_ payload: Gateway.GuildCreate) async
    func onGuildUpdate(_ payload: Guild) async
    func onGuildDelete(_ payload: UnavailableGuild) async
    func onGuildBanAdd(_ payload: Gateway.GuildBan) async
    func onGuildBanRemove(_ payload: Gateway.GuildBan) async
    func onGuildEmojisUpdate(_ payload: Gateway.GuildEmojisUpdate) async
    func onGuildStickersUpdate(_ payload: Gateway.GuildStickersUpdate) async
    func onGuildIntegrationsUpdate(_ payload: Gateway.GuildIntegrationsUpdate) async
    func onGuildMemberAdd(_ payload: Gateway.GuildMemberAdd) async
    func onGuildMemberRemove(_ payload: Gateway.GuildMemberRemove) async
    func onGuildMemberUpdate(_ payload: Gateway.GuildMemberAdd) async
    func onGuildMembersChunk(_ payload: Gateway.GuildMembersChunk) async
    func onRequestGuildMembers(_ payload: Gateway.RequestGuildMembers) async
    func onGuildRoleCreate(_ payload: Gateway.GuildRole) async
    func onGuildRoleUpdate(_ payload: Gateway.GuildRole) async
    func onGuildRoleDelete(_ payload: Gateway.GuildRoleDelete) async
    func onGuildScheduledEventCreate(_ payload: GuildScheduledEvent) async
    func onGuildScheduledEventUpdate(_ payload: GuildScheduledEvent) async
    func onGuildScheduledEventDelete(_ payload: GuildScheduledEvent) async
    func onGuildScheduledEventUserAdd(_ payload: Gateway.GuildScheduledEventUser) async
    func onGuildScheduledEventUserRemove(_ payload: Gateway.GuildScheduledEventUser) async
    func onGuildAuditLogEntryCreate(_ payload: AuditLog.Entry) async
    func onIntegrationCreate(_ payload: Gateway.IntegrationCreate) async
    func onIntegrationUpdate(_ payload: Gateway.IntegrationCreate) async
    func onIntegrationDelete(_ payload: Gateway.IntegrationDelete) async
    func onInteractionCreate(_ payload: Interaction) async
    func onInviteCreate(_ payload: Gateway.InviteCreate) async
    func onInviteDelete(_ payload: Gateway.InviteDelete) async
    func onMessageCreate(_ payload: Gateway.MessageCreate) async
    func onMessageUpdate(_ payload: DiscordChannel.PartialMessage) async
    func onMessageDelete(_ payload: Gateway.MessageDelete) async
    func onMessageDeleteBulk(_ payload: Gateway.MessageDeleteBulk) async
    func onMessageReactionAdd(_ payload: Gateway.MessageReactionAdd) async
    func onMessageReactionRemove(_ payload: Gateway.MessageReactionRemove) async
    func onMessageReactionRemoveAll(_ payload: Gateway.MessageReactionRemoveAll) async
    func onMessageReactionRemoveEmoji(_ payload: Gateway.MessageReactionRemoveEmoji) async
    func onPresenceUpdate(_ payload: Gateway.PresenceUpdate) async
    func onRequestPresenceUpdate(_ payload: Gateway.Identify.Presence) async
    func onStageInstanceCreate(_ payload: StageInstance) async
    func onStageInstanceDelete(_ payload: StageInstance) async
    func onStageInstanceUpdate(_ payload: StageInstance) async
    func onTypingStart(_ payload: Gateway.TypingStart) async
    func onUserUpdate(_ payload: DiscordUser) async
    func onVoiceStateUpdate(_ payload: VoiceState) async
    func onRequestVoiceStateUpdate(_ payload: VoiceStateUpdate) async
    func onVoiceServerUpdate(_ payload: Gateway.VoiceServerUpdate) async
    func onWebhooksUpdate(_ payload: Gateway.WebhooksUpdate) async
    func onApplicationCommandPermissionsUpdate(_ payload: GuildApplicationCommandPermissions) async
    func onAutoModerationRuleCreate(_ payload: AutoModerationRule) async
    func onAutoModerationRuleUpdate(_ payload: AutoModerationRule) async
    func onAutoModerationRuleDelete(_ payload: AutoModerationRule) async
    func onAutoModerationActionExecution(_ payload: AutoModerationActionExecution) async
}

public extension GatewayEventHandler {
    @inlinable
    func handle() {
        Task {
            await self.handleAsync()
        }
    }
    
    // MARK: - Default Do-Nothings
    
    @inlinable
    func onEventHandlerStart() async -> Bool { true }
    
    func onChannelCreate(_: DiscordChannel) async { }
    func onChannelUpdate(_: DiscordChannel) async { }
    func onChannelDelete(_: DiscordChannel) async { }
    func onChannelPinsUpdate(_: Gateway.ChannelPinsUpdate) async { }
    func onThreadCreate(_: DiscordChannel) async { }
    func onThreadUpdate(_: DiscordChannel) async { }
    func onThreadDelete(_: Gateway.ThreadDelete) async { }
    func onThreadSyncList(_: Gateway.ThreadListSync) async { }
    func onThreadMemberUpdate(_: Gateway.ThreadMemberUpdate) async { }
    func onThreadMembersUpdate(_: Gateway.ThreadMembersUpdate) async { }
    func onGuildCreate(_: Gateway.GuildCreate) async { }
    func onGuildUpdate(_: Guild) async { }
    func onGuildDelete(_: UnavailableGuild) async { }
    func onGuildBanAdd(_: Gateway.GuildBan) async { }
    func onGuildBanRemove(_: Gateway.GuildBan) async { }
    func onGuildEmojisUpdate(_: Gateway.GuildEmojisUpdate) async { }
    func onGuildStickersUpdate(_: Gateway.GuildStickersUpdate) async { }
    func onGuildIntegrationsUpdate(_: Gateway.GuildIntegrationsUpdate) async { }
    func onGuildMemberAdd(_: Gateway.GuildMemberAdd) async { }
    func onGuildMemberRemove(_: Gateway.GuildMemberRemove) async { }
    func onGuildMemberUpdate(_: Gateway.GuildMemberAdd) async { }
    func onGuildMembersChunk(_: Gateway.GuildMembersChunk) async { }
    func onRequestGuildMembers(_: Gateway.RequestGuildMembers) async { }
    func onGuildRoleCreate(_: Gateway.GuildRole) async { }
    func onGuildRoleUpdate(_: Gateway.GuildRole) async { }
    func onGuildRoleDelete(_: Gateway.GuildRoleDelete) async { }
    func onGuildScheduledEventCreate(_: GuildScheduledEvent) async { }
    func onGuildScheduledEventUpdate(_: GuildScheduledEvent) async { }
    func onGuildScheduledEventDelete(_: GuildScheduledEvent) async { }
    func onGuildScheduledEventUserAdd(_: Gateway.GuildScheduledEventUser) async { }
    func onGuildScheduledEventUserRemove(_: Gateway.GuildScheduledEventUser) async { }
    func onGuildAuditLogEntryCreate(_: AuditLog.Entry) async { }
    func onIntegrationCreate(_: Gateway.IntegrationCreate) async { }
    func onIntegrationUpdate(_: Gateway.IntegrationCreate) async { }
    func onIntegrationDelete(_: Gateway.IntegrationDelete) async { }
    func onInteractionCreate(_: Interaction) async { }
    func onInviteCreate(_: Gateway.InviteCreate) async { }
    func onInviteDelete(_: Gateway.InviteDelete) async { }
    func onMessageCreate(_: Gateway.MessageCreate) async { }
    func onMessageUpdate(_: DiscordChannel.PartialMessage) async { }
    func onMessageDelete(_: Gateway.MessageDelete) async { }
    func onMessageDeleteBulk(_: Gateway.MessageDeleteBulk) async { }
    func onMessageReactionAdd(_: Gateway.MessageReactionAdd) async { }
    func onMessageReactionRemove(_: Gateway.MessageReactionRemove) async { }
    func onMessageReactionRemoveAll(_: Gateway.MessageReactionRemoveAll) async { }
    func onMessageReactionRemoveEmoji(_: Gateway.MessageReactionRemoveEmoji) async { }
    func onPresenceUpdate(_: Gateway.PresenceUpdate) async { }
    func onRequestPresenceUpdate(_: Gateway.Identify.Presence) async { }
    func onStageInstanceCreate(_: StageInstance) async { }
    func onStageInstanceDelete(_: StageInstance) async { }
    func onStageInstanceUpdate(_: StageInstance) async { }
    func onTypingStart(_: Gateway.TypingStart) async { }
    func onUserUpdate(_: DiscordUser) async { }
    func onVoiceStateUpdate(_: VoiceState) async { }
    func onRequestVoiceStateUpdate(_: VoiceStateUpdate) async { }
    func onVoiceServerUpdate(_: Gateway.VoiceServerUpdate) async { }
    func onWebhooksUpdate(_: Gateway.WebhooksUpdate) async { }
    func onApplicationCommandPermissionsUpdate(_: GuildApplicationCommandPermissions) async { }
    func onAutoModerationRuleCreate(_: AutoModerationRule) async { }
    func onAutoModerationRuleUpdate(_: AutoModerationRule) async { }
    func onAutoModerationRuleDelete(_: AutoModerationRule) async { }
    func onAutoModerationActionExecution(_: AutoModerationActionExecution) async { }
}

// MARK: - Handle
extension GatewayEventHandler {
    @inlinable
    func handleAsync() async {
        guard await self.onEventHandlerStart() else { return }
        
        switch event.data {
        case .none, .heartbeat, .identify, .hello, .ready, .resume, .resumed, .invalidSession:
            /// State management data, users don't need to touch these.
            break
        case let .channelCreate(payload):
            await onChannelCreate(payload)
        case let .channelUpdate(payload):
            await onChannelUpdate(payload)
        case let .channelDelete(payload):
            await onChannelDelete(payload)
        case let .channelPinsUpdate(payload):
            await onChannelPinsUpdate(payload)
        case let .threadCreate(payload):
            await onThreadCreate(payload)
        case let .threadUpdate(payload):
            await onThreadUpdate(payload)
        case let .threadDelete(payload):
            await onThreadDelete(payload)
        case let .threadSyncList(payload):
            await onThreadSyncList(payload)
        case let .threadMemberUpdate(payload):
            await onThreadMemberUpdate(payload)
        case let .threadMembersUpdate(payload):
            await onThreadMembersUpdate(payload)
        case let .guildCreate(payload):
            await onGuildCreate(payload)
        case let .guildUpdate(payload):
            await onGuildUpdate(payload)
        case let .guildDelete(payload):
            await onGuildDelete(payload)
        case let .guildBanAdd(payload):
            await onGuildBanAdd(payload)
        case let .guildBanRemove(payload):
            await onGuildBanRemove(payload)
        case let .guildEmojisUpdate(payload):
            await onGuildEmojisUpdate(payload)
        case let .guildStickersUpdate(payload):
            await onGuildStickersUpdate(payload)
        case let .guildIntegrationsUpdate(payload):
            await onGuildIntegrationsUpdate(payload)
        case let .guildMemberAdd(payload):
            await onGuildMemberAdd(payload)
        case let .guildMemberRemove(payload):
            await onGuildMemberRemove(payload)
        case let .guildMemberUpdate(payload):
            await onGuildMemberUpdate(payload)
        case let .guildMembersChunk(payload):
            await onGuildMembersChunk(payload)
        case let .requestGuildMembers(payload):
            await onRequestGuildMembers(payload)
        case let .guildRoleCreate(payload):
            await onGuildRoleCreate(payload)
        case let .guildRoleUpdate(payload):
            await onGuildRoleUpdate(payload)
        case let .guildRoleDelete(payload):
            await onGuildRoleDelete(payload)
        case let .guildScheduledEventCreate(payload):
            await onGuildScheduledEventCreate(payload)
        case let .guildScheduledEventUpdate(payload):
            await onGuildScheduledEventUpdate(payload)
        case let .guildScheduledEventDelete(payload):
            await onGuildScheduledEventDelete(payload)
        case let .guildScheduledEventUserAdd(payload):
            await onGuildScheduledEventUserAdd(payload)
        case let .guildScheduledEventUserRemove(payload):
            await onGuildScheduledEventUserRemove(payload)
        case let .guildAuditLogEntryCreate(payload):
            await onGuildAuditLogEntryCreate(payload)
        case let .integrationCreate(payload):
            await onIntegrationCreate(payload)
        case let .integrationUpdate(payload):
            await onIntegrationUpdate(payload)
        case let .integrationDelete(payload):
            await onIntegrationDelete(payload)
        case let .interactionCreate(payload):
            await onInteractionCreate(payload)
        case let .inviteCreate(payload):
            await onInviteCreate(payload)
        case let .inviteDelete(payload):
            await onInviteDelete(payload)
        case let .messageCreate(payload):
            await onMessageCreate(payload)
        case let .messageUpdate(payload):
            await onMessageUpdate(payload)
        case let .messageDelete(payload):
            await onMessageDelete(payload)
        case let .messageDeleteBulk(payload):
            await onMessageDeleteBulk(payload)
        case let .messageReactionAdd(payload):
            await onMessageReactionAdd(payload)
        case let .messageReactionRemove(payload):
            await onMessageReactionRemove(payload)
        case let .messageReactionRemoveAll(payload):
            await onMessageReactionRemoveAll(payload)
        case let .messageReactionRemoveEmoji(payload):
            await onMessageReactionRemoveEmoji(payload)
        case let .presenceUpdate(payload):
            await onPresenceUpdate(payload)
        case let .requestPresenceUpdate(payload):
            await onRequestPresenceUpdate(payload)
        case let .stageInstanceCreate(payload):
            await onStageInstanceCreate(payload)
        case let .stageInstanceDelete(payload):
            await onStageInstanceDelete(payload)
        case let .stageInstanceUpdate(payload):
            await onStageInstanceUpdate(payload)
        case let .typingStart(payload):
            await onTypingStart(payload)
        case let .userUpdate(payload):
            await onUserUpdate(payload)
        case let .voiceStateUpdate(payload):
            await onVoiceStateUpdate(payload)
        case let .requestVoiceStateUpdate(payload):
            await onRequestVoiceStateUpdate(payload)
        case let .voiceServerUpdate(payload):
            await onVoiceServerUpdate(payload)
        case let .webhooksUpdate(payload):
            await onWebhooksUpdate(payload)
        case let .applicationCommandPermissionsUpdate(payload):
            await onApplicationCommandPermissionsUpdate(payload)
        case let .autoModerationRuleCreate(payload):
            await onAutoModerationRuleCreate(payload)
        case let .autoModerationRuleUpdate(payload):
            await onAutoModerationRuleUpdate(payload)
        case let .autoModerationRuleDelete(payload):
            await onAutoModerationRuleDelete(payload)
        case let .autoModerationActionExecution(payload):
            await onAutoModerationActionExecution(payload)
        }
    }
}
