import Foundation
import XCTest

/// XCTest's own `XCTestExpectation` is waaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaay too flaky on linux.
actor Expectation {
    nonisolated let description: String
    private var fulfilled = false
    private var fulfillment: (@Sendable () -> Void)? = nil

    init(description: String) {
        self.description = description
    }

    nonisolated func fulfill(
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        Task { await self._fulfill(file: file, line: line) }
    }

    private func _fulfill(
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
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
        Task { await self._onFulfillment(block: block) }
    }

    private func _onFulfillment(block: @Sendable @escaping () -> Void) async {
        if self.fulfilled {
            block()
        } else {
            self.fulfillment = block
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
        let storage = FulfillmentStorage()

        let task = Task {
            try await Task.sleep(for: .nanoseconds(Int(timeout * 1_000_000_000)))
            let indices = storage.getIndices()
            let left = expectations
                .enumerated()
                .filter { !indices.contains($0.offset) }
            if !left.isEmpty {
                XCTFail(
                    "Some expectations failed to resolve in \(timeout) seconds: \(left)",
                    file: file,
                    line: line
                )
                storage.endContinuation()
            }
        }

        await withCheckedContinuation { (_cont: CheckedContinuation<(), Never>) in
            storage.setContinuation(to: _cont)

            for (idx, expectation) in expectations.enumerated() {
                expectation.onFulfillment {
                    let indices = storage.appendingIndex(idx)
                    let left = expectations
                        .enumerated()
                        .filter { !indices.contains($0.offset) }
                    if left.isEmpty {
                        task.cancel()
                        storage.endContinuation()
                    }
                }
            }
        }
    }
}

// MARK: - Indices
private class FulfillmentStorage {
    private var indices: [Int] = []
    private var continuation: CheckedContinuation<(), Never>? = nil
    private let queue = DispatchQueue(label: "FulfillmentStorageQueue")

    init() { }

    func getIndices() -> [Int] {
        queue.sync {
            self.indices
        }
    }

    func appendingIndex(_ index: Int) -> [Int] {
        queue.sync {
            self.indices.append(index)
            return self.indices
        }
    }

    func setContinuation(to new: CheckedContinuation<(), Never>) {
        queue.sync {
            self.continuation = new
        }
    }

    func endContinuation(file: StaticString = #filePath, line: UInt = #line) {
        queue.sync {
            if self.continuation != nil {
                self.continuation!.resume()
                self.continuation = nil
            } else {
                XCTFail(
                    "Trying to end continuation while it has already ended",
                    file: file,
                    line: line
                )
            }
        }
    }
}
