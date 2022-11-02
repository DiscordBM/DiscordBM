import Logging

/**
 A hack to make sure internal decoding of enums that conform to `String` or `Int`
 doesn't fail just because Discord has added a new value which the enums don't contain yet.
 If `DiscordGlobalConfiguration.enableLoggingDuringDecode` is enabled, this will log
 the new values that were decoded successfully but the enum didn't have a representation for.
 */
protocol ToleratesDecode: RawRepresentable where Self: Decodable, Self.RawValue: Decodable { }
protocol ToleratesStringDecode: ToleratesDecode where Self.RawValue == String { }
protocol ToleratesIntDecode: ToleratesDecode where Self.RawValue == Int { }

private enum TolerateDecodeKind {
    case string
    case int
    case none
    
    init<D>(type: D.Type, shouldTolerateDecode: Bool) {
        switch shouldTolerateDecode {
        case true:
            switch D.self {
            case is any ToleratesStringDecode.Type: self = .string
            case is any ToleratesIntDecode.Type: self = .int
            default: self = .none
            }
        case false: self = .none
        }
    }
}

private let toleratesDecodeLogger = DiscordGlobalConfiguration
    .makeDecodeLogger("ToleratesDecodeProtocol")

// MARK: - +KeyedDecodingContainer
extension KeyedDecodingContainer {
    func decode<D>(_: Array<D>.Type, forKey key: Key) throws -> Array<D>
    where D: Decodable {
        let shouldTolerateDecode = D.self is any ToleratesDecode.Type
        let toleratesDecodeKind = TolerateDecodeKind(
            type: D.self,
            shouldTolerateDecode: shouldTolerateDecode
        )
        
        var elements = Array<D>()
        var container = try self.nestedUnkeyedContainer(forKey: key)
        while !container.isAtEnd {
            do {
                let element = try container.decode(D.self)
                elements.append(element)
            } catch {
                switch toleratesDecodeKind {
                case .none:
                    throw error
                case .string:
                    if let key = try? container.decode(String.self) {
                        toleratesDecodeLogger.warning("ToleratesDecode found new key", metadata: [
                            "newKey": .string(key),
                            "decodedSoFar": .stringConvertible(elements),
                            "type": .string(_typeName(D.self))
                        ])
                    } else {
                        throw error
                    }
                case .int:
                    if let key = try? container.decode(Int.self) {
                        toleratesDecodeLogger.warning("ToleratesDecode found new key", metadata: [
                            "newKey": .stringConvertible(key),
                            "decodedSoFar": .stringConvertible(elements),
                            "type": .string(_typeName(D.self))
                        ])
                    } else {
                        throw error
                    }
                }
            }
        }
        
        return elements
    }
}
