import WSClient
import NIOWebSocket
import NIOCore
import CompressNIO

struct ZlibDecompressorWSExtension: WebSocketExtension, @unchecked Sendable {
    let name = "zlib-stream"
    let decompressor: ZlibDecompressor
    let allocator = ByteBufferAllocator()

    init() throws {
        self.decompressor = try ZlibDecompressor(algorithm: .zlib, windowSize: 15)
    }

    /// Process frame received from websocket
    func processReceivedFrame(_ frame: WebSocketFrame, context: WebSocketExtensionContext) throws -> WebSocketFrame {
        var frame = frame

        var decompressionBuffer = allocator.buffer(
            capacity: max(16_000, frame.data.readableBytes * 4)
        )

        try self.decompress(
            from: &frame.data,
            into: &decompressionBuffer,
            reserveCapacity: false
        )

        frame.data = consume decompressionBuffer

        return frame
    }

    func decompress(
        from frame: inout ByteBuffer,
        into buffer: inout ByteBuffer,
        reserveCapacity: Bool
    ) throws {
        if reserveCapacity {
            buffer.reserveCapacity(minimumWritableBytes: buffer.readableBytes)
        }
        do {
            try self.decompressor.inflate(
                from: &frame,
                to: &buffer
            )
        } catch let error as CompressNIOError where error == .bufferOverflow {
            try self.decompress(
                from: &frame,
                into: &buffer,
                reserveCapacity: true
            )
        }
    }

    /// Process frame about to be sent to websocket
    func processFrameToSend(_ frame: WebSocketFrame, context: WebSocketExtensionContext) -> WebSocketFrame {
        frame
    }

    func shutdown() {}
}
