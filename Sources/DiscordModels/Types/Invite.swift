/// https://docs.discord.com/developers/resources/invite#invite-object-invite-structure
public struct Invite: Sendable, Codable {

    @UnstableEnum<_CompatibilityIntTypeAlias>
    public enum Kind: Sendable, Codable {
        case guild  // 0
        case groupDm  // 1
        case friend  // 2
        case __undocumented(_CompatibilityIntTypeAlias)
    }

    /// https://docs.discord.com/developers/resources/invite#invite-object-invite-target-types
    @UnstableEnum<_CompatibilityIntTypeAlias>
    public enum TargetKind: Sendable, Codable {
        case stream  // 1
        case embeddedApplication  // 2
        case __undocumented(_CompatibilityIntTypeAlias)
    }

    /// https://docs.discord.com/developers/resources/invite#invite-object-guild-invite-flags
    @UnstableEnum<_CompatibilityUIntTypeAlias>
    public enum Flag: Sendable {
        case isGuestInvite  // 0
        case __undocumented(_CompatibilityUIntTypeAlias)
    }

    public var type: Kind
    public var code: String
    public var guild: PartialGuild?
    public var channel: DiscordChannel?
    public var inviter: DiscordUser?
    public var target_type: TargetKind?
    public var target_user: DiscordUser?
    public var target_application: PartialApplication?
    public var approximate_presence_count: Int?
    public var approximate_member_count: Int?
    public var expires_at: DiscordTimestamp?
    public var guild_scheduled_event: GuildScheduledEvent?
    public var flags: IntBitField<Flag>?
}

/// https://docs.discord.com/developers/resources/invite#invite-object-invite-structure
/// https://docs.discord.com/developers/resources/invite#invite-metadata-object-invite-metadata-structure
public struct InviteWithMetadata: Sendable, Codable {
    public var type: Invite.Kind
    public var code: String
    public var guild: PartialGuild?
    public var channel: DiscordChannel?
    public var inviter: DiscordUser?
    public var target_type: Invite.TargetKind?
    public var target_user: DiscordUser?
    public var target_application: PartialApplication?
    public var approximate_presence_count: Int?
    public var approximate_member_count: Int?
    public var expires_at: DiscordTimestamp?
    public var guild_scheduled_event: GuildScheduledEvent?
    public var flags: IntBitField<Invite.Flag>?
    public var uses: Int
    public var max_uses: Int
    public var max_age: Int
    public var temporary: Bool
    public var created_at: DiscordTimestamp
}

/// https://docs.discord.com/developers/resources/invite#invite-object-invite-structure
public struct PartialInvite: Sendable, Codable {
    public var type: Invite.Kind?
    public var code: String?
    public var guild: PartialGuild?
    public var channel: DiscordChannel?
    public var inviter: DiscordUser?
    public var target_type: Invite.TargetKind?
    public var target_user: DiscordUser?
    public var target_application: PartialApplication?
    public var approximate_presence_count: Int?
    public var approximate_member_count: Int?
    public var expires_at: DiscordTimestamp?
    public var guild_scheduled_event: GuildScheduledEvent?
    public var flags: IntBitField<Invite.Flag>?
}
