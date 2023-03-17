@preconcurrency import AsyncHTTPClient
import DiscordModels
import NIOHTTP1
import struct NIOCore.ByteBuffer
import NIOFoundationCompat
import Foundation

public struct DiscordHTTPRequest: Sendable {
    /// The endpoint to send the request to.
    public let endpoint: Endpoint
    /// The query parameters of the request.
    public let queries: [(String, String?)]
    /// The extra headers of the request.
    public let headers: HTTPHeaders
    
    public init(
        to endpoint: Endpoint,
        queries: [(String, String?)] = [],
        headers: HTTPHeaders = [:]
    ) {
        self.endpoint = endpoint
        self.queries = queries
        self.headers = headers
    }
}

/// Represents a raw Discord HTTP response.
public struct DiscordHTTPResponse: Sendable, CustomStringConvertible {
    let _response: HTTPClient.Response
    
    internal init(_response: HTTPClient.Response) {
        self._response = _response
    }
    
    public init(
        host: String,
        status: HTTPResponseStatus,
        version: HTTPVersion,
        headers: HTTPHeaders = [:],
        body: ByteBuffer? = nil
    ) {
        self._response = .init(
            host: host,
            status: status,
            version: version,
            headers: headers,
            body: body
        )
    }
    
    /// Remote host of the request.
    public var host: String {
        _response.host
    }
    /// Response HTTP status.
    public var status: HTTPResponseStatus {
        _response.status
    }
    /// Response HTTP version.
    public var version: HTTPVersion {
        _response.version
    }
    /// Response HTTP headers.
    public var headers: HTTPHeaders {
        _response.headers
    }
    /// Response body.
    public var body: ByteBuffer? {
        _response.body
    }
    
    public var description: String {
        "DiscordHTTPResponse("
        + "host: \(host), "
        + "status: \(status), "
        + "version: \(version), "
        + "headers: \(headers), "
        + "body: \(body.map({ String(buffer: $0) }) ?? "nil")"
        + ")"
    }
    
    /// Throws an error if the response does not indicate success.
    @inlinable
    public func guardSuccess() throws {
        guard (200..<300).contains(self.status.code) else {
            throw DiscordHTTPError.badStatusCode(self)
        }
    }
    
    /// Makes sure the response is a success response, or tries to find a `JSONError`
    /// so you have a chance to process the error and try to recover.
    ///
    /// Returns `none` if the response is a success response.
    /// Returns `jsonError` if it's a recognizable error.
    /// Otherwise returns `badStatusCode`.
    ///
    /// The `JSONError` does not contain the full Discord error response.
    /// For manual debugging, it's better to directly read the contents of the response:
    /// ```
    /// let httpResponse: DiscordHTTPResponse = ...
    /// print(httpResponse.description)
    /// ```
    @inlinable
    public func decodeError() -> DiscordHTTPErrorResponse {
        if (200..<300).contains(self.status.code) {
            return .none
        } else {
            if let error = try? self._decode(as: JSONError.self) {
                return .jsonError(error)
            } else {
                return .badStatusCode(self)
            }
        }
    }
    
    /// Decode the response into an arbitrary type.
    @inlinable
    public func decode<D: Decodable>(as _: D.Type = D.self) throws -> D {
        try self.guardSuccess()
        return try self._decode()
    }
    
    /// Doesn't check for success of the response
    @usableFromInline
    func _decode<D: Decodable>(as _: D.Type = D.self) throws -> D {
        if let data = body.map({ Data(buffer: $0, byteTransferStrategy: .noCopy) }) {
            return try DiscordGlobalConfiguration.decoder.decode(D.self, from: data)
        } else {
            throw DiscordHTTPError.emptyBody(self)
        }
    }
}

/// Represents a Discord HTTP response for endpoints that return some data in the body.
public struct DiscordClientResponse<C>: Sendable where C: Codable {
    /// The raw http response.
    public let httpResponse: DiscordHTTPResponse
    
    public init(httpResponse: DiscordHTTPResponse) {
        self.httpResponse = httpResponse
    }
    
    /// Throws an error if the response does not indicate success.
    @inlinable
    public func guardSuccess() throws {
        try self.httpResponse.guardSuccess()
    }
    
