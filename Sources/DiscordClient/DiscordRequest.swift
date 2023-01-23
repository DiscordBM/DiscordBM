import NIOHTTP1

public struct DiscordRequest {
    public let endpoint: Endpoint
    public let queries: [(String, String?)]
    public let headers: HTTPHeaders
    public let includeAuthorization: Bool
    
    public init(
        to endpoint: Endpoint,
        queries: [(String, String?)] = [],
        headers: HTTPHeaders = [:],
        includeAuthorization: Bool = true
    ) {
        self.endpoint = endpoint
        self.queries = queries
        self.headers = headers
        self.includeAuthorization = includeAuthorization
    }
}
