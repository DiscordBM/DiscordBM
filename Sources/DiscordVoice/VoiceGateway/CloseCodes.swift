/// https://discord.com/developers/docs/topics/voice-connections#voice-events-voice-gateway-close-event-codes
public enum VoiceGatewayCloseCode: UInt16, Sendable, Codable {
    case unknownError = 4000
    case unknownOpcode = 4001
    case decodeError = 4002
    case notAuthenticated = 4003
    case authenticationFailed = 4004
    case alreadyAuthenticated = 4005
    case sessionNoLongerValid = 4006
    case sessionTimeout = 4009
    case serverNotFound = 4011
    case unknownProtocol = 4012
    case disconnected = 4014
    case voiceServerCrashed = 4015
    case unknownEncryptionMode = 4016
    case daveRequired = 4017
    case rateLimited = 4021
    case callTerminated = 4022

    /// Whether the connection should attempt to reconnect with a resume after this close.
    ///
    /// `false` for codes that require no reconnect at all, or for codes that require
    /// a fresh session instead of a resume. Use `newSession` to distinguish those two.
    public var reconnect: Bool {
        switch self {
        case .unknownError: return true
        case .unknownOpcode: return true
        case .decodeError: return true
        case .notAuthenticated: return true
        case .authenticationFailed: return false
        case .alreadyAuthenticated: return true
        case .sessionNoLongerValid: return false
        case .sessionTimeout: return false
        case .serverNotFound: return false
        case .unknownProtocol: return true
        case .disconnected: return false
        case .voiceServerCrashed: return true
        case .unknownEncryptionMode: return false
        case .daveRequired: return false
        case .rateLimited: return false
        case .callTerminated: return false
        }
    }

    /// Whether the close requires abandoning the current session and starting a new one.
    ///
    /// When `true`, clear all session state and request a new voice state update.
    /// When `false` and `reconnect` is `true`, attempt a resume with existing session data.
    public var newSession: Bool {
        switch self {
        case .sessionNoLongerValid: return true
        case .sessionTimeout: return true
        case .serverNotFound: return true
        default: return false
        }
    }
}
