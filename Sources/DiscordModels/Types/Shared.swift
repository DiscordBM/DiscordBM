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
    
    public init(from decoder: Decoder) throws {
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
    
    public func encode(to encoder: Encoder) throws {
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else {
            let int = try container.decode(Int.self)
            self = .int(int)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else {
            let double = try container.decode(Double.self)
            self = .double(double)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
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
    
    struct _DiscordLocaleCodableContainer<C: Codable>: Codable {
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
    
    public init(from decoder: Decoder) throws {
        let container = try _DiscordLocaleCodableContainer<C>(from: decoder)
        self.values = container.toDictionary()
    }
    
    public func encode(to encoder: Encoder) throws {
        let container = _DiscordLocaleCodableContainer<C>(self.values)
        try container.encode(to: encoder)
    }
}

extension DiscordLocaleDict: Sendable where C: Sendable { }

//MARK: - DiscordTimestamp

/// A timestamp that decode/encodes itself how Discord expects.
public struct DiscordTimestamp: Codable {
    
    /// Read `helpAnchor` for help about each error case.
    public enum DecodingError: LocalizedError {
        case unexpectedFormat([CodingKey], String)
        case conversionFailure([CodingKey], String, DateComponents)
        
        public var errorDescription: String? {
            switch self {
            case let .unexpectedFormat(codingKey, timestamp):
                return "unexpectedFormat(\(codingKey), \(timestamp))"
            case let .conversionFailure(codingKey, timestamp, components):
                return "conversionFailure(\(codingKey), \(timestamp), \(components))"
            }
        }
        
        public var helpAnchor: String? {
            switch self {
            case let .unexpectedFormat(codingKey, timestamp):
                return "The timestamp had an unexpected format. This is a library decoding issue, please report this at https://github.com/MahdiBM/DiscordBM/issues. Coding key: \(codingKey.map(\.stringValue)), timestamp: \(timestamp)"
            case let .conversionFailure(codingKey, timestamp, components):
                return "Could not convert the timestamp to a 'Date'. This is a library decoding issue, please report this at https://github.com/MahdiBM/DiscordBM/issues. Coding key: \(codingKey.map(\.stringValue)), timestamp: \(timestamp), components: \(components)"
            }
        }
    }
    
    public var date: Date

    public init(date: Date) {
        self.date = date
    }
    
    public init(from decoder: Decoder) throws {
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
    
    public func encode(to encoder: Encoder) throws {
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

//MARK: - Bitfield

/// A protocol for bit-fields.
public protocol BitField: ExpressibleByArrayLiteral {
    associatedtype R: RawRepresentable where R: Hashable, R.RawValue == Int
    var value: Int { get set }
    init(_ value: Int)
}

private let bitFieldLogger = DiscordGlobalConfiguration.makeDecodeLogger("DBM.BitField")

extension BitField {
    
    public init(arrayLiteral elements: R...) {
        self.init(Self.toBitValue(elements))
    }
    
    public init(_ elements: [R]) {
        self.init(Self.toBitValue(elements))
    }
    
    public func getAllElements() -> (values: Set<R>, unknown: Set<Int>) {
        var bitValue = self.value
        var values: ContiguousArray<R> = []
        var unknownValues: Set<Int> = []
        guard bitValue > 0 else { return ([], []) }
        var counter = 0
        while bitValue != 0 {
            if (bitValue & 1) == 1 {
                if let newValue = R(rawValue: counter) {
                    values.append(newValue)
                } else {
                    unknownValues.insert(counter)
                }
            }
            bitValue = bitValue >> 1
            counter += 1
        }
        return (Set(values), unknownValues)
    }
    
    public static func toBitValue<S>(_ elements: S) -> Int where S: Sequence, S.Element == R {
        elements.map(\.rawValue)
            .map({ 1 << $0 })
            .reduce(into: 0, +=)
    }

    /// Returns true if the element exists in the value.
    public func contains(_ element: R) -> Bool {
        (self.value & element.rawValue) == 1
    }

    /// Inserts the element to the value if it doesn't exist.
    public mutating func insert(_ element: R) {
        self.value = self.value | element.rawValue
    }

    /// Removes the element from the value if it doesn't exist.
    public mutating func removing(_ element: R) {
        #warning("fix logic")
        self.value = self.value | element.rawValue
    }

    public mutating func removeAll(_ elements: [R]) {
#warning("fix logic")
        self.value = self.value | element.rawValue
    }
}

/// A bit-field that decode/encodes itself as an integer.
public struct IntBitField<R>: BitField
where R: RawRepresentable, R: Hashable, R.RawValue == Int {
    
    public var value: Int
    
    public init(_ value: Int) {
        self.value = value
    }
}

extension IntBitField: Codable {
    public init(from decoder: Decoder) throws {
        self.value = try Int(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try self.value.encode(to: encoder)
    }
}

extension IntBitField: Sendable where R: Sendable { }

/// Read `helpAnchor` for help about each error case.
public enum StringBitFieldDecodingError: LocalizedError, CustomStringConvertible {
    case notRepresentingInt(String)

    public var description: String {
        switch self {
        case let .notRepresentingInt(string):
            return "StringBitFieldDecodingError.notRepresentingInt(\(string))"
        }
    }

    public var errorDescription: String? {
        self.description
    }

    public var helpAnchor: String? {
        switch self {
        case let .notRepresentingInt(string):
            return "The string value could not be converted to an integer. This is a library decoding issue, please report this at https://github.com/MahdiBM/DiscordBM/issues. String: \(string)"
        }
    }
}

/// A bit-field that decode/encodes itself as a string.
public struct StringBitField<R>: BitField
where R: RawRepresentable, R: Hashable, R.RawValue == Int {

    public var value: Int

    public init(_ value: Int) {
        self.value = value
    }
}

extension StringBitField: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let int = Int(string) else {
            throw StringBitFieldDecodingError.notRepresentingInt(string)
        }
        self.value = int
    }

    public func encode(to encoder: Encoder) throws {
        try "\(self.value)".encode(to: encoder)
    }
}

extension StringBitField: Sendable where R: Sendable { }

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

    public init(from decoder: Decoder) throws {
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
    
    public func encode(to encoder: Encoder) throws {
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
    
    public init(from decoder: Decoder) throws {
        self.value = try .init(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
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
    
    public init(from decoder: Decoder) throws {
        self.value = try .init(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
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
    
    public init(from decoder: Decoder) throws {
        self.value = try .init(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        try self.value.encode(to: encoder)
    }
}

extension DereferenceBox: Sendable where C: Sendable { }

//MARK: - Snowflake

public protocol SnowflakeProtocol:
    Sendable,
    Codable,
    Hashable,
    CustomStringConvertible,
    ExpressibleByStringLiteral {

    var value: String { get }
    init(_ value: String)
}

extension SnowflakeProtocol {
    /// Initializes a snowflake from another snowflake.
    public init(_ snowflake: any SnowflakeProtocol) {
        self.init(snowflake.value)
    }

    public init(from decoder: Decoder) throws {
        try self.init(.init(from: decoder))
#if DISCORDBM_ENABLE_LOGGING_DURING_DECODE
        if self.parse() == nil {
            DiscordGlobalConfiguration.makeDecodeLogger("SnowflakeProtocol").warning(
                "Could not parse a snowflake", metadata: [
                    "type": "\(Self.self)",
                    "decoder": "\(decoder)",
                    "decoded": "\(self.value)"
                ]
            )
        }
#endif
    }

    public func encode(to encoder: Encoder) throws {
        try self.value.encode(to: encoder)
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    /// Initializes a snowflake from a `SnowflakeInfo`.
    @inlinable
    public init(info: SnowflakeInfo) {
        self = info.toSnowflake(as: Self.self)
    }

    /// Parses the snowflake to `SnowflakeInfo`.
    @inlinable
    public func parse() -> SnowflakeInfo? {
        SnowflakeInfo(from: self.value)
    }

    /// Makes a fake snowflake.
    /// - Parameter date: The date when this snowflake is supposed to have been created at.
    @inlinable
    public static func makeFake(date: Date = Date()) throws -> Self {
        try self.init(info: SnowflakeInfo.makeFake(date: date))
    }
}

/// Use the `Snowflake` type-aliases instead. e.g. `Snowflake<DiscordUser>` ❌, `UserSnowflake` ✅.
/// This type is expressible by string literal. This means the following code is valid:
/// ```
/// let snowflake: ChannelSnowflake = "192839184848484"
/// ```
/// If you really need to, you can convert snowflakes to each other:
/// ```
/// let appId: ApplicationSnowflake = "192839184848484"
/// let botId: UserSnowflake = Snowflake(appId)
/// ```
public struct Snowflake<Tag>: SnowflakeProtocol {
    public let value: String

    public init(_ value: String) {
        self.value = value
    }

    public var description: String {
        #"Snowflake<\#(Swift._typeName(Tag.self, qualified: false))>("\#(value)")"#
    }
}

/// Type-erased snowflake.
/// This type is expressible by string literal. This means the following code is valid:
/// ```
/// let snowflake: AnySnowflake = "192839184848484"
/// ```
/// If you really need to, you can convert snowflakes to each other:
/// ```
/// let appId: AnySnowflake = "192839184848484"
/// let botId: UserSnowflake = Snowflake(appId)
/// ```
public struct AnySnowflake: SnowflakeProtocol {
    public let value: String

    public init(_ value: String) {
        self.value = value
    }

    public var description: String {
        #"AnySnowflake("\#(value)")"#
    }
}

public func == (lhs: any SnowflakeProtocol, rhs: any SnowflakeProtocol) -> Bool {
    lhs.value == rhs.value
}

//MARK: Snowflake convenience type-aliases

/// Convenience type-alias for `Snowflake<Guild>`
public typealias GuildSnowflake = Snowflake<Guild>

/// Convenience type-alias for `Snowflake<DiscordChannel>`
public typealias ChannelSnowflake = Snowflake<DiscordChannel>

/// Convenience type-alias for `Snowflake<DiscordChannel.Message>`
public typealias MessageSnowflake = Snowflake<DiscordChannel.Message>

/// Convenience type-alias for `Snowflake<DiscordUser>`
public typealias UserSnowflake = Snowflake<DiscordUser>

/// Convenience type-alias for `Snowflake<PartialApplication>`
public typealias ApplicationSnowflake = Snowflake<PartialApplication>

/// Convenience type-alias for `Snowflake<PartialEmoji>`
public typealias EmojiSnowflake = Snowflake<PartialEmoji>

/// Convenience type-alias for `Snowflake<Sticker>`
public typealias StickerSnowflake = Snowflake<Sticker>

/// Convenience type-alias for `Snowflake<Role>`
public typealias RoleSnowflake = Snowflake<Role>

/// Convenience type-alias for `Snowflake<AutoModerationRule>`
public typealias RuleSnowflake = Snowflake<AutoModerationRule>

/// Convenience type-alias for `Snowflake<StickerPack>`
public typealias StickerPackSnowflake = Snowflake<StickerPack>

/// Convenience type-alias for `Snowflake<Webhook>`
public typealias WebhookSnowflake = Snowflake<Webhook>

/// Convenience type-alias for `Snowflake<GuildScheduledEvent>`
public typealias GuildScheduledEventSnowflake = Snowflake<GuildScheduledEvent>

/// Convenience type-alias for `Snowflake<ApplicationCommand>`
public typealias CommandSnowflake = Snowflake<ApplicationCommand>

/// Convenience type-alias for `Snowflake<Interaction>`
public typealias InteractionSnowflake = Snowflake<Interaction>

/// Convenience type-alias for `Snowflake<Integration>`
public typealias IntegrationSnowflake = Snowflake<Integration>

/// Convenience type-alias for `Snowflake<AuditLog.Entry>`
public typealias AuditLogEntrySnowflake = Snowflake<AuditLog.Entry>

/// Convenience type-alias for `Snowflake<DiscordChannel.Message.Attachment>`
public typealias AttachmentSnowflake = Snowflake<DiscordChannel.Message.Attachment>

/// Convenience type-alias for `Snowflake<DiscordChannel.ForumTag>`
public typealias ForumTagSnowflake = Snowflake<DiscordChannel.ForumTag>

/// Convenience type-alias for `Snowflake<Team>`
public typealias TeamSnowflake = Snowflake<Team>

/// Convenience type-alias for `Snowflake<StageInstance>`
public typealias StageInstanceSnowflake = Snowflake<StageInstance>

/// Convenience type-alias for `Snowflake<Gateway.Activity.Assets>`
public typealias AssetsSnowflake = Snowflake<Gateway.Activity.Assets>

/// The parsed info of a snowflake.
public struct SnowflakeInfo: Sendable {

    /// Read `helpAnchor` for help about each error case.
    public enum Error: LocalizedError {
        case fieldTooBig(_ name: String, value: String, max: Int)
        case fieldTooSmall(_ name: String, value: String, min: UInt64)

        public var errorDescription: String? {
            switch self {
            case let .fieldTooBig(name, value, max):
                return "fieldTooBig(\(name), value: \(value), max: \(max))"
            case let .fieldTooSmall(name, value, min):
                return "fieldTooSmall(\(name), value: \(value), min: \(min))"
            }
        }

        public var helpAnchor: String? {
            switch self {
            case let .fieldTooBig(name, value, max):
                return "Entered field '\(name)' is bigger than expected. It has a value of '\(value)', but max accepted is '\(max)'"
            case let .fieldTooSmall(name, value, min):
                return "Entered field '\(name)' is smaller than expected. It has a value of '\(value)', but min accepted is '\(min)'"
            }
        }
    }

    /// Time since epoch, in milli-seconds, when the snowflake was created.
    public var timestamp: UInt64
    /// The internal unique id of the worker that created the snowflake.
    public var workerId: UInt8
    /// The internal unique id of the process that created the snowflake.
    public var processId: UInt8
    /// The sequence number of the snowflake in the millisecond when it was created.
    public var sequenceNumber: UInt16

    /// The timestamp converted to `Date`.
    public var date: Date {
        Date(timeIntervalSince1970: Double(self.timestamp) / 1_000)
    }

    static let discordEpochConstant: UInt64 = 1_420_070_400_000

    /// - Parameters:
    ///   - timestamp: Time since epoch, in milli-seconds, when the snowflake was created.
    ///   - workerId: The internal unique id of the worker that created the snowflake.
    ///   - processId: The internal unique id of the process that created the snowflake.
    ///   - sequenceNumber: The sequence number of the snowflake in the millisecond when it was created.
    ///
    ///   Throws `SnowflakeInfo.Error`
    public init(timestamp: UInt64, workerId: UInt8, processId: UInt8, sequenceNumber: UInt16) throws {
        guard timestamp <= (1 << 42) else {
            throw Error.fieldTooBig("timestamp", value: "\(timestamp)", max: 1 << 42)
        }
        guard workerId <= (1 << 5) else {
            throw Error.fieldTooBig("workerId", value: "\(workerId)", max: 1 << 5)
        }
        guard processId <= (1 << 5) else {
            throw Error.fieldTooBig("processId", value: "\(processId)", max: 1 << 5)
        }
        guard sequenceNumber <= (1 << 12) else {
            throw Error.fieldTooBig("sequenceNumber", value: "\(sequenceNumber)", max: 1 << 12)
        }

        self.timestamp = timestamp
        self.workerId = workerId
        self.processId = processId
        self.sequenceNumber = sequenceNumber
    }

    /// - Parameters:
    ///   - date: Time date when the snowflake was created.
    ///   - workerId: The internal unique id of the worker that created the snowflake.
    ///   - processId: The internal unique id of the process that created the snowflake.
    ///   - sequenceNumber: The sequence number of the snowflake in the millisecond when it was created.
    ///
    ///   Throws `SnowflakeInfo.Error`
    public init(date: Date, workerId: UInt8, processId: UInt8, sequenceNumber: UInt16) throws {
        guard date.timeIntervalSince1970 >= Double(SnowflakeInfo.discordEpochConstant / 1_000) else {
            throw Error.fieldTooSmall("date", value: "\(date.timeIntervalSince1970)", min: SnowflakeInfo.discordEpochConstant)
        }

        let timeSince1970 = UInt64(date.timeIntervalSince1970)
        guard timeSince1970 < (1 << 42 / 1_000) else {
            throw Error.fieldTooBig("date", value: "\(timeSince1970)", max: (1 << 42 / 1_000))
        }

        self.timestamp = UInt64(date.timeIntervalSince1970 * 1_000)

        guard timestamp < (1 << 42) else {
            let max = (1 << 42 / 1_000) - 1
            throw Error.fieldTooBig("date", value: "\(timestamp)", max: max)
        }
        guard workerId <= (1 << 5) else {
            throw Error.fieldTooBig("workerId", value: "\(workerId)", max: 1 << 5)
        }
        guard processId <= (1 << 5) else {
            throw Error.fieldTooBig("processId", value: "\(processId)", max: 1 << 5)
        }
        guard sequenceNumber <= (1 << 12) else {
            throw Error.fieldTooBig("sequenceNumber", value: "\(sequenceNumber)", max: 1 << 12)
        }

        self.workerId = workerId
        self.processId = processId
        self.sequenceNumber = sequenceNumber
    }

    /// Makes a fake snowflake.
    /// - Parameter date: The date when this snowflake is supposed to have been created at.
    @inlinable
    internal static func makeFake(date: Date) throws -> SnowflakeInfo {
        try SnowflakeInfo(date: date, workerId: 0, processId: 0, sequenceNumber: 0)
    }

    @usableFromInline
    internal init? (from snowflake: String) {
        guard let value = UInt64(snowflake) else { return nil }
        self.timestamp = (value >> 22) + SnowflakeInfo.discordEpochConstant
        self.workerId = UInt8((value >> 17) & 0x1F)
        self.processId = UInt8((value >> 12) & 0x1F)
        self.sequenceNumber = UInt16(value & 0xFFF)
    }

    @inlinable
    internal init? (from snowflake: any SnowflakeProtocol) {
        self.init(from: snowflake.value)
    }

    @usableFromInline
    internal func toSnowflake<S: SnowflakeProtocol>(as type: S.Type) -> S {
        let timestamp = (self.timestamp - SnowflakeInfo.discordEpochConstant) << 22
        let workerId = UInt64(self.workerId) << 17
        let processId = UInt64(self.processId) << 12
        let value = timestamp | workerId | processId | UInt64(self.sequenceNumber)
        return S("\(value)")
    }
}

//MARK: +Calendar

private extension Calendar {
    static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .init(identifier: "UTC")!
        return calendar
    }()
}
