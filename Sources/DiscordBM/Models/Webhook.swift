
/// https://discord.com/developers/docs/resources/webhook#webhook-object-webhook-structure
public struct Webhook: Sendable, Codable {
    
    /// https://discord.com/developers/docs/resources/webhook#webhook-object-webhook-types
    public enum Kind: Int, Sendable, Codable, ToleratesIntDecodeMarker {
        case incoming = 1
        case channelFollower = 2
        case application = 3
    }
    
    public var id: String
    public var type: Kind
    public var guild_id: String?
    public var channel_id: String?
    public var user: DiscordUser?
    public var name: String?
    public var avatar: String?
    public var token: String?
    public var application_id: String?
    public var source_guild: PartialGuild?
    public var source_channel: PartialChannel?
    public var url: String?
}