    /// Makes sure the response is a success response, or tries to find a `JSONError`
    /// so you have a chance to process the error and try to recover.
    ///
    /// Returns `none` if the response is a success response.
    /// Returns `jsonError` if it's a recognizable error.
    /// Otherwise returns `badStatusCode`.
    ///
    /// The `JSONError` does not contain the full Discord error response.
    /// For manual debugging, it's better to directly read the contents of the response:
    /// ```
    /// let httpResponse: DiscordHTTPResponse = ...
    /// print(httpResponse.description)
    /// ```
    @inlinable
    public func decodeError() -> DiscordHTTPErrorResponse {
        self.httpResponse.decodeError()
    }
    
    /// Decode the response.
    @inlinable
    public func decode() throws -> C {
        try httpResponse.decode(as: C.self)
    }
}

/// Represents a Discord HTTP response for CDN endpoints.
public struct DiscordCDNResponse: Sendable {
    /// The raw http response.
    public let httpResponse: DiscordHTTPResponse
    /// The fallback name for the file that will be decoded.
    public let fallbackFileName: String
    
    public init(httpResponse: DiscordHTTPResponse, fallbackFileName: String) {
        self.httpResponse = httpResponse
        self.fallbackFileName = fallbackFileName
    }
    
    @inlinable
    public func guardSuccess() throws {
        try self.httpResponse.guardSuccess()
    }
    
    @inlinable
    public func getFile(overrideName: String? = nil) throws -> RawFile {
        try self.guardSuccess()
        guard let body = self.httpResponse.body else {
            throw DiscordHTTPError.emptyBody(httpResponse)
        }
        guard let contentType = self.httpResponse.headers.first(name: "Content-Type") else {
            throw DiscordHTTPError.noContentTypeHeader(httpResponse)
        }
        let name = overrideName ?? fallbackFileName
        return RawFile(data: body, nameNoExtension: name, contentType: contentType)
    }
}

/// Represents a possible Discord HTTP error.
public enum DiscordHTTPErrorResponse: Sendable {
    /// The response indicates success. No errors have been found.
    case none
    /// The response does not indicate success and there is a recognizable error in the body.
    case jsonError(JSONError)
    /// The response does not indicate success and there is no recognizable error in the body.
    case badStatusCode(DiscordHTTPResponse)
}

/// Read `helpAnchor` for help about each error case.
public enum DiscordHTTPError: LocalizedError {
    case rateLimited(url: String)
    case badStatusCode(DiscordHTTPResponse)
    case emptyBody(DiscordHTTPResponse)
    case noContentTypeHeader(DiscordHTTPResponse)
    case appIdParameterRequired
    case queryParametersMutuallyExclusive(queries: [(String, String)])
    case queryParameterOutOfBounds(name: String, value: String?, lowerBound: Int, upperBound: Int)
    
    public var errorDescription: String? {
        switch self {
        case let .rateLimited(url):
            return "rateLimited(url: \(url))"
        case let .badStatusCode(response):
            return "badStatusCode(\(response))"
        case let .emptyBody(response):
            return "emptyBody(\(response))"
        case let .noContentTypeHeader(response):
            return "noContentTypeHeader(\(response))"
        case .appIdParameterRequired:
            return "appIdParameterRequired"
        case let .queryParametersMutuallyExclusive(queries):
            return "queryParametersMutuallyExclusive(queries: \(queries))"
        case let .queryParameterOutOfBounds(name, value, lowerBound, upperBound):
            return "queryParameterOutOfBounds(name: \(name), value: \(value ?? "nil"), lowerBound: \(lowerBound), upperBound: \(upperBound))"
        }
    }
    
    public var helpAnchor: String? {
        switch self {
        case let .rateLimited(url):
            return "Discord has rate-limited you at '\(url)'. Try to send less messages or send at a slower pace"
        case let .badStatusCode(response):
            return "Discord responded with a non-200 status code. Discord says: \(response.body.map(String.init) ?? "nil")"
        case let .emptyBody(response):
            return "The response body was unexpectedly empty. If it happens frequently, you should report it to me at https://github.com/MahdiBM/DiscordBM/issues. Discord's response: \(response)"
        case let .noContentTypeHeader(response):
            return "Discord didn't send a Content-Type header. See if they mentions any errors in the response: \(response)"
        case .appIdParameterRequired:
            return "The 'appId' parameter is required. Either pass it in the initializer of DefaultDiscordClient/BotGatewayManager or use the 'appId' function parameter"
        case let .queryParametersMutuallyExclusive(queries):
            return "Discord only accepts one of these query parameters at a time: \(queries)"
        case let .queryParameterOutOfBounds(name, value, lowerBound, upperBound):
            return "The query parameter '\(name)' with a value of '\(value ?? "nil")' is out of the Discord-acceptable bounds of \(lowerBound)...\(upperBound)"
        }
    }
}
