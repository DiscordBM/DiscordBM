import XCTest
import NIO
import NIOHTTP1
import NIOSSL
import NIOWebSocket
@testable import DiscordWebSocket

final class WebSocketKitTests: XCTestCase {
    func testWebSocketEcho() throws {
        let server = try ServerBootstrap.webSocket(on: self.elg) { req, ws in
            ws.onTextBuffer { buffer in
                Task {
                    try await ws.send(String(buffer: buffer))
                }
            }
        }.bind(host: "localhost", port: 0).wait()

        guard let port = server.localAddress?.port else {
            XCTFail("couldn't get port from \(server.localAddress.debugDescription)")
            return
        }

        let promise = elg.next().makePromise(of: String.self)
        let closePromise = elg.next().makePromise(of: Void.self)
        Task {
            let ws: WebSocket
            do {
                ws = try await WebSocket.connect(to: "ws://localhost:\(port)", on: elg)
            } catch {
                return promise.fail(error)
            }
            try await ws.send("hello")
            ws.onTextBuffer { buffer in
                promise.succeed(String(buffer: buffer))
                ws.close(promise: closePromise)
            }
        }
        try XCTAssertEqual(promise.futureResult.wait(), "hello")
        XCTAssertNoThrow(try closePromise.futureResult.wait())
        try server.close(mode: .all).wait()
    }
    
    func testWebSocketWithClientCompression() async throws {
        let serverConnectedPromise = elg.next().makePromise(of: WebSocket.self)
        let server = try await ServerBootstrap.webSocket(on: self.elg) { req, ws in
            serverConnectedPromise.succeed(ws)
        }.bind(host: "localhost", port: 0).get()
        
        guard let port = server.localAddress?.port else {
            XCTFail("couldn't get port from \(server.localAddress.debugDescription)")
            return
        }
        
        let closePromise = elg.next().makePromise(of: Void.self)
        var configuration = WebSocketClient.Configuration()
        configuration.decompression = .enabled
        let ws = try await WebSocket.connect(
            to: "ws://localhost:\(port)",
            configuration: configuration,
            on: elg
        )
        
        var receivedDeflatedStrings: [String] = []
        ws.onBinary { buffer in
            let string = String(buffer: buffer)
            if receivedDeflatedStrings.contains(string) {
                XCTFail("ws received the same string multiple times: \(string)")
            } else {
                receivedDeflatedStrings.append(string)
            }
            if !deflatedDataDecodedStrings.contains(string) {
                XCTFail("ws received unknown string: \(string)")
            }
            if receivedDeflatedStrings.count == deflatedData.count {
                ws.close(promise: closePromise)
            }
        }
        
        let serverWs = try await serverConnectedPromise.futureResult.get()
        for data in deflatedData {
            try await serverWs.send(raw: data, opcode: .binary)
        }
        
        XCTAssertNoThrow(try closePromise.futureResult.wait())
        try await server.close(mode: .all).get()
    }

    func testBadHost() async throws {
        do {
            _ = try await WebSocket.connect(host: "asdf", on: elg)
            XCTFail("Did not throw error")
        } catch {
            /// Nothing
        }
    }

    func testServerClose() throws {
        let sendPromise = self.elg.next().makePromise(of: Void.self)
        let serverClose = self.elg.next().makePromise(of: Void.self)
        let clientClose = self.elg.next().makePromise(of: Void.self)
        let server = try ServerBootstrap.webSocket(on: self.elg) { req, ws in
            ws.onTextBuffer { buffer in
                if String(buffer: buffer) == "close" {
                    ws.close(promise: serverClose)
                }
            }
        }.bind(host: "localhost", port: 0).wait()

        guard let port = server.localAddress?.port else {
            XCTFail("couldn't get port from \(server.localAddress.debugDescription)")
            return
        }

        Task {
            let ws: WebSocket
            do {
                ws = try await WebSocket.connect(to: "ws://localhost:\(port)", on: self.elg)
            } catch {
                return sendPromise.fail(error)
            }
            ws.send("close", promise: sendPromise)
            ws.onClose.cascade(to: clientClose)
        }

        XCTAssertNoThrow(try sendPromise.futureResult.wait())
        XCTAssertNoThrow(try serverClose.futureResult.wait())
        XCTAssertNoThrow(try clientClose.futureResult.wait())
        try server.close(mode: .all).wait()
    }

