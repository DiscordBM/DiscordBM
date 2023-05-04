import XCTest
import NIO
import NIOHTTP1
import NIOWebSocket
import DiscordWebSocket

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
final class AsyncWebSocketKitTests: XCTestCase {
    func testWebSocketEcho() async throws {
        let server = try await ServerBootstrap.webSocket(on: self.elg) { req, ws in
            ws.onText { buffer in
                Task {
                    try await ws.send(String(buffer: buffer))
                }
            }
        }.bind(host: "localhost", port: 0).get()

        guard let port = server.localAddress?.port else {
            XCTFail("couldn't get port from \(server.localAddress.debugDescription)")
            return
        }

        let promise = elg.next().makePromise(of: String.self)

        Task {
            do {
                let ws = try await WebSocket.connect(to: "ws://localhost:\(port)", on: self.elg)
                try await ws.send("hello")
                ws.onText { buffer in
                    promise.succeed(String(buffer: buffer))
                    Task {
                        do {
                            try await ws.close()
                        } catch {
                            XCTFail("Failed to close websocket, error: \(error)")
                        }
                    }
                }
            } catch {
                promise.fail(error)
            }
        }

        let result = try await promise.futureResult.get()
        XCTAssertEqual(result, "hello")
        try await server.close(mode: .all)
    }

    var elg: EventLoopGroup!
    override func setUp() {
        // needs to be at least two to avoid client / server on same EL timing issues
        self.elg = MultiThreadedEventLoopGroup(numberOfThreads: 2)
    }
    override func tearDown() {
        try! self.elg.syncShutdownGracefully()
    }
}
