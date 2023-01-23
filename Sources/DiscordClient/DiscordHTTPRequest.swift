import NIOHTTP1

public struct DiscordHTTPRequest {
    public let endpoint: Endpoint
    public let queries: [(String, String?)]
    public let headers: HTTPHeaders
    
    public init(
        to endpoint: Endpoint,
        queries: [(String, String?)] = [],
        headers: HTTPHeaders = [:]
    ) {
        self.endpoint = endpoint
        self.queries = queries
        self.headers = headers
    }
}
