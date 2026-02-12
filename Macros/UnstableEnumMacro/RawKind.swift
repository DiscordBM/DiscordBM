enum RawKind: String {
    case String
    case _CompatibilityIntTypeAlias
    case _CompatibilityUIntTypeAlias
    case UInt8

    var isInteger: Bool {
        switch self {
        case ._CompatibilityIntTypeAlias, ._CompatibilityUIntTypeAlias, .UInt8:
            return true
        case .String:
            return false
        }
    }
}
