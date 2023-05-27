import DiscordModels
import Foundation
import AsyncHTTPClient
import Logging
import NIOHTTP1
import NIOCore
import Atomics

/// The fact that this could be used by multiple different `DiscordClient`s with
/// different `token`s should not matter because buckets are random anyway.
private let rateLimiter = HTTPRateLimiter(label: "DiscordClientRateLimiter")

public struct DefaultDiscordClient: DiscordClient {
    public let client: HTTPClient
    public let authentication: AuthenticationHeader
    public let appId: ApplicationSnowflake?
    public let configuration: ClientConfiguration
    public let logger = DiscordGlobalConfiguration.makeLogger("DefaultDiscordClient")
    /// Discord apparently looks at this for figuring out library-usages.
    /// Technically they could also look at the info passed in Gateway's identify payload, for that.
    /// From what I've figured, if Discord sees a lot of people are using the same library, they
    /// will contact the owner and add the library to the list of suggested libraries on their website.
    public let userAgent = "DiscordBM (https://github.com/mahdibm/discordbm, 1.0.0)"

    /// Use `getCache()` to get the appropriate cache.

    /// The cache used for requests that require an auth header.
    let _authCache: ClientCache
    
    private static let requestIdGenerator = ManagedAtomic(UInt(0))

    /// `token` must be a bot token.
    public init(
        httpClient: HTTPClient,
        token: Secret,
        appId: ApplicationSnowflake? = nil,
        configuration: ClientConfiguration = .init()
    ) async {
        self.client = httpClient
        self.authentication = .botToken(token)
        self.appId = appId ?? self.authentication.extractAppIdIfAvailable()
        self.configuration = configuration
        self._authCache = await ClientCacheStorage.shared.cache(for: self.authentication)
    }

    /// `token` must be a bot token.
    public init(
        httpClient: HTTPClient,
        token: String,
        appId: ApplicationSnowflake? = nil,
        configuration: ClientConfiguration = .init()
    ) async {
        self.client = httpClient
        self.authentication = .botToken(Secret(token))
        self.appId = appId ?? self.authentication.extractAppIdIfAvailable()
        self.configuration = configuration
        self._authCache = await ClientCacheStorage.shared.cache(for: self.authentication)
    }

    /// `oAuthToken` must be an OAuth token.
    public init(
        httpClient: HTTPClient,
        oAuthToken: Secret,
        appId: ApplicationSnowflake? = nil,
        configuration: ClientConfiguration = .init()
    ) async {
        self.client = httpClient
        self.authentication = .oAuthToken(oAuthToken)
        /// OAuth tokens don't contain an app-id to extract
        self.appId = appId
        self.configuration = configuration
        self._authCache = await ClientCacheStorage.shared.cache(for: self.authentication)
    }

    /// `oAuthToken` must be an OAuth token.
    public init(
        httpClient: HTTPClient,
        oAuthToken: String,
        appId: ApplicationSnowflake? = nil,
        configuration: ClientConfiguration = .init()
    ) async {
        self.client = httpClient
        self.authentication = .oAuthToken(Secret(oAuthToken))
        /// OAuth tokens don't contain an app-id to extract
        self.appId = appId
        self.configuration = configuration
        self._authCache = await ClientCacheStorage.shared.cache(for: self.authentication)
    }

    public init(
        httpClient: HTTPClient,
        authentication: AuthenticationHeader,
        appId: ApplicationSnowflake? = nil,
        configuration: ClientConfiguration = .init()
    ) async {
        self.client = httpClient
        self.authentication = authentication
        self.appId = appId ?? self.authentication.extractAppIdIfAvailable()
        self.configuration = configuration
        self._authCache = await ClientCacheStorage.shared.cache(for: self.authentication)
    }

    @usableFromInline
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
                try await Task.sleep(for: .nanoseconds(nanos))
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

    @usableFromInline
    func includeInRateLimits(
        endpoint: AnyEndpoint,
        headers: HTTPHeaders,
        status: HTTPResponseStatus
    ) async {
        await rateLimiter.include(endpoint: endpoint, headers: headers, status: status)
    }

