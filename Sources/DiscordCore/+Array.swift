
extension Array where Element == (String, String?) {
    public func makeForURLQuery() -> String {
        self.compactMap { key, value -> (String, String)? in
            guard let value else { return nil }
            return (key, value)
        }.makeForURLQuery()
    }
}

extension Array where Element == (String, String) {
    public func makeForURLQuery() -> String {
        if self.isEmpty {
            return ""
        } else {
            return "?" + self.compactMap { key, value -> String? in
                let value = value.addingPercentEncoding(
                    withAllowedCharacters: .urlQueryAllowed
                ) ?? value
                return "\(key)=\(value)"
            }.joined(separator: "&")
        }
    }
}
