/// Configuration for a voice connection and voice gateway.
public struct VoiceConfiguration: Sendable {

    /// Timeout for joining a voice channel and completing the full handshake.
    public var joinTimeout: Duration

    /// Maximum number of reconnect attempts before the connection is closed permanently.
    public var maxReconnectAttempts: Int

    /// - Parameters:
    ///   - joinTimeout: Timeout for joining a voice channel and completing the full handshake.
    ///   - maxReconnectAttempts: Maximum reconnect attempts before giving up.
    public init(
        joinTimeout: Duration = .seconds(30),
        maxReconnectAttempts: Int = 5
    ) {
        self.joinTimeout = joinTimeout
        self.maxReconnectAttempts = maxReconnectAttempts
    }
}
