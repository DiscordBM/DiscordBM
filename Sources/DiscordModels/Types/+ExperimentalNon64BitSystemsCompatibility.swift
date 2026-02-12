#if ExperimentalNon64BitSystemsCompatibility
/// NOT PART OF THE PUBLIC API.
/// Use `Int64` instead.
public typealias _CompatibilityIntTypeAlias = Int64
#else
/// NOT PART OF THE PUBLIC API.
/// Use `Int` instead.
public typealias _CompatibilityIntTypeAlias = Int
#endif

#if ExperimentalNon64BitSystemsCompatibility
/// NOT PART OF THE PUBLIC API.
/// Use `UInt64` instead.
public typealias _CompatibilityUIntTypeAlias = UInt64
#else
/// NOT PART OF THE PUBLIC API.
/// Use `UInt` instead.
public typealias _CompatibilityUIntTypeAlias = UInt
#endif
