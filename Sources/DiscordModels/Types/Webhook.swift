
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
public struct WebhookAddress: Hashable {
    
    public enum Error: Swift.Error {
        case invalidUrl(String)
    }
    
    public var id: String
    public var token: String
    
    /// For example if webhook url is https://discord.com/api/webhooks/1066284436045439037/dSs4nFhjpxcOh6HWD_5QJaq ,
    /// Then id is `1066284436045439037` and token is `dSs4nFhjpxcOh6HWD_5QJaq`.
    public static func deconstructed(id: String, token: String) -> WebhookAddress {
        WebhookAddress(id: id, token: token)
    }
    
    /// Example: https://discord.com/api/webhooks/1066284436045439037/dSs4nFhjpxcOh6HWD_5QJaq
    public static func url(_ url: String) throws -> WebhookAddress {
        guard let (id, token) = extractWebhookUrlIdAndToken(url) else {
            throw Error.invalidUrl(url)
        }
        return WebhookAddress(id: id, token: token)
    }
    
    @usableFromInline
    static func extractWebhookUrlIdAndToken(_ url: String) -> (id: String, token: String)? {
        guard let split = url
            .components(separatedBy: "api/webhooks/")
            .last?
            .split(separator: "/")
            .filter({ !$0.isEmpty })
        else { return nil }
        let id = String(split[split.count - 2])
        let token = String(split.last!)
        return (id, token)
    }
}
