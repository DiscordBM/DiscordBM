import Dave
import DiscordModels
import Foundation

/// Concrete implementation of `DAVESession` wrapping swift-dave's `DaveSession`.
final class LiveDAVESession: DAVESession, @unchecked Sendable {

    private let session: DaveSession
    private let outgoingStream: AsyncStream<OutgoingDAVEMessage>

    init(userID: UserSnowflake, channelID: ChannelSnowflake) throws {
        let uID = UInt64(userID.rawValue) ?? 0
        let cID = UInt64(channelID.rawValue) ?? 0
        let session = try DaveSession(userID: uID, channelID: cID)
        self.session = session

        let (stream, continuation) = AsyncStream<OutgoingDAVEMessage>.makeStream()
        self.outgoingStream = stream

        Task {
            for await msg in await session.outgoing {
                switch msg {
                case let .keyPackage(data):
                    continuation.yield(.keyPackage(data))
                case let .commitAndWelcome(data):
                    continuation.yield(.commitAndWelcome(data))
                case let .readyForTransition(transitionID):
                    continuation.yield(.readyForTransition(transitionID: UInt16(truncatingIfNeeded: transitionID)))
                case let .invalidCommitWelcome(transitionID):
                    continuation.yield(.invalidCommitWelcome(transitionID: UInt16(truncatingIfNeeded: transitionID)))
                }
            }
            continuation.finish()
        }
    }

    var maxSupportedProtocolVersion: Int {
        Int(DaveSession.maxSupportedProtocolVersion.rawValue)
    }

    var isReady: Bool {
        get async {
            await session.isReady
        }
    }

    var outgoing: AsyncStream<OutgoingDAVEMessage> {
        outgoingStream
    }

    func acknowledgeProtocolVersion(_ version: Int) async throws {
        try await session.acknowledgeProtocolVersion(DaveProtocolVersion(rawValue: UInt16(version)))
    }

    func prepareTransition(id: UInt16, protocolVersion: Int) async throws {
        try await session.prepareTransition(
            transitionID: UInt64(id),
            protocolVersion: DaveProtocolVersion(rawValue: UInt16(protocolVersion))
        )
    }

    func executeTransition(id: UInt16) async throws {
        try await session.executeTransition(transitionID: UInt64(id))
    }

    func prepareEpoch(_ epoch: UInt32, protocolVersion: Int) async throws {
        try await session.prepareEpoch(
            UInt64(epoch),
            protocolVersion: DaveProtocolVersion(rawValue: UInt16(protocolVersion))
        )
    }

    func setExternalSender(_ data: [UInt8]) async throws {
        try await session.setExternalSender(data)
    }

    func processProposals(_ data: [UInt8]) async throws {
        try await session.processProposals(data)
    }

    func announceCommitTransition(id: UInt16, commit: [UInt8]) async throws {
        // Ensure transition is registered in transitions tracker prior to processing commit.
        try? await session.prepareTransition(transitionID: UInt64(id), protocolVersion: .v1)
        try await session.announceCommitTransition(transitionID: UInt64(id), commit: commit)
    }

    func processWelcome(id: UInt16, welcome: [UInt8]) async throws {
        // Ensure transition is registered in transitions tracker prior to processing welcome.
        try? await session.prepareTransition(transitionID: UInt64(id), protocolVersion: .v1)
        try await session.processWelcome(transitionID: UInt64(id), welcome: welcome)
    }

    func assignSSRC(_ ssrc: UInt32) async throws {
        try await session.assignSSRC(ssrc, codec: .opus)
    }

    func addUser(_ userID: UserSnowflake) async throws {
        let uID = UInt64(userID.rawValue) ?? 0
        try await session.addUser(userID: uID)
    }

    func removeUser(_ userID: UserSnowflake) async throws {
        let uID = UInt64(userID.rawValue) ?? 0
        try await session.removeUser(userID: uID)
    }

    func encrypt(frame: [UInt8], ssrc: UInt32) async throws -> [UInt8] {
        try await session.encrypt(frame: frame, ssrc: ssrc)
    }

    func decrypt(frame: [UInt8], userID: UserSnowflake) async throws -> [UInt8] {
        let uID = UInt64(userID.rawValue) ?? 0
        return try await session.decrypt(frame: frame, userID: uID)
    }

    func close() async {
        await session.close()
    }
}
