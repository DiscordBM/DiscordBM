import DiscordModels
import Foundation
import AsyncHTTPClient
import Logging
import struct NIOPosix.NIOConnectionError
import NIOConcurrencyHelpers
import NIOHTTP1
import NIOCore
import Atomics

/// The fact that this could be used by multiple different `DiscordClient`s with
/// different `token`s should not matter because buckets are random anyway.
private let rateLimiter = HTTPRateLimiter(label: "DiscordClientRateLimiter")

//MARK: - DefaultDiscordClient
public struct DefaultDiscordClient: Sendable, DiscordClient {
    
    let client: HTTPClient
    public let token: Secret
    public let appId: ApplicationSnowflake?
    let configuration: ClientConfiguration
    let cache: ClientCache?
    let logger = DiscordGlobalConfiguration.makeLogger("DefaultDiscordClient")
    
    private static let requestIdGenerator = ManagedAtomic(UInt(0))
    
    /// If you provide no app id, you'll need to pass it to some functions on call site.
    public init(
        httpClient: HTTPClient,
        token: Secret,
        appId: ApplicationSnowflake?,
        configuration: ClientConfiguration = .init()
    ) {
        self.client = httpClient
        self.token = token
        self.appId = appId
        self.configuration = configuration
        if configuration.cachingBehavior.isDisabled {
            self.cache = nil
        } else {
            /// So each token has its own cache, because
            /// answers might be different for different tokens.
            self.cache = ClientCacheStorage.shared.cache(for: token)
        }
    }
    
    /// If you provide no app id, you'll need to pass it to some functions on call site.
    public init(
        httpClient: HTTPClient,
        token: String,
        appId: ApplicationSnowflake?,
        configuration: ClientConfiguration = .init()
    ) {
        self.init(
            httpClient: httpClient,
            token: Secret(token),
            appId: appId,
            configuration: configuration
        )
    }

    func checkRateLimitsAllowRequest(
        to endpoint: AnyEndpoint,
        requestId: UInt,
        retriesSoFar: Int
    ) async throws {
        switch await rateLimiter.shouldRequest(to: endpoint) {
        case .true: return
        case .false:
            /// `HTTPRateLimiter` already logs this.
            throw DiscordHTTPError.rateLimited(url: "\(endpoint.urlDescription)")
        case let .after(after):
            /// If we make the request, we'll get 429-ed. So we can just assume the status is 429.
            if self.configuration.shouldRetry(
                status: .tooManyRequests,
                retriesSoFar: retriesSoFar
            ) {
                logger.debug(
                    "HTTP bucket is exhausted. Will wait before making the request",
                    metadata: [
                        "wait-time": .stringConvertible(after),
                        "retriesWithoutThis": .stringConvertible(retriesSoFar),
                        "endpoint": .stringConvertible(endpoint.urlDescription),
                        "request-id": .stringConvertible(requestId)
                    ]
                )
                let nanos = UInt64(after * 1_000_000_000)
                try await Task.sleep(nanoseconds: nanos)
                await rateLimiter.addGlobalRateLimitRecord()
            } else {
                logger.warning(
                    "HTTP bucket is exhausted. Retry policy does not allow retry",
                    metadata: [
                        "solution": "Make requests slower or increase 'configuration.retryPolicy.backoff.basedOnHeaders.maxAllowed'",
                        "wait-time": .stringConvertible(after),
                        "retriesWithoutThis": .stringConvertible(retriesSoFar),
                        "endpoint": .stringConvertible(endpoint.urlDescription),
                        "request-id": .stringConvertible(requestId)
                    ]
                )
                throw DiscordHTTPError.rateLimited(url: "\(endpoint.urlDescription)")
            }
        }
    }
    
    func includeInRateLimits(
        endpoint: AnyEndpoint,
        headers: HTTPHeaders,
        status: HTTPResponseStatus
    ) async {
        await rateLimiter.include(endpoint: endpoint, headers: headers, status: status)
    }
    
