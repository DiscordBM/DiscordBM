public enum ThreadArchiveDuration: Int, Codable {
    case oneHour = 60
    case oneDay = 1440 // 24 * 60
    case threeDays = 4320 // 3 * 24 * 60
    case sevenDays = 10080 // 7 * 24 * 60
}

public enum ThreadType: Int, Codable {
    case newsThread = 10
    case publicThread = 11
    case privateThread = 12
}
