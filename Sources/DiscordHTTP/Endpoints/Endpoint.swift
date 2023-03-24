import NIOHTTP1

public protocol Endpoint: Sendable {
    var url: String { get }
    /// Doesn't expose secret url path parameters.
    var urlDescription: String { get }
    var httpMethod: HTTPMethod { get }
    /// Interaction endpoints don't count against the global rate limit.
    /// Even if the global rate-limit is exceeded, you can still respond to interactions.
    var countsAgainstGlobalRateLimit: Bool { get }
    /// Some endpoints like don't require an authorization header because the endpoint itself
    /// contains some kind of authorization token. Like some of the webhook endpoints.
    var requiresAuthorizationHeader: Bool { get }
    /// Path parameters.
    var parameters: [String] { get }
    var id: Int { get }
}
