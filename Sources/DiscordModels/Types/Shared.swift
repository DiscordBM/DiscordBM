#if os(macOS) /// Xcode toolchains don't usually throw preconcurrency warnings.
import Foundation
#else
@preconcurrency import Foundation
#endif

//MARK: - StringIntDoubleBool

/// To dynamically decode/encode String or Int or Double or Bool.
public enum StringIntDoubleBool: Sendable, Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    
    public var asString: String {
        switch self {
        case .string(let string): return string
        case .int(let int): return "\(int)"
        case .double(let double): return String(format: "%.2f", double)
        case .bool(let bool): return "\(bool)"
        }
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else {
            let double = try container.decode(Double.self)
            self = .double(double)
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(string):
            try container.encode(string)
        case let .int(int):
            try container.encode(int)
        case let .double(double):
            try container.encode(double)
        case let .bool(bool):
            try container.encode(bool)
        }
    }
}

//MARK: - StringOrInt

/// To dynamically decode/encode String or Int.
public enum StringOrInt: Sendable, Codable {
    case string(String)
    case int(Int)
    
    public var asString: String {
        switch self {
        case .string(let string): return string
        case .int(let int): return "\(int)"
        }
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else {
            let int = try container.decode(Int.self)
            self = .int(int)
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(string):
            try container.encode(string)
        case let .int(int):
            try container.encode(int)
        }
    }
}

//MARK: - IntOrDouble

public enum IntOrDouble: Sendable, Codable {
    case int(Int)
    case double(Double)
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else {
            let double = try container.decode(Double.self)
            self = .double(double)
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .int(int):
            try container.encode(int)
        case let .double(double):
            try container.encode(double)
        }
    }
}

//MARK: - DiscordLocale

/// https://discord.com/developers/docs/reference#locales
public enum DiscordLocale: String, Sendable, Codable, ToleratesStringDecodeMarker {
    case danish = "da"
    case german = "de"
    case englishUK = "en-GB"
    case englishUS = "en-US"
    case spanish = "es-ES"
    case french = "fr"
    case croatian = "hr"
    case italian = "it"
    case lithuanian = "lt"
    case hungarian = "hu"
    case dutch = "nl"
    case norwegian = "no"
    case polish = "pl"
    case portuguese = "pt-BR"
    case romanian = "ro"
    case finnish = "fi"
    case swedish = "sv-SE"
    case vietnamese = "vi"
    case turkish = "tr"
    case czech = "cs"
    case greek = "el"
    case bulgarian = "bg"
    case russian = "ru"
    case ukrainian = "uk"
    case hindi = "hi"
    case thai = "th"
    case chineseChina = "zh-CN"
    case japanese = "ja"
    case chineseTaiwan = "zh-TW"
    case korean = "ko"
}

//MARK: - DiscordLocaleDict

/// A container to decode/encode `[DiscordLocale: String]`,
/// because Discord doesn't like how Codable decode/encodes `[DiscordLocale: String]`.
public struct DiscordLocaleDict<C: Codable>: Codable, ExpressibleByDictionaryLiteral {
    
    struct _DiscordLocaleCodableContainer: Codable {
        var danish: C?
        var german: C?
        var englishUK: C?
        var englishUS: C?
        var spanish: C?
        var french: C?
        var croatian: C?
        var italian: C?
        var lithuanian: C?
        var hungarian: C?
        var dutch: C?
        var norwegian: C?
        var polish: C?
        var portuguese: C?
        var romanian: C?
        var finnish: C?
        var swedish: C?
        var vietnamese: C?
        var turkish: C?
        var czech: C?
        var greek: C?
        var bulgarian: C?
        var russian: C?
        var ukrainian: C?
        var hindi: C?
        var thai: C?
        var chineseChina: C?
        var japanese: C?
        var chineseTaiwan: C?
        var korean: C?
        
        enum CodingKeys: String, CodingKey {
            case danish = "da"
            case german = "de"
            case englishUK = "en-GB"
            case englishUS = "en-US"
            case spanish = "es-ES"
            case french = "fr"
            case croatian = "hr"
            case italian = "it"
            case lithuanian = "lt"
            case hungarian = "hu"
            case dutch = "nl"
            case norwegian = "no"
            case polish = "pl"
            case portuguese = "pt-BR"
            case romanian = "ro"
            case finnish = "fi"
            case swedish = "sv-SE"
            case vietnamese = "vi"
            case turkish = "tr"
            case czech = "cs"
            case greek = "el"
            case bulgarian = "bg"
            case russian = "ru"
            case ukrainian = "uk"
            case hindi = "hi"
            case thai = "th"
            case chineseChina = "zh-CN"
            case japanese = "ja"
            case chineseTaiwan = "zh-TW"
            case korean = "ko"
        }
        
