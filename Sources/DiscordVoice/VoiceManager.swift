import DiscordGateway
import DiscordModels
import Foundation
import Logging
import NIOCore
import NIOPosix

/// Manages voice connections across guilds for a Discord bot.
///
/// Route events from your `GatewayManager` by calling `handleEvent(_:)`.
///
/// https://discord.com/developers/docs/topics/voice-connections
public actor VoiceManager {

    private var connections: [GuildSnowflake: VoiceConnection] = [:]
    private let eventLoopGroup: any EventLoopGroup
    private let userID: UserSnowflake
    private let config: VoiceConfiguration
    private let sendVoiceStateUpdate: @Sendable (VoiceStateUpdate) async -> Void
    private let logger: Logger

    /// - Parameters:
    ///   - eventLoopGroup: An `EventLoopGroup` for UDP networking. Defaults to `MultiThreadedEventLoopGroup.singleton`.
    ///   - userID: The bot's own user snowflake.
    ///   - config: General configuration for voice connections.
    ///   - sendVoiceStateUpdate: Closure to send a voice state update over the gateway.
    public init(
        eventLoopGroup: any EventLoopGroup = MultiThreadedEventLoopGroup.singleton,
        userID: UserSnowflake,
        config: VoiceConfiguration = .init(),
        sendVoiceStateUpdate: @escaping @Sendable (VoiceStateUpdate) async -> Void
    ) {
        self.eventLoopGroup = eventLoopGroup
        self.userID = userID
        self.config = config
        self.sendVoiceStateUpdate = sendVoiceStateUpdate

        let logger = DiscordGlobalConfiguration.makeLogger("VoiceManager")
        self.logger = logger
    }

    /// Convenience initializer using a `GatewayManager`.
    public init(
        gateway: any GatewayManager,
        eventLoopGroup: any EventLoopGroup = MultiThreadedEventLoopGroup.singleton,
        userID: UserSnowflake,
        config: VoiceConfiguration = .init()
    ) {
        self.init(
            eventLoopGroup: eventLoopGroup,
            userID: userID,
            config: config,
            sendVoiceStateUpdate: { update in
                await gateway.updateVoiceState(payload: update)
            }
        )
    }

    /// Joins a voice channel in the specified guild.
    ///
    /// - Parameters:
    ///   - guildID: Target guild snowflake.
    ///   - channelID: Target channel snowflake.
    ///   - selfMute: Whether the bot should be self-muted.
    ///   - selfDeaf: Whether the bot should be self-deafened.
    /// - Returns: The established `VoiceConnection`.
    public func join(
        guildID: GuildSnowflake,
        channelID: ChannelSnowflake,
        selfMute: Bool = false,
        selfDeaf: Bool = false
    ) async throws -> VoiceConnection {
        if let existing = connections[guildID] {
            if await existing.channelID == channelID {
                return existing
            }
            await existing.close()
            connections.removeValue(forKey: guildID)
        }

        let connection = VoiceConnection(
            guildID: guildID,
            userID: userID,
            config: config,
            eventLoopGroup: eventLoopGroup,
            sendVoiceStateUpdate: sendVoiceStateUpdate
        )
        connections[guildID] = connection

        do {
            try await connection.open(
                channelID: channelID,
                selfMute: selfMute,
                selfDeaf: selfDeaf
            )
            return connection
        } catch {
            connections.removeValue(forKey: guildID)
            await connection.close()
            throw error
        }
    }

    /// Leaves the voice channel in the specified guild and closes the connection.
    public func leave(guildID: GuildSnowflake) async {
        guard let connection = connections.removeValue(forKey: guildID) else { return }
        await connection.close()
    }

    /// Returns the active voice connection for the given guild, if any.
    public func connection(for guildID: GuildSnowflake) -> VoiceConnection? {
        connections[guildID]
    }

    /// Processes an event from the main Discord gateway.
    /// Routes `voiceStateUpdate` and `voiceServerUpdate` events to the appropriate guild connection.
    public func handleEvent(_ event: Gateway.Event) async {
        switch event.data {
        case let .voiceStateUpdate(voiceState):
            logger.debug(
                "VoiceManager routing voiceStateUpdate",
                metadata: [
                    "guild_id": .string(voiceState.guild_id.rawValue),
                    "user_id": .string(voiceState.user_id.rawValue),
                    "channel_id": .string(voiceState.channel_id?.rawValue ?? "nil"),
                    "hasConnection": .stringConvertible(connections[voiceState.guild_id] != nil),
                ]
            )
            await connections[voiceState.guild_id]?.handleVoiceStateUpdate(voiceState)
        case let .voiceServerUpdate(serverUpdate):
            logger.debug(
                "VoiceManager routing voiceServerUpdate",
                metadata: [
                    "guild_id": .string(serverUpdate.guild_id.rawValue),
                    "endpoint": .string(serverUpdate.endpoint ?? "nil"),
                    "hasConnection": .stringConvertible(connections[serverUpdate.guild_id] != nil),
                ]
            )
            await connections[serverUpdate.guild_id]?.handleVoiceServerUpdate(serverUpdate)
        default:
            break
        }
    }
}
