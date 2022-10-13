@testable import DiscordBM
import NIOPosix
import AsyncHTTPClient
import XCTest

class DiscordClientTests: XCTestCase {
    
    func testMessageSendDelete() async throws {
        let elg = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(elg))
        defer {
            try! httpClient.syncShutdown()
            try! elg.syncShutdownGracefully()
        }
        
        let client = DefaultDiscordClient(
            httpClient: httpClient,
            token: Constants.token,
            appId: Constants.appId
        )
        
        let text = "Testing! \(Int.random(in: 0..<1_000_000))"
        let createResponse = try await client.createMessage(
            channelId: Constants.testChannel,
            payload: .init(content: text)
        )
        
        XCTAssertEqual(createResponse.raw.status, .ok)
        
        let message = try createResponse.decode()
        XCTAssertEqual(message.content, text)
        
        let deletionResponse = try await client.deleteMessage(
            channelId: Constants.testChannel,
            messageId: message.id
        )
        
        XCTAssertEqual(deletionResponse.status, .noContent)
    }
}
