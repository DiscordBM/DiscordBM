enum RawKind: String {
    case String
    case _Int_CompatibilityTypealias
    case _UInt_CompatibilityTypealias
    case UInt8

    var isInteger: Bool {
        switch self {
        case ._Int_CompatibilityTypealias, ._UInt_CompatibilityTypealias, .UInt8:
            return true
        case .String:
            return false
        }
    }
}
