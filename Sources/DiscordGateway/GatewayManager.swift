import Atomics
import DiscordModels
import struct NIOCore.ByteBuffer

public protocol GatewayManager: AnyActor {
    /// The client to send requests to Discord with.
    nonisolated var client: any DiscordClient { get }
    /// This gateway manager's identifier.
    nonisolated var id: UInt { get }
    /// The identification payload that is sent to Discord.
    nonisolated var identifyPayload: Gateway.Identify { get }

    /// Connects to Discord.
    func connect() async
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