    @usableFromInline
    func getFromCache(
        identity: CacheableEndpointIdentity?,
        requiresAuthHeader: Bool,
        parameters: [String],
        queries: [(String, String?)]
    ) async -> DiscordHTTPResponse? {
        /// Since the `ClientCache` is shared and another `DiscordClient` could have
        /// had added a response to it, at least make sure that this
        /// `DiscordClient` should be using any caching at all for the endpoint.
        guard let identity,
              self.configuration.cachingBehavior.getTTL(for: identity) != nil
        else { return nil }
        return await self.getCache(
            requiresAuthHeader: requiresAuthHeader
        ).get(item: .init(
            identity: identity,
            parameters: parameters,
            queries: queries
        ))
    }
    
    func saveInCache(
        response: DiscordHTTPResponse,
        identity: CacheableEndpointIdentity?,
        requiresAuthHeader: Bool,
        parameters: [String],
        queries: [(String, String?)]
    ) async {
        guard let identity,
              (200..<300).contains(response.status.code),
              let ttl = self.configuration.cachingBehavior.getTTL(for: identity)
        else { return }
        await self.getCache(requiresAuthHeader: requiresAuthHeader).add(
            response: response,
            item: .init(
                identity: identity,
                parameters: parameters,
                queries: queries
            ), ttl: ttl
        )
        logger.debug("Saved response in cache", metadata: [
            "endpointIdentity": .stringConvertible(identity),
            "queries": .stringConvertible(queries)
        ])
    }

    @usableFromInline
    func execute(_ request: HTTPClient.Request) async throws -> DiscordHTTPResponse {
        DiscordHTTPResponse(
            _response: try await self.client.execute(
                request: request,
                deadline: .now() + configuration.requestTimeoutAmount,
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
            try await Task.sleep(for: .nanoseconds(UInt64(retryWait * 1_000_000_000)))
        }
        retriesSoFar += 1
        logger.trace("Will retry a request right now", metadata: [
            "request-id": .stringConvertible(requestId),
            "retriesWithoutThis": .stringConvertible(retriesSoFar)
        ])
    }

    /// Returns an appropriate `ClientCache`.
    func getCache(requiresAuthHeader: Bool) -> ClientCache {
        if requiresAuthHeader {
            return self._authCache
        } else {
            return .global
        }
    }

    /// Sends requests and retries if needed.
    @usableFromInline
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
                requiresAuthHeader: req.endpoint.requiresAuthorizationHeader,
                parameters: req.endpoint.parameters,
                queries: req.queries
            )
        }
        
        return response
    }

    @inlinable
    public func send(request req: DiscordHTTPRequest) async throws -> DiscordHTTPResponse {
        try await self.sendWithRetries(request: req) {
            identity, retryCounter, requestId in
            
            if let cached = await self.getFromCache(
                identity: identity,
                requiresAuthHeader: req.endpoint.requiresAuthorizationHeader,
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
                try self.authentication.addHeader(headers: &request.headers, request: req)
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
                requiresAuthHeader: req.endpoint.requiresAuthorizationHeader,
                parameters: req.endpoint.parameters,
                queries: req.queries
            ) {
                return (cached, true)
            }
            if let cached = await self.getFromCache(
                identity: identity,
                requiresAuthHeader: req.endpoint.requiresAuthorizationHeader,
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
                try self.authentication.addHeader(headers: &request.headers, request: req)
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
                requiresAuthHeader: req.endpoint.requiresAuthorizationHeader,
                parameters: req.endpoint.parameters,
                queries: req.queries
            ) {
                return (cached, true)
            }
            if let cached = await self.getFromCache(
                identity: identity,
                requiresAuthHeader: req.endpoint.requiresAuthorizationHeader,
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
                contentType = "multipart/form-data; boundary=\(MultipartConfiguration.boundary)"
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
                try self.authentication.addHeader(headers: &request.headers, request: req)
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
