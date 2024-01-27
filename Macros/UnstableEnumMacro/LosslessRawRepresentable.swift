
/// Just a compile-time protocol to make sure `UnstableEnumMacro` types are safe to
/// force-unwrap when using ``RawRepresentable.init(rawValue:)``
///
/// This is assigned to all types with `UnstableEnumMacro` attribute.
@_marker
public protocol LosslessRawRepresentable { }
