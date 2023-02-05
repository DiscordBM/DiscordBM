import Atomics
import DiscordModels
import struct NIOCore.ByteBuffer

#if swift(>=5.7)
/// If you're seeing the **Cannot find type 'AnyActor' in scope** error,
/// you need to update to Xcode 14.1. Sorry, this a known Xcode issue.
public protocol DiscordActor: AnyActor { }
#else /// Swift `5.6` doesn't have `AnyActor`.
public protocol DiscordActor: AnyObject { }
#endif

public protocol GatewayManager: DiscordActor {
    /// A client to send requests to Discord.
    nonisolated var client: any DiscordClient { get }
    /// This gateway manager's identifier.
    nonisolated var id: Int { get }
    /// The current state of the gateway manager.
    nonisolated var state: GatewayState { get }
    
    /// Starts connecting to Discord.
    func connect() async
    /// https://discord.com/developers/docs/topics/gateway-events#request-guild-members
    func requestGuildMembersChunk(payload: Gateway.RequestGuildMembers) async
    /// https://discord.com/developers/docs/topics/gateway-events#update-presence
    func updatePresence(payload: Gateway.Identify.Presence) async
    /// https://discord.com/developers/docs/topics/gateway-events#update-voice-state
    func updateVoiceState(payload: VoiceStateUpdate) async
    /// Adds a handler to be notified of events.
    func addEventHandler(_ handler: @escaping (Gateway.Event) -> Void) async
    /// Adds a handler to be notified of event parsing failures.
    func addEventParseFailureHandler(_ handler: @escaping (Error, ByteBuffer) -> Void) async
    /// Disconnects from Discord.
    func disconnect() async
}

public enum GatewayState: Int, Sendable, AtomicValue, CustomStringConvertible {
    case stopped
    case noConnection
    case connecting
    case configured
    case connected
    
    public var description: String {
        switch self {
        case .stopped: return "stopped"
        case .noConnection: return "noConnection"
        case .connecting: return "connecting"
        case .configured: return "configured"
        case .connected: return "connected"
        }
    }
}
