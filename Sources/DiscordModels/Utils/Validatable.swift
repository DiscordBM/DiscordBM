
public protocol ValidatablePayload {
    /// Default library functions only throw ``ValidationError``.
    func validate() throws
}

public enum ValidationError: Error {
    /// At least one of these fields is required to be present.
    case atLeastOneFieldIsRequired(names: [String])
    /// Too many characters in the target (likely a String). Need to shorten it.
    case tooManyCharacters(name: String, max: Int)
    /// Count of characters in the target (likely a String) is not acceptable.
    case invalidCharactersCount(name: String, min: Int, max: Int)
    /// Too many elements in the target (likely an Array). Need to shorten it.
    case tooManyElements(name: String, max: Int)
    /// At least one of the values you are trying to send is prohibited. Remove them.
    case containsProhibitedValues(name: String, reason: String, valuesRepresentation: String)
    /// Precondition needs to be met first.
    case hasPrecondition(name: String, reason: String)
    /// Field can't be empty.
    case cantBeEmpty(name: String)
    /// The number is too big or too small.
    case numberOutOfRange(name: String, number: String, min: String, max: String)
}

extension ValidatablePayload {
    
    @inlinable
    func validateAtLeastOneIsNotEmpty(
        _ isEmpties: Bool?...,
        names: String...
    ) throws {
        guard isEmpties.contains(where: { $0 == false || $0 == nil }) else {
            throw ValidationError.atLeastOneFieldIsRequired(names: names)
        }
    }
    
    @inlinable
    func validateCharacterCountDoesNotExceed(_ value: String?, max: Int, name: String) throws {
        guard value?.unicodeScalars.count ?? 0 <= max else {
            throw ValidationError.tooManyCharacters(name: name, max: max)
        }
    }
    
    @inlinable
    func validateCharacterCountInRange(_ value: String?, min: Int, max: Int, name: String) throws {
        let count = value?.unicodeScalars.count ?? 0
        guard min <= count, count <= max else {
            throw ValidationError.invalidCharactersCount(name: name, min: min, max: max)
        }
    }
    
    @inlinable
    func validateCombinedCharacterCountDoesNotExceed(
        _ count: Int?,
        max: Int,
        names: String...
    ) throws {
        guard count ?? 0 <= max else {
            throw ValidationError.tooManyCharacters(name: names.joined(separator: "+"), max: max)
        }
    }
    
    @inlinable
    func validateElementCountDoesNotExceed<T>(_ array: Array<T>?, max: Int, name: String) throws {
        guard array?.count ?? 0 <= max else {
            throw ValidationError.tooManyElements(name: name, max: max)
        }
    }
    
    @inlinable
    func validateOnlyContains<C: Collection>(
        _ values: C?,
        name: String,
        reason: String,
        where block: (C.Element) -> Bool
    ) throws {
        if values?.first(where: { !block($0) }) != nil {
            throw ValidationError.containsProhibitedValues(
                name: name,
                reason: reason,
                valuesRepresentation: "\(values!)"
            )
        }
    }
    
    @inlinable
    func validateHasPrecondition(
        condition: Bool,
        allowedIf: Bool,
        name: String,
        reason: String
    ) throws {
        if condition {
            if !allowedIf {
                throw ValidationError.hasPrecondition(
                    name: name,
                    reason: reason
                )
            }
        }
    }
    
    @inlinable
    func validateAssertIsNotEmpty(_ isNotEmpty: Bool, name: String) throws {
        if !isNotEmpty {
            throw ValidationError.cantBeEmpty(name: name)
        }
    }
    
    @inlinable
    func validateNumberInRange<N: Numeric & Comparable>(
        _ number: N?,
        min: N,
        max: N,
        name: String
    ) throws {
        if let number = number {
            guard number >= min, number <= max else {
                throw ValidationError.numberOutOfRange(
                    name: name,
                    number: "\(number)",
                    min: "\(min)",
                    max: "\(max)"
                )
            }
        }
    }
}
