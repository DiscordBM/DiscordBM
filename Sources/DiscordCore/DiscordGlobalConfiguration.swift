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
    public static var enableLoggingDuringDecode: Bool = false
    /// Global rate-limit for requests per second.
    /// 50 by default, but you can ask Discord for a raise.
    public static var globalRateLimit = 50
    /// Whether or not to perform validations for `DefaultDiscordClient` payloads, before sending.
    /// The library will throw a ``ValidationError`` if it finds anything invalid in the payload.
    /// This all works based on Discord docs' validation notes.
    public static var performClientSideValidations = true
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
