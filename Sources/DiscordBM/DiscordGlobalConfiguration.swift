import Foundation
import Logging

public enum DiscordGlobalConfiguration {
    /// Currently only 10 is supported.
    public static let apiVersion = 10
    public static var decoder: any DiscordDecoder = JSONDecoder()
    public static var encoder: any DiscordEncoder = JSONEncoder()
    /// Function to make loggers with. You can override it with your own logger.
    /// The `String` argument represents the label of the logger.
    public static var makeLogger: (String) -> Logger = { Logger(label: $0) }
    /// Log about sub-optimal situations during decode.
    /// For example if a type can't find a representation for a decoded value,
    /// and has to get rid of that value.
    /// Does not include decode errors.
    public static var enableLoggingDuringDecode: Bool = false
    /// Global rate-limit for requests per second. Currently 50 by default.
    public static var globalRateLimit = 50
}

//MARK: - Internal DiscordGlobalConfiguration
extension DiscordGlobalConfiguration {
    static func makeDecodeLogger(_ label: String) -> Logger {
        if enableLoggingDuringDecode {
            return DiscordGlobalConfiguration.makeLogger(label)
        } else {
            return Logger(label: label, factory: SwiftLogNoOpLogHandler.init)
        }
    }
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
