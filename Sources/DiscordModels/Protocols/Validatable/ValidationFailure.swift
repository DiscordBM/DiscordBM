
public enum ValidationFailure: Sendable {
    /// At least one of these fields is required to be present.
    case atLeastOneFieldIsRequired(names: [String])
    /// Too many characters in the target (likely a String). Need to shorten it.
    case tooManyCharacters(name: String, max: Int)
    /// Count of characters in the target (likely a String) is not acceptable.
    case characterCountOutOfRange(name: String, min: Int, max: Int)
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
    
    /// To be used in `ValidationError`.
    var errorDescription: String {
        switch self {
        case let .atLeastOneFieldIsRequired(names):
            return "atLeastOneFieldIsRequired(names: \(names))"
        case let .tooManyCharacters(name, max):
            return "tooManyCharacters(name: \(name), max: \(max))"
        case let .characterCountOutOfRange(name, min, max):
            return "characterCountOutOfRange(name: \(name), min: \(min), max: \(max))"
        case let .tooManyElements(name, max):
            return "tooManyElements(name: \(name), max: \(max))"
        case let .containsProhibitedValues(name, reason, valuesRepresentation):
            return "containsProhibitedValues(name: \(name), reason: \(reason), valuesRepresentation: \(valuesRepresentation))"
        case let .hasPrecondition(name, reason):
            return "hasPrecondition(name: \(name), reason: \(reason))"
        case let .cantBeEmpty(name):
            return "cantBeEmpty(name: \(name))"
        case let .numberOutOfRange(name, number, min, max):
            return "numberOutOfRange(name: \(name), number: \(number), min: \(min), max: \(max))"
        }
    }
    
    /// To be used in `ValidationError`.
    var helpAnchor: String {
        switch self {
        case let .atLeastOneFieldIsRequired(names):
            return "At least one of these fields is required: \(names)"
        case let .tooManyCharacters(name, max):
            return "Too many characters in the '\(name)' field. Max allowed is '\(max)'"
        case let .characterCountOutOfRange(name, min, max):
            return "Character count of the '\(name)' field is out of the acceptable range of \(min)...\(max)"
        case let .tooManyElements(name, max):
            return "Too many elements in the '\(name)' field. Max allowed is '\(max)'"
        case let .containsProhibitedValues(name, reason, valuesRepresentation):
            return "The '\(name)' field contains prohibited values. Values: \(valuesRepresentation). Reason: \(reason)"
        case let .hasPrecondition(name, reason):
            return "A precondition was not met for the '\(name)' field. Reason: \(reason)"
        case let .cantBeEmpty(name):
            return "The '\(name)' field can't be empty."
        case let .numberOutOfRange(name, number, min, max):
            return "The '\(name)' is set to the number '\(number)' which is out of the acceptable range of \(min)...\(max)"
        }
    }
}

extension Array where Element == ValidationFailure {
    /// Throws a `ValidationError` if any `ValidationFailure`s are available.
    /// - Parameter model: The data to be reported for debugging in case of throwing.
    public func `throw`(model: any Sendable) throws {
        if !self.isEmpty {
            throw ValidationError(model: model, failures: self)
        }
    }
}
