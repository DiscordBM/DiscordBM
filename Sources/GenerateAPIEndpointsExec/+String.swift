
extension StringProtocol {
    func toCamelCase() -> String {
        var capitalized = self.capitalized
            .replacingOccurrences(of: "_", with: " ")
            .filter({ !$0.isWhitespace })
        if !capitalized.isEmpty {
            let lower = capitalized.removeFirst().lowercased()
            capitalized = lower + capitalized
        }
        return capitalized
    }
}
