/// A transport encryption mode supported by the Discord voice UDP pipeline.
///
/// https://discord.com/developers/docs/topics/voice-connections#establishing-a-voice-udp-connection
public enum TransportEncryptionMode: String, Sendable, Codable, CaseIterable {
    /// AES-256-GCM with an `rtpsize` nonce.
    case aead_aes256_gcm_rtpsize
    /// XChaCha20-Poly1305 with an `rtpsize` nonce.
    case aead_xchacha20_poly1305_rtpsize
}

/// Encrypts and decrypts RTP packet payloads for the Discord voice UDP pipeline.
///
/// The nonce is a `UInt32` counter stored in little-endian at the start, padded to
/// 12 bytes for AES-256-GCM or 24 bytes for XChaCha20-Poly1305. The counter value is
/// appended in little-endian at the end of each encrypted packet.
///
/// https://discord.com/developers/docs/topics/voice-connections#transport-encryption-modes
protocol TransportEncryptor: Sendable {

    /// Encrypts `plaintext` with `key` using the 12-byte `header` as associated data.
    ///
    /// Returns the ciphertext with the 4-byte nonce counter appended.
    func seal(
        plaintext: [UInt8],
        key: [UInt8],
        nonce: UInt32,
        header: [UInt8]
    ) throws -> [UInt8]

    /// Decrypts `ciphertext` (with the 4-byte nonce counter stripped) using
    /// the 12-byte `header` as associated data.
    func open(
        ciphertext: [UInt8],
        key: [UInt8],
        nonce: UInt32,
        header: [UInt8]
    ) throws -> [UInt8]
}

/// Errors thrown by transport encryption operations.
enum TransportEncryptionError: Error, CustomStringConvertible {
    /// Authentication failed or the data is otherwise invalid.
    case authenticationFailure
    /// The key length is not 32 bytes.
    case invalidKeyLength(Int)
    /// The nonce counter overflowed. The session must be renegotiated.
    case nonceOverflow

    var description: String {
        switch self {
        case .authenticationFailure:
            return "TransportEncryptionError.authenticationFailure"
        case .invalidKeyLength(let len):
            return "TransportEncryptionError.invalidKeyLength(\(len))"
        case .nonceOverflow:
            return "TransportEncryptionError.nonceOverflow"
        }
    }
}

/// Returns the preferred encryptor from the list of server-advertised modes.
///
/// Prefers `aead_aes256_gcm_rtpsize`; falls back to `aead_xchacha20_poly1305_rtpsize`.
/// Returns `nil` if neither required mode is listed.
func preferredEncryptor(from modes: [String]) -> (any TransportEncryptor, TransportEncryptionMode)? {
    for rawMode in modes {
        switch TransportEncryptionMode(rawValue: rawMode) {
        case .aead_aes256_gcm_rtpsize:
            return (AES256GCMEncryptor(), .aead_aes256_gcm_rtpsize)
        case .aead_xchacha20_poly1305_rtpsize:
            return (XChaCha20Poly1305Encryptor(), .aead_xchacha20_poly1305_rtpsize)
        case .none:
            continue
        }
    }
    return nil
}
