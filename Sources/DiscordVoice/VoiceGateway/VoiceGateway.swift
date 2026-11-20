import Atomics
import DiscordGateway
import DiscordModels
import Foundation
import Logging
import NIOCore
import WSClient

import enum NIOWebSocket.WebSocketErrorCode
import struct NIOWebSocket.WebSocketOpcode

/// Actor managing the WebSocket signaling connection for a Discord voice session.
///
/// https://discord.com/developers/docs/topics/voice-connections#voice-gateway-versioning
public actor VoiceGateway {

    private nonisolated let connectionId = ManagedAtomic(UInt(0))
    private var outboundWriter: WebSocketOutboundWriter?
    private var lastHeartbeatNonce: Int?
    private var heartbeatAcked = true
    private var lastSequence: UInt16?

    private let eventsStream: AsyncStream<VoiceGateway.InboundEvent>
    private let eventsContinuation: AsyncStream<VoiceGateway.InboundEvent>.Continuation

    private let eventLoopGroup: any EventLoopGroup
    private let logger: Logger
    private let maxReconnectAttempts: Int
    private var reconnectAttempts = 0
    private var isClosed = false

    // Saved connection parameters for reconnection/resumption
    private var endpoint: String?
    private var sessionId: String?
    private var token: String?
    private var serverId: GuildSnowflake?
    private var userId: UserSnowflake?
    private var daveMaxProtocolVersion: Int = 0

    /// Stream of all inbound voice gateway events.
    public var events: AsyncStream<VoiceGateway.InboundEvent> {
        eventsStream
    }

    public init(eventLoopGroup: any EventLoopGroup, maxReconnectAttempts: Int = 5) {
        self.eventLoopGroup = eventLoopGroup
        self.maxReconnectAttempts = maxReconnectAttempts
        let logger = DiscordGlobalConfiguration.makeLogger("VoiceGateway")
        self.logger = logger

        let (stream, continuation) = AsyncStream<VoiceGateway.InboundEvent>.makeStream()
        self.eventsStream = stream
        self.eventsContinuation = continuation
    }

    /// Connects to the Discord voice gateway and processes messages.
    ///
    /// - Parameters:
    ///   - endpoint: Hostname or domain for the voice server (from Voice Server Update).
    ///   - sessionId: Gateway voice session ID (from Voice State Update).
    ///   - token: Voice authentication token (from Voice Server Update).
    ///   - serverId: Target guild snowflake.
    ///   - userId: The bot's user snowflake.
    ///   - daveMaxProtocolVersion: Maximum DAVE protocol version supported.
    public func connect(
        endpoint: String,
        sessionId: String,
        token: String,
        serverId: GuildSnowflake,
        userId: UserSnowflake,
        daveMaxProtocolVersion: Int = 1
    ) async {
        self.isClosed = false
        self.endpoint = endpoint
        self.sessionId = sessionId
        self.token = token
        self.serverId = serverId
        self.userId = userId
        self.daveMaxProtocolVersion = daveMaxProtocolVersion

        await self.performConnect()
    }

    private func performConnect() async {
        guard !isClosed, let endpoint = self.endpoint else { return }

        let connectionId = self.connectionId.wrappingIncrementThenLoad(ordering: .relaxed)
        let cleanedEndpoint = endpoint.replacingOccurrences(of: ":80", with: "").trimmingCharacters(
            in: CharacterSet(charactersIn: "/")
        )
        let url = "wss://\(cleanedEndpoint)/?v=8"

        logger.debug(
            "Connecting to Voice Gateway",
            metadata: ["url": .string(url), "connectionId": .stringConvertible(connectionId)]
        )

        let configuration = WebSocketClientConfiguration(maxFrameSize: 1 << 24)

        Task {
            do {
                typealias HandlerType = WebSocketDataHandler<WebSocketClient.Context>
                let handler: HandlerType = { inbound, outbound, context in
                    await self.setupOutboundWriter(outbound, forConnectionWithId: connectionId)

                    for try await message in inbound.messages(maxSize: 1 << 24) {
                        await self.processMessage(message, forConnectionWithId: connectionId)
                    }
                }

                let closeFrame = try await WebSocketClient.connect(
                    url: url,
                    configuration: configuration,
                    eventLoopGroup: self.eventLoopGroup,
                    logger: self.logger,
                    handler: handler
                )

                await self.onClose(closeFrame: closeFrame, error: nil, forConnectionWithId: connectionId)
            } catch {
                await self.onClose(closeFrame: nil, error: error, forConnectionWithId: connectionId)
            }
        }
    }

    private func setupOutboundWriter(_ writer: WebSocketOutboundWriter, forConnectionWithId connectionId: UInt) {
        guard self.connectionId.load(ordering: .relaxed) == connectionId else { return }
        self.outboundWriter = writer
    }

    private func processMessage(_ message: WebSocketMessage, forConnectionWithId connectionId: UInt) async {
        guard self.connectionId.load(ordering: .relaxed) == connectionId else { return }

        switch message {
        case let .text(text):
            logger.trace("VoiceGateway received text", metadata: ["text": .string(text)])
            guard let data = text.data(using: .utf8) else { return }
            await self.processJSONData(data, forConnectionWithId: connectionId)

        case let .binary(byteBuffer):
            logger.trace(
                "VoiceGateway received binary",
                metadata: ["bytes": .stringConvertible(byteBuffer.readableBytes)]
            )
            var buffer = byteBuffer
            guard let bytes = buffer.readBytes(length: buffer.readableBytes) else { return }
            await self.processBinaryBytes(bytes, forConnectionWithId: connectionId)
        }
    }

    private func processJSONData(_ data: Data, forConnectionWithId connectionId: UInt) async {
        do {
            let envelope = try DiscordGlobalConfiguration.decoder.decode(VoiceGateway.InboundEnvelope.self, from: data)
            if let seq = envelope.s {
                self.lastSequence = seq
            }

            switch envelope.op {
            case .hello:
                struct HelloEnvelope: Decodable {
                    var d: VoiceGateway.Hello
                }
                let hello = try DiscordGlobalConfiguration.decoder.decode(HelloEnvelope.self, from: data).d
                self.setupHeartbeatTask(
                    forConnectionWithId: connectionId,
                    every: .milliseconds(Int64(hello.heartbeat_interval))
                )
                await self.sendIdentifyOrResume()
                self.eventsContinuation.yield(.hello(hello))

            case .ready:
                struct ReadyEnvelope: Decodable {
                    var d: VoiceGateway.Ready
                }
                let ready = try DiscordGlobalConfiguration.decoder.decode(ReadyEnvelope.self, from: data).d
                self.reconnectAttempts = 0
                self.eventsContinuation.yield(.ready(ready))

            case .resumed:
                self.reconnectAttempts = 0
                self.eventsContinuation.yield(.resumed)

            case .sessionDescription:
                struct SessionDescriptionEnvelope: Decodable {
                    var d: VoiceGateway.SessionDescription
                }
                let desc = try DiscordGlobalConfiguration.decoder.decode(SessionDescriptionEnvelope.self, from: data).d
                self.eventsContinuation.yield(.sessionDescription(desc))

            case .speaking:
                struct SpeakingEnvelope: Decodable {
                    var d: VoiceGateway.Speaking
                }
                let speaking = try DiscordGlobalConfiguration.decoder.decode(SpeakingEnvelope.self, from: data).d
                self.eventsContinuation.yield(.speaking(speaking))

            case .heartbeatAck:
                struct HeartbeatAckEnvelope: Decodable {
                    var d: VoiceGateway.HeartbeatAck
                }
                let ack = try DiscordGlobalConfiguration.decoder.decode(HeartbeatAckEnvelope.self, from: data).d
                if let lastNonce = self.lastHeartbeatNonce, ack.t != lastNonce {
                    logger.warning(
                        "Heartbeat ACK nonce mismatch; reconnecting",
                        metadata: ["expected": .stringConvertible(lastNonce), "got": .stringConvertible(ack.t)]
                    )
                    await self.reconnectNow()
                    return
                }
                self.heartbeatAcked = true
                self.eventsContinuation.yield(.heartbeatAck(ack))

            case .clientsConnect:
                struct ClientsConnectEnvelope: Decodable {
                    var d: VoiceGateway.ClientsConnect
                }
                let cc = try DiscordGlobalConfiguration.decoder.decode(ClientsConnectEnvelope.self, from: data).d
                self.eventsContinuation.yield(.clientsConnect(cc))

            case .clientDisconnect:
                struct ClientDisconnectEnvelope: Decodable {
                    var d: VoiceGateway.ClientDisconnect
                }
                let cd = try DiscordGlobalConfiguration.decoder.decode(ClientDisconnectEnvelope.self, from: data).d
                self.eventsContinuation.yield(.clientDisconnect(cd))

            case .davePrepareTransition:
                struct TransitionEnvelope: Decodable {
                    var d: VoiceGateway.DAVEPrepareTransition
                }
                let trans = try DiscordGlobalConfiguration.decoder.decode(TransitionEnvelope.self, from: data).d
                self.eventsContinuation.yield(.davePrepareTransition(trans))

            case .daveExecuteTransition:
                struct ExecuteEnvelope: Decodable {
                    var d: VoiceGateway.DAVEExecuteTransition
                }
                let exec = try DiscordGlobalConfiguration.decoder.decode(ExecuteEnvelope.self, from: data).d
                self.eventsContinuation.yield(.daveExecuteTransition(exec))

            case .davePrepareEpoch:
                struct EpochEnvelope: Decodable {
                    var d: VoiceGateway.DAVEPrepareEpoch
                }
                let epoch = try DiscordGlobalConfiguration.decoder.decode(EpochEnvelope.self, from: data).d
                self.eventsContinuation.yield(.davePrepareEpoch(epoch))

            default:
                logger.debug(
                    "Received unhandled or undocumented voice opcode",
                    metadata: ["opcode": .stringConvertible(envelope.op.rawValue)]
                )
            }
        } catch {
            logger.debug("Failed to decode voice gateway JSON message", metadata: ["error": .string("\(error)")])
        }
    }

    private func processBinaryBytes(_ bytes: [UInt8], forConnectionWithId connectionId: UInt) async {
        guard let frame = parseInboundBinaryFrame(bytes) else {
            logger.debug("Malformed inbound binary frame", metadata: ["count": .stringConvertible(bytes.count)])
            return
        }

        self.lastSequence = frame.sequence

        switch frame.opcode {
        case 25:
            self.eventsContinuation.yield(.daveMLSExternalSender(frame.payload))

        case 27:
            self.eventsContinuation.yield(.daveMLSProposals(frame.payload))

        case 29:
            guard frame.payload.count >= 2 else { return }
            let id = (UInt16(frame.payload[0]) << 8) | UInt16(frame.payload[1])
            let commit = Array(frame.payload[2...])
            self.eventsContinuation.yield(.daveAnnounceCommitTransition(id: id, commit: commit))

        case 30:
            guard frame.payload.count >= 2 else { return }
            let id = (UInt16(frame.payload[0]) << 8) | UInt16(frame.payload[1])
            let welcome = Array(frame.payload[2...])
            self.eventsContinuation.yield(.daveMLSWelcome(id: id, welcome: welcome))

        default:
            logger.debug("Received unknown binary opcode", metadata: ["opcode": .stringConvertible(frame.opcode)])
        }
    }

    private func sendIdentifyOrResume() async {
        guard let serverId = self.serverId, let token = self.token else { return }

        if let sessionId = self.sessionId, let lastSeq = self.lastSequence {
            logger.debug(
                "Attempting to resume voice session",
                metadata: ["sessionId": .string(sessionId), "seq": .stringConvertible(lastSeq)]
            )
            let resume = VoiceGateway.Resume(server_id: serverId, session_id: sessionId, token: token, seq_ack: lastSeq)
            try? await self.send(opcode: .resume, data: resume)
        } else if let sessionId = self.sessionId, let userId = self.userId {
            logger.debug("Identifying to voice gateway", metadata: ["sessionId": .string(sessionId)])
            let identify = VoiceGateway.Identify(
                server_id: serverId,
                user_id: userId,
                session_id: sessionId,
                token: token,
                max_dave_protocol_version: daveMaxProtocolVersion
            )
            try? await self.send(opcode: .identify, data: identify)
        }
    }

    private func setupHeartbeatTask(forConnectionWithId connectionId: UInt, every duration: Duration) {
        Task {
            try? await Task.sleep(for: duration)
            guard self.connectionId.load(ordering: .relaxed) == connectionId, !self.isClosed else { return }

            if !self.heartbeatAcked {
                self.logger.warning(
                    "Zombie connection detected: previous heartbeat was not acknowledged; reconnecting",
                    metadata: ["connectionId": .stringConvertible(connectionId)]
                )
                await self.reconnectNow()
                return
            }

            let nonce = Int(Date().timeIntervalSince1970 * 1000) & Int(Int32.max)
            self.lastHeartbeatNonce = nonce
            self.heartbeatAcked = false

            let payload = VoiceGateway.Heartbeat(t: nonce, seq_ack: self.lastSequence)
            try? await self.send(opcode: .heartbeat, data: payload)

            self.setupHeartbeatTask(forConnectionWithId: connectionId, every: duration)
        }
    }

    private func reconnectNow() async {
        self.connectionId.wrappingIncrement(ordering: .relaxed)
        await self.closeWebSocket(code: .goingAway)
        await self.performConnect()
    }

    private func onClose(
        closeFrame: WebSocketCloseFrame?,
        error: (any Error)?,
        forConnectionWithId connectionId: UInt
    ) async {
        guard self.connectionId.load(ordering: .relaxed) == connectionId, !self.isClosed else { return }

        let rawCode: UInt16? = {
            if let closeFrame {
                switch closeFrame.closeCode {
                case let .unknown(num):
                    return num
                default:
                    return nil
                }
            }
            return nil
        }()

        let closeCode = rawCode.flatMap { VoiceGatewayCloseCode(rawValue: $0) }
        logger.debug(
            "Voice gateway closed",
            metadata: [
                "code": .string("\(String(describing: closeCode))"), "error": .string("\(String(describing: error))"),
            ]
        )

        if let closeCode {
            if closeCode.newSession {
                self.eventsContinuation.yield(.disconnected(code: closeCode, needsNewSession: true))
                return
            }
            if !closeCode.reconnect {
                self.eventsContinuation.yield(.disconnected(code: closeCode, needsNewSession: false))
                return
            }
        }

        if reconnectAttempts >= maxReconnectAttempts {
            logger.warning("Exceeded maximum voice reconnect attempts; closing permanently")
            self.eventsContinuation.yield(.disconnected(code: closeCode, needsNewSession: false))
            return
        }

        reconnectAttempts += 1
        let backoffDelay = min(1 << reconnectAttempts, 10)
        logger.debug(
            "Will attempt voice reconnect",
            metadata: [
                "attempt": .stringConvertible(reconnectAttempts), "backoffSeconds": .stringConvertible(backoffDelay),
            ]
        )

        try? await Task.sleep(for: .seconds(backoffDelay))
        await self.performConnect()
    }

    /// Sends a JSON-encoded payload to the voice gateway.
    public func send<D: Encodable & Sendable>(opcode: VoiceGatewayOpcode, data: D) async throws {
        guard let writer = self.outboundWriter else { return }
        let payload = VoiceGateway.OutboundEvent(op: opcode, d: data)
        let encodedData = try DiscordGlobalConfiguration.encoder.encode(payload)
        guard let jsonString = String(data: encodedData, encoding: .utf8) else { return }
        try await writer.write(.text(jsonString))
    }

    /// Sends a binary frame to the voice gateway.
    public func sendBinary(_ bytes: [UInt8]) async throws {
        guard let writer = self.outboundWriter else { return }
        var buffer = ByteBuffer()
        buffer.writeBytes(bytes)
        try await writer.write(.custom(.init(fin: true, opcode: .binary, data: buffer)))
    }

    /// Closes the voice gateway connection.
    public func close() async {
        self.isClosed = true
        self.connectionId.wrappingIncrement(ordering: .relaxed)
        await self.closeWebSocket(code: .normalClosure)
    }

    private func closeWebSocket(code: WebSocketErrorCode) async {
        try? await self.outboundWriter?.close(code, reason: nil)
        self.outboundWriter = nil
    }
}
