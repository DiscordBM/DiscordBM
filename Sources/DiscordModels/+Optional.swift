
public enum OptionalError: Error, CustomStringConvertible {
    case nilValue(typeName: String, file: String, function: String, line: UInt)

    public var description: String {
        switch self {
        case let .nilValue(typeName, file, function, line):
            return "OptionalError.nilValue(typeName: \(typeName), file: \(file), function: \(function), line: \(line))"
        }
    }
}

extension Optional {
    /// Sorry for the extension, but I think this will be decently helpful.
    /// One reason why I named it `requireValue()` and not just `require()`, is to
    /// reduce chances of name collisions.

    /// Utility function to require a value from optional values, or throw an error.
    ///
    /// Examples:
    /// ```swift
    /// let value: String? = "Hi!"
    /// let unwrapped: String = try value.require() /// will be of value "Hi!"
    ///
    /// let value: Int? = nil
    /// let unwrapped: Int = try value.require() /// Will throw `OptionalError.nilValue()`
    /// ```
    @inlinable
    public func requireValue(
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) throws -> Wrapped {
        switch self {
        case .some(let wrapped):
            return wrapped
        case .none:
            throw OptionalError.nilValue(
                typeName: Swift._typeName(Self.self, qualified: false),
                file: file,
                function: function,
                line: line
            )
        }
    }
}