        init(_ dictionary: [DiscordLocale: C]) {
            for (key, value) in dictionary {
                switch key {
                case .danish: self.danish = value
                case .german: self.german = value
                case .englishUK: self.englishUK = value
                case .englishUS: self.englishUS = value
                case .spanish: self.spanish = value
                case .french: self.french = value
                case .croatian: self.croatian = value
                case .italian: self.italian = value
                case .lithuanian: self.lithuanian = value
                case .hungarian: self.hungarian = value
                case .dutch: self.dutch = value
                case .norwegian: self.norwegian = value
                case .polish: self.polish = value
                case .portuguese: self.portuguese = value
                case .romanian: self.romanian = value
                case .finnish: self.finnish = value
                case .swedish: self.swedish = value
                case .vietnamese: self.vietnamese = value
                case .turkish: self.turkish = value
                case .czech: self.czech = value
                case .greek: self.greek = value
                case .bulgarian: self.bulgarian = value
                case .russian: self.russian = value
                case .ukrainian: self.ukrainian = value
                case .hindi: self.hindi = value
                case .thai: self.thai = value
                case .chineseChina: self.chineseChina = value
                case .japanese: self.japanese = value
                case .chineseTaiwan: self.chineseTaiwan = value
                case .korean: self.korean = value
                }
            }
        }
        
        func toDictionary() -> [DiscordLocale: C] {
            let values = [
                (key: DiscordLocale.danish, value: self.danish),
                (key: DiscordLocale.german, value: self.german),
                (key: DiscordLocale.englishUK, value: self.englishUK),
                (key: DiscordLocale.englishUS, value: self.englishUS),
                (key: DiscordLocale.spanish, value: self.spanish),
                (key: DiscordLocale.french, value: self.french),
                (key: DiscordLocale.croatian, value: self.croatian),
                (key: DiscordLocale.italian, value: self.italian),
                (key: DiscordLocale.lithuanian, value: self.lithuanian),
                (key: DiscordLocale.hungarian, value: self.hungarian),
                (key: DiscordLocale.dutch, value: self.dutch),
                (key: DiscordLocale.norwegian, value: self.norwegian),
                (key: DiscordLocale.polish, value: self.polish),
                (key: DiscordLocale.portuguese, value: self.portuguese),
                (key: DiscordLocale.romanian, value: self.romanian),
                (key: DiscordLocale.finnish, value: self.finnish),
                (key: DiscordLocale.swedish, value: self.swedish),
                (key: DiscordLocale.vietnamese, value: self.vietnamese),
                (key: DiscordLocale.turkish, value: self.turkish),
                (key: DiscordLocale.czech, value: self.czech),
                (key: DiscordLocale.greek, value: self.greek),
                (key: DiscordLocale.bulgarian, value: self.bulgarian),
                (key: DiscordLocale.russian, value: self.russian),
                (key: DiscordLocale.ukrainian, value: self.ukrainian),
                (key: DiscordLocale.hindi, value: self.hindi),
                (key: DiscordLocale.thai, value: self.thai),
                (key: DiscordLocale.chineseChina, value: self.chineseChina),
                (key: DiscordLocale.japanese, value: self.japanese),
                (key: DiscordLocale.chineseTaiwan, value: self.chineseTaiwan),
                (key: DiscordLocale.korean, value: self.korean),
            ].compactMap { key, value -> (key: DiscordLocale, value: C)? in
                if let value {
                    return (key, value)
                } else {
                    return nil
                }
            }
            return Dictionary(uniqueKeysWithValues: values)
        }
    }
    
    public var values: [DiscordLocale: C]
    
    public init(dictionaryLiteral elements: (DiscordLocale, C)...) {
        self.values = .init(elements, uniquingKeysWith: { l, _ in l })
    }
    
    public init(_ elements: [DiscordLocale: C]) {
        self.values = elements
    }
    
    public init? (_ elements: [DiscordLocale: C]?) {
        guard let elements else { return nil }
        self.values = elements
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try _DiscordLocaleCodableContainer(from: decoder)
        self.values = container.toDictionary()
    }
    
