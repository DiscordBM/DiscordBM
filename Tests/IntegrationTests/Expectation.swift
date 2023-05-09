import XCTest

/// XCTest's own `XCTestExpectation` is waaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaay too flaky on linux.
actor Expectation {
    nonisolated let description: String
    private var fulfilled = false
    private var fulfillment: (() async -> Void)? = nil
    private var alreadyFulfilled = false

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
        if self.alreadyFulfilled {
            XCTFail(
                "Expectation '\(self.description)' was already fulfilled",
                file: file,
                line: line
            )
        } else {
            self.fulfilled = true
            self.alreadyFulfilled = true
            await self.fulfillment?()
        }
    }

    nonisolated func onFulfillment(block: @Sendable @escaping () async -> Void) {
        Task { await self._onFulfillment(block: block) }
    }

    private func _onFulfillment(block: @Sendable @escaping () async -> Void) async {
        if self.fulfilled {
            self.alreadyFulfilled = true
            await block()
        } else {
            self.fulfillment = block
        }
    }
}

private actor Indices {
    var value: [Int] = []

    init() { }

    func append(_ index: Int) {
        self.value.append(index)
    }

    func contains(_ index: Int) -> Bool {
        self.value.contains(index)
    }
}

extension XCTestCase {
    func waitFulfill(
        for expectations: [Expectation],
        timeout: Double,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let fulfilledIndices = Indices()

        Task {
            try await Task.sleep(for: .nanoseconds(Int(timeout * 1_000_000_000)))
            var left = [String]()
            for (idx, exp) in expectations.enumerated() {
                if await !fulfilledIndices.contains(idx) {
                    left.append(exp.description)
                }
            }
            if !left.isEmpty {
                XCTFail(
                    "Some expectations failed: \(left)",
                    file: file,
                    line: line
                )
            }
        }

        await withCheckedContinuation { (cont: CheckedContinuation<(), Never>) in
            for (idx, expectation) in expectations.enumerated() {
                expectation.onFulfillment {
                    await fulfilledIndices.append(idx)
                    var anyLeft = false
                    for idx in expectations.indices {
                        if await !fulfilledIndices.contains(idx) {
                            anyLeft = true
                            break
                        }
                    }
                    if !anyLeft {
                        cont.resume()
                    }
                }
            }
        }
    }
}
