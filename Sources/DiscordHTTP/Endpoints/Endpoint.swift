import NIOHTTP1

public protocol Endpoint: Sendable, CustomStringConvertible {
    var url: String { get }
    /// Doesn't expose secret url path parameters.
    var urlDescription: String { get }
    var httpMethod: HTTPMethod { get }
    /// Interaction endpoints don't count against the global rate limit.
    /// Even if the global rate-limit is exceeded, you can still respond to interactions.
    /// So this is used for interaction endpoints.
    var countsAgainstGlobalRateLimit: Bool { get }
    /// Some endpoints don't require an authorization header, sometimes because the endpoint url
    /// itself contains some kind of authorization token. Like some of the webhook endpoints.
    var requiresAuthorizationHeader: Bool { get }
    /// Path parameters.
    var parameters: [String] { get }
    var id: Int { get }
}

/// Just to switch between the 3 endpoint types.
public enum AnyEndpoint: Endpoint {
    case api(APIEndpoint)
    case cdn(CDNEndpoint)
    case loose(LooseEndpoint)
    
    public var url: String {
        switch self {
        case let .api(endpoint):
            return endpoint.url
        case let .cdn(endpoint):
            return endpoint.url
        case let .loose(endpoint):
            return endpoint.url
        }
    }
    
    public var urlDescription: String {
        switch self {
        case let .api(endpoint):
            return endpoint.urlDescription
        case let .cdn(endpoint):
            return endpoint.urlDescription
        case let .loose(endpoint):
            return endpoint.urlDescription
        }
    }
    
    public var httpMethod: HTTPMethod {
        switch self {
        case let .api(endpoint):
            return endpoint.httpMethod
        case let .cdn(endpoint):
            return endpoint.httpMethod
        case let .loose(endpoint):
            return endpoint.httpMethod
        }
    }
    
    public var countsAgainstGlobalRateLimit: Bool {
        switch self {
        case let .api(endpoint):
            return endpoint.countsAgainstGlobalRateLimit
        case let .cdn(endpoint):
            return endpoint.countsAgainstGlobalRateLimit
        case let .loose(endpoint):
            return endpoint.countsAgainstGlobalRateLimit
        }
    }
    
    public var requiresAuthorizationHeader: Bool {
        switch self {
        case let .api(endpoint):
            return endpoint.requiresAuthorizationHeader
        case let .cdn(endpoint):
            return endpoint.requiresAuthorizationHeader
        case let .loose(endpoint):
            return endpoint.requiresAuthorizationHeader
        }
    }
    
    public var parameters: [String] {
        switch self {
        case let .api(endpoint):
            return endpoint.parameters
        case let .cdn(endpoint):
            return endpoint.parameters
        case let .loose(endpoint):
            return endpoint.parameters
        }
    }
    
    public var id: Int {
        switch self {
        case let .api(endpoint):
            return endpoint.id
        case let .cdn(endpoint):
            return -endpoint.id
        case let .loose(endpoint):
            return endpoint.id
        }
    }
    
    public var description: String {
        switch self {
        case let .api(endpoint):
            return "AnyEndpoint.api(\(endpoint))"
        case let .cdn(endpoint):
            return "AnyEndpoint.cdn(\(endpoint))"
        case let .loose(endpoint):
            return "AnyEndpoint.loose(\(endpoint))"
        }
    }
}
