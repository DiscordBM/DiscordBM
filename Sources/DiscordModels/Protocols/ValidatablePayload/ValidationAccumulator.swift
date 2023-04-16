
/// Accumulates all `ValidationFailure`s that `ValidationPayload` validation functions return.
@resultBuilder
struct ValidationAccumulator {
    
    static func buildBlock(_ components: ValidationResult...) -> [ValidationFailure] {
        components.flatMap { $0.get() }
    }
    
    static func buildArray(_ components: [ValidationResult]) -> [ValidationFailure] {
        components.flatMap { $0.get() }
    }
    
    static func buildEither(first components: [ValidationResult]) -> [ValidationFailure] {
        components.flatMap { $0.get() }
    }
    
    static func buildEither(second components: [ValidationResult]) -> [ValidationFailure] {
        components.flatMap { $0.get() }
    }

    static func buildOptional(_ components: [ValidationResult]?) -> [ValidationFailure] {
        (components ?? []).flatMap { $0.get() }
    }
}