    public func encode(to encoder: any Encoder) throws {
        let container = _DiscordLocaleCodableContainer(self.values)
        try container.encode(to: encoder)
    }
}

extension DiscordLocaleDict: Sendable where C: Sendable { }

//MARK: - DiscordTimestamp

/// A timestamp that decode/encodes itself how Discord expects.
public struct DiscordTimestamp: Codable {
    
    /// Read `helpAnchor` for help about each error case.
    public enum DecodingError: Swift.Error, CustomStringConvertible {
        /// The timestamp had an unexpected format. This is a library decoding issue, please report this at https://github.com/MahdiBM/DiscordBM/issues.
        case unexpectedFormat([any CodingKey], String)
        /// Could not convert the timestamp to a 'Date'. This is a library decoding issue, please report this at https://github.com/MahdiBM/DiscordBM/issues.
        case conversionFailure([any CodingKey], String, DateComponents)

        public var description: String {
            switch self {
            case let .unexpectedFormat(codingKey, timestamp):
                return "DiscordTimestamp.DecodingError.unexpectedFormat(\(codingKey), \(timestamp))"
            case let .conversionFailure(codingKey, timestamp, components):
                return "DiscordTimestamp.DecodingError.conversionFailure(\(codingKey), \(timestamp), \(components))"
            }
        }
    }
    
    public var date: Date

    public init(date: Date) {
        self.date = date
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        
        let startIndex = string.startIndex
        func index(_ offset: Int) -> String.Index {
            string.index(startIndex, offsetBy: offset)
        }
        
        let components: DateComponents
        
        if string.count == 32 {
            guard let year = Int(string[startIndex...index(3)]),
                  let month = Int(string[index(5)...index(6)]),
                  let day = Int(string[index(8)...index(9)]),
                  let hour = Int(string[index(11)...index(12)]),
                  let minute = Int(string[index(14)...index(15)]),
                  let second = Int(string[index(17)...index(18)]),
                  let microSecond = Int(string[index(20)...index(25)])
            else {
                throw DecodingError.unexpectedFormat(container.codingPath, string)
            }
            components = DateComponents(
                calendar: Calendar.utc,
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second,
                nanosecond: microSecond * 1_000
            )
        } else if string.count == 25 {
            guard let year = Int(string[startIndex...index(3)]),
                  let month = Int(string[index(5)...index(6)]),
                  let day = Int(string[index(8)...index(9)]),
                  let hour = Int(string[index(11)...index(12)]),
                  let minute = Int(string[index(14)...index(15)]),
                  let second = Int(string[index(17)...index(18)])
            else {
                throw DecodingError.unexpectedFormat(container.codingPath, string)
            }
            components = DateComponents(
                calendar: Calendar.utc,
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second
            )
        } else {
            throw DecodingError.unexpectedFormat(container.codingPath, string)
        }
        guard let date = Calendar.utc.date(from: components) else {
            throw DecodingError.conversionFailure(container.codingPath, string, components)
        }
        self.date = date
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        
        let componentSet: Set<Calendar.Component> = [
            .year, .month, .day, .hour, .minute, .second, .nanosecond
        ]
        let components = Calendar.utc.dateComponents(componentSet, from: date)
        guard let year = components.year,
              let month = components.month,
              let day = components.day,
              let hour = components.hour,
              let minute = components.minute,
              let second = components.second,
              let nanoSecond = components.nanosecond
        else {
            throw EncodingError.invalidValue(date, .init(
                codingPath: container.codingPath,
                debugDescription: "Programming Error. Could not encode Date to Discord Timestamp. Please report: https://github.com/MahdiBM/DiscordBM/issues"
            ))
        }
        let miliSecond = nanoSecond / 1_000
        
        func fixedDigit(_ int: Int, _ length: Int) -> String {
            let description = "\(int)"
            let zeroCount = length - description.count
            if zeroCount > 0 {
                return String(repeating: "0", count: zeroCount) + description
            } else {
                return description
            }
        }
        
        let f = (
            year: fixedDigit(year, 4),
            month: fixedDigit(month, 2),
            day: fixedDigit(day, 2),
            hour: fixedDigit(hour, 2),
            minute: fixedDigit(minute, 2),
            second: fixedDigit(second, 2),
            mili: fixedDigit(miliSecond, 6)
        )
        
        let str = "\(f.year)-\(f.month)-\(f.day)T\(f.hour):\(f.minute):\(f.second).\(f.mili)+00:00"
        
        try container.encode(str)
    }
}

