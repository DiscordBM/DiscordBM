@preconcurrency import AsyncHTTPClient
import DiscordModels
import NIOHTTP1
import struct NIOCore.ByteBuffer
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
        if let data = body.map({ Data(buffer: $0) }) {
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
    public func getFile(preferredName: String? = nil) throws -> RawFile {
        try self.guardIsSuccessfulResponse()
        guard let body = self.httpResponse.body else {
            throw DiscordClientError.emptyBody(httpResponse)
        }
        guard let contentType = self.httpResponse.headers.first(name: "Content-Type") else {
            throw DiscordClientError.noContentTypeHeader(httpResponse)
        }
        let name = preferredName ?? fallbackFileName
        return RawFile(data: body, nameNoExtension: name, contentType: contentType)
    }
}
