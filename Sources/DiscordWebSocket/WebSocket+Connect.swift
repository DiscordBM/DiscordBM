extension WebSocket {
    public static func connect(
        to url: String,
        headers: HTTPHeaders = [:],
        configuration: WebSocketClient.Configuration = .init(),
        on eventLoopGroup: EventLoopGroup,
        onBuffer: @Sendable @escaping (ByteBuffer) -> () = { _ in },
        onClose: @Sendable @escaping (WebSocket) -> () = { _ in }
    ) async throws -> WebSocket {
        guard let url = URL(string: url) else {
            throw WebSocketClient.Error.invalidURL
        }
        let scheme = url.scheme ?? "ws"
        return try await WebSocketClient(
            eventLoopGroupProvider: .shared(eventLoopGroup),
            configuration: configuration
        ).connect(
            scheme: scheme,
            host: url.host ?? "localhost",
            port: url.port ?? (scheme == "wss" ? 443 : 80),
            path: url.path,
            query: url.query,
            headers: headers,
            onBuffer: onBuffer,
            onClose: onClose
        )
    }
}
