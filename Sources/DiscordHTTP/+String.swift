extension String {
    func urlPathEncoded(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? string
    }
}
