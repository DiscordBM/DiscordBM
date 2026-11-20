/// An outgoing DAVE protocol message that must be sent to the voice gateway.
///
/// Opcodes 26 and 28 are sent as binary frames; opcodes 23 and 31 are sent as JSON.
public enum OutgoingDAVEMessage: Sendable {
    /// A key package (voice gateway opcode 26). Sent as a binary frame.
    case keyPackage([UInt8])
    /// A commit and welcome (voice gateway opcode 28). Sent as a binary frame.
    case commitAndWelcome([UInt8])
    /// Ready for transition (voice gateway opcode 23). Sent as a JSON frame.
    case readyForTransition(transitionID: UInt16)
    /// Invalid commit or welcome (voice gateway opcode 31). Sent as a JSON frame.
    case invalidCommitWelcome(transitionID: UInt16)
}

/// Internal protocol describing what voice code needs from a DAVE session.
///
/// `Dave.DaveSession` from swift-dave conforms to this protocol via `LiveDAVESession`.
/// A lightweight mock conforms to this protocol in unit tests.
protocol DAVESession: AnyObject, Sendable {

    /// The maximum DAVE protocol version this session supports.
    var maxSupportedProtocolVersion: Int { get }

    /// Whether the session is ready to encrypt and decrypt frames.
    ///
    /// Callers must not call `encrypt(frame:ssrc:)` while this returns `false`.
    var isReady: Bool { get async }

    /// Outgoing messages that the voice code must forward to the voice gateway.
    var outgoing: AsyncStream<OutgoingDAVEMessage> { get async }

    /// Acknowledges the protocol version received in the Session Description (opcode 4).
    func acknowledgeProtocolVersion(_ version: Int) async throws

    /// Handles a Prepare Transition message (opcode 21).
    func prepareTransition(id: UInt16, protocolVersion: Int) async throws

    /// Handles an Execute Transition message (opcode 22).
    func executeTransition(id: UInt16) async throws

    /// Handles a Prepare Epoch message (opcode 24).
    func prepareEpoch(_ epoch: UInt32, protocolVersion: Int) async throws

    /// Handles an MLS External Sender message (opcode 25).
    func setExternalSender(_ data: [UInt8]) async throws

    /// Handles an MLS Proposals message (opcode 27).
    func processProposals(_ data: [UInt8]) async throws

    /// Handles an Announce Commit Transition message (opcode 29).
    func announceCommitTransition(id: UInt16, commit: [UInt8]) async throws

    /// Handles a Welcome message (opcode 30).
    func processWelcome(id: UInt16, welcome: [UInt8]) async throws

    /// Associates the bot's outbound SSRC with the Opus codec.
    ///
    /// Call this once after the SSRC is known from the Ready payload.
    func assignSSRC(_ ssrc: UInt32) async throws

    /// Adds a remote user to the session so their frames can be decrypted.
    func addUser(_ userID: UserSnowflake) async throws

    /// Removes a remote user from the session.
    func removeUser(_ userID: UserSnowflake) async throws

    /// Encrypts an Opus frame using the DAVE session key.
    ///
    /// Throws `DAVESessionError.notReady` if `isReady` is `false`.
    func encrypt(frame: [UInt8], ssrc: UInt32) async throws -> [UInt8]

    /// Decrypts a received frame for the given user.
    func decrypt(frame: [UInt8], userID: UserSnowflake) async throws -> [UInt8]

    /// Closes the session and releases all resources.
    func close() async
}
