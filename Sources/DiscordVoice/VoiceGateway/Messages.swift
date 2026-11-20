import DiscordModels
import Foundation

/// https://discord.com/developers/docs/topics/voice-connections#speaking
public struct SpeakingFlags: OptionSet, Sendable, Codable {
    public var rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let microphone = SpeakingFlags(rawValue: 1 << 0)
    public static let soundshare = SpeakingFlags(rawValue: 1 << 1)
    public static let priority = SpeakingFlags(rawValue: 1 << 2)
    public static let none = SpeakingFlags([])
}

/// Payloads and events for the Discord Voice Gateway.
/// https://discord.com/developers/docs/topics/voice-connections
extension VoiceGateway {

    /// Outbound JSON envelope sent to Discord voice gateway.
    public struct OutboundEvent<D: Encodable & Sendable>: Encodable, Sendable {
        public var op: VoiceGatewayOpcode
        public var d: D

        public init(op: VoiceGatewayOpcode, d: D) {
            self.op = op
            self.d = d
        }
    }

    /// Inbound JSON envelope received from Discord voice gateway.
    public struct InboundEnvelope: Decodable, Sendable {
        public var op: VoiceGatewayOpcode
        public var s: UInt16?
    }

    // MARK: Inbound JSON Payloads

    /// https://discord.com/developers/docs/topics/voice-connections#heartbeating-example-gateway-hello-payload
    public struct Hello: Sendable, Codable {
        public var heartbeat_interval: Double

        public init(heartbeat_interval: Double) {
            self.heartbeat_interval = heartbeat_interval
        }
    }

    /// https://discord.com/developers/docs/topics/voice-connections#establishing-a-voice-udp-connection-example-voice-ready-payload
    public struct Ready: Sendable, Codable {
        public var ssrc: UInt32
        public var ip: String
        public var port: Int
        public var modes: [String]

        public init(ssrc: UInt32, ip: String, port: Int, modes: [String]) {
            self.ssrc = ssrc
            self.ip = ip
            self.port = port
            self.modes = modes
        }
    }

    /// https://discord.com/developers/docs/topics/voice-connections#establishing-a-voice-udp-connection-example-session-description-payload
    public struct SessionDescription: Sendable, Codable {
        public var mode: String
        public var secret_key: [UInt8]
        public var dave_protocol_version: Int?

        public init(mode: String, secret_key: [UInt8], dave_protocol_version: Int? = nil) {
            self.mode = mode
            self.secret_key = secret_key
            self.dave_protocol_version = dave_protocol_version
        }
    }

    /// https://discord.com/developers/docs/topics/voice-connections#speaking
    public struct Speaking: Sendable, Codable {
        public var speaking: Int
        public var delay: Int?
        public var ssrc: UInt32
        public var user_id: UserSnowflake?

        public init(speaking: Int, delay: Int? = nil, ssrc: UInt32, user_id: UserSnowflake? = nil) {
            self.speaking = speaking
            self.delay = delay
            self.ssrc = ssrc
            self.user_id = user_id
        }
    }

    /// Opcode 11 - clients connect
    public struct ClientsConnect: Sendable, Codable {
        public var user_ids: [UserSnowflake]

        public init(user_ids: [UserSnowflake]) {
            self.user_ids = user_ids
        }
    }

    /// Opcode 13 - client disconnect
    public struct ClientDisconnect: Sendable, Codable {
        public var user_id: UserSnowflake

        public init(user_id: UserSnowflake) {
            self.user_id = user_id
        }
    }

    /// Opcode 6 - heartbeat ack
    public struct HeartbeatAck: Sendable, Codable {
        public var t: Int

        public init(t: Int) {
            self.t = t
        }
    }

    // MARK: DAVE JSON Payloads

    /// Opcode 21 - DAVE Prepare Transition
    public struct DAVEPrepareTransition: Sendable, Codable {
        public var protocol_version: Int
        public var transition_id: UInt16

        public init(protocol_version: Int, transition_id: UInt16) {
            self.protocol_version = protocol_version
            self.transition_id = transition_id
        }
    }

    /// Opcode 22 - DAVE Execute Transition
    public struct DAVEExecuteTransition: Sendable, Codable {
        public var transition_id: UInt16

        public init(transition_id: UInt16) {
            self.transition_id = transition_id
        }
    }

    /// Opcode 23 - DAVE Transition Ready (client -> server)
    public struct DAVETransitionReadyAck: Sendable, Codable {
        public var transition_id: UInt16

        public init(transition_id: UInt16) {
            self.transition_id = transition_id
        }
    }

    /// Opcode 24 - DAVE Prepare Epoch
    public struct DAVEPrepareEpoch: Sendable, Codable {
        public var protocol_version: Int
        public var epoch: UInt32

        public init(protocol_version: Int, epoch: UInt32) {
            self.protocol_version = protocol_version
            self.epoch = epoch
        }
    }

    /// Opcode 31 - DAVE Invalid Commit/Welcome (client -> server)
    public struct DAVEInvalidCommitWelcome: Sendable, Codable {
        public var transition_id: UInt16

        public init(transition_id: UInt16) {
            self.transition_id = transition_id
        }
    }

