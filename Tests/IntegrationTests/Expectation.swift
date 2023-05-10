import Foundation
import XCTest

/// XCTest's own `XCTestExpectation` is waaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaay too flaky on linux.
class Expectation {
    nonisolated let description: String
    private var fulfilled = false
    private var fulfillment: (@Sendable () -> Void)? = nil
    let queue: DispatchQueue

    init(description: String) {
        self.description = description
        self.queue = DispatchQueue(label: "QueueForExpectation:\(description)")
    }

    func fulfill(
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        queue.sync {
            self._fulfill(file: file, line: line)
        }
    }

    private func _fulfill(
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        if self.fulfilled {
            XCTFail(
                "Expectation '\(self.description)' was already fulfilled",
                file: file,
                line: line
            )
        } else {
            self.fulfilled = true
            self.fulfillment?()
        }
    }

    nonisolated func onFulfillment(block: @Sendable @escaping () -> Void) {
        queue.sync {
            self._onFulfillment(block: block)
        }
    }

    private func _onFulfillment(block: @Sendable @escaping () -> Void) {
        if self.fulfilled {
            block()
        } else {
            self.fulfillment = block
        }
    }
}

// MARK: - Indices
private class Indices {
    private var value: [Int] = []
    let queue = DispatchQueue(label: "ExpectationIndicesQueue")

    init() { }

    func get() -> [Int] {
        queue.sync {
            self.value
        }
    }

    func appending(_ index: Int) -> [Int] {
        queue.sync {
            self.value.append(index)
            return self.value
        }
    }
}

// MARK: - +XCTestCase
extension XCTestCase {
    func waitFulfillment(
        of expectations: [Expectation],
        timeout: Double,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let fulfilledIndices = Indices()

        let task = Task(priority: .high) {
            try await Task.sleep(for: .nanoseconds(Int(timeout * 1_000_000_000)))
            let indices = fulfilledIndices.get()
            let left = expectations
                .enumerated()
                .filter { !indices.contains($0.offset) }
            if !left.isEmpty {
                XCTFail(
                    "Some expectations failed to resolve in \(timeout) seconds: \(left)",
                    file: file,
                    line: line
                )
            }
        }

        await withCheckedContinuation { (cont: CheckedContinuation<(), Never>) in
            for (idx, expectation) in expectations.enumerated() {
                expectation.onFulfillment {
                    let indices = fulfilledIndices.appending(idx)
                    let left = expectations
                        .enumerated()
                        .filter { !indices.contains($0.offset) }
                    if left.isEmpty {
                        task.cancel()
                        cont.resume()
                    }
                }
            }
        }
    }
}
