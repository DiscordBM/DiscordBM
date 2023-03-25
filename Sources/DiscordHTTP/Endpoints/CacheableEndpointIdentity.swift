/// The endpoints that can be cached. Basically the GET endpoints.
public enum CacheableEndpointIdentity: Sendable, Hashable, CustomStringConvertible {
    case api(CacheableAPIEndpointIdentity)
    case cdn(CDNEndpointIdentity)
    
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
        }
    }
    
    public var description: String {
        switch self {
        case .api(let endpoint):
            return "api(\(endpoint))"
        case .cdn(let endpoint):
            return "cdn(\(endpoint))"
        }
    }
}
