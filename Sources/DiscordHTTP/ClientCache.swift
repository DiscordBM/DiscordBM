import struct Foundation.Date

/// This doesn't use the `Cache-Control` header because I couldn't
/// find a 2xx response with a `Cache-Control` header returned by Discord.
actor ClientCache {

    struct CacheableItem: Hashable {
        let identity: CacheableEndpointIdentity
        let parameters: [String]
        let queries: [(String, String?)]

        func hash(into hasher: inout Hasher) {
            switch identity {
            case .api(let endpoint):
                hasher.combine(0)
                hasher.combine(endpoint.rawValue)
            case .cdn(let endpoint):
                hasher.combine(1)
                hasher.combine(endpoint.rawValue)
            case .loose(let endpoint):
                hasher.combine(2)
                endpoint.hash(into: &hasher)
            }
            for param in parameters {
                hasher.combine(param)
            }
            for (key, value) in queries {
                hasher.combine(key)
                hasher.combine(value)
            }
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.identity == rhs.identity &&
            lhs.parameters == rhs.parameters &&
            lhs.queries.elementsEqual(rhs.queries, by: {
                $0.0 == $1.0 &&
                $0.1 == $1.1
            })
        }
    }

    /// [ID: ExpirationTime]
    var timeTable = [CacheableItem: Double]()
    /// [ID: Response]
    var storage = [CacheableItem: DiscordHTTPResponse]()

    static let global = ClientCache()

    init() {
        Task { await self.collectGarbage() }
    }

    func add(response: DiscordHTTPResponse, item: CacheableItem, ttl: Double) {
        self.timeTable[item] = Date().timeIntervalSince1970 + ttl
        self.storage[item] = response
    }

    func get(item: CacheableItem) -> DiscordHTTPResponse? {
        if let time = self.timeTable[item] {
            if time > Date().timeIntervalSince1970 {
                return storage[item]
            } else {
                self.timeTable[item] = nil
                self.storage[item] = nil
                return nil
            }
        } else {
            return nil
        }
    }

    private func collectGarbage() async {
        /// Quit in case of task cancelation.
        guard (try? await Task.sleep(for: .seconds(60))) != nil else { return }
        let now = Date().timeIntervalSince1970
        for (item, expirationDate) in self.timeTable {
            if expirationDate < now {
                self.timeTable[item] = nil
                self.storage[item] = nil
            }
        }
        await collectGarbage()
    }
}

// MARK: - ClientCacheStorage

actor ClientCacheStorage {

    /// [Token: ClientCache]
    private var storage = [String: ClientCache]()
    private var noAuth: ClientCache? = nil

    private init() { }

    static let shared = ClientCacheStorage()

    func cache(for authenticationHeader: AuthenticationHeader) -> ClientCache {
        if let id = authenticationHeader.id {
            if let cache = self.storage[id] {
                return cache
            } else {
                let cache = ClientCache()
                self.storage[id] = cache
                return cache
            }
        } else {
            if let noAuth {
                return noAuth
            } else {
                self.noAuth = .init()
                return self.noAuth!
            }
        }
    }
}
