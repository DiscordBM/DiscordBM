import Foundation

/// Read `helpAnchor` for help.
public struct ValidationError: Sendable, Error, CustomStringConvertible {
    /// The model that failed the validations.
    public let model: any Sendable
    /// The failed validations. Will never be empty.
    public let failures: [ValidationFailure]

    public var description: String {
        "ValidationError { model: \(model), failures: \(failures.map(\.description)) }"
    }
}
