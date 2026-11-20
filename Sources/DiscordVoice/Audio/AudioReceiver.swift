import DiscordModels
import Foundation
import Logging

/// Actor responsible for receiving, decrypting, and dispatching incoming audio frames.
///
/// https://discord.com/developers/docs/topics/voice-connections#encrypting-and-sending-voice
actor AudioReceiver {

    private var receiver: (any OpusFrameReceiver)?
    private var isRunning = false
    private let packets: AsyncStream<[UInt8]>
    private let encryptor: any TransportEncryptor
    private let key: [UInt8]
    private let dave: any DAVESession
    private let logger: Logger

    init(
        packets: AsyncStream<[UInt8]>,
        encryptor: any TransportEncryptor,
        key: [UInt8],
        dave: any DAVESession,
        logger: Logger
    ) {
        self.packets = packets
        self.encryptor = encryptor
        self.key = key
        self.dave = dave
        self.logger = logger
    }

    /// Sets or clears the active Opus frame receiver.
    func setReceiver(_ receiver: (any OpusFrameReceiver)?) {
        self.receiver = receiver
    }

    /// Starts processing inbound UDP datagrams.
    ///
    /// - Parameter ssrcUserMap: Asynchronous mapping function from SSRC to Discord user ID.
    func start(
        ssrcUserMap: @escaping @Sendable (UInt32) async -> UserSnowflake?
    ) async {
        self.isRunning = true

        for await rawPacket in packets {
            guard isRunning else { break }

            guard case let .success(parsed) = parseRTPPacket(rawPacket) else {
                continue
            }

            guard let userID = await ssrcUserMap(parsed.ssrc) else {
                // Unknown SSRC; drop packet silently per protocol rules until speaking event is mapped
                continue
            }

            let header = Array(rawPacket[0..<parsed.headerLength])
            let plaintext: [UInt8]
            do {
                plaintext = try encryptor.open(
                    ciphertext: parsed.ciphertext,
                    key: key,
                    nonce: parsed.nonce,
                    header: header
                )
            } catch {
                logger.debug(
                    "Failed transport AEAD decryption for packet from user",
                    metadata: [
                        "userID": .stringConvertible(userID),
                        "error": .string("\(error)"),
                    ]
                )
                continue
            }

            guard
                let opus = stripRTPExtensionAndPadding(
                    plaintext: plaintext,
                    hasExtension: parsed.hasExtension,
                    extensionBodyLength: parsed.extensionBodyLength,
                    hasPadding: parsed.hasPadding
                )
            else {
                logger.trace(
                    "Failed stripping RTP extension/padding from packet",
                    metadata: ["plainLen": .stringConvertible(plaintext.count)]
                )
                continue
            }

            let frameToDeliver: [UInt8]
            let daveReady = await dave.isReady
            if daveReady && opus != AudioSender.silenceFrame {
                do {
                    frameToDeliver = try await dave.decrypt(frame: opus, userID: userID)
                } catch {
                    logger.debug(
                        "DAVE frame decryption failed, dropping frame",
                        metadata: [
                            "userID": .stringConvertible(userID),
                            "error": .string("\(error)"),
                        ]
                    )
                    continue
                }
            } else {
                frameToDeliver = opus
            }

            await receiver?.receive(frame: frameToDeliver, from: userID)
        }
    }

    /// Stops the audio receiving loop.
    func stop() {
        self.isRunning = false
    }
}
