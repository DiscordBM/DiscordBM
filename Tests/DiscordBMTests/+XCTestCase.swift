import XCTest

extension XCTestCase {
    func waitFulfill(for expectations: [XCTestExpectation], timeout: Double) async {
#if swift(>=5.8) && os(macOS)
        await fulfillment(of: expectations, timeout: timeout)
#else
        wait(for: expectations, timeout: timeout)
#endif
    }
}
