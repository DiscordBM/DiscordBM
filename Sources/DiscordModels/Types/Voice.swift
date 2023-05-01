
/// https://discord.com/developers/docs/topics/gateway-events#update-voice-state-gateway-voice-state-update-structure
public struct VoiceState: Sendable, Codable {
    public var guild_id: Snowflake<Guild>
    public var channel_id: Snowflake<DiscordChannel>?
    public var user_id: Snowflake<DiscordUser>
    public var member: Guild.Member?
    public var session_id: String
    public var deaf: Bool
    public var mute: Bool
    public var self_deaf: Bool
    public var self_mute: Bool
    public var self_stream: Bool?
    public var self_video: Bool
    public var suppress: Bool
    public var request_to_speak_timestamp: DiscordTimestamp?
}

/// https://discord.com/developers/docs/topics/gateway-events#update-voice-state-gateway-voice-state-update-structure
public struct PartialVoiceState: Sendable, Codable {
    public var channel_id: Snowflake<DiscordChannel>?
    public var user_id: Snowflake<DiscordUser>
    public var member: Guild.Member?
    public var session_id: String
    public var deaf: Bool
    public var mute: Bool
    public var self_deaf: Bool
    public var self_mute: Bool
    public var self_stream: Bool?
    public var self_video: Bool
    public var suppress: Bool
    public var request_to_speak_timestamp: DiscordTimestamp?
    
    public init(voiceState: VoiceState) {
        self.channel_id = voiceState.channel_id
        self.user_id = voiceState.user_id
        self.member = voiceState.member
        self.session_id = voiceState.session_id
        self.deaf = voiceState.deaf
        self.mute = voiceState.mute
        self.self_deaf = voiceState.self_deaf
        self.self_mute = voiceState.self_mute
        self.self_stream = voiceState.self_stream
        self.self_video = voiceState.self_video
        self.suppress = voiceState.suppress
        self.request_to_speak_timestamp = voiceState.request_to_speak_timestamp
    }
}

/// https://discord.com/developers/docs/topics/gateway-events#update-voice-state-gateway-voice-state-update-structure
public struct VoiceStateUpdate: Sendable, Codable {
    public var guild_id: Snowflake<Guild>
    public var channel_id: Snowflake<DiscordChannel>?
    public var self_deaf: Bool
    public var self_mute: Bool
    
    /// For Gateway Voice-State update.
    public init(
        guildId: Snowflake<Guild>,
        channelId: Snowflake<DiscordChannel>? = nil,
        selfMute: Bool,
        selfDeaf: Bool
    ) {
        self.guild_id = guildId
        self.channel_id = channelId
        self.self_mute = selfMute
        self.self_deaf = selfDeaf
    }
}
