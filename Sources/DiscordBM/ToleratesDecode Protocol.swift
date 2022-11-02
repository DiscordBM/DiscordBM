import Logging

/**
 A hack to make sure internal decoding of enums that conform to `String` or `Int`
 doesn't fail just because Discord has added a new value which the enums don't contain yet.
 If `DiscordGlobalConfiguration.enableLoggingDuringDecode` is enabled, this will log
 the new values that were decoded successfully but the enum didn't have a representation for.
 */
protocol ToleratesDecode { }
protocol ToleratesStringDecodeMarker: ToleratesDecode { }
protocol ToleratesIntDecodeMarker: ToleratesDecode { }

private enum ToleratesDecodeKind {
    case string
    case int
    case none
    
    init<D>(type: D.Type, shouldTolerateDecode: Bool) {
        switch shouldTolerateDecode {
        case true:
            switch D.self {
            case is any ToleratesStringDecodeMarker.Type: self = .string
            case is any ToleratesIntDecodeMarker.Type: self = .int
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
        let toleratesDecodeKind = ToleratesDecodeKind(
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
                case .none: break
                case .string:
                    if let value = try? container.decode(String.self) {
                        toleratesDecodeLogger.warning("Found a new enum value", metadata: [
                            "newKey": .string(value),
                            "decodedSoFar": .stringConvertible(elements),
                            "totalCount": .stringConvertible(container.count ?? -1),
                            "type": .string(_typeName(D.self))
                        ])
                        continue
                    }
                case .int:
                    if let value = try? container.decode(Int.self) {
                        toleratesDecodeLogger.warning("Found a new enum value", metadata: [
                            "newKey": .stringConvertible(value),
                            "decodedSoFar": .stringConvertible(elements),
                            "totalCount": .stringConvertible(container.count ?? -1),
                            "type": .string(_typeName(D.self))
                        ])
                        continue
                    }
                }
                throw error
            }
        }
        
        return elements
    }
}
