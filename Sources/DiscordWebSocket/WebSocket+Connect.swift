extension WebSocket {
    public static func connect(
        to url: String,
        headers: HTTPHeaders = [:],
        configuration: WebSocketClient.Configuration = .init(),
        on eventLoopGroup: EventLoopGroup
    ) async throws -> WebSocket {
        guard let url = URL(string: url) else {
            throw WebSocketClient.Error.invalidURL
        }
        return try await self.connect(
            to: url,
            headers: headers,
            configuration: configuration,
            on: eventLoopGroup
        )
    }

    public static func connect(
        to url: URL,
        headers: HTTPHeaders = [:],
        configuration: WebSocketClient.Configuration = .init(),
        on eventLoopGroup: EventLoopGroup
    ) async throws -> WebSocket {
        let scheme = url.scheme ?? "ws"
        return try await self.connect(
            scheme: scheme,
            host: url.host ?? "localhost",
            port: url.port ?? (scheme == "wss" ? 443 : 80),
            path: url.path,
            query: url.query,
            headers: headers,
            configuration: configuration,
            on: eventLoopGroup
        )
    }

    public static func connect(
        scheme: String = "ws",
        host: String,
        port: Int = 80,
        path: String = "/",
        query: String? = nil,
        headers: HTTPHeaders = [:],
        configuration: WebSocketClient.Configuration = .init(),
        on eventLoopGroup: EventLoopGroup
    ) async throws -> WebSocket {
        return try await WebSocketClient(
            eventLoopGroupProvider: .shared(eventLoopGroup),
            configuration: configuration
        ).connect(
            scheme: scheme,
            host: host,
            port: port,
            path: path,
            query: query,
            headers: headers
        )
    }
}
