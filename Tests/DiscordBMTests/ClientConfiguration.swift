@testable import DiscordBM
import XCTest
import struct NIOCore.TimeAmount
import struct NIOHTTP1.HTTPHeaders

class ClientConfigurationTests: XCTestCase {
    
    typealias RetryPolicy = ClientConfiguration.RetryPolicy
    typealias Backoff = ClientConfiguration.RetryPolicy.Backoff
    
    func testRetryPolicyShouldRetry() throws {
        do {
            let policy = RetryPolicy.default
            XCTAssertTrue(policy.shouldRetry(status: .internalServerError, retriesSoFar: 0))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 1))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 2))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 100000))
        }
        
        do {
            let policy = RetryPolicy(
                statuses: [.badGateway],
                maxRetries: 5
            )
            
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
            var policy = RetryPolicy.default
            policy.statuses.append(.badGateway)
            policy.maxRetries = 1
            
            XCTAssertTrue(policy.shouldRetry(status: .badGateway, retriesSoFar: 0))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 1))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 2))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 10))
            XCTAssertFalse(policy.shouldRetry(status: .badGateway, retriesSoFar: 100000))
            
            XCTAssertTrue(policy.shouldRetry(status: .internalServerError, retriesSoFar: 0))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 1))
            XCTAssertFalse(policy.shouldRetry(status: .internalServerError, retriesSoFar: 2))
        }
    }
    
    func testRetryPolicyConstantBackoff() throws {
        let backoff = Backoff.constant(.seconds(1))
        let times = [
            backoff.waitTimeBeforeRetry(retriesSoFar: 0, headers: [:]),
            backoff.waitTimeBeforeRetry(retriesSoFar: 1, headers: [:]),
            backoff.waitTimeBeforeRetry(retriesSoFar: 2, headers: [:]),
            backoff.waitTimeBeforeRetry(retriesSoFar: 10, headers: [:]),
            backoff.waitTimeBeforeRetry(retriesSoFar: .max, headers: [:])
        ]
        for time in times {
            XCTAssertEqual(time, .seconds(1))
        }
    }
    
    func testRetryPolicyLinearBackoff() throws {
        let base = TimeAmount.milliseconds(200)
        let coefficient = TimeAmount.milliseconds(800)
        let backoff = Backoff.linear(
            base: base,
            coefficient: coefficient,
            multiplyUpToTimes: 3
        )
        
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 0, headers: [:]), base)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 1, headers: [:]), base + coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 2, headers: [:]), base + 2 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 3, headers: [:]), base + 3 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 4, headers: [:]), base + 3 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 5, headers: [:]), base + 3 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 10, headers: [:]), base + 3 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: .max, headers: [:]), base + 3 * coefficient)
    }
    
    func testRetryPolicyHeadersBackoffWithElse() throws {
        let base = TimeAmount.milliseconds(200)
        let coefficient = TimeAmount.milliseconds(800)
        let linearBackoff = Backoff.linear(
            base: base,
            coefficient: coefficient,
            multiplyUpToTimes: 3
        )
        let maxAllowed = TimeAmount.seconds(12)
        let backoff = Backoff.basedOnTheRetryAfterHeader(
            maxAllowed: maxAllowed,
            retryIfGreater: true,
            else: linearBackoff
        )
        
        /// Headers greater than the max allowed
        do {
            let headers = HTTPHeaders([("Retry-After", "166")])
            func backoffWait(retriesSoFar: Int, headers: HTTPHeaders) -> TimeAmount? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: headers)
            }
            XCTAssertEqual(backoffWait(retriesSoFar: 0, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 1, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 2, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 3, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 4, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 5, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 10, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: .max, headers: headers), maxAllowed)
        }
        
        /// Headers smaller than the max allowed
        do {
            let headers = HTTPHeaders([("Retry-After", "8.939")])
            func backoffWait(retriesSoFar: Int, headers: HTTPHeaders) -> TimeAmount? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: headers)
            }
            let headerTime = TimeAmount.milliseconds(8939)
            XCTAssertEqual(backoffWait(retriesSoFar: 0, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 1, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 2, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 3, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 4, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 5, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 10, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: .max, headers: headers), headerTime)
        }
        
        /// No headers
        do {
            func backoffWait(retriesSoFar: Int) -> TimeAmount? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: [:])
            }
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 0, headers: [:]), base)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 1, headers: [:]), base + coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 2, headers: [:]), base + 2 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 3, headers: [:]), base + 3 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 4, headers: [:]), base + 3 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 5, headers: [:]), base + 3 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 10, headers: [:]), base + 3 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: .max, headers: [:]), base + 3 * coefficient)
        }
    }
    
    func testRetryPolicyHeadersBackoffWithoutElse() throws {
        let maxAllowed = TimeAmount.seconds(10)
        let backoff = Backoff.basedOnTheRetryAfterHeader(
            maxAllowed: maxAllowed,
            retryIfGreater: false,
            else: nil
        )
        
        /// Headers greater than the max allowed
        do {
            let headers = HTTPHeaders([("Retry-After", "11.5555")])
            func backoffWait(retriesSoFar: Int, headers: HTTPHeaders) -> TimeAmount? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: headers)
            }
            XCTAssertEqual(backoffWait(retriesSoFar: 0, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 1, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 2, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 3, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 4, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 5, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 10, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: .max, headers: headers), nil)
        }
        
        /// Headers smaller than the max allowed
        do {
            let headers = HTTPHeaders([("Retry-After", "1")])
            func backoffWait(retriesSoFar: Int, headers: HTTPHeaders) -> TimeAmount? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: headers)
            }
            let headerTime = TimeAmount.seconds(1)
            XCTAssertEqual(backoffWait(retriesSoFar: 0, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 1, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 2, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 3, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 4, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 5, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 10, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: .max, headers: headers), headerTime)
        }
        
        /// No headers
        do {
            func backoffWait(retriesSoFar: Int) -> TimeAmount? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: [:])
            }
            XCTAssertEqual(backoffWait(retriesSoFar: 0), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 1), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 2), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 3), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 4), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 5), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 10), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: .max), nil)
        }
    }
}

private func * (lhs: Int64, rhs: TimeAmount) -> TimeAmount {
    .nanoseconds(rhs.nanoseconds * lhs)
}
