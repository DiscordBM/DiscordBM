import NIOCore
import NIOWebSocket
import Foundation

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension WebSocket {
    public func send<S>(_ text: S) async throws
        where S: Collection, S.Element == Character
    {
        let promise = eventLoop.makePromise(of: Void.self)
        send(text, promise: promise)
        return try await promise.futureResult.get()
    }

    public func send(_ binary: [UInt8]) async throws {
        let promise = eventLoop.makePromise(of: Void.self)
        send(binary, promise: promise)
        return try await promise.futureResult.get()
    }

    public func send<Data>(
        raw data: Data,
        opcode: WebSocketOpcode,
        fin: Bool = true
    ) async throws
        where Data: DataProtocol
    {
        let promise = eventLoop.makePromise(of: Void.self)
        send(raw: data, opcode: opcode, fin: fin, promise: promise)
        return try await promise.futureResult.get()
    }
}
