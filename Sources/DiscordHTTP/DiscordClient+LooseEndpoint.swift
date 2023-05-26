import enum NIOHTTP1.HTTPMethod

public extension DiscordClient {
    /// https://discord.com/developers/docs/reference#image-formatting-cdn-endpoints
    @inlinable
    func getFromCDN(url: String) async throws -> DiscordCDNResponse {
        let endpoint = LooseEndpoint(url: url)
        let fallbackName: String = url
            .split(separator: "/").last?
            .split(separator: ".").first
            .map { String($0) } ?? "unknown"
        return try await self.send(request: .init(to: endpoint), fallbackFileName: fallbackName)
    }
}
