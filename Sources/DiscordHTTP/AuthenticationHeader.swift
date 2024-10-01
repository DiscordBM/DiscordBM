import DiscordModels
import NIOHTTP1
import struct Foundation.Data
import Logging

public enum AuthenticationHeader: Sendable {
    case userToken(Secret)
    case botToken(Secret)
    case oAuthToken(Secret)
    case none

    @inlinable
    var id: String? {
        switch self {
        case .userToken(let secret):
            return "\(secret.value.hash)"
        case .botToken(let secret):
            return "b-\(secret.value.hash)"
        case .oAuthToken(let secret):
            return "o-\(secret.value.hash)"
        case .none:
            return nil
        }
    }

    /// Adds an authentication header or throws an error.
    @inlinable
    func addHeader(headers: inout HTTPHeaders, request: DiscordHTTPRequest) throws {
        switch self {
        case .userToken(let secret):
            headers.replaceOrAdd(name: "Authorization", value: secret.value)
        case .botToken(let secret):
            headers.replaceOrAdd(name: "Authorization", value: "Bot \(secret.value)")
        case .oAuthToken(let secret):
            headers.replaceOrAdd(name: "Authorization", value: "Bearer \(secret.value)")
        case .none:
            throw DiscordHTTPError.authenticationHeaderRequired(request: request)
        }
    }

    /// Extracts the app-id from a bot token. Otherwise returns nil.
    @inlinable
    func extractAppIdIfAvailable() -> ApplicationSnowflake? {
        switch self {
        case let .botToken(token):
            if let base64 = token.value.split(separator: ".").first {
                for base64 in [base64, base64 + "=="] {
                    if let data = Data(base64Encoded: String(base64)),
                       let decoded = String(data: data, encoding: .utf8) {
                        return ApplicationSnowflake(decoded)
                    }
                }
            }

            DiscordGlobalConfiguration.makeLogger("AuthenticationHeader").error(
                "Cannot extract app-id from the bot token, please report this at https://github.com/DiscordBM/DiscordBM/issues. It can be an empty issue with a title like 'AuthenticationHeader failed to decode app-id'", metadata: [
                    "botTokenSecret": .stringConvertible(token)
                ]
            )
            return nil
        case .oAuthToken, .userToken, .none: return nil
        }
    }
}
