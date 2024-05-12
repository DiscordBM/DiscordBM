
/// The endpoints that can be cached. Basically the GET endpoints.
/// UNSTABLE ENUM, DO NOT USE EXHAUSTIVE SWITCH STATEMENTS.
public enum CacheableEndpointIdentity: Sendable, Hashable, CustomStringConvertible {
    case api(CacheableAPIEndpointIdentity)
    case cdn(CDNEndpointIdentity)
    case loose(LooseEndpoint)

    @usableFromInline
    init? (endpoint: AnyEndpoint) {
        switch endpoint {
        case let .api(endpoint):
            if let endpoint = CacheableAPIEndpointIdentity(endpoint: endpoint) {
                self = .api(endpoint)
            } else {
                return nil
            }
        case let .cdn(endpoint):
            self = .cdn(CDNEndpointIdentity(endpoint: endpoint))
        case let .loose(endpoint):
            self = .loose(endpoint)
        }
    }
    
    public var description: String {
        switch self {
        case .api(let endpoint):
            return "CacheableEndpointIdentity.api(\(endpoint))"
        case .cdn(let endpoint):
            return "CacheableEndpointIdentity.cdn(\(endpoint))"
        case .loose(let endpoint):
            return "CacheableEndpointIdentity.loose(\(endpoint))"
        }
    }
}
