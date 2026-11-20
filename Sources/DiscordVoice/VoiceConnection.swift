import DiscordModels
import Foundation
import Logging
import NIOCore
import NIOPosix

/// Errors thrown by `VoiceConnection`.
public enum VoiceConnectionError: Error, CustomStringConvertible {
    case joinTimeout
    case connectionClosed
    case noCompatibleEncryptionMode
    case failedToInitializeDAVE(String)

    public var description: String {
        switch self {
        case .joinTimeout:
            return "VoiceConnectionError.joinTimeout"
        case .connectionClosed:
            return "VoiceConnectionError.connectionClosed"
        case .noCompatibleEncryptionMode:
            return "VoiceConnectionError.noCompatibleEncryptionMode"
        case let .failedToInitializeDAVE(reason):
            return "VoiceConnectionError.failedToInitializeDAVE(\(reason))"
        }
    }
}

/// A complete voice connection to a Discord voice channel in a specific guild.
///
/// https://discord.com/developers/docs/topics/voice-connections
public actor VoiceConnection {

    public let guildID: GuildSnowflake
    public let userID: UserSnowflake
    private(set) public var channelID: ChannelSnowflake?

    private let config: VoiceConfiguration
    private let logger: Logger
    private let eventLoopGroup: any EventLoopGroup
    private let sendVoiceStateUpdate: @Sendable (VoiceStateUpdate) async -> Void

    private var gateway: VoiceGateway?
    private var udp: VoiceUDP?
    private var dave: (any DAVESession)?
    private var audioSender: AudioSender?
    private var audioReceiver: AudioReceiver?

    private var provider: (any OpusFrameProvider)?
    private var receiver: (any OpusFrameReceiver)?

    private var ssrcUserMap: [UInt32: UserSnowflake] = [:]
    private var selfSSRC: UInt32?
    private var encryptor: (any TransportEncryptor)?
    private var secretKey: [UInt8] = []

    // Handshake state
    private var pendingSessionID: String?
    private var pendingToken: String?
    private var pendingEndpoint: String?
    private var voiceStateReceived = false
    private var voiceServerReceived = false

    private var joinContinuation: CheckedContinuation<Void, any Error>?
    private var eventProcessingTask: Task<Void, Never>?
    private var daveOutgoingTask: Task<Void, Never>?
    private var isClosed = false

    public init(
        guildID: GuildSnowflake,
        userID: UserSnowflake,
        config: VoiceConfiguration = .init(),
        eventLoopGroup: any EventLoopGroup = MultiThreadedEventLoopGroup.singleton,
        sendVoiceStateUpdate: @escaping @Sendable (VoiceStateUpdate) async -> Void
    ) {
        self.guildID = guildID
        self.userID = userID
        self.config = config
        self.eventLoopGroup = eventLoopGroup
        self.sendVoiceStateUpdate = sendVoiceStateUpdate

        var logger = DiscordGlobalConfiguration.makeLogger("VoiceConnection")
        logger[metadataKey: "guild_id"] = .string("\(guildID.rawValue)")
        self.logger = logger
    }

    /// Opens the voice connection to the given channel.
    ///
    /// Waits until the entire voice handshake completes (Session Description received).
    /// Throws if the handshake times out or fails.
    public func open(
        channelID: ChannelSnowflake,
        selfMute: Bool = false,
        selfDeaf: Bool = false
    ) async throws {
        self.channelID = channelID
        self.isClosed = false
        self.voiceStateReceived = false
        self.voiceServerReceived = false
        self.pendingSessionID = nil
        self.pendingToken = nil
        self.pendingEndpoint = nil

        let update = VoiceStateUpdate(
            guildId: guildID,
            channelId: channelID,
            selfMute: selfMute,
            selfDeaf: selfDeaf
        )

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await withTaskCancellationHandler {
                    try await withCheckedThrowingContinuation { continuation in
                        Task {
                            await self.prepareJoin(continuation: continuation, update: update)
                        }
                    }
                } onCancel: {
                    Task {
                        await self.cancelJoinContinuation()
                    }
                }
            }

            group.addTask {
                try await Task.sleep(for: self.config.joinTimeout)
                throw VoiceConnectionError.joinTimeout
            }

            try await group.next()
            group.cancelAll()
        }
    }

    private func prepareJoin(continuation: CheckedContinuation<Void, any Error>, update: VoiceStateUpdate) async {
        if self.isClosed {
            continuation.resume(throwing: VoiceConnectionError.connectionClosed)
        } else {
            self.joinContinuation = continuation
            logger.debug(
                "Sending voice state update to join channel",
                metadata: [
                    "guild_id": .string(update.guild_id.rawValue),
                    "channel_id": .string(update.channel_id?.rawValue ?? "nil"),
                ]
            )
            await self.sendVoiceStateUpdate(update)
        }
    }

    private func cancelJoinContinuation() {
        self.joinContinuation?.resume(throwing: CancellationError())
        self.joinContinuation = nil
    }

    /// Sets or clears the active Opus frame provider.
    public func setFrameProvider(_ provider: (any OpusFrameProvider)?) async {
        self.provider = provider
        await audioSender?.setProvider(provider)
    }

    /// Sets or clears the active Opus frame receiver.
    public func setFrameReceiver(_ receiver: (any OpusFrameReceiver)?) async {
        self.receiver = receiver
        await audioReceiver?.setReceiver(receiver)
    }

    /// Explicitly updates the speaking state.
    public func setSpeaking(_ flags: SpeakingFlags) async throws {
        guard let ssrc = self.selfSSRC, let gateway = self.gateway else { return }
        let payload = VoiceGateway.SpeakingPayload(speaking: flags.rawValue, ssrc: ssrc)
        try await gateway.send(opcode: .speaking, data: payload)
    }

    /// Looks up a Discord user ID for a given audio SSRC.
    public func userID(for ssrc: UInt32) -> UserSnowflake? {
        ssrcUserMap[ssrc]
    }

    /// Feeds a `VoiceState` from the main Discord gateway.
    public func handleVoiceStateUpdate(_ update: VoiceState) async {
        guard update.guild_id == self.guildID, update.user_id == self.userID else { return }

        logger.debug(
            "VoiceConnection handleVoiceStateUpdate",
            metadata: [
                "channel_id": .string(update.channel_id?.rawValue ?? "nil"),
                "session_id": .string(update.session_id),
            ]
        )

        if update.channel_id == nil {
            logger.debug("Voice state channel is nil; connection disconnected by server")
            await self.close()
            return
        }

        self.pendingSessionID = update.session_id
        self.voiceStateReceived = true
        await self.tryStartHandshake()
    }

    /// Feeds a `VoiceServerUpdate` from the main Discord gateway.
    public func handleVoiceServerUpdate(_ update: Gateway.VoiceServerUpdate) async {
        guard update.guild_id == self.guildID, let endpoint = update.endpoint else {
            logger.debug(
                "VoiceConnection handleVoiceServerUpdate ignored (guild mismatch or nil endpoint)",
                metadata: [
                    "guild_id": .string(update.guild_id.rawValue), "endpoint": .string(update.endpoint ?? "nil"),
                ]
            )
            return
        }

        logger.debug(
            "VoiceConnection handleVoiceServerUpdate",
            metadata: ["endpoint": .string(endpoint)]
        )

        self.pendingToken = update.token
        self.pendingEndpoint = endpoint
        self.voiceServerReceived = true
        await self.tryStartHandshake()
    }

    private func tryStartHandshake() async {
        logger.debug(
            "VoiceConnection tryStartHandshake check",
            metadata: [
                "voiceStateReceived": .stringConvertible(voiceStateReceived),
                "voiceServerReceived": .stringConvertible(voiceServerReceived),
                "hasEndpoint": .stringConvertible(pendingEndpoint != nil),
                "hasToken": .stringConvertible(pendingToken != nil),
                "hasSessionID": .stringConvertible(pendingSessionID != nil),
            ]
        )

        guard voiceStateReceived, voiceServerReceived,
            let endpoint = pendingEndpoint,
            let token = pendingToken,
            let sessionId = pendingSessionID,
            let channelID = self.channelID
        else {
            return
        }

        logger.debug("Voice connection initiating handshake", metadata: ["endpoint": .string(endpoint)])

        // Clear flags so old handshake state is never reused
        self.voiceStateReceived = false
        self.voiceServerReceived = false
        self.pendingEndpoint = nil
        self.pendingToken = nil
        self.pendingSessionID = nil

        let daveSession: any DAVESession
        do {
            daveSession = try LiveDAVESession(userID: self.userID, channelID: channelID)
            self.dave = daveSession
        } catch {
            logger.error("Failed to initialize DAVE session", metadata: ["error": .string("\(error)")])
            joinContinuation?.resume(throwing: VoiceConnectionError.failedToInitializeDAVE("\(error)"))
            joinContinuation = nil
            return
        }

        let gateway = VoiceGateway(
            eventLoopGroup: self.eventLoopGroup,
            maxReconnectAttempts: self.config.maxReconnectAttempts
        )
        self.gateway = gateway

        // Start listening to DAVE outgoing messages immediately so none are dropped
        daveOutgoingTask?.cancel()
        daveOutgoingTask = Task { [weak self] in
            for await message in await daveSession.outgoing {
                guard let self, !Task.isCancelled else { break }
                switch message {
                case let .keyPackage(bytes):
                    self.logger.debug(
                        "Sending DAVE MLS key package",
                        metadata: ["bytes": .stringConvertible(bytes.count)]
                    )
                    let frame = makeOutboundBinaryFrame(opcode: 26, payload: bytes)
                    try? await self.gateway?.sendBinary(frame)
                case let .commitAndWelcome(bytes):
                    self.logger.debug(
                        "Sending DAVE MLS commit and welcome",
                        metadata: ["bytes": .stringConvertible(bytes.count)]
                    )
                    let frame = makeOutboundBinaryFrame(opcode: 28, payload: bytes)
                    try? await self.gateway?.sendBinary(frame)
                case let .readyForTransition(transitionID):
                    self.logger.debug(
                        "Sending DAVE transition ready ack",
                        metadata: ["transitionID": .stringConvertible(transitionID)]
                    )
                    let ack = VoiceGateway.DAVETransitionReadyAck(transition_id: transitionID)
                    try? await self.gateway?.send(opcode: .daveTransitionReady, data: ack)
                case let .invalidCommitWelcome(transitionID):
                    self.logger.warning(
                        "Sending DAVE invalid commit and welcome notice",
                        metadata: ["transitionID": .stringConvertible(transitionID)]
                    )
                    let payload = VoiceGateway.DAVEInvalidCommitWelcome(transition_id: transitionID)
                    try? await self.gateway?.send(opcode: .daveMLSInvalidCommitWelcome, data: payload)
                }
            }
        }

        eventProcessingTask?.cancel()
        eventProcessingTask = Task { [weak self] in
            for await event in await gateway.events {
                guard let self else { break }
                await self.handleGatewayEvent(event)
            }
        }

        await gateway.connect(
            endpoint: endpoint,
            sessionId: sessionId,
            token: token,
            serverId: self.guildID,
            userId: self.userID,
            daveMaxProtocolVersion: daveSession.maxSupportedProtocolVersion
        )
    }

    private func handleGatewayEvent(_ event: VoiceGateway.InboundEvent) async {
        guard !isClosed else { return }

        switch event {
        case .hello:
            break

        case let .ready(ready):
            self.selfSSRC = ready.ssrc
            await self.handleReady(ready)

        case let .sessionDescription(desc):
            await self.handleSessionDescription(desc)

        case let .speaking(speaking):
            logger.trace(
                "Received voice speaking event",
                metadata: [
                    "ssrc": .stringConvertible(speaking.ssrc),
                    "userID": .stringConvertible(speaking.user_id?.rawValue ?? "nil"),
                    "speaking": .stringConvertible(speaking.speaking),
                ]
            )
            if let uid = speaking.user_id, speaking.ssrc != 0 {
                self.ssrcUserMap[speaking.ssrc] = uid
            }

        case let .clientsConnect(cc):
            for uid in cc.user_ids {
                try? await dave?.addUser(uid)
            }

        case let .clientDisconnect(cd):
            try? await dave?.removeUser(cd.user_id)
            if let ssrc = ssrcUserMap.first(where: { $0.value == cd.user_id })?.key {
                ssrcUserMap.removeValue(forKey: ssrc)
            }

        case let .davePrepareTransition(trans):
            logger.debug(
                "Received DAVE prepare transition",
                metadata: [
                    "transition_id": .stringConvertible(trans.transition_id),
                    "protocol_version": .stringConvertible(trans.protocol_version),
                ]
            )
            try? await dave?.prepareTransition(id: trans.transition_id, protocolVersion: trans.protocol_version)
            if trans.transition_id != 0 {
                let ack = VoiceGateway.DAVETransitionReadyAck(transition_id: trans.transition_id)
                try? await self.gateway?.send(opcode: .daveTransitionReady, data: ack)
            }

        case let .daveExecuteTransition(exec):
            logger.debug(
                "Received DAVE execute transition",
                metadata: ["transition_id": .stringConvertible(exec.transition_id)]
            )
            try? await dave?.executeTransition(id: exec.transition_id)

        case let .davePrepareEpoch(epoch):
            logger.debug(
                "Received DAVE prepare epoch",
                metadata: [
                    "epoch": .stringConvertible(epoch.epoch),
                    "protocol_version": .stringConvertible(epoch.protocol_version),
                ]
            )
            try? await dave?.prepareEpoch(epoch.epoch, protocolVersion: epoch.protocol_version)

        case let .daveMLSExternalSender(payload):
            logger.debug("Received DAVE MLS external sender", metadata: ["bytes": .stringConvertible(payload.count)])
            try? await dave?.setExternalSender(payload)

        case let .daveMLSProposals(payload):
            logger.debug("Received DAVE MLS proposals", metadata: ["bytes": .stringConvertible(payload.count)])
            try? await dave?.processProposals(payload)

        case let .daveAnnounceCommitTransition(id, commit):
            logger.debug(
                "Received DAVE announce commit transition",
                metadata: [
                    "id": .stringConvertible(id),
                    "commit_len": .stringConvertible(commit.count),
                ]
            )
            try? await dave?.announceCommitTransition(id: id, commit: commit)
            if id != 0 {
                logger.debug("Sending DAVE transition ready ack", metadata: ["transition_id": .stringConvertible(id)])
                let ack = VoiceGateway.DAVETransitionReadyAck(transition_id: id)
                try? await self.gateway?.send(opcode: .daveTransitionReady, data: ack)
            }

        case let .daveMLSWelcome(id, welcome):
            logger.debug(
                "Received DAVE MLS welcome",
                metadata: [
                    "id": .stringConvertible(id),
                    "welcome_len": .stringConvertible(welcome.count),
                ]
            )
            try? await dave?.processWelcome(id: id, welcome: welcome)
            if id != 0 {
                logger.debug(
                    "Sending DAVE transition ready ack for welcome",
                    metadata: ["transition_id": .stringConvertible(id)]
                )
                let ack = VoiceGateway.DAVETransitionReadyAck(transition_id: id)
                try? await self.gateway?.send(opcode: .daveTransitionReady, data: ack)
            }

        case let .disconnected(code, needsNewSession):
            logger.debug(
                "Voice gateway disconnected",
                metadata: [
                    "code": .string("\(String(describing: code))"),
                    "needsNewSession": .stringConvertible(needsNewSession),
                ]
            )
            if needsNewSession {
                await self.handleNeedNewSession()
            } else {
                await self.close()
            }

        default:
            break
        }
    }

    private func handleReady(_ ready: VoiceGateway.Ready) async {
        guard let (encryptor, mode) = preferredEncryptor(from: ready.modes) else {
            logger.error(
                "No compatible encryption mode found in server modes",
                metadata: ["modes": .string("\(ready.modes)")]
            )
            joinContinuation?.resume(throwing: VoiceConnectionError.noCompatibleEncryptionMode)
            joinContinuation = nil
            return
        }
        self.encryptor = encryptor

        let udp = VoiceUDP(eventLoopGroup: self.eventLoopGroup)
        self.udp = udp

        do {
            let (externalIP, externalPort) = try await udp.discover(ip: ready.ip, port: ready.port, ssrc: ready.ssrc)
            logger.debug(
                "Discovered external IP and port",
                metadata: [
                    "ip": .string(externalIP), "port": .stringConvertible(externalPort), "mode": .string(mode.rawValue),
                ]
            )

            try? await dave?.assignSSRC(ready.ssrc)

            let selectProtocol = VoiceGateway.SelectProtocol(
                protocol_name: "udp",
                data: .init(address: externalIP, port: Int(externalPort), mode: mode.rawValue)
            )
            try await gateway?.send(opcode: .selectProtocol, data: selectProtocol)
        } catch {
            logger.error("IP discovery failed", metadata: ["error": .string("\(error)")])
            joinContinuation?.resume(throwing: error)
            joinContinuation = nil
        }
    }

    private func handleSessionDescription(_ desc: VoiceGateway.SessionDescription) async {
        logger.debug(
            "Received session description",
            metadata: [
                "mode": .string(desc.mode),
                "dave_protocol_version": .string(String(describing: desc.dave_protocol_version)),
                "secret_key_len": .stringConvertible(desc.secret_key.count),
            ]
        )
        self.secretKey = desc.secret_key

        if let version = desc.dave_protocol_version {
            logger.debug("Acknowledging DAVE protocol version", metadata: ["version": .stringConvertible(version)])
            try? await dave?.acknowledgeProtocolVersion(version)
        } else {
            logger.debug("Acknowledging DAVE protocol version 0 (passthrough)")
            try? await dave?.acknowledgeProtocolVersion(0)
        }

        // Start AudioSender and AudioReceiver
        if let dave = self.dave, let encryptor = self.encryptor, let udp = self.udp {
            let sender = AudioSender(dave: dave, logger: self.logger)
            await sender.setProvider(self.provider)
            self.audioSender = sender

            let ssrc = self.selfSSRC ?? 0
            let key = self.secretKey

            Task { [weak self] in
                await sender.start(
                    ssrc: ssrc,
                    encryptor: encryptor,
                    key: key,
                    send: { [weak self] packet in
                        guard let self else { return }
                        try await self.udp?.send(packet)
                    },
                    speaking: { [weak self] flags in
                        guard let self else { return }
                        try await self.setSpeaking(flags)
                    }
                )
            }

            let receiver = AudioReceiver(
                packets: await udp.packets,
                encryptor: encryptor,
                key: key,
                dave: dave,
                logger: self.logger
            )
            await receiver.setReceiver(self.receiver)
            self.audioReceiver = receiver

            Task { [weak self] in
                await receiver.start(ssrcUserMap: { [weak self] ssrc in
                    guard let self else { return nil }
                    return await self.userID(for: ssrc)
                })
            }
        }

        // Handshake is complete!
        joinContinuation?.resume()
        joinContinuation = nil
    }

    private func handleNeedNewSession() async {
        await self.audioSender?.stop()
        self.audioSender = nil
        await self.audioReceiver?.stop()
        self.audioReceiver = nil
        await self.udp?.close()
        self.udp = nil
        await self.dave?.close()
        self.dave = nil

        if let channelID = self.channelID {
            let update = VoiceStateUpdate(
                guildId: guildID,
                channelId: channelID,
                selfMute: false,
                selfDeaf: false
            )
            await sendVoiceStateUpdate(update)
        }
    }

    /// Closes the voice connection and disconnects from the channel.
    public func close() async {
        guard !isClosed else { return }
        self.isClosed = true

        joinContinuation?.resume(throwing: VoiceConnectionError.connectionClosed)
        joinContinuation = nil

        eventProcessingTask?.cancel()
        eventProcessingTask = nil
        daveOutgoingTask?.cancel()
        daveOutgoingTask = nil

        await audioSender?.stop()
        audioSender = nil
        await audioReceiver?.stop()
        audioReceiver = nil
        await udp?.close()
        udp = nil
        await gateway?.close()
        gateway = nil
        await dave?.close()
        dave = nil

        let update = VoiceStateUpdate(
            guildId: guildID,
            channelId: nil,
            selfMute: false,
            selfDeaf: false
        )
        await sendVoiceStateUpdate(update)
    }
}
