import Foundation

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
    
    public var boolValue: Bool? {
        switch self {
        case .bool(let bool): return bool
        default: return nil
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

/// Not sure what exactly it is. Some kind of hash container.
public struct Hashes: Sendable, Codable {
    
    public struct Item: Sendable, Codable {
        public var omitted: Bool?
        public var hash: String
        
        public init(omitted: Bool, hash: String) {
            self.omitted = omitted
            self.hash = hash
        }
    }
    
    public var version: Int
    public var roles: Item
    public var metadata: Item
    public var channels: Item
    
    public init(version: Int, roles: Item, metadata: Item, channels: Item) {
        self.version = version
        self.roles = roles
        self.metadata = metadata
        self.channels = channels
    }
}

/// https://discord.com/developers/docs/reference#locales
public enum DiscordLocale: String, Sendable, Codable {
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

/// A timestamp that decode/encodes itself how Discord expects.
public struct DiscordTimestamp: Codable {
    
    public enum DecodingError: Error {
        case unexpectedFormat([CodingKey], String)
        case conversionFailure([CodingKey], String, DateComponents)
    }
    
    public var date: Date
    
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
                debugDescription: "Programming Error. Could not encode Date to Discord Timestamp."
            ))
        }
        let miliSecond = nanoSecond / 1_000
        
        func fixedDigit(_ int: Int, _ length: Int) -> String {
            let description = "\(int)"
            let zeroCount = length - description.count
            if zeroCount > 0 {
                return Array(repeating: "0", count: zeroCount) + description
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

#if swift(>=5.7)
extension DiscordTimestamp: Sendable { }
#else
extension DiscordTimestamp: @unchecked Sendable { }
#endif

private enum BitFieldError: Error {
    case notRepresentingInt
}

/// A protocol for bit-fields.
public protocol BitField: ExpressibleByArrayLiteral {
    associatedtype R: RawRepresentable where R: Hashable, R.RawValue == Int
    var values: Set<R> { get set }
    var unknownValues: Set<Int> { get set }
    init(_ values: Set<R>, unknownValues: Set<Int>)
}

private let bitFieldLogger = DiscordGlobalConfiguration.makeLogger("BitField")

extension BitField {
    
    public init(arrayLiteral elements: R...) {
        self.init(Set(elements), unknownValues: [])
    }
    
    public init(_ elements: [R]) {
        self.init(Set(elements), unknownValues: [])
    }
    
    public init(bitValue: Int) {
        var bitValue = bitValue
        var values: ContiguousArray<R> = []
        var unknownValues: Set<Int> = []
        while bitValue > 0 {
            let halfUp = (bitValue / 2) + 1
            let log = log2(Double(halfUp))
            let intValue = Int(log.rounded(.up))
            
            if let newValue = R(rawValue: intValue) {
                values.append(newValue)
            } else {
                unknownValues.insert(intValue)
            }
            bitValue -= 1 << intValue
        }
        
        self.init(
            Set(values),
            unknownValues: unknownValues
        )
    }
    
    public func toBitValue() -> Int {
        (values.map(\.rawValue) + unknownValues)
            .map({ 1 << $0 })
            .reduce(into: 0, +=)
    }
}

/// A bit-field that decode/encodes itself as an integer.
public struct IntBitField<R>: BitField, Codable
where R: RawRepresentable, R: Hashable, R.RawValue == Int {
    
    public var values: Set<R>
    public var unknownValues: Set<Int>
    
    public init(_ values: Set<R>, unknownValues: Set<Int> = []) {
        self.values = values
        self.unknownValues = unknownValues
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let int = try container.decode(Int.self)
        self.init(bitValue: int)
        if !self.unknownValues.isEmpty {
            bitFieldLogger.warning("Non-empty bit-field unknown values", metadata: [
                "unknownValues": "\(unknownValues)",
                "values": "\(values.map(\.rawValue))",
                "rawType": "\(Swift._typeName(R.self))",
                "codingPath": "\(decoder.codingPath)"
            ])
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let value = self.toBitValue()
        try container.encode(value)
    }
}

extension IntBitField: Sendable where R: Sendable { }

/// A bit-field that decode/encodes itself as a string.
public struct StringBitField<R>: BitField, Codable
where R: RawRepresentable, R: Hashable, R.RawValue == Int {
    
    public var values: Set<R>
    public var unknownValues: Set<Int>
    
    public init(_ values: Set<R>, unknownValues: Set<Int> = []) {
        self.values = values
        self.unknownValues = unknownValues
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let int = Int(string) else {
            throw BitFieldError.notRepresentingInt
        }
        self.init(bitValue: int)
        if !self.unknownValues.isEmpty {
            bitFieldLogger.warning("Non-empty bit-field unknown values", metadata: [
                "unknownValues": "\(unknownValues)",
                "values": "\(values.map(\.rawValue))",
                "rawType": "\(Swift._typeName(R.self))",
                "codingPath": "\(decoder.codingPath)"
            ])
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let value = self.toBitValue()
        try container.encode("\(value)")
    }
}

extension StringBitField: Sendable where R: Sendable { }

/// An array consisting of two integers.
public struct IntPair: Sendable, Codable {
    public var first: Int
    public var second: Int
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let array = try container.decode([Int].self)
        guard array.count == 2 else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: container.codingPath,
                debugDescription: "Expected 2 integers in the array, found \(array.count)."
            ))
        }
        self.first = array[0]
        self.second = array[1]
    }
    
    public func encode(to encoder: Encoder) throws {
        try [first, second].encode(to: encoder)
    }
}

//MARK: - TolerantDecode

private let tolerantDecodeLogger = DiscordGlobalConfiguration.makeLogger("DecodeTolerable")

/// An ``Array`` that tolerates decode failure of its elements.
public struct TolerantDecodeArray<Element>:
    Codable,
    ExpressibleByArrayLiteral
where Element: RawRepresentable,
      Element.RawValue: Codable {
    
    public var values: [Element] = []
    public var unknownValues: [Element.RawValue] = []
    
    public init(_ values: [Element], unknownValues: [Element.RawValue] = []) {
        self.values = values
        self.unknownValues = unknownValues
    }
    
    public init(arrayLiteral elements: Element...) {
        self.values = elements
    }
    
    public init() { }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        var values: ContiguousArray<Element> = []
        while !container.isAtEnd {
            let rawValue = try container.decode(Element.RawValue.self)
            if let value = Element.init(rawValue: rawValue) {
                values.append(value)
            } else {
                self.unknownValues.append(rawValue)
            }
        }
        if !self.unknownValues.isEmpty {
            tolerantDecodeLogger.warning("TolerantDecodeArray found unconsidered values.", metadata: [
                "values": "\(values)",
                "unknownValues": "\(self.unknownValues)",
                "codingPath": "\(container.codingPath.map(\.debugDescription))",
                "type": "\(Swift._typeName(Self.self))"
            ])
        }
        self.values = Array(values)
    }
    
    public func encode(to encoder: Encoder) throws {
        try self.values.map(\.rawValue).encode(to: encoder)
    }
}

