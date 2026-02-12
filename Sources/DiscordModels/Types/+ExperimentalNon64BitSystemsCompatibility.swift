#if ExperimentalNon64BitSystemsCompatibility
/// NOT PART OF THE PUBLIC API.
/// Use `Int64` instead.
public typealias _Int_CompatibilityTypealias = Int64
#else
/// NOT PART OF THE PUBLIC API.
/// Use `Int` instead.
public typealias _Int_CompatibilityTypealias = Int
#endif

#if ExperimentalNon64BitSystemsCompatibility
/// NOT PART OF THE PUBLIC API.
/// Use `UInt64` instead.
public typealias _UInt_CompatibilityTypealias = UInt64
#else
/// NOT PART OF THE PUBLIC API.
/// Use `UInt` instead.
public typealias _UInt_CompatibilityTypealias = UInt
#endif
