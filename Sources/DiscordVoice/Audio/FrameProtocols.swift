/// Provides Opus-encoded audio frames for transmission.
///
/// Implement this protocol to supply audio to a voice connection.
/// The connection pulls one frame every 20 ms. Each frame must be a complete
/// Opus-encoded packet ready to send; partial or raw PCM frames are not accepted.
///
/// When no frame is available, return `nil`. The sender will transmit five silence
/// frames (`0xF8 0xFF 0xFE`) and then stop marking the bot as speaking.
public protocol OpusFrameProvider: AnyObject, Sendable {

    /// Returns the next Opus frame, or `nil` if no audio is available.
    func nextFrame() async -> [UInt8]?
}

/// Receives decrypted, per-user Opus frames from an active voice connection.
///
/// Implement this protocol to consume incoming audio from other participants.
/// Each call delivers one complete Opus-encoded packet from the given user.
public protocol OpusFrameReceiver: AnyObject, Sendable {

    /// Delivers a decrypted Opus frame from the given user.
    ///
    /// - Parameters:
    ///   - frame: A complete Opus-encoded audio packet.
    ///   - userID: The Discord user who sent the frame.
    func receive(frame: [UInt8], from userID: UserSnowflake) async
}
