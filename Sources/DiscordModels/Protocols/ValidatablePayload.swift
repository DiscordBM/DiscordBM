import Foundation

public protocol ValidatablePayload: Sendable {
    /// Returns a list of validations for the type.
    ///
    /// Default library functions only throw ``ValidationError``.
    @ValidationAccumulator func validations() -> Validation
}

/// Read `helpAnchor` for help about each error case.
public struct ValidationError: LocalizedError {
    public let model: Any
    public let failedValidations: [Validation]
    
    public var errorDescription: String? {
        "ValidationError { model: \(model), failedValidations: \(failedValidations.compactMap(\.errorDescription)) }"
    }
    
    public var helpAnchor: String? {
        "ValidationError { model: \(model), failedValidations: \(failedValidations.compactMap(\.helpAnchor)) }"
    }
}

public enum Validation {
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
    
    /// Multiple `Validation`.
    case combined([Validation])
    
    /// No validation.
    case none
    
    /// To be used in `ValidationError`.
    var errorDescription: String? {
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
        case let .combined(errors):
            return "combined(\(errors.compactMap(\.errorDescription)))"
        case .none:
            return "none"
        }
    }
    
    /// To be used in `ValidationError`.
    var helpAnchor: String? {
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
        case let .combined(errors):
            return "This is a `combined` validation error and it should not have been thrown. Please use 'try Validation.throw()' instead of just throwing a 'Validation'. Multiple validations failed: \(errors.compactMap(\.helpAnchor).joined(separator: ";"))"
        case .none:
            return "This is an empty error so should not have been thrown. Please use 'try Validation.throw()' instead of just throwing a 'Validation'."
        }
    }
    
    var allErrors: [Self] {
        switch self {
        case let .combined(errors):
            return errors.flatMap(\.allErrors)
        case .none:
            return []
        default:
            return [self]
        }
    }
    
    /// Throws a `ValidationError` if any `Validation`s fail.
    /// - Parameter model: The data to be reported for debugging in case of throwing.
    public func `throw`(model: Any) throws {
        let all = self.allErrors
        if !all.isEmpty {
            throw ValidationError(model: model, failedValidations: all)
        }
    }
}

extension ValidatablePayload {
    
    @inlinable
    func validateAtLeastOneIsNotEmpty(
        _ isEmpties: Bool?...,
        names: String...
    ) -> Validation? {
        guard isEmpties.contains(where: { $0 == false || $0 == nil }) else {
            return Validation.atLeastOneFieldIsRequired(names: names)
        }
        return nil
    }
    
    @inlinable
    func validateCharacterCountDoesNotExceed(_ value: String?, max: Int, name: String) -> Validation? {
        guard value?.unicodeScalars.count ?? 0 <= max else {
            return Validation.tooManyCharacters(name: name, max: max)
        }
        return nil
    }
    
    @inlinable
    func validateCharacterCountInRange(_ value: String?, min: Int, max: Int, name: String) -> Validation? {
        let count = value?.unicodeScalars.count ?? 0
        guard min <= count, count <= max else {
            return Validation.characterCountOutOfRange(name: name, min: min, max: max)
        }
        return nil
    }
    
    @inlinable
    func validateCombinedCharacterCountDoesNotExceed(
        _ count: Int?,
        max: Int,
        names: String...
    ) -> Validation? {
        guard count ?? 0 <= max else {
            return Validation.tooManyCharacters(name: names.joined(separator: "+"), max: max)
        }
        return nil
    }
    
    @inlinable
    func validateElementCountDoesNotExceed<T>(_ array: Array<T>?, max: Int, name: String) -> Validation? {
        guard array?.count ?? 0 <= max else {
            return Validation.tooManyElements(name: name, max: max)
        }
        return nil
    }
    
    @inlinable
    func validateOnlyContains<C: Collection>(
        _ values: C?,
        name: String,
        reason: String,
        where block: (C.Element) -> Bool
    ) -> Validation? {
        if values?.first(where: { !block($0) }) != nil {
            return Validation.containsProhibitedValues(
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
    ) -> Validation? {
        if let value = value,
           values.contains(where: { value.localizedCaseInsensitiveContains($0) }) {
            return Validation.containsProhibitedValues(
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
    ) -> Validation? {
        if condition {
            if !allowedIf {
                return Validation.hasPrecondition(name: name, reason: reason)
            }
        }
        return nil
    }
    
    @inlinable
    func validateAssertIsNotEmpty(_ isNotEmpty: Bool, name: String) -> Validation? {
        if !isNotEmpty {
            return Validation.cantBeEmpty(name: name)
        }
        return nil
    }
    
    @inlinable
    func validateNumberInRange<N: Numeric & Comparable>(
        _ number: N?,
        min: N,
        max: N,
        name: String
    ) -> Validation? {
        if let number = number {
            guard number >= min, number <= max else {
                return Validation.numberOutOfRange(
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
    public func validations() -> Validation {
        for element in self {
            element.validations()
        }
    }
}

/// Accumulates all `Validation?`s that `ValidationPayload` functions return.
/// Then DiscordBM can run all the validations and report all failed validations back to user.
@resultBuilder
struct ValidationAccumulator {
    
    typealias Component = Validation?
    
    static func buildBlock(_ components: Component...) -> Component {
        .combined(components.compactMap { $0 })
    }
    
    static func buildBlock(_ components: [Component]) -> Component {
        .combined(components.compactMap { $0 })
    }
    
    static func buildArray(_ components: [Component]) -> Component {
        .combined(components.compactMap { $0 })
    }
    
    static func buildPartialBlock(first: Component) -> Component {
        first
    }
    
    static func buildPartialBlock(accumulated: Component, next: Component) -> Component {
        .combined((accumulated?.allErrors ?? []) + (next?.allErrors ?? []))
    }
    
    static func buildEither(first component: Component) -> Component {
        component
    }
    
    static func buildEither(second component: Component) -> Component {
        component
    }
    
    static func buildFinalResult(_ component: Component) -> Validation {
        component ?? .combined([])
    }
}
