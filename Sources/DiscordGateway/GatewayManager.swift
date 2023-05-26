import Atomics
import DiscordModels
import struct NIOCore.ByteBuffer

public protocol GatewayManager: AnyActor {
    /// The client to send requests to Discord with.
    nonisolated var client: any DiscordClient { get }
    /// This gateway manager's identifier.
    nonisolated var id: UInt { get }
    /// The current state of the gateway manager.
    nonisolated var state: GatewayState { get }
    /// The identification payload that is sent to Discord.
    nonisolated var identifyPayload: Gateway.Identify { get }

    /// Starts connecting to Discord.
    /// If you want to become aware of when the connection is established, you need
    /// to listen for the related Gateway events such as 'ready' and 'resume'.
    nonisolated func connect()
    /// https://discord.com/developers/docs/topics/gateway-events#request-guild-members
    func requestGuildMembersChunk(payload: Gateway.RequestGuildMembers) async
    /// https://discord.com/developers/docs/topics/gateway-events#update-presence
    func updatePresence(payload: Gateway.Identify.Presence) async
    /// https://discord.com/developers/docs/topics/gateway-events#update-voice-state
    func updateVoiceState(payload: VoiceStateUpdate) async
    /// Makes an stream of Gateway events.
    func makeEventsStream() async -> AsyncStream<Gateway.Event>
    /// Makes an stream of Gateway event parse failures.
    func makeEventsParseFailureStream() async -> AsyncStream<(any Error, ByteBuffer)>
    /// Disconnects from Discord.
    func disconnect() async
}

// FIXME: These are to help users fix breaking changes easier.
// Should remove these when the package is out of beta.
public extension GatewayManager {
    @available(*, unavailable, renamed: "makeEventsStream")
    func makeEventStream() async -> AsyncStream<Gateway.Event> {
        fatalError()
    }

    @available(*, unavailable, renamed: "makeEventsParseFailureStream")
    func makeEventParseFailureStream() async -> AsyncStream<(any Error, ByteBuffer)> {
        fatalError()
    }

    @available(*, unavailable, message: "Use 'makeEventsStream()' instead: 'for await event in await bot.makeEventsStream() { /*handle event*/ }'")
    func addEventHandler(_ handler: @Sendable @escaping (Gateway.Event) -> Void) { }

    @available(*, unavailable, message: "Use 'makeEventsParseFailureStream()' instead: 'for await (error, buffer) in await bot.makeEventsParseFailureStream() { /*handle error & buffer*/ }'")
    func addEventParseFailureHandler(
        _ handler: @Sendable @escaping (any Error, ByteBuffer) -> Void
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
