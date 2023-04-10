
/// Accumulates all `ValidationFailure`s that `ValidationPayload` validation functions return.
@resultBuilder
struct ValidationAccumulator {
    
    static func buildBlock(_ components: ValidationResult...) -> [ValidationFailure] {
        components.flatMap { $0.get() }
    }
    
    static func buildArray(_ components: [ValidationResult]) -> [ValidationFailure] {
        components.flatMap { $0.get() }
    }
    
    static func buildEither(first component: [ValidationResult]) -> [ValidationFailure] {
        component.flatMap { $0.get() }
    }
    
    static func buildEither(second component: [ValidationResult]) -> [ValidationFailure] {
        component.flatMap { $0.get() }
    }
}
