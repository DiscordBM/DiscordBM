
/// https://discord.com/developers/docs/resources/invite#invite-object-invite-structure
public struct Invite: Sendable, Codable {

    /// https://discord.com/developers/docs/resources/invite#invite-object-invite-target-types
    public enum TargetKind: Int, Sendable, Codable {
        case stream = 1
        case embeddedApplication = 2
    }

    public let code: String
    public let guild: PartialGuild?
    public let channel: DiscordChannel?
    public let inviter: DiscordUser?
    public let target_type: TargetKind?
    public let target_user: DiscordUser?
    public let target_application: PartialApplication?
    public let approximate_presence_count: Int?
    public let approximate_member_count: Int?
    public let expires_at: DiscordTimestamp?
    public let guild_scheduled_event: GuildScheduledEvent?
}

/// https://discord.com/developers/docs/resources/invite#invite-object-invite-structure
/// https://discord.com/developers/docs/resources/invite#invite-metadata-object-invite-metadata-structure
public struct InviteWithMetadata: Sendable, Codable {
    public let code: String
    public let guild: PartialGuild?
    public let channel: DiscordChannel?
    public let inviter: DiscordUser?
    public let target_type: Invite.TargetKind?
    public let target_user: DiscordUser?
    public let target_application: PartialApplication?
    public let approximate_presence_count: Int?
    public let approximate_member_count: Int?
    public let expires_at: DiscordTimestamp?
    public let guild_scheduled_event: GuildScheduledEvent?
    public var uses: Int
    public var max_uses: Int
    public var max_age: Int
    public var temporary: Bool
    public var created_at: DiscordTimestamp
}

/// https://discord.com/developers/docs/resources/invite#invite-object-invite-structure
public struct PartialInvite: Sendable, Codable {
    public let code: String?
    public let guild: PartialGuild?
    public let channel: DiscordChannel?
    public let inviter: DiscordUser?
    public let target_type: Invite.TargetKind?
    public let target_user: DiscordUser?
    public let target_application: PartialApplication?
    public let approximate_presence_count: Int?
    public let approximate_member_count: Int?
    public let expires_at: DiscordTimestamp?
    public let guild_scheduled_event: GuildScheduledEvent?
}
