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
            policy.statuses.insert(.badGateway)
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
        let backoff = Backoff.constant(1)
        let times = [
            backoff.waitTimeBeforeRetry(retriesSoFar: 0, headers: [:]),
            backoff.waitTimeBeforeRetry(retriesSoFar: 1, headers: [:]),
            backoff.waitTimeBeforeRetry(retriesSoFar: 2, headers: [:]),
            backoff.waitTimeBeforeRetry(retriesSoFar: 10, headers: [:]),
            backoff.waitTimeBeforeRetry(retriesSoFar: Int.max - 1, headers: [:])
        ]
        for time in times {
            XCTAssertEqual(time, 1)
        }
    }
    
    func testRetryPolicyLinearBackoff() throws {
        let base = 0.2
        let coefficient = 0.8
        let backoff = Backoff.linear(base: base, coefficient: coefficient, upToTimes: 3)
        
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 0, headers: [:]), base + coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 1, headers: [:]), base + 2 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 2, headers: [:]), base + 3 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 3, headers: [:]), base + 3 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 4, headers: [:]), base + 3 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 5, headers: [:]), base + 3 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 10, headers: [:]), base + 3 * coefficient)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: Int.max - 1, headers: [:]), base + 3 * coefficient)
    }
    
    func testRetryPolicyExponentialBackoff() throws {
        let base = 1.5
        let coefficient = 0.8
        let rate = 3.0
        let backoff = Backoff.exponential(
            base: base,
            coefficient: coefficient,
            rate: rate,
            upToTimes: 4
        )
        
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 0, headers: [:]), base + coefficient * rate)
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 1, headers: [:]), base + coefficient * (pow(rate, 2)))
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 2, headers: [:]), base + coefficient * (pow(rate, 3)))
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 3, headers: [:]), base + coefficient * (pow(rate, 4)))
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 4, headers: [:]), base + coefficient * (pow(rate, 4)))
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 5, headers: [:]), base + coefficient * (pow(rate, 4)))
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 10, headers: [:]), base + coefficient * (pow(rate, 4)))
        XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: Int.max - 1, headers: [:]), base + coefficient * (pow(rate, 4)))
    }
    
    func testRetryPolicyHeadersBackoffWithElse() throws {
        let base = 0.2
        let coefficient = 0.8
        let linearBackoff = Backoff.linear(base: base, coefficient: coefficient, upToTimes: 3)
        let maxAllowed = 12.0
        let backoff = Backoff.basedOnHeaders(
            maxAllowed: 12,
            retryIfGreater: true,
            else: linearBackoff
        )
        
        /// Headers greater than the max allowed
        do {
            let headers = HTTPHeaders([("Retry-After", "166")])
            func backoffWait(retriesSoFar: Int, headers: HTTPHeaders) -> Double? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: headers)
            }
            XCTAssertEqual(backoffWait(retriesSoFar: 0, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 1, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 2, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 3, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 4, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 5, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: 10, headers: headers), maxAllowed)
            XCTAssertEqual(backoffWait(retriesSoFar: Int.max - 1, headers: headers), maxAllowed)
        }
        
        /// Headers smaller than the max allowed
        do {
            let headers = HTTPHeaders([("Retry-After", "8.939")])
            func backoffWait(retriesSoFar: Int, headers: HTTPHeaders) -> Double? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: headers)
            }
            let headerTime = 8.939
            XCTAssertEqual(backoffWait(retriesSoFar: 0, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 1, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 2, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 3, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 4, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 5, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 10, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: Int.max - 1, headers: headers), headerTime)
        }
        
        /// No headers
        do {
            func backoffWait(retriesSoFar: Int) -> Double? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: [:])
            }
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 0, headers: [:]), base + coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 1, headers: [:]), base + 2 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 2, headers: [:]), base + 3 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 3, headers: [:]), base + 3 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 4, headers: [:]), base + 3 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 5, headers: [:]), base + 3 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: 10, headers: [:]), base + 3 * coefficient)
            XCTAssertEqual(backoff.waitTimeBeforeRetry(retriesSoFar: Int.max - 1, headers: [:]), base + 3 * coefficient)
        }
    }
    
    func testRetryPolicyHeadersBackoffWithoutElse() throws {
        let maxAllowed = 10.0
        let backoff = Backoff.basedOnHeaders(
            maxAllowed: maxAllowed,
            retryIfGreater: false,
            else: nil
        )
        
        /// Headers greater than the max allowed
        do {
            let headers = HTTPHeaders([("Retry-After", "11.5555")])
            func backoffWait(retriesSoFar: Int, headers: HTTPHeaders) -> Double? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: headers)
            }
            XCTAssertEqual(backoffWait(retriesSoFar: 0, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 1, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 2, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 3, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 4, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 5, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 10, headers: headers), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: Int.max - 1, headers: headers), nil)
        }
        
        /// Headers smaller than the max allowed
        do {
            let headers = HTTPHeaders([("Retry-After", "1")])
            func backoffWait(retriesSoFar: Int, headers: HTTPHeaders) -> Double? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: headers)
            }
            let headerTime = 1.0
            XCTAssertEqual(backoffWait(retriesSoFar: 0, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 1, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 2, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 3, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 4, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 5, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: 10, headers: headers), headerTime)
            XCTAssertEqual(backoffWait(retriesSoFar: Int.max - 1, headers: headers), headerTime)
        }
        
        /// No headers
        do {
            func backoffWait(retriesSoFar: Int) -> Double? {
                backoff.waitTimeBeforeRetry(retriesSoFar: retriesSoFar, headers: [:])
            }
            XCTAssertEqual(backoffWait(retriesSoFar: 0), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 1), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 2), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 3), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 4), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 5), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: 10), nil)
            XCTAssertEqual(backoffWait(retriesSoFar: Int.max - 1), nil)
        }
    }
}