extension TolerantDecodeArray: Sendable where Element: Sendable, Element.RawValue: Sendable { }

/// A ``Date`` and ``DiscordTimestamp`` that tolerates decode failures.
public struct TolerantDecodeDate: Codable {
    
    public var date: Date
    
    public init(date: Date) {
        self.date = date
    }
    
    public init(from decoder: Decoder) throws {
        if let date = try? decoder.singleValueContainer().decode(Date.self) {
            self.date = date
        } else {
            self.date = try DiscordTimestamp(from: decoder).date
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.date)
    }
}

#if swift(>=5.7)
extension TolerantDecodeDate: Sendable { }
#else
extension TolerantDecodeDate: @unchecked Sendable { }
#endif

/// A dynamic color type that decode/encodes itself as an integer which Discord expects.
public struct DiscordColor: Sendable, Codable, ExpressibleByIntegerLiteral {
    
    public let value: Int
    
    public var asRGB: (red: Int, green: Int, blue: Int) {
        let red = value >> 16
        let green = (value & 0x00FF00) >> 8
        let blue = value & 0x0000FF
        return (red, green, blue)
    }
    
    public var asHex: String {
        "#" + String(self.value, radix: 16, uppercase: true)
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
        self.value = (red << 16) + (green << 8) + blue
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
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(Int.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        try self.value.encode(to: encoder)
    }
}

/// A type that will try to keep its content a secret when used with string interpolation.
/// This is to stop leaking the token in the logs, for whatever reason.
public struct Secret:
    Sendable,
    Codable,
    ExpressibleByStringLiteral,
    CustomStringConvertible,
    CustomDebugStringConvertible {
    
    internal var _storage: String
    
    public init(stringLiteral value: String) {
        self._storage = value
    }
    
    public init(_ value: String) {
        self._storage = value
    }
    
    public var description: String {
        let count = _storage.count
        let keepCount = count > 24 ? 6 : 0
        let dropped = _storage.dropLast(count - keepCount)
        return "\(dropped)****"
    }
    
    public var debugDescription: String {
        "\(self)".debugDescription
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self._storage = try container.decode(String.self)
    }
    
    public mutating func set(to newValue: String) {
        self._storage = newValue
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self._storage)
    }
}

/// A class so we can use the same type recursively in itself.
public final class DereferenceBox<C>: Codable, CustomStringConvertible where C: Codable {
    public let value: C
    
    public init(value: C) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        value = try C.init(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
    
    public var description: String {
        "\(value)"
    }
}

extension DereferenceBox: Sendable where C: Sendable { }
