import Foundation
import NIOCore
import NIOHTTP1

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
        var looseEndpointsTTL: Double?

        init(
            apiEndpointsStorage: [CacheableAPIEndpointIdentity: Double] = [:],
            cdnEndpointsStorage: [CDNEndpointIdentity: Double] = [:],
            apiEndpointsDefaultTTL: Double? = nil,
            cdnEndpointsDefaultTTL: Double? = nil,
            looseEndpointsTTL: Double? = nil
        ) {
            self.apiEndpointsStorage = apiEndpointsStorage
            self.cdnEndpointsStorage = cdnEndpointsStorage
            self.apiEndpointsDefaultTTL = apiEndpointsDefaultTTL
            self.cdnEndpointsDefaultTTL = cdnEndpointsDefaultTTL
            self.looseEndpointsTTL = looseEndpointsTTL

            /// Necessary for `BotGatewayManager`.
            /// Users realistically shouldn't need to call these endpoints anyway.
            /// Even if they do want to call these endpoints, the value Discord sends is
            /// already cached value, so this caching behavior shouldn't cause any problems.
            self.apiEndpointsStorage.updateValue(120, forKey: .getGateway)
            self.apiEndpointsStorage.updateValue(120, forKey: .getBotGateway)
        }

        /// Uses the TTL in the 'endpoints'. If not available, falls back to `defaultTTL`.
        /// Setting TTL to `0` in endpoints, disables caching for that endpoint.
        /// NOTE: Caching behavior for `getGateway` and `getBotGateway` api endpoints
        /// can't be modified by users.
        public static func custom(
            apiEndpoints: [CacheableAPIEndpointIdentity: Double] = [:],
            cdnEndpoints: [CDNEndpointIdentity: Double] = [:],
            apiEndpointsDefaultTTL: Double? = 5,
            cdnEndpointsDefaultTTL: Double? = nil,
            looseEndpointsTTL: Double? = nil
        ) -> CachingBehavior {
            CachingBehavior(
                apiEndpointsStorage: apiEndpoints,
                cdnEndpointsStorage: cdnEndpoints,
                apiEndpointsDefaultTTL: apiEndpointsDefaultTTL,
                cdnEndpointsDefaultTTL: cdnEndpointsDefaultTTL
            )
        }

        /// Caches all cacheable endpoints for 5 seconds,
        /// except for `getGateway` which is cached for an hour.
        public static var enabled: CachingBehavior {
            CachingBehavior.enabled(defaultTTL: 5)
        }

        /// Caches all cacheable API endpoints for the entered seconds,
        /// Doesn't cache CDN endpoints.
        public static func enabled(defaultTTL: Double) -> CachingBehavior {
            CachingBehavior.custom(apiEndpointsDefaultTTL: defaultTTL)
        }

        /// Doesn't allow caching at all.
        public static var disabled: CachingBehavior {
            CachingBehavior()
        }

        @inlinable
        func getTTL(for identity: CacheableEndpointIdentity) -> Double? {
            switch identity {
            case let .api(cacheableAPIEndpointIdentity):
                guard let ttl = self.apiEndpointsStorage[cacheableAPIEndpointIdentity]
                else { return self.apiEndpointsDefaultTTL }
                return ttl == 0 ? nil : ttl
            case let .cdn(cdnEndpointIdentity):
                guard let ttl = self.cdnEndpointsStorage[cdnEndpointIdentity]
                else { return self.cdnEndpointsDefaultTTL }
                return ttl == 0 ? nil : ttl
            case .loose:
                return self.looseEndpointsTTL
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
            @inlinable
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
        @usableFromInline
        func shouldRetry(status: HTTPResponseStatus, retriesSoFar times: Int) -> Bool {
            self.maxRetries > times && self.statuses.contains(status)
        }
    }

    /// The behavior used for caching requests.
    /// Due to how it works, you shouldn't use `CachingBehavior`s
    /// with different TTLs for the same bot-token.
    public let cachingBehavior: CachingBehavior
    var requestTimeoutAmount: TimeAmount
    /// How much for the `HTTPClient` to wait for a connection before failing.
    public var requestTimeout: Duration {
        get {
            .nanoseconds(self.requestTimeoutAmount.nanoseconds)
        }
        set {
            let comps = newValue.components
            let seconds = comps.seconds * 1_000_000_000
            let attos = comps.attoseconds / 1_000_000_000
            let nanos = seconds + attos
            self.requestTimeoutAmount = .nanoseconds(nanos)
        }
    }
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

    @inlinable
    func shouldRetry(status: HTTPResponseStatus, retriesSoFar times: Int) -> Bool {
        self.retryPolicy?.shouldRetry(status: status, retriesSoFar: times) ?? false
    }

    /// Returns the amount of time that the client should wait before the next retry, if any.
    @inlinable
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
        requestTimeout: Duration = .seconds(30),
        enableLoggingForRequests: Bool = false,
        retryPolicy: RetryPolicy? = .default,
        performValidations: Bool = true
    ) {
        self.cachingBehavior = cachingBehavior
        self.enableLoggingForRequests = enableLoggingForRequests
        self.retryPolicy = retryPolicy
        self.performValidations = performValidations

        self.requestTimeoutAmount = .zero
        self.requestTimeout = requestTimeout
    }
}

//MARK: +HTTPHeaders
extension HTTPHeaders {
    @inlinable
    func resetOrRetryAfterHeaderValue() -> String? {
        self.first(name: "x-ratelimit-reset-after") ?? self.first(name: "retry-after")
    }
}
