import WSClient
import NIOWebSocket
import NIOCore
import CompressNIO
import Logging

private let zlibAllocator = ByteBufferAllocator()

/// Will be used for only 1 WS connection so won't need concurrency guards.
struct ZlibDecompressorWSExtension: WebSocketExtension, @unchecked Sendable {
    let name = "zlib-stream"
    let decompressor: ZlibDecompressor
    let logger: Logger

    init(logger: Logger) throws {
        self.decompressor = try ZlibDecompressor(algorithm: .zlib, windowSize: 15)
        self.logger = logger
    }

    func processReceivedFrame(_ frame: WebSocketFrame, context: WebSocketExtensionContext) throws -> WebSocketFrame {
        var frame = frame
        let frameReadableBytes = frame.data.readableBytes
        frame.data = try self.decompress(from: &frame.data)
        logger.trace("Decompressed a Discord message", metadata: [
            "compressedBytes": .stringConvertible(frameReadableBytes),
            "decompressedBytes": .stringConvertible(frame.data.readableBytes),
            "compressionRatio": .stringConvertible(Double(frame.data.readableBytes) / Double(frameReadableBytes))
        ])
        return frame
    }

    func decompress(from frame: inout ByteBuffer) throws -> ByteBuffer {
        var buffer = zlibAllocator.buffer(
            /// `16_360 = 2^14 - 24`, `24` is accounting for allocation overheads.
            /// This doesn't really do anything as of now, since
            /// NIO will decide the final reserved capacity on its own anyway.
            ///
            /// The `* 16` of `frame.readableBytes * 16` comes based on this link:
            /// https://discord.com/blog/how-discord-reduced-websocket-traffic-by-40-percent
            /// which mentions up to `~14` times compression ratio for Discord events with zlib.
            /// Since Discord events are never way too big, I preferred to overestimate the
            /// possible ratio, rather than underestimating by using `* 4` or `* 8`.
            capacity: max(16_360, frame.readableBytes * 16)
        )
        while true {
            do {
                try self.decompressor.inflate(
                    from: &frame,
                    to: &buffer
                )
                /// If no errors were thrown then the decompression must have fully succeeded.
                return buffer
            } catch let error as CompressNIOError where error == .bufferOverflow {
                /// If we have a `.bufferOverflow`,
                /// double the capacity and continue decompression.
                buffer.reserveCapacity(minimumWritableBytes: buffer.readableBytes)
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