    func testClientClose() throws {
        let sendPromise = self.elg.next().makePromise(of: Void.self)
        let serverClose = self.elg.next().makePromise(of: Void.self)
        let clientClose = self.elg.next().makePromise(of: Void.self)
        let server = try ServerBootstrap.webSocket(on: self.elg) { req, ws in
            ws.onTextBuffer { buffer in
                Task {
                    try await ws.send(String(buffer: buffer))
                }
            }
            ws.onClose.cascade(to: serverClose)
        }.bind(host: "localhost", port: 0).wait()

        guard let port = server.localAddress?.port else {
            XCTFail("couldn't get port from \(server.localAddress.debugDescription)")
            return
        }

        Task {
            let ws: WebSocket
            do {
                ws = try await WebSocket.connect(to: "ws://localhost:\(port)", on: self.elg)
            } catch {
                return sendPromise.fail(error)
            }
            ws.send("close", promise: sendPromise)
            ws.onTextBuffer { buffer in
                if String(buffer: buffer) == "close" {
                    ws.close(promise: clientClose)
                }
            }
        }

        XCTAssertNoThrow(try sendPromise.futureResult.wait())
        XCTAssertNoThrow(try serverClose.futureResult.wait())
        XCTAssertNoThrow(try clientClose.futureResult.wait())
        try server.close(mode: .all).wait()
    }

    func testImmediateSend() throws {
        let promise = self.elg.next().makePromise(of: String.self)
        let server = try ServerBootstrap.webSocket(on: self.elg) { req, ws in
            ws.send("hello")
            ws.onTextBuffer { buffer in
                promise.succeed(String(buffer: buffer))
                ws.close(promise: nil)
            }
        }.bind(host: "localhost", port: 0).wait()

        guard let port = server.localAddress?.port else {
            XCTFail("couldn't get port from \(server.localAddress.debugDescription)")
            return
        }

        Task {
            let ws: WebSocket
            do {
                ws = try await WebSocket.connect(to: "ws://localhost:\(port)", on: self.elg)
            } catch {
                return promise.fail(error)
            }
            ws.onTextBuffer { _ in
                Task {
                    try await ws.send("goodbye")
                    try await ws.close()
                }
            }
        }

        try XCTAssertEqual(promise.futureResult.wait(), "goodbye")
        try server.close(mode: .all).wait()
    }

    func testErrorCode() throws {
        let promise = self.elg.next().makePromise(of: WebSocketErrorCode.self)

        let server = try ServerBootstrap.webSocket(on: self.elg) { req, ws in
            ws.close(code: .normalClosure, promise: nil)
        }.bind(host: "localhost", port: 0).wait()

        guard let port = server.localAddress?.port else {
            XCTFail("couldn't get port from \(server.localAddress.debugDescription)")
            return
        }

        Task {
            let ws: WebSocket
            do {
                ws = try await WebSocket.connect(to: "ws://localhost:\(port)", on: self.elg)
            } catch {
                return promise.fail(error)
            }
            ws.onTextBuffer { _ in
                ws.send("goodbye")
            }
            ws.onClose.whenSuccess {
                promise.succeed(ws.closeCode!)
                XCTAssertEqual(ws.closeCode, WebSocketErrorCode.normalClosure)
            }
        }

        try XCTAssertEqual(promise.futureResult.wait(), WebSocketErrorCode.normalClosure)
        try server.close(mode: .all).wait()
    }

    func testHeadersAreSent() throws {
        let promiseAuth = self.elg.next().makePromise(of: String.self)
        
        // make sure there is no content-length header
        let promiseNoContentLength = self.elg.next().makePromise(of: Bool.self)
        
        let server = try ServerBootstrap.webSocket(on: self.elg) { req, ws in
            promiseAuth.succeed(req.headers.first(name: "Auth")!)
            promiseNoContentLength.succeed(req.headers.contains(name: "content-length"))
            ws.close(promise: nil)
        }.bind(host: "localhost", port: 0).wait()

        guard let port = server.localAddress?.port else {
            XCTFail("couldn't get port from \(server.localAddress.debugDescription)")
            return
        }

        Task {
            do {
                let ws = try await WebSocket.connect(
                    to: "ws://localhost:\(port)",
                    headers: ["Auth": "supersecretsauce"],
                    on: self.elg
                )
                try await ws.close()
            } catch {
                promiseAuth.fail(error)
            }
        }

        try XCTAssertEqual(promiseAuth.futureResult.wait(), "supersecretsauce")
        try XCTAssertFalse(promiseNoContentLength.futureResult.wait())
        try server.close(mode: .all).wait()
    }
    
