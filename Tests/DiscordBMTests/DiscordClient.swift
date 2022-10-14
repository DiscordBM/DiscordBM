@testable import DiscordBM
import NIOPosix
import AsyncHTTPClient
import XCTest

class DiscordClientTests: XCTestCase {
    
    func testMessageSendDelete() async throws {
        
        let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        defer {
            try! httpClient.syncShutdown()
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
