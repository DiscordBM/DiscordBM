import XCTest

extension XCTestCase {
    func XCTAssertNoAsyncThrow(
        _ block: () async throws -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            try await block()
        } catch {
            XCTFail("Block threw: \(error)", file: file, line: line)
        }
    }
}
