@testable import DiscordBM
import Atomics
import XCTest

class SerialQueueTests: XCTestCase {
    
    func testFirstTrySucceedsImmediately() async {
        let queue = SerialQueue(waitTime: .milliseconds(250))
        let number = ManagedAtomic(0)
        
        Task {
            queue.perform {
                number.wrappingIncrement(ordering: .relaxed)
            }
        }
        
        try! await Task.sleep(nanoseconds: 10_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 1)
    }
    
    func testSecondTryNeedsToWait() async {
        let queue = SerialQueue(waitTime: .seconds(2))
        let number = ManagedAtomic(0)
        
        Task {
            for _ in 0..<2 {
                queue.perform {
                    number.wrappingIncrement(ordering: .relaxed)
                }
            }
        }
        
        /// 50ms so the number should be 1
        try! await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 1)
        
        /// 500ms so the number should still be 1
        try! await Task.sleep(nanoseconds: 450_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 1)
        
        /// 1s so the number should still be 1
        try! await Task.sleep(nanoseconds: 500_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 1)
        
        /// 1.5s so the number should still be 1
        try! await Task.sleep(nanoseconds: 500_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 1)
        
        /// 2s so now the number should be 2
        /// 520ms instead of just 500ms is to make sure the test isn't flaky
        try! await Task.sleep(nanoseconds: 520_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 2)
    }
    
    func testALotOfTriesNeedToWaitInQueue() async {
        let queue = SerialQueue(waitTime: .milliseconds(100))
        let number = ManagedAtomic(0)
        
        Task {
            for _ in 0..<5 {
                queue.perform {
                    number.wrappingIncrement(ordering: .relaxed)
                }
            }
        }
        
        /// 50ms so the number should be 1
        try! await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 1)
        
        /// 100ms so the number should be 2
        try! await Task.sleep(nanoseconds: 60_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 2)
        
        /// 150ms so the number should be 2
        try! await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 2)
        
        /// 200ms so the number should be 3
        try! await Task.sleep(nanoseconds: 60_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 3)
        
        /// 250ms so the number should be 3
        try! await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 3)
        
        /// 300ms so the number should be 4
        try! await Task.sleep(nanoseconds: 60_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 4)
        
        /// 350ms so the number should be 4
        try! await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 4)
        
        /// 400ms so the number should be 5
        try! await Task.sleep(nanoseconds: 60_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 5)
        
        /// 450ms so the number should be 5
        try! await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 5)
        
        /// 500ms so the number should be 5
        try! await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 5)
        
        /// 550ms so the number should be 5
        try! await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 5)
        
        /// 600ms so the number should be 5
        try! await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 5)
        
        /// 1600ms so the number should be 5
        try! await Task.sleep(nanoseconds: 1_000_000_000)
        XCTAssertEqual(number.load(ordering: .relaxed), 5)
    }
}
