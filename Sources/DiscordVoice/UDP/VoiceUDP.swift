import DiscordModels
import Foundation
import Logging
import NIOCore
import NIOPosix

/// Errors thrown by `VoiceUDP`.
public enum VoiceUDPError: Error, CustomStringConvertible {
    case discoveryTimeout
    case invalidDiscoveryResponse(String)
    case notConnected
    case channelClosed

    public var description: String {
        switch self {
        case .discoveryTimeout:
            return "VoiceUDPError.discoveryTimeout"
        case let .invalidDiscoveryResponse(reason):
            return "VoiceUDPError.invalidDiscoveryResponse(\(reason))"
        case .notConnected:
            return "VoiceUDPError.notConnected"
        case .channelClosed:
            return "VoiceUDPError.channelClosed"
        }
    }
}

/// Parses an IP discovery response packet per Discord's voice UDP protocol.
/// Response packet is 74 bytes:
/// - bytes 0..1: type = 2 (UInt16 BE)
/// - bytes 2..3: length = 70 (UInt16 BE)
/// - bytes 4..7: ssrc (UInt32 BE)
/// - bytes 8..71: null-terminated / null-padded IP address string (64 bytes)
/// - bytes 72..73: port (UInt16 BE)
///
/// https://discord.com/developers/docs/topics/voice-connections#ip-discovery
func parseDiscoveryResponse(_ bytes: [UInt8], expectedSSRC: UInt32) -> Result<(ip: String, port: UInt16), VoiceUDPError>
{
    guard bytes.count == 74 else {
        return .failure(.invalidDiscoveryResponse("Expected 74 bytes, got \(bytes.count)"))
    }
    let type = (UInt16(bytes[0]) << 8) | UInt16(bytes[1])
    guard type == 2 else {
        return .failure(.invalidDiscoveryResponse("Expected type 2, got \(type)"))
    }
    let length = (UInt16(bytes[2]) << 8) | UInt16(bytes[3])
    guard length == 70 else {
        return .failure(.invalidDiscoveryResponse("Expected length 70, got \(length)"))
    }
    let ssrc =
        (UInt32(bytes[4]) << 24)
        | (UInt32(bytes[5]) << 16)
        | (UInt32(bytes[6]) << 8)
        | UInt32(bytes[7])
    guard ssrc == expectedSSRC else {
        return .failure(.invalidDiscoveryResponse("SSRC mismatch: expected \(expectedSSRC), got \(ssrc)"))
    }

    let ipBytes = bytes[8..<72]
    guard let nullIdx = ipBytes.firstIndex(of: 0) else {
        return .failure(.invalidDiscoveryResponse("No null terminator in IP string"))
    }
    let validIPBytes = bytes[8..<nullIdx]
    guard let ip = String(bytes: validIPBytes, encoding: .ascii), !ip.isEmpty else {
        return .failure(.invalidDiscoveryResponse("Invalid ASCII IP string"))
    }

    let port = (UInt16(bytes[72]) << 8) | UInt16(bytes[73])
    return .success((ip: ip, port: port))
}