extension DiscordTimestamp: Sendable { }

//MARK: - IntPair

/// An array consisting of two integers.
public struct IntPair: Sendable, Codable, CustomStringConvertible {
    public var first: Int
    public var second: Int

    public var description: String {
        "(\(self.first), \(self.second))"
    }

    public init(_ first: Int, _ second: Int) {
        self.first = first
        self.second = second
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let array = try container.decode([Int].self)
        guard array.count == 2 else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: container.codingPath,
                debugDescription: "Expected 2 integers in \(array.debugDescription)"
            ))
        }
        self.first = array[0]
        self.second = array[1]
    }
    
    public func encode(to encoder: any Encoder) throws {
        try [first, second].encode(to: encoder)
    }
}

//MARK: - DiscordColor

/// A dynamic color type that decode/encodes itself as an integer which Discord expects.
public struct DiscordColor: Sendable, Codable, Equatable, ExpressibleByIntegerLiteral {
    
    public let value: Int
    
    public static let purple = DiscordColor(_unsafeValue: 7414159)
    public static let red = DiscordColor(_unsafeValue: 16711680)
    public static let orange = DiscordColor(_unsafeValue: 16753920)
    public static let brown = DiscordColor(_unsafeValue: 12756051)
    public static let yellow = DiscordColor(_unsafeValue: 16770610)
    public static let green = DiscordColor(_unsafeValue: 65280)
    public static let blue = DiscordColor(_unsafeValue: 255)
    
    public func asRGB() -> (red: Int, green: Int, blue: Int) {
        let red = value >> 16
        let green = (value >> 8) & 0x00FF
        let blue = value & 0x0000FF
        return (red, green, blue)
    }
    
    public func asHex() -> String {
        "#" + String(self.value, radix: 16, uppercase: true)
    }
    
    init(_unsafeValue value: Int) {
        self.value = value
    }
    
    public init(integerLiteral value: Int) {
        self.init(value: value)!
    }
    
    public init? (value: Int) {
        guard value >= 0,
              value < (1 << 24)
        else { return nil }
        self.value = value
    }
    
    public init? (red: Int, green: Int, blue: Int) {
        guard (0..<256).contains(red),
              (0..<256).contains(green),
              (0..<256).contains(blue)
        else { return nil }
        self.value = red << 16 | green << 8 | blue
    }
    
    public init? (hex: String) {
        var dropCount = 0
        if hex.hasPrefix("#") {
            dropCount = 1
        }
        guard let value = Int(hex.dropFirst(dropCount), radix: 16) else {
            return nil
        }
        self.value = value
    }
    
    public init(from decoder: any Decoder) throws {
        self.value = try .init(from: decoder)
    }
    
    public func encode(to encoder: any Encoder) throws {
        try self.value.encode(to: encoder)
    }
}

//MARK: - Secret

/// A type that will try to keep its content a secret when used with string interpolation.
/// This is to stop leaking something like a token in somewhere like the logs.
public struct Secret:
    Sendable,
    Codable,
    ExpressibleByStringLiteral,
    CustomStringConvertible,
    CustomDebugStringConvertible {
    
    public var value: String
    
    public init(stringLiteral value: String) {
        self.value = value
    }
    
    public init(_ value: String) {
        self.value = value
    }
    
    public var description: String {
        let count = value.count
        let keepCount = count > 24 ? 4 : 0
        let dropped = value.dropLast(count - keepCount)
        return #"Secret("\#(dropped)****")"#
    }
    
    public var debugDescription: String {
        self.description
    }
    
    public init(from decoder: any Decoder) throws {
        self.value = try .init(from: decoder)
    }
    
    public func encode(to encoder: any Encoder) throws {
        try self.value.encode(to: encoder)
    }
}

//MARK: - DereferenceBox

/// A class so we can use the same type recursively in itself.
public final class DereferenceBox<C>: Codable where C: Codable {
    public let value: C
    
    public init(value: C) {
        self.value = value
    }
    
    public init(from decoder: any Decoder) throws {
        self.value = try .init(from: decoder)
    }
    
    public func encode(to encoder: any Encoder) throws {
        try self.value.encode(to: encoder)
    }
}

extension DereferenceBox: Sendable where C: Sendable { }

//MARK: +Calendar

private extension Calendar {
    static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .init(identifier: "UTC")!
        return calendar
    }()
}
