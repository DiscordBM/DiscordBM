
/// https://discord.com/developers/docs/topics/gateway-events#update-voice-state-gateway-voice-state-update-structure
public struct VoiceState: Sendable, Codable {
    public var guild_id: String
    public var channel_id: String?
    public var self_mute: Bool
    public var self_deaf: Bool
    public var self_video: Bool?
    public var self_stream: Bool?
    public var user_id: String?
    public var mute: Bool?
    public var deaf: Bool?
    public var request_to_speak_timestamp: DiscordTimestamp?
    public var session_id: String?
    public var member: Guild.Member?
    public var suppress: Bool?
}

/// https://discord.com/developers/docs/resources/voice#voice-state-object-voice-state-structure
public struct PartialVoiceState: Sendable, Codable {
    public var guild_id: String?
    public var channel_id: String?
    public var user_id: String?
    public var member: Guild.Member?
    public var session_id: String?
    public var deaf: Bool?
    public var mute: Bool?
    public var self_deaf: Bool?
    public var self_mute: Bool?
    public var self_stream: Bool?
    public var self_video: Bool?
    public var suppress: Bool?
    public var request_to_speak_timestamp: DiscordTimestamp?
}
