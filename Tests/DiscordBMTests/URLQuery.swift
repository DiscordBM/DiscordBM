import DiscordBM
import XCTest

class URLQueryTests: XCTestCase {

    func testSpecialCharactersInValuesAreEscaped() throws {
        let queries: [(String, String?)] = [
            ("space", "a b"),
            ("ampersand", "a&b=c"),
            ("equals", "a=b"),
            ("plus", "a+b"),
            ("hash", "a#b"),
            ("question", "a?b"),
            ("all", "x y&z=1+2#3?4"),
        ]

        XCTAssertEqual(
            queries.makeForURLQuery(),
            "?space=a%20b&ampersand=a%26b%3Dc&equals=a%3Db&plus=a%2Bb&hash=a%23b&question=a%3Fb&all=x%20y%26z%3D1%2B2%233%3F4"
        )
    }

    func testOrdinaryValuesAreUnchanged() throws {
        let queries: [(String, String?)] = [
            ("after", "1030118727418646629"),
            ("with_counts", "true"),
            ("before", "2026-01-01T00:00:00Z"),
            ("limit", "100"),
        ]

        XCTAssertEqual(
            queries.makeForURLQuery(),
            "?after=1030118727418646629&with_counts=true&before=2026-01-01T00:00:00Z&limit=100"
        )
    }

    func testNilValuesAreSkipped() throws {
        let queries: [(String, String?)] = [
            ("a", "1"),
            ("b", nil),
            ("c", "3"),
            ("d", nil),
        ]

        XCTAssertEqual(queries.makeForURLQuery(), "?a=1&c=3")

        let allNil: [(String, String?)] = [("a", nil), ("b", nil)]
        XCTAssertEqual(allNil.makeForURLQuery(), "")

        let empty: [(String, String?)] = []
        XCTAssertEqual(empty.makeForURLQuery(), "")
    }
}
