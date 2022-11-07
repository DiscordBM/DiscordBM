
/// https://discord.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-entry-structure
public struct AuditLog: Sendable, Codable {
    
    public struct Change: Sendable, Codable {
        public var new_value?    mixed (matches object field's type)    New value of the key
        public var old_value?    mixed (matches object field's type)    Old value of the key
        public var key: String
    }
    
    public enum EventKind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case guildUpdate = 1
        case channelCreate = 10
        case channelUpdate = 11
        case channelDelete = 12
        case channelOverwriteCreate = 13
        case channelOverwriteUpdate = 14
        case channelOverwriteDelete = 15
        case memberKick = 20
        case memberPrune = 21
        case memberBanAdd = 22
        case memberBanRemove = 23
        case memberUpdate = 24
        case memberRoleUpdate = 25
        case memberMove = 26
        case memberDisconnect = 27
        case botAdd = 28
        case roleCreate = 30
        case roleUpdate = 31
        case roleDelete = 32
        case inviteCreate = 40
        case inviteUpdate = 41
        case inviteDelete = 42
        case webhookCreate = 50
        case webhookUpdate = 51
        case webhookDelete = 52
        case emojiCreate = 60
        case emojiUpdate = 61
        case emojiDelete = 62
        case messageDelete = 72
        case messageBulkDelete = 73
        case messagePin = 74
        case messageUnpin = 75
        case integrationCreate = 80
        case integrationUpdate = 81
        case integrationDelete = 82
        case stageInstanceCreate = 83
        case stageInstanceUpdate = 84
        case stageInstanceDelete = 85
        case stickerCreate = 90
        case stickerUpdate = 91
        case stickerDelete = 92
        case guildScheduledEventCreate = 100
        case guildScheduledEventUpdate = 101
        case guildScheduledEventDelete = 102
        case threadCreate = 110
        case threadUpdate = 111
        case threadDelete = 112
        case applicationCommandPermissionUpdate = 121
        case autoModerationRuleCreate = 140
        case autoModerationRuleUpdate = 141
        case autoModerationRuleDelete = 142
        case autoModerationBlockMessage = 143
        case autoModerationFlagToChannel = 144
        case autoModerationUserCommunicationDisabled = 145
    }
    
    public enum EventPayload: Sendable, Codable {
        case guild(Guild)
        case channel(DiscordChannel)
        case channelOverwrite(DiscordChannel.Overwrite)
        case member(Guild.Member)
        case partialRole(Role) // PARTIAL
        case role(Role)
        case inviteAndMetadata()// ?
        case webhook(Webhook)
        case emoji(PartialEmoji)
    }
    
    public var target_id: String?
    public var changes: [Change]?
    public var user_id: String?
    public var id: String
    public var action_type: EventKind
    public var options: [Option]
    public var reason: String?
}
