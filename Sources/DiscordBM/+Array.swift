
extension Array where Element == (String, String) {
    func makeForURLQuery() -> String {
        if self.isEmpty {
            return ""
        } else {
            return "?" + self.map({ key, value in
                let value = value.addingPercentEncoding(
                    withAllowedCharacters: .urlQueryAllowed
                ) ?? value
                return "\(key)=\(value)"
            }).joined(separator: "&")
        }
    }
}
