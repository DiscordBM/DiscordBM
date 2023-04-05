@testable import DiscordModels
import XCTest

class ValidatablePayloadTests: XCTestCase, @unchecked Sendable, ValidatablePayload {
    
    /// `ValidatablePayload` requirement
    func validate() throws { }
    
    func testValidateAssertIsNotEmpty() throws {
        try validateAssertIsNotEmpty(true, name: "a")
        XCTAssertThrowsError(
            try validateAssertIsNotEmpty(false, name: "a")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, ValidationError.cantBeEmpty(self, name: "a"))
        }
    }
    
    func testValidateAtLeastOneIsNotEmpty() throws {
        try validateAtLeastOneIsNotEmpty(false, names: "a")
        try validateAtLeastOneIsNotEmpty(nil, names: "a")
        try validateAtLeastOneIsNotEmpty(false, true, names: "a")
        try validateAtLeastOneIsNotEmpty(nil, true, names: "a")
        try validateAtLeastOneIsNotEmpty(false, nil, true, names: "a")
        try validateAtLeastOneIsNotEmpty(false, false, nil, nil, true, true, names: "a")
        try validateAtLeastOneIsNotEmpty(nil, names: "a")
        XCTAssertThrowsError(
            try validateAtLeastOneIsNotEmpty(true, names: "a")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, .atLeastOneFieldIsRequired(self, names: ["a"]))
        }
    }
    
    func testValidateCharacterCountDoesNotExceed() throws {
        /// Some characters are 2 unicode bytes.
        /// It's important to always use `char.unicodeScalars.count` instead of `char.count`.
        XCTAssertEqual("🇯🇵".count, 1)
        XCTAssertEqual("🇯🇵".unicodeScalars.count, 2)
        
        try validateCharacterCountDoesNotExceed(nil, max: 0, name: "a")
        try validateCharacterCountDoesNotExceed(nil, max: 12, name: "a")
        try validateCharacterCountDoesNotExceed("", max: 0, name: "a")
        try validateCharacterCountDoesNotExceed("abcde", max: 5, name: "a")
        try validateCharacterCountDoesNotExceed("🇯🇵", max: 2, name: "emoji")
        XCTAssertThrowsError(
            try validateCharacterCountDoesNotExceed("🇯🇵", max: 1, name: "emoji")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, .tooManyCharacters(self, name: "emoji", max: 1))
        }
        XCTAssertThrowsError(
            try validateCharacterCountDoesNotExceed("abdcefghijk", max: 10, name: "a")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, .tooManyCharacters(self, name: "a", max: 10))
        }
    }
    
    func testValidateCharacterCountInRange() throws {
        try validateCharacterCountInRange(nil, min: 0, max: 0, name: "a")
        try validateCharacterCountInRange(nil, min: 0, max: 12, name: "a")
        try validateCharacterCountInRange("", min: 0, max: 0, name: "a")
        try validateCharacterCountInRange("abcde", min: 5, max: 5, name: "a")
        try validateCharacterCountInRange("🇯🇵", min: 1, max: 2, name: "emoji")
        XCTAssertThrowsError(
            try validateCharacterCountInRange("🇯🇵", min: 3, max: 4, name: "emoji")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, .characterCountOutOfRange(self, name: "emoji", min: 3, max: 4))
        }
        XCTAssertThrowsError(
            try validateCharacterCountInRange("abdcefghijk", min: 20, max: 40, name: "a")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, .characterCountOutOfRange(self, name: "a", min: 20, max: 40))
        }
    }
    
    func testValidateCombinedCharacterCountDoesNotExceed() throws {
        try validateCombinedCharacterCountDoesNotExceed(nil, max: 0, names: "a")
        try validateCombinedCharacterCountDoesNotExceed(nil, max: 1, names: "a")
        try validateCombinedCharacterCountDoesNotExceed(0, max: 0, names: "a")
        try validateCombinedCharacterCountDoesNotExceed(0, max: 1, names: "a")
        try validateCombinedCharacterCountDoesNotExceed(5, max: 5, names: "a")
        try validateCombinedCharacterCountDoesNotExceed(5_000, max: 5_000, names: "a")
        XCTAssertThrowsError(
            try validateCombinedCharacterCountDoesNotExceed(5_001, max: 5_000, names: "a", "b")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, .tooManyCharacters(self, name: "a+b", max: 5_000))
        }
    }
    
    func testValidateElementCountDoesNotExceed() throws {
        try validateElementCountDoesNotExceed(Optional<Array<Never>>.none, max: 0, name: "a")
        try validateElementCountDoesNotExceed(Optional<Array<String>>.none, max: 1, name: "a")
        try validateElementCountDoesNotExceed([String](), max: 0, name: "a")
        try validateElementCountDoesNotExceed([String](), max: 1, name: "a")
        try validateElementCountDoesNotExceed([1, 2, 3, 4], max: 4, name: "a")
        XCTAssertThrowsError(
            try validateElementCountDoesNotExceed([1, 2, 3, 4, 5], max: 4, name: "t")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, .tooManyElements(self, name: "t", max: 4))
        }
    }
    
    func testValidateOnlyContains() throws {
        try validateOnlyContains(
            Optional<Array<String>>.none,
            name: "r",
            reason: "k",
            where: { _ in false }
        )
        try validateOnlyContains(
            Optional<Array<Int>>.none,
            name: "r",
            reason: "k",
            where: { _ in true }
        )
        try validateOnlyContains(
            [1, 2, 3],
            name: "r",
            reason: "k",
            where: { [1, 2, 3].contains($0) }
        )
        XCTAssertThrowsError(
            try validateOnlyContains(
                [1, 2, 3, 4],
                name: "r",
                reason: "k",
                where: { [1, 2, 3].contains($0) }
            )
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, .containsProhibitedValues(
                self,
                name: "r",
                reason: "k",
                valuesRepresentation: "\([1, 2, 3, 4])"
            ))
        }
    }
    
    func testValidateCaseInsensitivelyDoesNotContain() throws {
        try validateCaseInsensitivelyDoesNotContain(
            nil,
            name: "aaabbb",
            values: ["discord", "clyde"],
            reason: "res"
        )
        try validateCaseInsensitivelyDoesNotContain(
            "discor",
            name: "aaabbb",
            values: ["discord", "clyde"],
            reason: "res"
        )
        XCTAssertThrowsError(
            try validateCaseInsensitivelyDoesNotContain(
                "diScordclYde",
                name: "aabb",
                values: ["discord", "clyde"],
                reason: "rrr"
            )
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, .containsProhibitedValues(
                self,
                name: "aabb",
                reason: "rrr",
                valuesRepresentation: "\(["discord", "clyde"])"
            ))
        }
    }
    
    func testValidateHasPrecondition() throws {
        try validateHasPrecondition(
            condition: true,
            allowedIf: true,
            name: "qq",
            reason: "pji"
        )
        try validateHasPrecondition(
            condition: false,
            allowedIf: false,
            name: "qq",
            reason: "pji"
        )
        try validateHasPrecondition(
            condition: false,
            allowedIf: true,
            name: "qq",
            reason: "pji"
        )
        XCTAssertThrowsError(
            try validateHasPrecondition(
                condition: true,
                allowedIf: false,
                name: "qq",
                reason: "pji"
            )
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, .hasPrecondition(self, name: "qq", reason: "pji"))
        }
    }
    
    func validateNumberInRange() throws {
        try validateNumberInRange(1, min: 0, max: 21_600, name: "adoand")
        try validateNumberInRange(0, min: 0, max: 21_600, name: "")
        try validateNumberInRange(21_599, min: 0, max: 21_600, name: "qerqer")
        try validateNumberInRange(21_600.9, min: 0, max: 21_601, name: "kkdasd")
        try validateNumberInRange(999, min: 0, max: 998, name: "tt")
        XCTAssertThrowsError(
            try validateNumberInRange(9, min: 10, max: 21, name: "tt")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, .numberOutOfRange(self, name: "tt", number: "9", min: "10", max: "21"))
        }
        XCTAssertThrowsError(
            try validateNumberInRange(22, min: 10, max: 21, name: "c,axz")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(
                error,
                .numberOutOfRange(self, name: "c,axz", number: "22", min: "10", max: "21")
            )
        }
        XCTAssertThrowsError(
            try validateNumberInRange(-1391293, min: 10, max: 21, name: "rqerqrew")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(
                error,
                .numberOutOfRange(self, name: "rqerqrew", number: "-1391293", min: "10", max: "21")
            )
        }
        XCTAssertThrowsError(
            try validateNumberInRange(934129139, min: 10, max: 21, name: "oewo")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(
                error,
                .numberOutOfRange(self, name: "oewo", number: "934129139", min: "10", max: "21")
            )
        }
    }
}

extension ValidationError: Equatable {
    public static func == (lhs: ValidationError, rhs: ValidationError) -> Bool {
        "\(lhs)" == "\(rhs)"
    }
}
