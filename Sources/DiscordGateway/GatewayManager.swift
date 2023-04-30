import Atomics
import DiscordModels
import struct NIOCore.ByteBuffer

#if swift(>=5.7)
/// If you're seeing the **Cannot find type 'AnyActor' in scope** error,
/// you need to update to Xcode 14.1 or higher. Sorry, this a known Xcode issue.
public protocol DiscordActor: AnyActor { }
#else /// Swift `5.6` doesn't have `AnyActor`.
public protocol DiscordActor: Sendable, AnyObject { }
#endif

public protocol GatewayManager: DiscordActor {
    /// The client to send requests to Discord with.
    nonisolated var client: any DiscordClient { get }
    /// This gateway manager's identifier.
    nonisolated var id: UInt { get }
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
    /// Makes an stream of Gateway events.
    func makeEventStream() async -> AsyncStream<Gateway.Event>
    /// Makes an stream of Gateway event parse failures.
    func makeEventParseFailureStream() async -> AsyncStream<(Error, ByteBuffer)>
    /// Disconnects from Discord.
    func disconnect() async
}

// FIXME: Remove when out of beta
public extension GatewayManager {
    @available(*, unavailable, message: "Use 'makeEventStream()' instead: 'for await event in await bot.makeEventStream() { /*handle event*/ }'")
    func addEventHandler(_ handler: @Sendable @escaping (Gateway.Event) -> Void) { }

    @available(*, unavailable, message: "Use 'makeEventParseFailureStream()' instead: 'for await (error, buffer) in await bot.makeEventParseFailureStream() { /*handle error & buffer*/ }'")
    func addEventParseFailureHandler(
        _ handler: @Sendable @escaping (Error, ByteBuffer) -> Void
    ) { }
}

/// The state of a `GatewayManager`.
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
