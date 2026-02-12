struct EnumCase {
    let key: String
    let value: String

    func maybeQuotedValue(rawType: RawKind) -> String {
        switch rawType {
        case ._Int_CompatibilityTypealias, ._UInt_CompatibilityTypealias, .UInt8:
            return value
        case .String:
            return #""\#(value)""#
        }
    }
}
