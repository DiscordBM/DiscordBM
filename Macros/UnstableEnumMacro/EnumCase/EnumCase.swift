struct EnumCase {
    let key: String
    let value: String

    func maybeQuotedValue(rawType: RawKind) -> String {
        switch rawType {
        case ._CompatibilityIntTypeAlias, ._CompatibilityUIntTypeAlias, .UInt8:
            return value
        case .String:
            return #""\#(value)""#
        }
    }
}