    // MARK: Outbound JSON Payloads

    /// https://discord.com/developers/docs/topics/voice-connections#establishing-a-voice-udp-connection-example-voice-identify-payload
    public struct Identify: Sendable, Codable {
        public var server_id: GuildSnowflake
        public var user_id: UserSnowflake
        public var session_id: String
        public var token: String
        public var max_dave_protocol_version: Int?

        public init(
            server_id: GuildSnowflake,
            user_id: UserSnowflake,
            session_id: String,
            token: String,
            max_dave_protocol_version: Int? = nil
        ) {
            self.server_id = server_id
            self.user_id = user_id
            self.session_id = session_id
            self.token = token
            self.max_dave_protocol_version = max_dave_protocol_version
        }
    }

    /// https://discord.com/developers/docs/topics/voice-connections#establishing-a-voice-udp-connection-example-select-protocol-payload
    public struct SelectProtocol: Sendable, Codable {
        public struct Data: Sendable, Codable {
            public var address: String
            public var port: Int
            public var mode: String

            public init(address: String, port: Int, mode: String) {
                self.address = address
                self.port = port
                self.mode = mode
            }
        }

        public var protocol_name: String
        public var data: Data

        private enum CodingKeys: String, CodingKey {
            case protocol_name = "protocol"
            case data
        }

        public init(protocol_name: String = "udp", data: Data) {
            self.protocol_name = protocol_name
            self.data = data
        }
    }

    /// https://discord.com/developers/docs/topics/voice-connections#resuming-voice-connection-example-voice-resume-payload
    public struct Resume: Sendable, Codable {
        public var server_id: GuildSnowflake
        public var session_id: String
        public var token: String
        public var seq_ack: UInt16?

        public init(
            server_id: GuildSnowflake,
            session_id: String,
            token: String,
            seq_ack: UInt16? = nil
        ) {
            self.server_id = server_id
            self.session_id = session_id
            self.token = token
            self.seq_ack = seq_ack
        }
    }

    /// https://discord.com/developers/docs/topics/voice-connections#heartbeating-example-heartbeat-payload
    public struct Heartbeat: Sendable, Codable {
        public var t: Int
        public var seq_ack: UInt16?

        public init(t: Int, seq_ack: UInt16? = nil) {
            self.t = t
            self.seq_ack = seq_ack
        }
    }

    /// https://discord.com/developers/docs/topics/voice-connections#speaking
    public struct SpeakingPayload: Sendable, Codable {
        public var delay: Int
        public var speaking: Int
        public var ssrc: UInt32

        public init(delay: Int = 0, speaking: Int, ssrc: UInt32) {
            self.delay = delay
            self.speaking = speaking
            self.ssrc = ssrc
        }
    }

    // MARK: Binary Frames

    /// A binary frame received from Discord voice gateway.
    /// Format: `[sequence: UInt16 (BE)] [opcode: UInt8] [payload...]`
    public struct InboundBinaryFrame: Sendable {
        public var sequence: UInt16
        public var opcode: UInt8
        public var payload: [UInt8]

        public init(sequence: UInt16, opcode: UInt8, payload: [UInt8]) {
            self.sequence = sequence
            self.opcode = opcode
            self.payload = payload
        }
    }

    // MARK: High-level Inbound Event

    /// High-level events emitted by `VoiceGateway`.
    public enum InboundEvent: Sendable {
        case hello(Hello)
        case ready(Ready)
        case sessionDescription(SessionDescription)
        case speaking(Speaking)
        case clientsConnect(ClientsConnect)
        case clientDisconnect(ClientDisconnect)
        case heartbeatAck(HeartbeatAck)
        case resumed
        case davePrepareTransition(DAVEPrepareTransition)
        case daveExecuteTransition(DAVEExecuteTransition)
        case davePrepareEpoch(DAVEPrepareEpoch)
        case daveMLSExternalSender([UInt8])
        case daveMLSProposals([UInt8])
        case daveAnnounceCommitTransition(id: UInt16, commit: [UInt8])
        case daveMLSWelcome(id: UInt16, welcome: [UInt8])
        case disconnected(code: VoiceGatewayCloseCode?, needsNewSession: Bool)
    }
}

/// Parses an inbound binary frame from the Discord voice gateway.
/// Format: `[sequence: UInt16 (BE)] [opcode: UInt8] [payload...]`
public func parseInboundBinaryFrame(_ bytes: [UInt8]) -> VoiceGateway.InboundBinaryFrame? {
    guard bytes.count >= 3 else { return nil }
    let sequence = (UInt16(bytes[0]) << 8) | UInt16(bytes[1])
    let opcode = bytes[2]
    let payload = Array(bytes[3...])
    return VoiceGateway.InboundBinaryFrame(sequence: sequence, opcode: opcode, payload: payload)
}

/// Constructs an outbound binary frame to send to the Discord voice gateway.
/// Format: `[opcode: UInt8] [payload...]`
public func makeOutboundBinaryFrame(opcode: UInt8, payload: [UInt8]) -> [UInt8] {
    var out = [UInt8]()
    out.reserveCapacity(1 + payload.count)
    out.append(opcode)
    out.append(contentsOf: payload)
    return out
}
