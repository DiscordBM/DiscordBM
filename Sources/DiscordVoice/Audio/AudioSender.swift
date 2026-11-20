import DiscordModels
import Foundation
import Logging

/// Actor responsible for pacing and transmitting Opus audio frames over UDP.
///
/// https://discord.com/developers/docs/topics/voice-connections#encrypting-and-sending-voice
actor AudioSender {

    /// Standard Opus silence frame (3 bytes: 0xF8, 0xFF, 0xFE).
    static let silenceFrame: [UInt8] = [0xF8, 0xFF, 0xFE]

    private var provider: (any OpusFrameProvider)?
    private var stopped = false
    private var sequence: UInt16 = 0
    private var timestamp: UInt32 = 0
    private var nonce: UInt32 = 0

    private let dave: any DAVESession
    private let logger: Logger

    init(dave: any DAVESession, logger: Logger) {
        self.dave = dave
        self.logger = logger
    }

    /// Sets or clears the active Opus frame provider.
    func setProvider(_ provider: (any OpusFrameProvider)?) {
        self.provider = provider
    }

    /// Starts the 20 ms paced transmission loop.
    ///
    /// - Parameters:
    ///   - ssrc: The bot's assigned audio SSRC.
    ///   - encryptor: The negotiated transport encryptor.
    ///   - key: The 32-byte secret key from the Session Description.
    ///   - send: Callback to transmit raw encrypted datagrams over UDP.
    ///   - speaking: Callback to update the bot's speaking state.
    func start(
        ssrc: UInt32,
        encryptor: any TransportEncryptor,
        key: [UInt8],
        send: @escaping @Sendable ([UInt8]) async throws -> Void,
        speaking: @escaping @Sendable (SpeakingFlags) async throws -> Void
    ) async {
        self.stopped = false
        var isSpeaking = false
        var silenceCount = 0
        var daveActiveLogged = false

        logger.debug("Starting audio transmission loop", metadata: ["ssrc": .stringConvertible(ssrc)])

        var deadline = ContinuousClock.now

        while !stopped {
            deadline = deadline + .milliseconds(20)
            let now = ContinuousClock.now
            if deadline < now - .milliseconds(60) {
                // Fallen more than 3 frames behind; resync to current time
                deadline = now
            }

            let daveReady = await dave.isReady
            if daveReady && !daveActiveLogged {
                logger.debug("DAVE E2EE session ratchet is active")
                daveActiveLogged = true
            }

            let frame = await provider?.nextFrame()

            if let frame {
                silenceCount = 0
                if !isSpeaking {
                    logger.debug("Setting speaking state", metadata: ["flags": "microphone"])
                    try? await speaking(.microphone)
                    isSpeaking = true
                }

                if frame.count > 1400 {
                    logger.warning(
                        "Dropping audio frame exceeding 1400 bytes cap",
                        metadata: ["size": .stringConvertible(frame.count)]
                    )
                } else {
                    do {
                        // Encrypt with DAVE if ready; passthrough before DAVE ratchet activation and for silence frames.
                        let davePayload: [UInt8]
                        if daveReady && frame != Self.silenceFrame {
                            davePayload = (try? await dave.encrypt(frame: frame, ssrc: ssrc)) ?? frame
                        } else {
                            davePayload = frame
                        }

                        let rtpHeader = RTPHeader(sequence: sequence, timestamp: timestamp, ssrc: ssrc).encode()
                        let sealed = try encryptor.seal(
                            plaintext: davePayload,
                            key: key,
                            nonce: nonce,
                            header: rtpHeader
                        )

                        var packet = [UInt8]()
                        packet.reserveCapacity(rtpHeader.count + sealed.count)
                        packet.append(contentsOf: rtpHeader)
                        packet.append(contentsOf: sealed)

                        try await send(packet)

                        sequence &+= 1
                        timestamp &+= 960
                        nonce &+= 1
                    } catch {
                        logger.error(
                            "Failed to encrypt or send audio frame",
                            metadata: ["error": .string("\(error)")]
                        )
                    }
                }
            } else {
                // No frame from provider, send up to 5 silence frames to avoid audio glitches
                if silenceCount < 5 {
                    do {
                        let rtpHeader = RTPHeader(sequence: sequence, timestamp: timestamp, ssrc: ssrc).encode()
                        let sealed = try encryptor.seal(
                            plaintext: Self.silenceFrame,
                            key: key,
                            nonce: nonce,
                            header: rtpHeader
                        )

                        var packet = [UInt8]()
                        packet.reserveCapacity(rtpHeader.count + sealed.count)
                        packet.append(contentsOf: rtpHeader)
                        packet.append(contentsOf: sealed)

                        try await send(packet)

                        sequence &+= 1
                        timestamp &+= 960
                        nonce &+= 1
                        silenceCount += 1
                    } catch {
                        logger.debug(
                            "Failed to encrypt or send silence frame",
                            metadata: ["error": .string("\(error)")]
                        )
                    }
                } else if silenceCount == 5 && isSpeaking {
                    logger.debug("Audio provider exhausted; clearing speaking state")
                    try? await speaking(.none)
                    isSpeaking = false
                    silenceCount += 1
                }
            }

            try? await Task.sleep(until: deadline, clock: .continuous)
        }
    }

    /// Stops the audio sending loop.
    func stop() {
        self.stopped = true
    }
}
