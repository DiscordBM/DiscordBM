import Logging
import NIOCore
import XCTest
import libzstd

@testable import DiscordGateway

class ZstdDecompressorTests: XCTestCase {

    /// The decompressor sizes its first output buffer at `max(4096, 8 * compressedBytes)` and grows
    /// it only when `ZSTD_decompressStream` reports that the buffer filled up. JSON payloads
    /// routinely compress better than 8x, so this path runs on real gateway traffic: the guild
    /// payloads Discord sends right after `READY` are large and highly repetitive.
    func testPayloadThatCompressesBetterThanTheInitialBufferGuess() throws {
        let payload = Array(
            String(repeating: #"{"id":"1234567890123456789","name":"a-channel","type":0},"#, count: 500)
                .utf8
        )
        var frame = try self.compress(payload)
        /// Guards the premise of the test: a payload compressing 8x or less never fills the buffer.
        XCTAssertGreaterThan(payload.count, frame.readableBytes * 8)

        let decompressor = try ZstdDecompressorWSExtension(logger: Logger(label: "test"))
        let decompressed = try decompressor.decompress(
            compressedBytes: frame.readableBytes,
            from: &frame
        )

        XCTAssertEqual(Array(decompressed.readableBytesView), payload)
    }

    /// A payload small enough to fit in the first buffer, to keep the single-round path covered.
    func testPayloadThatFitsInTheInitialBuffer() throws {
        let payload = Array(#"{"op":11}"#.utf8)
        var frame = try self.compress(payload)

        let decompressor = try ZstdDecompressorWSExtension(logger: Logger(label: "test"))
        let decompressed = try decompressor.decompress(
            compressedBytes: frame.readableBytes,
            from: &frame
        )

        XCTAssertEqual(Array(decompressed.readableBytesView), payload)
    }

    /// The decompression context is shared across the frames of one connection, so consecutive
    /// frames must keep decoding correctly after a frame that needed the buffer to grow.
    func testConsecutiveFramesOnTheSameDecompressor() throws {
        let decompressor = try ZstdDecompressorWSExtension(logger: Logger(label: "test"))

        for count in [500, 1, 500] {
            let payload = Array(String(repeating: #"{"t":"MESSAGE_CREATE"},"#, count: count).utf8)
            var frame = try self.compress(payload)
            let decompressed = try decompressor.decompress(
                compressedBytes: frame.readableBytes,
                from: &frame
            )
            XCTAssertEqual(Array(decompressed.readableBytesView), payload)
        }
    }

    private func compress(_ bytes: [UInt8], file: StaticString = #filePath, line: UInt = #line) throws -> ByteBuffer {
        let bound = ZSTD_compressBound(bytes.count)
        var destination = [UInt8](repeating: 0, count: bound)
        let written = destination.withUnsafeMutableBytes { destinationBytes in
            bytes.withUnsafeBytes { sourceBytes in
                ZSTD_compress(
                    destinationBytes.baseAddress,
                    bound,
                    sourceBytes.baseAddress,
                    bytes.count,
                    ZSTD_defaultCLevel()
                )
            }
        }
        XCTAssertEqual(ZSTD_isError(written), 0, "zstd compression failed", file: file, line: line)
        return ByteBuffer(bytes: destination[..<written])
    }
}
