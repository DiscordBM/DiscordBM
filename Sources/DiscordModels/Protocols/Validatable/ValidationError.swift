import Foundation

/// Read `helpAnchor` for help about each error case.
public struct ValidationError: LocalizedError {
    /// The model that failed the validations.
    public let model: any Sendable
    public let failures: [ValidationFailure]
    
    public var errorDescription: String? {
        "ValidationError { model: \(model), failures: \(failures.map(\.errorDescription)) }"
    }
    
    public var helpAnchor: String? {
        "ValidationError { model: \(model), failures: \(failures.map(\.helpAnchor)) }"
    }
}
