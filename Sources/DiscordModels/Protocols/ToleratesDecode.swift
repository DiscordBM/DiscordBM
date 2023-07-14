import Logging

/**
 A hack to make sure internal decoding of array of enums that conform to `String` or `Int`
 don't fail just because Discord has added a new value which the enums don't contain yet.
 If `DiscordGlobalConfiguration.enableLoggingDuringDecode` is enabled, this will log
 the new values that were decoded successfully but the enum didn't have a representation for.
 `_ToleratesDecode` should not be used outside what there already is in this file.
 */
protocol _ToleratesDecode { }
protocol ToleratesStringDecodeMarker: _ToleratesDecode { }
protocol ToleratesIntDecodeMarker: _ToleratesDecode { }

private let toleratesDecodeLogger = DiscordGlobalConfiguration
    .makeDecodeLogger("ToleratesDecodeProtocol")

// MARK: - +KeyedDecodingContainer
extension KeyedDecodingContainer {
    public func decode<D>(
        _: Array<D>.Type,
        forKey key: Key
    ) throws -> Array<D> where D: Decodable {
        /// I know this check is rather slow, but I couldn't find a better way.
        if D.self is any _ToleratesDecode.Type {
            return try smartPath(Array<D>.self, forKey: key)
        } else {
            return try foundationPath(Array<D>.self, forKey: key)
        }
    }

    public func decodeIfPresent<D>(
        _: Array<D>.Type,
        forKey key: Key
    ) throws -> Array<D>? where D: Decodable {
        /// I know this check is rather slow, but I couldn't find a better way.
        /// Not 100% correct implementation, but i'm going to remove these junk anyway,
        /// when Swift 5.9 is out.
        if D.self is any _ToleratesDecode.Type {
            return try? smartPath(Array<D>.self, forKey: key)
        } else {
            return try foundationDecodeIfPresentPath(Array<D>.self, forKey: key)
        }
    }

    func smartPath<D>(
        _: Array<D>.Type,
        forKey key: Key
    ) throws -> Array<D> where D: Decodable {
        var elements = Array<D>()
        var container = try self.nestedUnkeyedContainer(forKey: key)
        /// Knowing that the internal decodes of this library don't really fail that much,
        /// I don't know why I shouldn't reserve the capacity beforehand,
        /// although Foundation doesn't do this.
        if let count = container.count {
            elements.reserveCapacity(count)
        }
        while !container.isAtEnd {
            do {
                let element = try container.decode(D.self)
                elements.append(element)
            } catch {
                switch D.self {
                case is any ToleratesStringDecodeMarker.Type:
                    if let value = try? container.decode(String.self) {
                        toleratesDecodeLogger.warning("Found a new enum value", metadata: [
                            "newKey": .string(value),
                            "decodedSoFar": .stringConvertible(DescriptionBox(elements)),
                            "totalCount": .stringConvertible(container.count ?? -1),
                            "type": .string(_typeName(D.self))
                        ])
                        continue
                    }
                case is any ToleratesIntDecodeMarker.Type:
                    if let value = try? container.decode(Int.self) {
                        toleratesDecodeLogger.warning("Found a new enum value", metadata: [
                            "newKey": .stringConvertible(value),
                            "decodedSoFar": .stringConvertible(DescriptionBox(elements)),
                            "totalCount": .stringConvertible(container.count ?? -1),
                            "type": .string(_typeName(D.self))
                        ])
                        continue
                    }
                default:
                    toleratesDecodeLogger.warning("Unhandled marker protocol that conforms to '_ToleratesDecode'. This is a programming error", metadata: ["type": .string(_typeName(D.self))])
                }
                throw error
            }
        }
        
        return elements
    }
    
    func foundationPath<D>(
        _: Array<D>.Type,
        forKey key: Key
    ) throws -> Array<D> where D: Decodable {
        var elements = Array<D>()
        var container = try self.nestedUnkeyedContainer(forKey: key)
        
        while !container.isAtEnd {
            let element = try container.decode(D.self)
            elements.append(element)
        }
        
        return elements
    }

    func foundationDecodeIfPresentPath<D>(
        _: Array<D>.Type,
        forKey key: Key
    ) throws -> Array<D>? where D: Decodable {
        guard self.contains(key) else { return nil }

        var elements = Array<D>()
        var container = try self.nestedUnkeyedContainer(forKey: key)

        while !container.isAtEnd {
            let element = try container.decode(D.self)
            elements.append(element)
        }

        return elements
    }
}

private struct DescriptionBox<T>: @unchecked Sendable, CustomStringConvertible {
    var value: T
    var description: String { "\(value)" }
    
    init(_ value: T) {
        self.value = value
    }
}
