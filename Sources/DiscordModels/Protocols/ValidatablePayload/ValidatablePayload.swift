import Foundation

public protocol ValidatablePayload: Sendable {
    /// Returns a list of validations for the type.
    ///
    /// Default library functions only throw ``ValidationError``.
    @ValidationAccumulator func validate() -> [ValidationFailure]
}

extension ValidatablePayload {
    
    @inlinable
    func validateAtLeastOneIsNotEmpty(
        _ isEmpties: Bool?...,
        names: String...
    ) -> ValidationFailure? {
        guard isEmpties.contains(where: { $0 == false || $0 == nil }) else {
            return ValidationFailure.atLeastOneFieldIsRequired(names: names)
        }
        return nil
    }
    
    @inlinable
    func validateCharacterCountDoesNotExceed(_ value: String?, max: Int, name: String) -> ValidationFailure? {
        guard value?.unicodeScalars.count ?? 0 <= max else {
            return ValidationFailure.tooManyCharacters(name: name, max: max)
        }
        return nil
    }
    
    @inlinable
    func validateCharacterCountInRange(_ value: String?, min: Int, max: Int, name: String) -> ValidationFailure? {
        let count = value?.unicodeScalars.count ?? 0
        guard min <= count, count <= max else {
            return ValidationFailure.characterCountOutOfRange(name: name, min: min, max: max)
        }
        return nil
    }

    @inlinable
    func validateCharacterCountInRangeOrNil(_ value: String?, min: Int, max: Int, name: String) -> ValidationFailure? {
        guard let value = value else { return nil }
        let count = value.unicodeScalars.count
        guard min <= count, count <= max else {
            return ValidationFailure.characterCountOutOfRange(name: name, min: min, max: max)
        }
        return nil
    }
    
    @inlinable
    func validateCombinedCharacterCountDoesNotExceed(
        _ count: Int?,
        max: Int,
        names: String...
    ) -> ValidationFailure? {
        guard count ?? 0 <= max else {
            return ValidationFailure.tooManyCharacters(name: names.joined(separator: "+"), max: max)
        }
        return nil
    }
    
    @inlinable
    func validateElementCountDoesNotExceed<T>(_ array: Array<T>?, max: Int, name: String) -> ValidationFailure? {
        guard array?.count ?? 0 <= max else {
            return ValidationFailure.tooManyElements(name: name, max: max)
        }
        return nil
    }
    
    @inlinable
    func validateOnlyContains<C: Collection>(
        _ values: C?,
        name: String,
        reason: String,
        where block: (C.Element) -> Bool
    ) -> ValidationFailure? {
        if values?.first(where: { !block($0) }) != nil {
            return ValidationFailure.containsProhibitedValues(
                name: name,
                reason: reason,
                valuesRepresentation: "\(values!)"
            )
        }
        return nil
    }
    
    @inlinable
    func validateCaseInsensitivelyDoesNotContain(
        _ value: String?,
        name: String,
        values: [String],
        reason: String
    ) -> ValidationFailure? {
        if let value = value,
           values.contains(where: { value.localizedCaseInsensitiveContains($0) }) {
            return ValidationFailure.containsProhibitedValues(
                name: name,
                reason: reason,
                valuesRepresentation: "\(values)"
            )
        }
        return nil
    }
    
    @inlinable
    func validateHasPrecondition(
        condition: Bool,
        allowedIf: Bool,
        name: String,
        reason: String
    ) -> ValidationFailure? {
        if condition {
            if !allowedIf {
                return ValidationFailure.hasPrecondition(name: name, reason: reason)
            }
        }
        return nil
    }
    
    @inlinable
    func validateAssertIsNotEmpty(_ isNotEmpty: Bool, name: String) -> ValidationFailure? {
        if !isNotEmpty {
            return ValidationFailure.cantBeEmpty(name: name)
        }
        return nil
    }
    
    @inlinable
    func validateNumberInRange<N: Numeric & Comparable>(
        _ number: N?,
        min: N,
        max: N,
        name: String
    ) -> ValidationFailure? {
        if let number = number {
            guard number >= min, number <= max else {
                return ValidationFailure.numberOutOfRange(
                    name: name,
                    number: "\(number)",
                    min: "\(min)",
                    max: "\(max)"
                )
            }
        }
        return nil
    }
}

// MARK: - +Array
extension Array: ValidatablePayload where Element: ValidatablePayload {
    public func validate() -> [ValidationFailure] {
        for element in self {
            element.validate()
        }
    }
}