/// Actor managing the UDP connection to Discord's voice server.
/// Handles IP discovery, sending audio datagrams, and receiving inbound packets.
///
/// https://discord.com/developers/docs/topics/voice-connections#establishing-a-voice-udp-connection
public actor VoiceUDP {

    private var channel: (any Channel)?
    private let eventLoopGroup: any EventLoopGroup
    private let logger: Logger
    private var sequence: UInt16 = 0
    private var timestamp: UInt32 = 0
    private var ssrc: UInt32 = 0
    private var serverAddress: SocketAddress?
    private var keepAliveTask: Task<Void, Never>?
    private var keepAliveCounter: UInt64 = 0

    private let audioStream: AsyncStream<[UInt8]>
    private let audioContinuation: AsyncStream<[UInt8]>.Continuation
    private let discoveryStream: AsyncStream<[UInt8]>
    private let discoveryContinuation: AsyncStream<[UInt8]>.Continuation

    /// Stream of all inbound UDP datagrams received on this socket.
    public var packets: AsyncStream<[UInt8]> {
        audioStream
    }

    public init(eventLoopGroup: any EventLoopGroup) {
        self.eventLoopGroup = eventLoopGroup
        let logger = DiscordGlobalConfiguration.makeLogger("VoiceUDP")
        self.logger = logger
        let (aStream, aContinuation) = AsyncStream<[UInt8]>.makeStream()
        self.audioStream = aStream
        self.audioContinuation = aContinuation
        let (dStream, dContinuation) = AsyncStream<[UInt8]>.makeStream()
        self.discoveryStream = dStream
        self.discoveryContinuation = dContinuation
    }

    /// Performs IP discovery to find our external IP and port as seen by Discord.
    ///
    /// - Parameters:
    ///   - ip: The voice server IP provided in the Ready event.
    ///   - port: The voice server port provided in the Ready event.
    ///   - ssrc: The bot's assigned SSRC from the Ready event.
    /// - Returns: Our external IP and port.
    public func discover(
        ip: String,
        port: Int,
        ssrc: UInt32
    ) async throws -> (ip: String, port: UInt16) {
        self.ssrc = ssrc
        let targetAddress = try SocketAddress(ipAddress: ip, port: port)
        self.serverAddress = targetAddress

        let aCont = self.audioContinuation
        let dCont = self.discoveryContinuation
        let group = (self.eventLoopGroup as? MultiThreadedEventLoopGroup) ?? MultiThreadedEventLoopGroup.singleton
        let bootstrap = DatagramBootstrap(group: group)
            .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .channelInitializer { channel in
                channel.pipeline.addHandler(
                    VoiceUDPInboundHandler(audioContinuation: aCont, discoveryContinuation: dCont)
                )
            }

        let channel = try await bootstrap.bind(host: "0.0.0.0", port: 0).get()
        self.channel = channel

        // Construct 74-byte discovery packet
        var discoveryPacket = [UInt8](repeating: 0, count: 74)
        discoveryPacket[0] = 0x00
        discoveryPacket[1] = 0x01  // Type = 1 (Request)
        discoveryPacket[2] = 0x00
        discoveryPacket[3] = 0x46  // Length = 70
        discoveryPacket[4] = UInt8((ssrc >> 24) & 0xFF)
        discoveryPacket[5] = UInt8((ssrc >> 16) & 0xFF)
        discoveryPacket[6] = UInt8((ssrc >> 8) & 0xFF)
        discoveryPacket[7] = UInt8(ssrc & 0xFF)

        var buffer = channel.allocator.buffer(capacity: 74)
        buffer.writeBytes(discoveryPacket)
        let envelope = AddressedEnvelope(remoteAddress: targetAddress, data: buffer)
        try await channel.writeAndFlush(envelope)

        logger.debug("Sent IP discovery packet, waiting for response", metadata: ["ssrc": .stringConvertible(ssrc)])

        // Wait up to 5 seconds for response
        return try await withThrowingTaskGroup(of: (ip: String, port: UInt16).self) { group in
            group.addTask { [discoveryStream] in
                for await packet in discoveryStream {
                    switch parseDiscoveryResponse(packet, expectedSSRC: ssrc) {
                    case let .success(result):
                        return result
                    case .failure:
                        continue
                    }
                }
                throw VoiceUDPError.channelClosed
            }

            group.addTask {
                try await Task.sleep(for: .seconds(5))
                throw VoiceUDPError.discoveryTimeout
            }

            guard let result = try await group.next() else {
                throw VoiceUDPError.discoveryTimeout
            }
            group.cancelAll()
            self.startKeepAlive()
            return result
        }
    }

    /// Starts sending 5-second UDP keep-alive datagrams per Discord specification.
    ///
    /// https://discord.com/developers/docs/topics/voice-connections#establishing-a-voice-udp-connection
    private func startKeepAlive() {
        keepAliveTask?.cancel()
        keepAliveTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))
                guard let self, !Task.isCancelled else { break }
                await self.sendKeepAlive()
            }
        }
    }

    private func sendKeepAlive() {
        guard let channel = self.channel, let serverAddress = self.serverAddress else { return }
        var buffer = channel.allocator.buffer(capacity: 8)
        buffer.writeInteger(UInt32(truncatingIfNeeded: keepAliveCounter), endianness: .little)
        buffer.writeInteger(UInt32(0), endianness: .little)
        keepAliveCounter &+= 1
        let envelope = AddressedEnvelope(remoteAddress: serverAddress, data: buffer)
        _ = channel.writeAndFlush(envelope)
    }

    /// Sends an encrypted packet over UDP to the Discord voice server.
    public func send(_ packet: [UInt8]) async throws {
        guard let channel = self.channel, let serverAddress = self.serverAddress else {
            throw VoiceUDPError.notConnected
        }
        var buffer = channel.allocator.buffer(capacity: packet.count)
        buffer.writeBytes(packet)
        let envelope = AddressedEnvelope(remoteAddress: serverAddress, data: buffer)
        try await channel.writeAndFlush(envelope)
    }

    /// Closes the UDP socket.
    public func close() async {
        keepAliveTask?.cancel()
        keepAliveTask = nil
        discoveryContinuation.finish()
        audioContinuation.finish()
        if let channel = self.channel {
            try? await channel.close()
            self.channel = nil
        }
    }
}

/// Simple NIO inbound handler that routes incoming datagram payloads:
/// 74-byte discovery response packets go to discoveryContinuation, and audio datagrams to audioContinuation.
private final class VoiceUDPInboundHandler: ChannelInboundHandler, @unchecked Sendable {
    typealias InboundIn = AddressedEnvelope<ByteBuffer>

    private let audioContinuation: AsyncStream<[UInt8]>.Continuation
    private let discoveryContinuation: AsyncStream<[UInt8]>.Continuation

    init(
        audioContinuation: AsyncStream<[UInt8]>.Continuation,
        discoveryContinuation: AsyncStream<[UInt8]>.Continuation
    ) {
        self.audioContinuation = audioContinuation
        self.discoveryContinuation = discoveryContinuation
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let envelope = unwrapInboundIn(data)
        var buffer = envelope.data
        if let bytes = buffer.readBytes(length: buffer.readableBytes) {
            if bytes.count == 74, bytes[1] == 2 {
                discoveryContinuation.yield(bytes)
            } else {
                audioContinuation.yield(bytes)
            }
        }
    }

    func errorCaught(context: ChannelHandlerContext, error: any Error) {
        context.close(promise: nil)
    }
}
