
extension Collection {
    var containsAnything: Bool {
        !self.isEmpty
    }
}


extension Optional where Wrapped: Collection {
    var containsAnything: Bool {
        self?.containsAnything == true
    }
}
