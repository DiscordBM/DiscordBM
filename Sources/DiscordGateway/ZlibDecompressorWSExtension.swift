import WSClient
import NIOWebSocket
import NIOCore
import CompressNIO

/// Will be used for only 1 WS connection so won't need concurrency guards.
struct ZlibDecompressorWSExtension: WebSocketExtension, @unchecked Sendable {
    let name = "zlib-stream"
    let decompressor: ZlibDecompressor
    let allocator = ByteBufferAllocator()

    init() throws {
        self.decompressor = try ZlibDecompressor(algorithm: .zlib, windowSize: 15)
    }

    func processReceivedFrame(_ frame: WebSocketFrame, context: WebSocketExtensionContext) throws -> WebSocketFrame {
        var frame = frame
        frame.data = try self.decompress(from: &frame.data)
        return frame
    }

    func decompress(from frame: inout ByteBuffer) throws -> ByteBuffer {
        var buffer = allocator.buffer(
            /// `16_360 = 2^14 - 24`, `24` is accounting for allocation overheads.
            /// This doesn't really do anything as of now, since
            /// NIO will decide the final reserved capacity on its own anyway.
            capacity: max(16_360, frame.readableBytes * 4)
        )
        var isFirst = true
        while true {
            isFirst ? isFirst.toggle() : buffer.reserveCapacity(
                /// Double the capacity
                minimumWritableBytes: buffer.readableBytes
            )
            do {
                try self.decompressor.inflate(
                    from: &frame,
                    to: &buffer
                )
                return buffer
            } catch let error as CompressNIOError where error == .bufferOverflow {
                continue
            }
        }
    }

    func processFrameToSend(
        _ frame: WebSocketFrame,
        context: WebSocketExtensionContext
    ) -> WebSocketFrame {
        frame
    }

    func shutdown() {}
}