    func getFromCache(
        identity: CacheableEndpointIdentity?,
        parameters: [String],
        queries: [(String, String?)]
    ) async -> DiscordHTTPResponse? {
        /// Since the `ClientCache` is shared and another `DiscordClient` could have
        /// had added a response to it, at least make sure that this
        /// `DiscordClient` should be using any caching at all for the endpoint.
        guard let identity,
              self.configuration.cachingBehavior.getTTL(for: identity) != nil
        else { return nil }
        return await cache?.get(item: .init(
            identity: identity,
            parameters: parameters,
            queries: queries
        ))
    }
    
    func saveInCache(
        response: DiscordHTTPResponse,
        identity: CacheableEndpointIdentity?,
        parameters: [String],
        queries: [(String, String?)]
    ) async {
        guard let identity,
              (200..<300).contains(response.status.code),
              let ttl = self.configuration.cachingBehavior.getTTL(for: identity)
        else { return }
        if let cache {
            logger.debug("Saved response in cache", metadata: [
                "endpointIdentity": .stringConvertible(identity),
                "queries": .stringConvertible(queries)
            ])
            await cache.add(
                response: response,
                item: .init(
                    identity: identity,
                    parameters: parameters,
                    queries: queries
                ), ttl: ttl
            )
        }
    }
    
    func execute(_ request: HTTPClient.Request) async throws -> DiscordHTTPResponse {
        DiscordHTTPResponse(
            _response: try await self.client.execute(
                request: request,
                deadline: .now() + configuration.requestTimeout,
                logger: configuration.enableLoggingForRequests
                ? DiscordGlobalConfiguration.makeLogger("DBM+HTTPClient")
                : Logger(label: "DBM-no-op-logger", factory: SwiftLogNoOpLogHandler.init)
            ).get()
        )
    }
    
    /// Waits for the next retry if needed, and increases the retry counter.
    func waitForRetryAndIncreaseRetryCount(
        retriesSoFar: inout Int,
        headers: HTTPHeaders,
        requestId: UInt
    ) async throws {
        let retryWait = self.configuration.waitTimeBeforeRetry(
            retriesSoFar: retriesSoFar,
            headers: headers
        )
        logger.debug("Will soon retry a request", metadata: [
            "request-id": .stringConvertible(requestId),
            "retriesWithoutThis": .stringConvertible(retriesSoFar),
            "waitSecondsBeforeRetry": .stringConvertible(retryWait ?? 0)
        ])
        if let retryWait {
            try await Task.sleep(nanoseconds: UInt64(retryWait * 1_000_000_000))
        }
        retriesSoFar += 1
        logger.trace("Will retry a request right now", metadata: [
            "request-id": .stringConvertible(requestId),
            "retriesWithoutThis": .stringConvertible(retriesSoFar)
        ])
    }
    
    /// Sends requests and retries if needed.
    func sendWithRetries(
        request req: DiscordHTTPRequest,
        sendRequest: (CacheableEndpointIdentity?, Int, UInt) async throws -> (DiscordHTTPResponse, Bool)
    ) async throws -> DiscordHTTPResponse {
        
        let identity = CacheableEndpointIdentity(endpoint: req.endpoint)
        let requestId = Self.requestIdGenerator.wrappingIncrementThenLoad(ordering: .relaxed)
        
        var retriesSoFar = 0
        var (response, cached) = try await sendRequest(identity, retriesSoFar, requestId)
        
        while configuration.shouldRetry(status: response.status, retriesSoFar: retriesSoFar) {
            try await waitForRetryAndIncreaseRetryCount(
                retriesSoFar: &retriesSoFar,
                headers: response.headers,
                requestId: requestId
            )
            (response, cached) = try await sendRequest(identity, retriesSoFar, requestId)
        }
        
        if !cached {
            await self.saveInCache(
                response: response,
                identity: identity,
                parameters: req.endpoint.parameters,
                queries: req.queries
            )
        }
        
        return response
    }
    
