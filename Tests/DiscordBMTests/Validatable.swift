@testable import DiscordModels
import XCTest

class ValidatablePayloadTests: XCTestCase, @unchecked Sendable, ValidatablePayload {
    
    /// `ValidatablePayload` requirement
    func validations() -> Validation { }
    
    func testValidateAssertIsNotEmpty() throws {
        try validateAssertIsNotEmpty(true, name: "a")?.throw(model: self)
        XCTAssertThrowsError(
            try validateAssertIsNotEmpty(false, name: "a")?.throw(model: self)
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, Validation.cantBeEmpty(name: "a"))
        }
    }
    
    func testValidateAtLeastOneIsNotEmpty() throws {
        try validateAtLeastOneIsNotEmpty(false, names: "a")?.throw(model: self)
        try validateAtLeastOneIsNotEmpty(nil, names: "a")?.throw(model: self)
        try validateAtLeastOneIsNotEmpty(false, true, names: "a")?.throw(model: self)
        try validateAtLeastOneIsNotEmpty(nil, true, names: "a")?.throw(model: self)
        try validateAtLeastOneIsNotEmpty(false, nil, true, names: "a")?.throw(model: self)
        try validateAtLeastOneIsNotEmpty(false, false, nil, nil, true, true, names: "a")?.throw(model: self)
        try validateAtLeastOneIsNotEmpty(nil, names: "a")?.throw(model: self)
        XCTAssertThrowsError(
            try validateAtLeastOneIsNotEmpty(true, names: "a")?.throw(model: self)
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .atLeastOneFieldIsRequired(names: ["a"]))
        }
    }
    
    func testValidateCharacterCountDoesNotExceed() throws {
        /// Some characters are 2 unicode bytes.
        /// It's important to always use `char.unicodeScalars.count` instead of `char.count`.
        XCTAssertEqual("🇯🇵".count, 1)
        XCTAssertEqual("🇯🇵".unicodeScalars.count, 2)
        
        try validateCharacterCountDoesNotExceed(nil, max: 0, name: "a")?.throw(model: self)
        try validateCharacterCountDoesNotExceed(nil, max: 12, name: "a")?.throw(model: self)
        try validateCharacterCountDoesNotExceed("", max: 0, name: "a")?.throw(model: self)
        try validateCharacterCountDoesNotExceed("abcde", max: 5, name: "a")?.throw(model: self)
        try validateCharacterCountDoesNotExceed("🇯🇵", max: 2, name: "emoji")?.throw(model: self)
        XCTAssertThrowsError(
            try validateCharacterCountDoesNotExceed("🇯🇵", max: 1, name: "emoji")?.throw(model: self)
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .tooManyCharacters(name: "emoji", max: 1))
        }
        XCTAssertThrowsError(
            try validateCharacterCountDoesNotExceed("abdcefghijk", max: 10, name: "a")?.throw(model: self)
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .tooManyCharacters(name: "a", max: 10))
        }
    }
    
    func testValidateCharacterCountInRange() throws {
        try validateCharacterCountInRange(nil, min: 0, max: 0, name: "a")?.throw(model: self)
        try validateCharacterCountInRange(nil, min: 0, max: 12, name: "a")?.throw(model: self)
        try validateCharacterCountInRange("", min: 0, max: 0, name: "a")?.throw(model: self)
        try validateCharacterCountInRange("abcde", min: 5, max: 5, name: "a")?.throw(model: self)
        try validateCharacterCountInRange("🇯🇵", min: 1, max: 2, name: "emoji")?.throw(model: self)
        XCTAssertThrowsError(
            try validateCharacterCountInRange("🇯🇵", min: 3, max: 4, name: "emoji")?.throw(model: self)
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .characterCountOutOfRange(name: "emoji", min: 3, max: 4))
        }
        XCTAssertThrowsError(
            try validateCharacterCountInRange("abdcefghijk", min: 20, max: 40, name: "a")?.throw(model: self)
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .characterCountOutOfRange(name: "a", min: 20, max: 40))
        }
    }
    
    func testValidateCombinedCharacterCountDoesNotExceed() throws {
        try validateCombinedCharacterCountDoesNotExceed(nil, max: 0, names: "a")?.throw(model: self)
        try validateCombinedCharacterCountDoesNotExceed(nil, max: 1, names: "a")?.throw(model: self)
        try validateCombinedCharacterCountDoesNotExceed(0, max: 0, names: "a")?.throw(model: self)
        try validateCombinedCharacterCountDoesNotExceed(0, max: 1, names: "a")?.throw(model: self)
        try validateCombinedCharacterCountDoesNotExceed(5, max: 5, names: "a")?.throw(model: self)
        try validateCombinedCharacterCountDoesNotExceed(5_000, max: 5_000, names: "a")?.throw(model: self)
        XCTAssertThrowsError(
            try validateCombinedCharacterCountDoesNotExceed(5_001, max: 5_000, names: "a", "b")?.throw(model: self)
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .tooManyCharacters(name: "a+b", max: 5_000))
        }
    }
    
    func testValidateElementCountDoesNotExceed() throws {
        try validateElementCountDoesNotExceed(Optional<Array<Never>>.none, max: 0, name: "a")?.throw(model: self)
        try validateElementCountDoesNotExceed(Optional<Array<String>>.none, max: 1, name: "a")?.throw(model: self)
        try validateElementCountDoesNotExceed([String](), max: 0, name: "a")?.throw(model: self)
        try validateElementCountDoesNotExceed([String](), max: 1, name: "a")?.throw(model: self)
        try validateElementCountDoesNotExceed([1, 2, 3, 4], max: 4, name: "a")?.throw(model: self)
        XCTAssertThrowsError(
            try validateElementCountDoesNotExceed([1, 2, 3, 4, 5], max: 4, name: "t")?.throw(model: self)
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .tooManyElements(name: "t", max: 4))
        }
    }
    
    func testValidateOnlyContains() throws {
        try validateOnlyContains(
            Optional<Array<String>>.none,
            name: "r",
            reason: "k",
            where: { _ in false }
        )?.throw(model: self)
        try validateOnlyContains(
            Optional<Array<Int>>.none,
            name: "r",
            reason: "k",
            where: { _ in true }
        )?.throw(model: self)
        try validateOnlyContains(
            [1, 2, 3],
            name: "r",
            reason: "k",
            where: { [1, 2, 3].contains($0) }
        )?.throw(model: self)
        XCTAssertThrowsError(
            try validateOnlyContains(
                [1, 2, 3, 4],
                name: "r",
                reason: "k",
                where: { [1, 2, 3].contains($0) }
            )?.throw(model: self)
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .containsProhibitedValues(
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
        )?.throw(model: self)
        try validateCaseInsensitivelyDoesNotContain(
            "discor",
            name: "aaabbb",
            values: ["discord", "clyde"],
            reason: "res"
        )?.throw(model: self)
        XCTAssertThrowsError(
            try validateCaseInsensitivelyDoesNotContain(
                "diScordclYde",
                name: "aabb",
                values: ["discord", "clyde"],
                reason: "rrr"
            )?.throw(model: self)
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .containsProhibitedValues(
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
        )?.throw(model: self)
        try validateHasPrecondition(
            condition: false,
            allowedIf: false,
            name: "qq",
            reason: "pji"
        )?.throw(model: self)
        try validateHasPrecondition(
            condition: false,
            allowedIf: true,
            name: "qq",
            reason: "pji"
        )?.throw(model: self)
        XCTAssertThrowsError(
            try validateHasPrecondition(
                condition: true,
                allowedIf: false,
                name: "qq",
                reason: "pji"
            )?.throw(model: self)
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .hasPrecondition(name: "qq", reason: "pji"))
        }
    }
    
    func validateNumberInRange() throws {
        try validateNumberInRange(1, min: 0, max: 21_600, name: "adoand")?.throw(model: self)
        try validateNumberInRange(0, min: 0, max: 21_600, name: "")?.throw(model: self)
        try validateNumberInRange(21_599, min: 0, max: 21_600, name: "qerqer")?.throw(model: self)
        try validateNumberInRange(21_600.9, min: 0, max: 21_601, name: "kkdasd")?.throw(model: self)
        try validateNumberInRange(999, min: 0, max: 998, name: "tt")?.throw(model: self)
        XCTAssertThrowsError(
            try validateNumberInRange(9, min: 10, max: 21, name: "tt")?.throw(model: self)
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .numberOutOfRange(name: "tt", number: "9", min: "10", max: "21"))
        }
        XCTAssertThrowsError(
            try validateNumberInRange(22, min: 10, max: 21, name: "c,axz")?.throw(model: self)
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(
                error,
                .numberOutOfRange(name: "c,axz", number: "22", min: "10", max: "21")
            )
        }
        XCTAssertThrowsError(
            try validateNumberInRange(-1391293, min: 10, max: 21, name: "rqerqrew")?.throw(model: self)
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(
                error,
                .numberOutOfRange(name: "rqerqrew", number: "-1391293", min: "10", max: "21")
            )
        }
        XCTAssertThrowsError(
            try validateNumberInRange(934129139, min: 10, max: 21, name: "oewo")?.throw(model: self)
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(
                error,
                .numberOutOfRange(name: "oewo", number: "934129139", min: "10", max: "21")
            )
        }
    }
    
    func testValidationsThrowsMultiple() throws {
        let embed = Embed(
            title: String(repeating: "a", count: 257),
            author: .init(name: String(repeating: "b", count: 256)),
            fields: .init(repeating: .init(name: "a", value: "b"), count: 26)
        )
        XCTAssertThrowsError(try embed.validations().throw(model: embed)) { error in
            let error = error as! ValidationError
            XCTAssertEqual("\(error.model)", "\(embed)")
            XCTAssertEqual(error.failedValidations, [
                .tooManyElements(name: "fields", max: 25),
                .tooManyCharacters(name: "title", max: 256)
            ])
        }
    }
    
    func XCTAssertErrorsEqual(_ expression1: ValidationError, _ expression2: Validation) {
        XCTAssertEqual(
            expression1.failedValidations.first!.errorDescription!,
            expression2.errorDescription!
        )
    }
}

extension Validation: Equatable {
    public static func == (lhs: Validation, rhs: Validation) -> Bool {
        "\(lhs)" == "\(rhs)"
    }
}
