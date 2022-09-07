import AsyncHTTPClient
import NIOCore
import NIOConcurrencyHelpers

public enum HTTPClientProvider {
    /// Use a shared HTTClient instance for the package.
    /// `eventLoopGroup` and `config` are only used for the initial creation of the shared instance.
    case useShared(eventLoopGroup: EventLoopGroup, config: HTTPClient.Configuration? = nil)
    /// Provide an available HTTPClient instance.
    case available(HTTPClient)
    #warning("Shutdown HTTPClient")
    func makeClient() -> HTTPClient {
        switch self {
        case let .useShared(elg, config):
            return HTTPClientStorage.shared.getClient(elg: elg, config: config)
        case let .available(client):
            return client
        }
    }
}

private class HTTPClientStorage {
    
    private let lock = Lock()
    private var discordShared: HTTPClient? = nil
    
    private init() { }
    static let shared = HTTPClientStorage()
    
    func getClient(elg: EventLoopGroup, config: HTTPClient.Configuration?) -> HTTPClient {
        lock.lock()
        defer { lock.unlock() }
        
        if let shared = discordShared {
            return shared
        } else {
            // TODO: don't use `.http1Only`?
            let configuration = config ?? {
                var config = HTTPClient.Configuration()
                config.httpVersion = .http1Only
                return config
            }()
            discordShared = .init(
                eventLoopGroupProvider: .shared(elg),
                configuration: configuration,
                backgroundActivityLogger: DiscordGlobalConfiguration.makeLogger("D-AHC-BG")
            )
            return discordShared!
        }
    }
}
