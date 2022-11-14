import Foundation
import Logging
import MultipartKit

public enum DiscordGlobalConfiguration {
    /// Currently only 10 is supported.
    public static let apiVersion = 10
    /// The global decoder to decode JSONs with.
    public static var decoder: any DiscordDecoder = JSONDecoder()
    /// The global encoder to encode JSONs with.
    public static var encoder: any DiscordEncoder = JSONEncoder()
    /// The global encoder to encode Multipart forms with.
    public static var multipartEncoder: any DiscordMultipartEncoder = FormDataEncoder()
    /// Function to make loggers with. You can override it with your own logger.
    /// The `String` argument represents the label of the logger.
    public static var makeLogger: (String) -> Logger = { Logger(label: $0) }
    /// Log about sub-optimal situations during decode.
    /// For example if a type can't find a representation to decode a value to,
    /// and has to get rid of that value.
    /// Does not include decode errors.
    /// For those interested to keep the library up to date.
    public static var enableLoggingDuringDecode: Bool = false
    /// Global rate-limit for requests per second.
    /// 50 by default, but you can ask Discord for a raise.
    public static var globalRateLimit = 50
    /// Whether or not to perform validations for `DiscordClient` payloads, before sending.
    /// The library will throw an error if it finds anything invalid in the payload.
    /// This all works based on Discord docs' validation notes.
    public static var performClientValidations = true
}

//MARK: - Internal DiscordGlobalConfiguration
extension DiscordGlobalConfiguration {
    static func makeDecodeLogger(_ label: String) -> Logger {
        if enableLoggingDuringDecode {
            var logger = DiscordGlobalConfiguration.makeLogger(label)
            logger[metadataKey: "explanation"] = "If you're using one of the recent versions of DiscordBM, please report this on https://github.com/MahdiBM/DiscordBM/issues if there are no similar issues, so we can keep DiscordBM up to date for the community"
            return logger
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

//MARK: DiscordMultipartEncoder
public protocol DiscordMultipartEncoder {
    func encode<E: Encodable>(_: E, boundary: String, into: inout ByteBuffer) throws
}

extension FormDataEncoder: DiscordMultipartEncoder { }