    func testQueryParamsAreSent() throws {
        let promise = self.elg.next().makePromise(of: String.self)

        let server = try ServerBootstrap.webSocket(on: self.elg) { req, ws in
            promise.succeed(req.uri)
            ws.close(promise: nil)
        }.bind(host: "localhost", port: 0).wait()

        guard let port = server.localAddress?.port else {
            XCTFail("couldn't get port from \(server.localAddress.debugDescription)")
            return
        }

        Task {
            do {
                let ws = try await WebSocket.connect(
                    to: "ws://localhost:\(port)?foo=bar&bar=baz",
                    on: self.elg
                )
                try await ws.close()
            } catch {
                promise.fail(error)
            }
        }

        try XCTAssertEqual(promise.futureResult.wait(), "/?foo=bar&bar=baz")
        try server.close(mode: .all).wait()
    }

    func testLocally() throws {
        // swap to test websocket server against local client
        try XCTSkipIf(true)

        let port = Int(1337)
        let shutdownPromise = self.elg.next().makePromise(of: Void.self)

        let server = try! ServerBootstrap.webSocket(on: self.elg) { req, ws in
            ws.send("welcome!")

            ws.onClose.whenComplete {
                print("ws.onClose done: \($0)")
            }

            ws.onTextBuffer { buffer in
                switch String(buffer: buffer) {
                case "shutdown":
                    shutdownPromise.succeed(())
                case "close":
                    ws.close().whenComplete {
                        print("ws.close() done \($0)")
                    }
                default:
                    Task {
                        try await ws.send(String(buffer: buffer).reversed())
                    }
                }
            }
        }.bind(host: "localhost", port: port).wait()
        print("Serving at ws://localhost:\(port)")

        print("Waiting for server shutdown...")
        try shutdownPromise.futureResult.wait()

        print("Waiting for server close...")
        try server.close(mode: .all).wait()
    }
    
    func testIPWithTLS() async throws {
        let server = try await ServerBootstrap.webSocket(on: self.elg, tls: true) { req, ws in
            _ = ws.close()
        }.bind(host: "127.0.0.1", port: 0).get()

        var tlsConfiguration = TLSConfiguration.makeClientConfiguration()
        tlsConfiguration.certificateVerification = .none
        
        let client = WebSocketClient(
            eventLoopGroupProvider: .shared(self.elg),
            configuration: .init(
                tlsConfiguration: tlsConfiguration
            )
        )

        guard let port = server.localAddress?.port else {
            XCTFail("couldn't get port from \(server.localAddress.debugDescription)")
            return
        }

        _ = try await client.connect(scheme: "wss", host: "127.0.0.1", port: port)
        
        try await server.close(mode: .all).get()
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

extension ServerBootstrap {
    static func webSocket(
        on eventLoopGroup: EventLoopGroup,
        tls: Bool = false,
        onUpgrade: @escaping (HTTPRequestHead, WebSocket) -> ()
    ) -> ServerBootstrap {
        return ServerBootstrap(group: eventLoopGroup).childChannelInitializer { channel in
            if tls {
                let (cert, key) = generateSelfSignedCert()
                let configuration = TLSConfiguration.makeServerConfiguration(
                    certificateChain: [.certificate(cert)],
                    privateKey: .privateKey(key)
                )
                let sslContext = try! NIOSSLContext(configuration: configuration)
                let handler = NIOSSLServerHandler(context: sslContext)
                _ = channel.pipeline.addHandler(handler)
            }
            let webSocket = NIOWebSocketServerUpgrader(
                shouldUpgrade: { channel, req in
                    return channel.eventLoop.makeSucceededFuture([:])
                },
                upgradePipelineHandler: { channel, req in
                    channel.eventLoop.makeFutureWithTask {
                        let ws = try await WebSocket.client(on: channel, decompression: nil)
                        onUpgrade(req, ws)
                    }
                }
            )
            return channel.pipeline.configureHTTPServerPipeline(
                withServerUpgrade: (
                    upgraders: [webSocket],
                    completionHandler: { ctx in
                        // complete
                    }
                )
            )
        }
    }
}
