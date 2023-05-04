extension WebSocket {
    public static func connect(
        to url: String,
        headers: HTTPHeaders = [:],
        configuration: WebSocketClient.Configuration = .init(),
        on eventLoopGroup: EventLoopGroup,
        onText: @Sendable @escaping (ByteBuffer) -> () = { _ in },
        onBinary: @Sendable @escaping (ByteBuffer) -> () = { _ in }
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
            onText: onText,
            onBinary: onBinary
        )
    }
}
