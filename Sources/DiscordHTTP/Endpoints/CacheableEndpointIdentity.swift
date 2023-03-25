/// The endpoints that can be cached. Basically the GET endpoints.
public enum CacheableEndpointIdentity: Sendable, Hashable, CustomStringConvertible {
    case apiEndpoint(CacheableAPIEndpointIdentity)
    case cdnEndpoint(CDNEndpointIdentity)
    
    init? (endpoint: APIEndpoint) {
        if let endpoint = CacheableAPIEndpointIdentity(endpoint: endpoint) {
            self = .apiEndpoint(endpoint)
        } else {
            return nil
        }
    }
    
    init(endpoint: CDNEndpoint) {
        self = .cdnEndpoint(CDNEndpointIdentity(endpoint: endpoint))
    }
    
    init(endpoint: any Endpoint) {
        if let endpoint = endpoint as? APIEndpoint {
            self = .init(endpoint: endpoint)
        } else if let endpoint = endpoint as? CDNEndpoint {
            self = .init(endpoint: endpoint)
        } else {
            fatalError("Unknown endpoint type: \(type(of: endpoint))")
        }
    }
    
    public var description: String {
        switch self {
        case .apiEndpoint(let cacheableAPIEndpointIdentity):
            return "apiEndpoint(\(cacheableAPIEndpointIdentity))"
        case .cdnEndpoint(let cdnEndpointIdentity):
            return "cdnEndpoint(\(cdnEndpointIdentity))"
        }
    }
}
