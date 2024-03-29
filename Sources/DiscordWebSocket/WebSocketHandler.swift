import NIO
import NIOWebSocket

extension WebSocket {
    public static func client(
        on channel: any Channel,
        decompression: Decompression.Configuration?,
        setWebSocket: @Sendable @escaping (WebSocket) async -> Void = { _ in },
        onBuffer: @Sendable @escaping (ByteBuffer) -> () = { _ in },
        onClose: @Sendable @escaping (WebSocket) -> () = { _ in }
    ) async throws -> WebSocket {
        let webSocket = try await WebSocket(
            channel: channel,
            decompression: decompression,
            setWebSocket: setWebSocket,
            onBuffer: onBuffer,
            onClose: onClose
        )
        try await channel.pipeline.addHandler(WebSocketHandler(webSocket: webSocket)).get()
        return webSocket
    }
}

extension WebSocketErrorCode {
    init(_ error: NIOWebSocketError) {
        switch error {
        case .invalidFrameLength:
            self = .messageTooLarge
        case .fragmentedControlFrame,
             .multiByteControlFrameLength:
            self = .protocolError
        }
    }
}

private final class WebSocketHandler: ChannelInboundHandler {
    typealias InboundIn = WebSocketFrame
    typealias OutboundOut = WebSocketFrame
    private var webSocket: WebSocket

    init(webSocket: WebSocket) {
        self.webSocket = webSocket
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let frame = self.unwrapInboundIn(data)
        self.webSocket.handle(incoming: frame)
    }

    func errorCaught(context: ChannelHandlerContext, error: any Error) {
        let errorCode: WebSocketErrorCode
        if let error = error as? NIOWebSocketError {
            errorCode = WebSocketErrorCode(error)
        } else {
            errorCode = .unexpectedServerError
        }
        _ = webSocket.closeWithFuture(code: errorCode)

        // We always forward the error on to let others see it.
        context.fireErrorCaught(error)
    }

    func channelInactive(context: ChannelHandlerContext) {
        let closedAbnormally = WebSocketErrorCode.unknown(1006)
        _ = webSocket.closeWithFuture(code: closedAbnormally)

        // We always forward the error on to let others see it.
        context.fireChannelInactive()
    }
}
