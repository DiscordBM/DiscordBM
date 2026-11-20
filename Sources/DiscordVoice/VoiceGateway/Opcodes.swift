import DiscordModels

/// https://discord.com/developers/docs/topics/voice-connections#voice-events
public enum VoiceGatewayOpcode: RawRepresentable, Sendable, Codable, Hashable, CustomStringConvertible {
    case identify  // 0
    case selectProtocol  // 1
    case ready  // 2
    case heartbeat  // 3
    case sessionDescription  // 4
    case speaking  // 5
    case heartbeatAck  // 6
    case resume  // 7
    case hello  // 8
    case resumed  // 9
    case clientsConnect  // 11
    case clientDisconnect  // 13
    case davePrepareTransition  // 21
    case daveExecuteTransition  // 22
    case daveTransitionReady  // 23
    case davePrepareEpoch  // 24
    case daveMLSExternalSender  // 25
    case daveMLSKeyPackage  // 26
    case daveMLSProposals  // 27
    case daveMLSCommitWelcome  // 28
    case daveAnnounceCommitTransition  // 29
    case daveMLSWelcome  // 30
    case daveMLSInvalidCommitWelcome  // 31
    case __undocumented(UInt8)

    public init(rawValue: UInt8) {
        switch rawValue {
        case 0: self = .identify
        case 1: self = .selectProtocol
        case 2: self = .ready
        case 3: self = .heartbeat
        case 4: self = .sessionDescription
        case 5: self = .speaking
        case 6: self = .heartbeatAck
        case 7: self = .resume
        case 8: self = .hello
        case 9: self = .resumed
        case 11: self = .clientsConnect
        case 13: self = .clientDisconnect
        case 21: self = .davePrepareTransition
        case 22: self = .daveExecuteTransition
        case 23: self = .daveTransitionReady
        case 24: self = .davePrepareEpoch
        case 25: self = .daveMLSExternalSender
        case 26: self = .daveMLSKeyPackage
        case 27: self = .daveMLSProposals
        case 28: self = .daveMLSCommitWelcome
        case 29: self = .daveAnnounceCommitTransition
        case 30: self = .daveMLSWelcome
        case 31: self = .daveMLSInvalidCommitWelcome
        default: self = .__undocumented(rawValue)
        }
    }

    public var rawValue: UInt8 {
        switch self {
        case .identify: return 0
        case .selectProtocol: return 1
        case .ready: return 2
        case .heartbeat: return 3
        case .sessionDescription: return 4
        case .speaking: return 5
        case .heartbeatAck: return 6
        case .resume: return 7
        case .hello: return 8
        case .resumed: return 9
        case .clientsConnect: return 11
        case .clientDisconnect: return 13
        case .davePrepareTransition: return 21
        case .daveExecuteTransition: return 22
        case .daveTransitionReady: return 23
        case .davePrepareEpoch: return 24
        case .daveMLSExternalSender: return 25
        case .daveMLSKeyPackage: return 26
        case .daveMLSProposals: return 27
        case .daveMLSCommitWelcome: return 28
        case .daveAnnounceCommitTransition: return 29
        case .daveMLSWelcome: return 30
        case .daveMLSInvalidCommitWelcome: return 31
        case let .__undocumented(val): return val
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(UInt8.self)
        self.init(rawValue: rawValue)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }

    public var description: String {
        "\(self.rawValue)"
    }
}
