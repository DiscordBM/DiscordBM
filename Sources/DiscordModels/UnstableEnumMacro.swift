
#if swift(>=5.9)
/// All unstable enums gain a new `unknown()` case containing any unexpected raw values
@attached(member, names: named(init), named(rawValue), named(unknown))
macro UnstableEnum() = #externalMacro(module: "UnstableEnumMacro", type: "UnstableEnumMacro")
#endif