    public func send(request req: DiscordHTTPRequest) async throws -> DiscordHTTPResponse {
        try await self.sendWithRetries(request: req) {
            identity, retryCounter, requestId in
            
            if let cached = await self.getFromCache(
                identity: identity,
                parameters: req.endpoint.parameters,
                queries: req.queries
            ) {
                logger.debug("Got cached response", metadata: [
                    "endpoint": .string(req.endpoint.urlDescription),
                    "queries": .stringConvertible(req.queries),
                    "retry": .stringConvertible(retryCounter)
                ])
                return (cached, true)
            }
            
            try await self.checkRateLimitsAllowRequest(
                to: req.endpoint,
                requestId: requestId,
                retriesSoFar: retryCounter
            )
            var request = try HTTPClient.Request(
                url: req.endpoint.url + req.queries.makeForURLQuery(),
                method: req.endpoint.httpMethod
            )
            request.headers = req.headers
            request.headers.add(name: "User-Agent", value: userAgent)
            if req.endpoint.requiresAuthorizationHeader {
                request.headers.replaceOrAdd(name: "Authorization", value: "Bot \(token.value)")
            }
            
            logger.debug("Will send a request to Discord", metadata: [
                "url": .stringConvertible(
                    req.endpoint.urlDescription + req.queries.makeForURLQuery()
                ),
                "method": .string(request.method.rawValue),
                "retry": .stringConvertible(retryCounter),
                "request-id": .stringConvertible(requestId)
            ])
            let response = try await self.execute(request)
            logger.debug("Received a response from Discord", metadata: [
                "response": .stringConvertible(response),
                "retry": .stringConvertible(retryCounter),
                "request-id": .stringConvertible(requestId)
            ])
            
            await self.includeInRateLimits(
                endpoint: req.endpoint,
                headers: response.headers,
                status: response.status
            )
            
            return (response, false)
        }
    }
    
