
/// Accumulates all `ValidationFailure`s that `ValidationPayload.validate()` returns.
@resultBuilder
struct ValidationAccumulator {
    
    typealias Component = ValidationResult
    
    static func buildBlock(_ components: ValidationResult...) -> [ValidationFailure] {
        components.flatMap { $0.get() }
    }
    
    static func buildArray(_ components: [ValidationResult]) -> [ValidationFailure] {
        components.flatMap { $0.get() }
    }
    
    static func buildOptional(_ component: [ValidationResult]?) -> [ValidationFailure] {
        component?.flatMap { $0.get() } ?? []
    }
    
    static func buildEither(first component: [ValidationResult]) -> [ValidationFailure] {
        component.flatMap { $0.get() }
    }
    
    static func buildEither(second component: [ValidationResult]) -> [ValidationFailure] {
        component.flatMap { $0.get() }
    }
}
