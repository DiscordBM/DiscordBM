import Foundation

import enum NIOHTTP1.HTTPMethod

/// A `CDNEndpoint` with a file extension that selects the image format.
/// https://docs.discord.com/developers/reference#image-formatting
public struct FormattedCDNEndpoint: Endpoint {
    public var endpoint: CDNEndpoint
    public var fileExtension: String?

    public init(_ endpoint: CDNEndpoint, fileExtension: String? = nil) {
        self.endpoint = endpoint
        self.fileExtension = fileExtension
    }

    public var url: String {
        guard let fileExtension = self.fileExtension else {
            return self.endpoint.url
        }
        let encodedFileExtension =
            fileExtension.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fileExtension
        return self.baseURL + self.endpointURLSuffixWithoutFixedExtension + "." + encodedFileExtension
    }

    public var urlDescription: String {
        self.url
    }

    public var httpMethod: HTTPMethod {
        self.endpoint.httpMethod
    }

    public var countsAgainstGlobalRateLimit: Bool {
        self.endpoint.countsAgainstGlobalRateLimit
    }

    public var requiresAuthorizationHeader: Bool {
        self.endpoint.requiresAuthorizationHeader
    }

    /// URL-path parameters, including the file extension.
    public var parameters: [String] {
        guard let fileExtension = self.fileExtension ?? self.fixedFileExtension else {
            return self.endpoint.parameters
        }
        return self.endpoint.parameters + [fileExtension]
    }

    public var id: Int {
        self.endpoint.id
    }

    public var description: String {
        "FormattedCDNEndpoint(endpoint: \(self.endpoint), fileExtension: \(self.fileExtension ?? "nil"))"
    }

    /// https://docs.discord.com/developers/reference#image-formatting-cdn-endpoints
    private var baseURL: String {
        switch self.endpoint {
        case .sticker where self.fileExtension == CDNEndpoint.StickerFormat.gif.rawValue:
            return "https://media.discordapp.net/"
        default:
            return "https://cdn.discordapp.com/"
        }
    }

    private var fixedFileExtension: String? {
        switch self.endpoint {
        case .defaultUserAvatar, .sticker:
            return "png"
        default:
            return nil
        }
    }

    private var endpointURLSuffixWithoutFixedExtension: String {
        guard let fixedFileExtension = self.fixedFileExtension else {
            return self.endpoint.urlSuffix
        }
        return String(self.endpoint.urlSuffix.dropLast(".\(fixedFileExtension)".count))
    }
}
