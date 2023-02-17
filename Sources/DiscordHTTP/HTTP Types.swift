@preconcurrency import AsyncHTTPClient
import DiscordModels
import NIOHTTP1
import struct NIOCore.ByteBuffer
import NIOFoundationCompat
import Foundation

public struct DiscordHTTPRequest {
    public let endpoint: Endpoint
    public let queries: [(String, String?)]
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
    
    @inlinable
    public func guardIsSuccessfulResponse() throws {
        guard (200..<300).contains(self.status.code) else {
            throw DiscordClientError.badStatusCode(self)
        }
    }
    
    @inlinable
    public func decode<D: Decodable>(as _: D.Type = D.self) throws -> D {
        try guardIsSuccessfulResponse()
        if let data = body.map({ Data(buffer: $0, byteTransferStrategy: .noCopy) }) {
            return try DiscordGlobalConfiguration.decoder.decode(D.self, from: data)
        } else {
            throw DiscordClientError.emptyBody(self)
        }
    }
}

public struct DiscordClientResponse<C>: Sendable where C: Codable {
    public let httpResponse: DiscordHTTPResponse
    
    public init(httpResponse: DiscordHTTPResponse) {
        self.httpResponse = httpResponse
    }
    
    @inlinable
    public func guardIsSuccessfulResponse() throws {
        try self.httpResponse.guardIsSuccessfulResponse()
    }
    
    @inlinable
    public func decode() throws -> C {
        try httpResponse.decode(as: C.self)
    }
}

public struct DiscordCDNResponse: Sendable {
    public let httpResponse: DiscordHTTPResponse
    public let fallbackFileName: String
    
    public init(httpResponse: DiscordHTTPResponse, fallbackFileName: String) {
        self.httpResponse = httpResponse
        self.fallbackFileName = fallbackFileName
    }
    
    @inlinable
    public func guardIsSuccessfulResponse() throws {
        try self.httpResponse.guardIsSuccessfulResponse()
    }
    
    @inlinable
    public func getFile(overrideName: String? = nil) throws -> RawFile {
        try self.guardIsSuccessfulResponse()
        guard let body = self.httpResponse.body else {
            throw DiscordClientError.emptyBody(httpResponse)
        }
        guard let contentType = self.httpResponse.headers.first(name: "Content-Type") else {
            throw DiscordClientError.noContentTypeHeader(httpResponse)
        }
        let name = overrideName ?? fallbackFileName
        return RawFile(data: body, nameNoExtension: name, contentType: contentType)
    }
}

/// Read `helpAnchor` for help about each error case.
public enum DiscordClientError: LocalizedError {
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
