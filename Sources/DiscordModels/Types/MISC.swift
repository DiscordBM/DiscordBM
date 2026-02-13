public enum DynamicURL: Sendable, Codable, ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    case exact(String)
    case attachment(name: String)

    public var asString: String {
        switch self {
        case let .exact(exact):
            return exact
        case let .attachment(name):
            return "attachment://\(name)"
        }
    }

    public init(stringLiteral string: String) {
        if string.hasPrefix("attachment://") {
            self = .attachment(name: String(string.dropFirst(13)))
        } else {
            self = .exact(string)
        }
    }

    public init(from string: String) {
        if string.hasPrefix("attachment://") {
            self = .attachment(name: String(string.dropFirst(13)))
        } else {
            self = .exact(string)
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = .init(from: string)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.asString)
    }
}
