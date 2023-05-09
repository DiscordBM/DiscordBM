import XCTest

/// XCTest's own `XCTestExpectation` is waaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaay too flaky on linux.
actor Expectation {
    nonisolated let description: String
    private var fulfilled = false
    private var fulfillment: (@Sendable () async -> Void)? = nil

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
            await self.fulfillment?()
        }
    }

    nonisolated func onFulfillment(block: @Sendable @escaping () async -> Void) {
        Task { await self._onFulfillment(block: block) }
    }

    private func _onFulfillment(block: @Sendable @escaping () async -> Void) async {
        if self.fulfilled {
            await block()
        } else {
            self.fulfillment = block
        }
    }
}

// MARK: - Indices
private actor Indices {
    var value: [Int] = []

    init() { }

    func appending(_ index: Int) -> [Int] {
        self.value.append(index)
        return value
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

        let task = Task {
            try await Task.sleep(for: .nanoseconds(Int(timeout * 1_000_000_000)))
            let indices = await fulfilledIndices.value
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
                    let indices = await fulfilledIndices.appending(idx)
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
