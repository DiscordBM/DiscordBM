import WSClient
import NIOWebSocket
import NIOCore
import CompressNIO

struct ZlibDecompressorWSExtension: WebSocketExtension, @unchecked Sendable {

    enum Error: Swift.Error, CustomStringConvertible {
        case expectedZSyncFlushBytesInTheEnd(buffer: ByteBuffer)

        var description: String {
            switch self {
            case .expectedZSyncFlushBytesInTheEnd(let buffer):
                "ZlibDecompressorWSExtension.Error.expectedZSyncFlushBytesInTheEnd(buffer: \(buffer))"
            }
        }
    }

    let name = "zlib-stream"
    let decompressor: ZlibDecompressor

    init() throws {
        self.decompressor = try ZlibDecompressor(algorithm: .zlib, windowSize: 15)
    }

    /// Process frame received from websocket
    func processReceivedFrame(_ frame: WebSocketFrame, context: WebSocketExtensionContext) throws -> WebSocketFrame {
        var frame = frame

        var decompressionBuffer = ByteBuffer()
        decompressionBuffer.reserveCapacity(
            max(16_000, frame.data.readableBytes * 4)
        )

        try self.decompressor.inflate(
            from: &frame.data,
            to: &decompressionBuffer
        )

        frame.data = consume decompressionBuffer

        return frame
    }

    /// Process frame about to be sent to websocket
    func processFrameToSend(_ frame: WebSocketFrame, context: WebSocketExtensionContext) -> WebSocketFrame {
        frame
    }

    func shutdown() {}
}
