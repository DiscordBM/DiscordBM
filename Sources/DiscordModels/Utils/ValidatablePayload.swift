import Foundation

public protocol ValidatablePayload: Sendable {
    /// Default library functions only throw ``ValidationError``.
    func validate() throws
}

/// Read `helpAnchor` for help about each error case.
public enum ValidationError: LocalizedError {
    
    /// Suboptimal that we only use `ValidatablePayload` as the first argument of each case:
    /// it would also be too much of a pain to manually do `CustomStringConvertible`
    /// for all `ValidatablePayload` types.
    
    /// At least one of these fields is required to be present.
    case atLeastOneFieldIsRequired(ValidatablePayload, names: [String])
    /// Too many characters in the target (likely a String). Need to shorten it.
    case tooManyCharacters(ValidatablePayload, name: String, max: Int)
    /// Count of characters in the target (likely a String) is not acceptable.
    case characterCountOutOfRange(ValidatablePayload, name: String, min: Int, max: Int)
    /// Too many elements in the target (likely an Array). Need to shorten it.
    case tooManyElements(ValidatablePayload, name: String, max: Int)
    /// At least one of the values you are trying to send is prohibited. Remove them.
    case containsProhibitedValues(ValidatablePayload, name: String, reason: String, valuesRepresentation: String)
    /// Precondition needs to be met first.
    case hasPrecondition(ValidatablePayload, name: String, reason: String)
    /// Field can't be empty.
    case cantBeEmpty(ValidatablePayload, name: String)
    /// The number is too big or too small.
    case numberOutOfRange(ValidatablePayload, name: String, number: String, min: String, max: String)
    
    public var errorDescription: String? {
        switch self {
        case let .atLeastOneFieldIsRequired(model, names):
            return "atLeastOneFieldIsRequired(\(model), names: \(names))"
        case let .tooManyCharacters(model, name, max):
            return "tooManyCharacters(\(model), name: \(name), max: \(max))"
        case let .characterCountOutOfRange(model, name, min, max):
            return "characterCountOutOfRange(\(model), name: \(name), min: \(min), max: \(max))"
        case let .tooManyElements(model, name, max):
            return "tooManyElements(\(model), name: \(name), max: \(max))"
        case let .containsProhibitedValues(model, name, reason, valuesRepresentation):
            return "containsProhibitedValues(\(model), name: \(name), reason: \(reason), valuesRepresentation: \(valuesRepresentation))"
        case let .hasPrecondition(model, name, reason):
            return "hasPrecondition(\(model), name: \(name), reason: \(reason))"
        case let .cantBeEmpty(model, name):
            return "cantBeEmpty(\(model), name: \(name))"
        case let .numberOutOfRange(model, name, number, min, max):
            return "numberOutOfRange(\(model), name: \(name), number: \(number), min: \(min), max: \(max))"
        }
    }
    
    public var helpAnchor: String? {
        switch self {
        case let .atLeastOneFieldIsRequired(model, names):
            return "The model: \(model). At least one of these fields is required: \(names)"
        case let .tooManyCharacters(model, name, max):
            return "The model: \(model). Too many characters in the '\(name)' field. Max allowed is '\(max)'"
        case let .characterCountOutOfRange(model, name, min, max):
            return "The model: \(model). Character count of the '\(name)' field is out of the acceptable range of \(min)...\(max)"
        case let .tooManyElements(model, name, max):
            return "The model: \(model). Too many elements in the '\(name)' field. Max allowed is '\(max)'"
        case let .containsProhibitedValues(model, name, reason, valuesRepresentation):
            return "The model: \(model). The '\(name)' field contains prohibited values. Values: \(valuesRepresentation). Reason: \(reason)"
        case let .hasPrecondition(model, name, reason):
            return "The model: \(model). A precondition was not met for the '\(name)' field. Reason: \(reason)"
        case let .cantBeEmpty(model, name):
            return "The model: \(model). The '\(name)' field can't be empty."
        case let .numberOutOfRange(model, name, number, min, max):
            return "The model: \(model). The '\(name)' is set to the number '\(number)' which is out of the acceptable range of \(min)...\(max)"
        }
    }
}

extension ValidatablePayload {
    
    @inlinable
    func validateAtLeastOneIsNotEmpty(
        _ isEmpties: Bool?...,
        names: String...
    ) throws {
        guard isEmpties.contains(where: { $0 == false || $0 == nil }) else {
            throw ValidationError.atLeastOneFieldIsRequired(self, names: names)
        }
    }
    
    @inlinable
    func validateCharacterCountDoesNotExceed(_ value: String?, max: Int, name: String) throws {
        guard value?.unicodeScalars.count ?? 0 <= max else {
            throw ValidationError.tooManyCharacters(self, name: name, max: max)
        }
    }
    
    @inlinable
    func validateCharacterCountInRange(_ value: String?, min: Int, max: Int, name: String) throws {
        let count = value?.unicodeScalars.count ?? 0
        guard min <= count, count <= max else {
            throw ValidationError.characterCountOutOfRange(self, name: name, min: min, max: max)
        }
    }
    
    @inlinable
    func validateCombinedCharacterCountDoesNotExceed(
        _ count: Int?,
        max: Int,
        names: String...
    ) throws {
        guard count ?? 0 <= max else {
            throw ValidationError.tooManyCharacters(self, name: names.joined(separator: "+"), max: max)
        }
    }
    
    @inlinable
    func validateElementCountDoesNotExceed<T>(_ array: Array<T>?, max: Int, name: String) throws {
        guard array?.count ?? 0 <= max else {
            throw ValidationError.tooManyElements(self, name: name, max: max)
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
                self,
                name: name,
                reason: reason,
                valuesRepresentation: "\(values!)"
            )
        }
    }
    
    @inlinable
    func validateCaseInsensitivelyDoesNotContain(
        _ value: String?,
        name: String,
        values: [String],
        reason: String
    ) throws {
        if let value = value,
           values.contains(where: { value.localizedCaseInsensitiveContains($0) }) {
            throw ValidationError.containsProhibitedValues(
                self,
                name: name,
                reason: reason,
                valuesRepresentation: "\(values)"
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
                    self,
                    name: name,
                    reason: reason
                )
            }
        }
    }
    
    @inlinable
    func validateAssertIsNotEmpty(_ isNotEmpty: Bool, name: String) throws {
        if !isNotEmpty {
            throw ValidationError.cantBeEmpty(self, name: name)
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
                    self, 
                    name: name,
                    number: "\(number)",
                    min: "\(min)",
                    max: "\(max)"
                )
            }
        }
    }
}

// MARK: - +Array
extension Array: ValidatablePayload where Element: ValidatablePayload {
    public func validate() throws {
        for element in self {
            try element.validate()
        }
    }
}
