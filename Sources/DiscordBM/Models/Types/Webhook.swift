
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

/// The address of a Webhook.
public enum WebhookAddress: Hashable {
    /// Example: https://discord.com/api/webhooks/1066284436045439037/dSs4nFhjpxcOh6HWD_5QJaq
    case url(String)
    /// For example if webhook url is https://discord.com/api/webhooks/1066284436045439037/dSs4nFhjpxcOh6HWD_5QJaq ,
    /// Then id is `1066284436045439037` and token is `dSs4nFhjpxcOh6HWD_5QJaq`.
    case deconstructed(id: String, token: String)
    
    @usableFromInline
    func toIdAndToken() -> (id: String, token: String)? {
        switch self {
        case let .url(url):
            return DiscordUtils.extractWebhookIdAndToken(webhookUrl: url)
        case let .deconstructed(id, token):
            return (id, token)
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        if let (id, token) = self.toIdAndToken() {
            hasher.combine(id)
            hasher.combine(token)
        } else {
            hasher.combine(0)
        }
    }
}
