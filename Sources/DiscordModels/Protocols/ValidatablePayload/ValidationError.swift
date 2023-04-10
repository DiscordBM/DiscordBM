import Foundation

/// Read `helpAnchor` for help.
public struct ValidationError: Sendable, LocalizedError {
    /// The model that failed the validations.
    public let model: any Sendable
    /// The failed validations. Will never be empty.
    public let failures: [ValidationFailure]
    
    public var errorDescription: String? {
        "ValidationError { model: \(model), failures: \(failures.map(\.errorDescription)) }"
    }
    
    public var helpAnchor: String? {
        "ValidationError { model: \(model), failures: \(failures.map(\.helpAnchor)) }"
    }
}