    public func send<E: Sendable & Encodable & ValidatablePayload>(
        request req: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordHTTPResponse {
        if configuration.performValidations {
            try payload.validate().throw(model: payload)
        }
        
        return try await self.sendWithRetries(request: req) {
            identity, retryCounter, requestId in
            
            let identity = CacheableEndpointIdentity(endpoint: req.endpoint)
            if let cached = await self.getFromCache(
                identity: identity,
                parameters: req.endpoint.parameters,
                queries: req.queries
            ) {
                return (cached, true)
            }
            if let cached = await self.getFromCache(
                identity: identity,
                parameters: req.endpoint.parameters,
                queries: req.queries
            ) {
                logger.debug("Got cached response", metadata: [
                    "endpoint": .string(req.endpoint.urlDescription),
                    "queries": .stringConvertible(req.queries),
                    "retry": .stringConvertible(retryCounter)
                ])
                return (cached, true)
            }
            
            try await self.checkRateLimitsAllowRequest(
                to: req.endpoint,
                requestId: requestId,
                retriesSoFar: retryCounter
            )
            
            let data = try DiscordGlobalConfiguration.encoder.encode(payload)
            var request = try HTTPClient.Request(
                url: req.endpoint.url + req.queries.makeForURLQuery(),
                method: req.endpoint.httpMethod
            )
            request.headers = req.headers
            request.headers.add(name: "User-Agent", value: userAgent)
            request.headers.replaceOrAdd(name: "Content-Type", value: "application/json")
            if req.endpoint.requiresAuthorizationHeader {
                request.headers.replaceOrAdd(name: "Authorization", value: "Bot \(token.value)")
            }
            
            request.body = .bytes(data)
            
            logger.debug("Will send a request to Discord", metadata: [
                "body": .string(String(data: data, encoding: .utf8) ?? "nil"),
                "url": .stringConvertible(
                    req.endpoint.urlDescription + req.queries.makeForURLQuery()
                ),
                "method": .string(request.method.rawValue),
                "retry": .stringConvertible(retryCounter),
                "request-id": .stringConvertible(requestId)
            ])
            let response = try await self.execute(request)
            logger.debug("Received a response from Discord", metadata: [
                "response": .stringConvertible(response),
                "retry": .stringConvertible(retryCounter),
                "request-id": .stringConvertible(requestId)
            ])
            
            await self.includeInRateLimits(
                endpoint: req.endpoint,
                headers: response.headers,
                status: response.status
            )
            
            return (response, false)
        }
    }
    
    public func sendMultipart<E: Sendable & MultipartEncodable & ValidatablePayload>(
        request req: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordHTTPResponse {
        if configuration.performValidations {
            try payload.validate().throw(model: payload)
        }
        
        return try await self.sendWithRetries(request: req) {
            identity, retryCounter, requestId in
            
            let identity = CacheableEndpointIdentity(endpoint: req.endpoint)
            if let cached = await self.getFromCache(
                identity: identity,
                parameters: req.endpoint.parameters,
                queries: req.queries
            ) {
                return (cached, true)
            }
            if let cached = await self.getFromCache(
                identity: identity,
                parameters: req.endpoint.parameters,
                queries: req.queries
            ) {
                logger.debug("Got cached response", metadata: [
                    "endpoint": .string(req.endpoint.urlDescription),
                    "queries": .stringConvertible(req.queries),
                    "retry": .stringConvertible(retryCounter)
                ])
                return (cached, true)
            }
            
            try await self.checkRateLimitsAllowRequest(
                to: req.endpoint,
                requestId: requestId,
                retriesSoFar: retryCounter
            )

            let contentType: String
            let buffer: ByteBuffer
            if let multipart = try payload.encodeMultipart() {
                contentType = "multipart/form-data; boundary=\(MultipartEncodingContainer.boundary)"
                buffer = multipart
            } else {
                contentType = "application/json"
                buffer = ByteBuffer(data: try DiscordGlobalConfiguration.encoder.encode(payload))
            }
            var request = try HTTPClient.Request(
                url: req.endpoint.url + req.queries.makeForURLQuery(),
                method: req.endpoint.httpMethod
            )
            request.headers = req.headers
            request.headers.add(name: "User-Agent", value: userAgent)
            request.headers.replaceOrAdd(name: "Content-Type", value: contentType)
            if req.endpoint.requiresAuthorizationHeader {
                request.headers.replaceOrAdd(name: "Authorization", value: "Bot \(token.value)")
            }
            
            request.body = .byteBuffer(buffer)
            
            logger.debug("Will send a request to Discord", metadata: [
                "body": .string(String(buffer: buffer)),
                "url": .stringConvertible(
                    req.endpoint.urlDescription + req.queries.makeForURLQuery()
                ),
                "method": .string(request.method.rawValue),
                "retry": .stringConvertible(retryCounter),
                "request-id": .stringConvertible(requestId)
            ])
            let response = try await self.execute(request)
            logger.debug("Received a response from Discord", metadata: [
                "response": .stringConvertible(response),
                "retry": .stringConvertible(retryCounter),
                "request-id": .stringConvertible(requestId)
            ])
            
            await self.includeInRateLimits(
                endpoint: req.endpoint,
                headers: response.headers,
                status: response.status
            )
            
            return (response, false)
        }
    }
}

//MARK: - ClientConfiguration

/// The configuration of `DefaultDiscordClient`.
public struct ClientConfiguration: Sendable {

    /// How to cache Discord API responses.
    public struct CachingBehavior: Sendable {
        
        /// [ID: TTL]
        @usableFromInline
        var apiEndpointsStorage = [CacheableAPIEndpointIdentity: Double]()
        /// [ID: TTL]
        @usableFromInline
        var cdnEndpointsStorage = [CDNEndpointIdentity: Double]()
        /// This instance's default TTL (Time-To-Live) for API endpoints.
        @usableFromInline
        var apiEndpointsDefaultTTL: Double?
        /// This instance's default TTL (Time-To-Live) for CDN endpoints.
        @usableFromInline
        var cdnEndpointsDefaultTTL: Double?
        @usableFromInline
        var isDisabled: Bool
        
        /// Uses the TTL in the `endpoints`. If not available, falls back to `defaultTTL`.
        /// Setting TTL to `0` in endpoints, disables caching for that endpoint.
        public static func custom(
            apiEndpoints: [CacheableAPIEndpointIdentity: Double] = [:],
            cdnEndpoints: [CDNEndpointIdentity: Double] = [:],
            apiEndpointsDefaultTTL: Double? = 5,
            cdnEndpointsDefaultTTL: Double? = nil
        ) -> CachingBehavior {
            CachingBehavior(
                apiEndpointsStorage: apiEndpoints,
                cdnEndpointsStorage: cdnEndpoints,
                apiEndpointsDefaultTTL: apiEndpointsDefaultTTL,
                cdnEndpointsDefaultTTL: cdnEndpointsDefaultTTL,
                isDisabled: false
            )
        }
        
        /// Caches all cacheable endpoints for 5 seconds,
        /// except for `getGateway` which is cached for an hour.
        public static var enabled: CachingBehavior {
            CachingBehavior.enabled(defaultTTL: 5)
        }
        
        /// Caches all cacheable API endpoints for the entered seconds,
        /// except for `getGateway` which is cached for an hour.
        /// Doesn't cache CDN endpoints.
        public static func enabled(defaultTTL: Double) -> CachingBehavior {
            CachingBehavior.custom(apiEndpointsDefaultTTL: defaultTTL)
        }
        
        /// Doesn't allow caching at all.
        public static var disabled: CachingBehavior {
            CachingBehavior(isDisabled: true)
        }
        
        @inlinable
        func getTTL(for identity: CacheableEndpointIdentity) -> Double? {
            if self.isDisabled { return nil }
            switch identity {
            case let .api(cacheableAPIEndpointIdentity):
                guard let ttl = self.apiEndpointsStorage[cacheableAPIEndpointIdentity]
                else { return self.apiEndpointsDefaultTTL }
                return ttl == 0 ? nil : ttl
            case let .cdn(cdnEndpointIdentity):
                guard let ttl = self.cdnEndpointsStorage[cdnEndpointIdentity]
                else { return self.cdnEndpointsDefaultTTL }
                return ttl == 0 ? nil : ttl
            }
        }
    }

    /// The policy to retry failed requests with.
    public struct RetryPolicy: Sendable {

        /// The backoff to apply before retrying failed requests.
        public indirect enum Backoff: Sendable {
            /// How many seconds.
            case constant(Double)
            /// `upToTimes` indicates how many times at maximum this should linearly increase
            /// the backoff. Does not indicate how many times the retrial will happen.
            /// Assuming `backoff = a + bx` is the linear equation, then: `a == base`, `b == coefficient`.
            /// `base` and `coefficient` are in seconds.
            /// `upToTimes` starts from `1` and will be compared to the # of the retry.
            case linear(
                base: Double = 0,
                coefficient: Double,
                upToTimes: UInt = .max
            )
            /// `upToTimes` indicates how many times at maximum this should linearly increase
            /// the backoff. Does not indicate how many times the retrial will happen.
            /// Assuming `backoff = a + b(c^x)` is the exponential equation, then: `a == base`, `b == coefficient`, `c == rate`.
            /// Make sure to keep `rate` above `1`.
            /// `base` and `rate` are in seconds.
            /// `upToTimes` starts from `1` and will be compared to the # of the retry.
            case exponential(
                base: Double = 0,
                coefficient: Double = 1,
                rate: Double = 2,
                upToTimes: UInt = .max
            )
            /// Based on the `x-ratelimit-reset-after` or the `Retry-After` header.
            ///
            /// Parameters:
            /// - `maxAllowed`: Max allowed amount in `Retry-After`. In seconds.
            /// - `retryIfGreater`: Retry or not, even if the header time is greater than
            ///  `maxAllowed`. If yes, the retry will happen after `maxAllowed` amount of time.
            /// - `else`: If the `Retry-After` header did not exist.
            ///
            /// NOTE: If `429 Too Many Requests` is included in the statuses list of `RetryPolicy`,
            /// the `DefaultDiscordClient` can use `Backoff.basedOnHeaders` to try to recover from
            /// request failures related to HTTP bucket exhaustion.
            case basedOnHeaders(
                maxAllowed: Double?,
                retryIfGreater: Bool = false,
                else: Backoff? = nil
            )
            
            public static var `default`: Backoff {
                .basedOnHeaders(
                    maxAllowed: 5,
                    retryIfGreater: false,
                    else: .exponential(base: 0.2, coefficient: 0.5, rate: 2, upToTimes: 10)
                )
            }
            
            /// Returns the time needed to wait before the next retry, if any.
            func waitTimeBeforeRetry(retriesSoFar: Int, headers: HTTPHeaders) -> Double? {
                switch self {
                case let .constant(constant):
                    return constant
                case let .linear(base, coefficient, upToTimes):
                    let times = retriesSoFar + 1
                    let multiplyFactor = min(Int(upToTimes), times)
                    let time = coefficient * Double(multiplyFactor) + base
                    return time
                case let .exponential(base, coefficient, rate, upToTimes):
                    let times = retriesSoFar + 1
                    let exponent = min(Int(upToTimes), times)
                    let time = base + coefficient * pow(rate, Double(exponent))
                    return time
                case let .basedOnHeaders(maxAllowed, retryIfGreater, elseBackoff):
                    if let header = headers.resetOrRetryAfterHeaderValue(),
                       let retryAfter = Double(header) {
                        if retryAfter <= (maxAllowed ?? 0) {
                            return retryAfter
                        } else {
                            if retryIfGreater {
                                return maxAllowed
                            } else {
                                return nil
                            }
                        }
                    } else {
                        return elseBackoff?.waitTimeBeforeRetry(
                            retriesSoFar: retriesSoFar,
                            headers: headers
                        )
                    }
                }
            }
        }
        
        private var _statuses: Set<HTTPResponseStatus>
        
        public var statuses: Set<HTTPResponseStatus> {
            get { self._statuses }
            set {
#if DEBUG
                precondition(
                    newValue.allSatisfy({ $0.code >= 400 }),
                    "Status codes less than 400 don't need retrying. This could cause problems"
                )
                self._statuses = newValue
#else
                self._statuses = newValue.filter({ $0.code >= 400 })
#endif
            }
        }
        
        /// Max amount of times to retry any eligible request.
        public var maxRetries: Int
        
        /// The backoff configuration, to wait a some amount of time _after_ a failed request.
        /// Default to `.default`.
        public var backoff: Backoff?
        
        /// Only retries status code 429, 500 and 502, and only once.
        @inlinable
        public static var `default`: RetryPolicy {
            RetryPolicy()
        }
        
        /// - Parameters:
        ///   - statuses: The statuses to be retried. Only 400+ statuses are allowed.
        ///   - maxRetries: Maximum times to retry a failed request.
        ///   - backoff: The backoff configuration, to wait a some amount of time
        ///   _after_ a failed request.
        public init(
            statuses: Set<HTTPResponseStatus> = [.tooManyRequests, .internalServerError, .badGateway],
            maxRetries: Int = 1,
            backoff: Backoff? = .default
        ) {
            self.maxRetries = maxRetries
            self.backoff = backoff
            self._statuses = []
            /// To trigger the checks
            self.statuses = statuses
        }
        
        /// Should retry a request or not.
        func shouldRetry(status: HTTPResponseStatus, retriesSoFar times: Int) -> Bool {
            self.maxRetries > times && self.statuses.contains(status)
        }
    }
    
    /// The behavior used for caching requests.
    /// Due to how it works, you shouldn't use `CachingBehavior`s with different TTLs for the same bot-token.
    public let cachingBehavior: CachingBehavior
    /// How much for the `HTTPClient` to wait for a connection before failing.
    public var requestTimeout: TimeAmount
    /// Ask `HTTPClient` to log when needed. Defaults to no logging.
    public var enableLoggingForRequests: Bool
    /// Retries failed requests based on this policy.
    /// Defaults to `.default`.
    public var retryPolicy: RetryPolicy?
    /// Whether or not to perform validations for payloads, before sending.
    /// The point is to catch invalid payload without actually sending them to Discord.
    /// The library will throw a ``ValidationError`` if it finds anything invalid in the payload.
    /// This all works based on Discord docs' validation notes.
    public var performValidations: Bool
    
    func shouldRetry(status: HTTPResponseStatus, retriesSoFar times: Int) -> Bool {
        self.retryPolicy?.shouldRetry(status: status, retriesSoFar: times) ?? false
    }
    
    /// Returns the amount of time that the client should wait before the next retry, if any.
    func waitTimeBeforeRetry(retriesSoFar times: Int, headers: HTTPHeaders) -> Double? {
        switch self.retryPolicy?.backoff {
        case let .some(backoff):
            return backoff.waitTimeBeforeRetry(retriesSoFar: times, headers: headers)
        case .none:
            return nil
        }
    }
    
    /// - Parameters:
    ///   - cachingBehavior: How to cache requests. Caching is disabled by default.
    ///   - requestTimeout: How many seconds to wait for each request before timing out.
    ///   - enableLoggingForRequests: Enable AHC request-specific logging.
    ///    Normal logs are not affected.
    ///   - retryPolicy: The policy to retry failed requests with.
    ///   - performValidations: Whether or not to perform validations for payloads,
    ///    before sending. The point is to catch invalid payload without actually sending them
    ///    to Discord. The library will throw a ``ValidationError`` if it finds anything invalid
    ///    in the payload. This all works based on Discord docs' validation notes.
    public init(
        cachingBehavior: CachingBehavior = .disabled,
        requestTimeout: TimeAmount = .seconds(30),
        enableLoggingForRequests: Bool = false,
        retryPolicy: RetryPolicy? = .default,
        performValidations: Bool = true
    ) {
        self.cachingBehavior = cachingBehavior
        self.requestTimeout = requestTimeout
        self.enableLoggingForRequests = enableLoggingForRequests
        self.retryPolicy = retryPolicy
        self.performValidations = performValidations
    }
}

//MARK: - ClientCacheStorage
private final class ClientCacheStorage {
    
    /// [Token: ClientCache]
    private var storage = [String: ClientCache]()
    private let lock = NIOLock()
    
    private init() { }
    
    static let shared = ClientCacheStorage()
    
    func cache(for token: Secret) -> ClientCache {
        self.lock.lock()
        defer { self.lock.unlock() }
        let token = token.value
        if let cache = self.storage[token] {
            return cache
        } else {
            let cache = ClientCache()
            self.storage[token] = cache
            return cache
        }
    }
}

//MARK: - ClientCache

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
        guard (try? await Task.sleep(nanoseconds: 60 * 1_000_000_000)) != nil else { return }
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

//MARK: +HTTPHeaders
private extension HTTPHeaders {
    func resetOrRetryAfterHeaderValue() -> String? {
        self.first(name: "x-ratelimit-reset-after") ?? self.first(name: "retry-after")
    }
}

//MARK: User-Agent constant
private let userAgent = "DiscordBM (https://github.com/mahdibm/discordbm, 1.0.0)"
