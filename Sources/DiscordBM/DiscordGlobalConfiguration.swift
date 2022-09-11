import Foundation
import Logging

public enum DiscordGlobalConfiguration {
    /// Currently only 10 is supported
    public static let apiVersion = 10
    public static var decoder: DiscordDecoder = JSONDecoder()
    public static var encoder: DiscordEncoder = JSONEncoder()
    /// Function to make loggers with. You can override it with your own logger.
    /// The `String` argument represents the label of the logger.
    public static var makeLogger: (String) -> Logger = { Logger(label: $0) }
    public static var webSocketMaxFrameSize = 1 << 31
}

//MARK: - DiscordDecoder
public protocol DiscordDecoder {
    func decode<D: Decodable>(_ type: D.Type, from: Data) throws -> D
}

extension JSONDecoder: DiscordDecoder { }

//MARK: - DiscordEncoder
public protocol DiscordEncoder {
    func encode<E: Encodable>(_ value: E) throws -> Data
}

extension JSONEncoder: DiscordEncoder { }
