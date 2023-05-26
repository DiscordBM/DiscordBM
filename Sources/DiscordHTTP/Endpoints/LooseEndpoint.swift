import enum NIOHTTP1.HTTPMethod

/// A loose endpoint.
/// Useful for getting data directly from a url.
public struct LooseEndpoint: Endpoint, Hashable {
    public var url: String

    public var urlDescription: String {
        self.url
    }

    public var httpMethod: HTTPMethod {
        .GET
    }

    public var requiresAuthorizationHeader: Bool {
        false
    }

    /// Only interaction endpoints don't count against the global rate-limit.
    public var countsAgainstGlobalRateLimit: Bool {
        true
    }

    public var parameters: [String] {
        []
    }

    public var id: Int {
        self.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(httpMethod.rawValue)
    }

    public var description: String {
        #"LooseEndpoint(url: "\#(url)", httpMethod: \#(httpMethod))"#
    }

    public init(url: String) {
        self.url = url
    }
}
