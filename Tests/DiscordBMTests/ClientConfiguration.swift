@testable import DiscordBM
import XCTest

class ClientConfigurationTests: XCTestCase {
    
    func testRetryPolicy() throws {
        do {
            typealias RetryPolicy = ClientConfiguration.RetryPolicy
            let policy = RetryPolicy.default
            XCTAssertTrue(policy.shouldRetry(status: .internalServerError, retriesSoFar: 0))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 1))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 2))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 100000))
        }
        
        do {
            typealias RetryPolicy = ClientConfiguration.RetryPolicy
            var policy = RetryPolicy()
            policy.setRetry(status: .badGateway, times: 5)
            
            XCTAssertTrue(policy.shouldRetry(status: .badGateway, retriesSoFar: 0))
            XCTAssertTrue(policy.shouldRetry(status: .badGateway, retriesSoFar: 1))
            XCTAssertTrue(policy.shouldRetry(status: .badGateway, retriesSoFar: 2))
            XCTAssertTrue(policy.shouldRetry(status: .badGateway, retriesSoFar: 3))
            XCTAssertTrue(policy.shouldRetry(status: .badGateway, retriesSoFar: 4))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 5))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 6))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 7))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 100000))
            
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 0))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 1))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 2))
        }
        
        do {
            typealias RetryPolicy = ClientConfiguration.RetryPolicy
            var policy = RetryPolicy.default
            policy.setRetry(status: .badGateway, times: 3)
            
            XCTAssertTrue(policy.shouldRetry(status: .badGateway, retriesSoFar: 0))
            XCTAssertTrue(policy.shouldRetry(status: .badGateway, retriesSoFar: 1))
            XCTAssertTrue(policy.shouldRetry(status: .badGateway, retriesSoFar: 2))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 3))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 4))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 5))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 100000))
            
            XCTAssertTrue(policy.shouldRetry(status: .internalServerError, retriesSoFar: 0))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 1))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 2))
        }
    }
}
