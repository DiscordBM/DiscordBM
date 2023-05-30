extension WebSocket {
    public static func connect(
        to url: String,
        headers: HTTPHeaders = [:],
        configuration: WebSocketClient.Configuration = .init(),
        on eventLoopGroup: any EventLoopGroup,
        setWebSocket: @Sendable @escaping (WebSocket) async -> Void = { _ in },
        onBuffer: @Sendable @escaping (ByteBuffer) -> () = { _ in },
        onClose: @Sendable @escaping (WebSocket) -> () = { _ in }
    ) async throws -> WebSocket {
        guard let url = URL(string: url) else {
            throw WebSocketClient.Error.invalidURLString(url)
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
            setWebSocket: setWebSocket,
            onBuffer: onBuffer,
            onClose: onClose
        )
    }
}
