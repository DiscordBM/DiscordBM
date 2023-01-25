@testable import DiscordModels
import XCTest

class ValidatableTests: XCTestCase, Validatable {
    
    func testValidateAssertIsNotEmpty() throws {
        try validateAssertIsNotEmpty(true, name: "a")
        XCTAssertThrowsError(
            try validateAssertIsNotEmpty(false, name: "a")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, ValidationError.cantBeEmpty(name: "a"))
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
            XCTAssertEqual(error, .atLeastOneFieldIsRequired(names: ["a"]))
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
            XCTAssertEqual(error, .tooManyCharacters(name: "emoji", max: 1))
        }
        XCTAssertThrowsError(
            try validateCharacterCountDoesNotExceed("abdcefghijk", max: 10, name: "a")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, .tooManyCharacters(name: "a", max: 10))
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
            XCTAssertEqual(error, .invalidCharactersCount(name: "emoji", min: 3, max: 4))
        }
        XCTAssertThrowsError(
            try validateCharacterCountInRange("abdcefghijk", min: 20, max: 40, name: "a")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, .invalidCharactersCount(name: "a", min: 20, max: 40))
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
            XCTAssertEqual(error, .tooManyCharacters(name: "a+b", max: 5_000))
        }
    }
    
    func testValidateElementCountDoesNotExceed() throws {
        try validateElementCountDoesNotExceed(Optional<Array<Never>>.none, max: 0, name: "a")
        try validateElementCountDoesNotExceed(Optional<Array<String>>.none, max: 1, name: "a")
        try validateElementCountDoesNotExceed([], max: 0, name: "a")
        try validateElementCountDoesNotExceed([], max: 1, name: "a")
        try validateElementCountDoesNotExceed([1, 2, 3, 4], max: 4, name: "a")
        XCTAssertThrowsError(
            try validateElementCountDoesNotExceed([1, 2, 3, 4, 5], max: 4, name: "t")
        ) { error in
            let error = error as! ValidationError
            XCTAssertEqual(error, .tooManyElements(name: "t", max: 4))
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
                name: "r",
                reason: "k",
                valuesRepresentation: "\([1, 2, 3, 4])"
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
            XCTAssertEqual(error, .hasPrecondition(name: "qq", reason: "pji"))
        }
    }
    
    func validate() throws { }
}

extension ValidationError: Equatable {
    public static func == (lhs: ValidationError, rhs: ValidationError) -> Bool {
        "\(lhs)" == "\(rhs)"
    }
}
