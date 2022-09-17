import struct Foundation.Date
import NIOHTTP1
import AsyncHTTPClient

private let logger = DiscordGlobalConfiguration.makeLogger("DiscordBM.HTTPRateLimiter")

actor HTTPRateLimiter {
    
    private struct Bucket: Hashable, CustomStringConvertible {
        fileprivate var bucket: String
        private var limit: Int
        private var remaining: Int
        private var reset: Double
        private var resetAfter: Double
        
        var description: String {
            "Bucket(" +
            "bucket: \(bucket.debugDescription), " +
            "limit: \(limit), " +
            "remaining: \(remaining), " +
            "reset: \(reset.debugDescription), " +
            "resetAfter: \(resetAfter.debugDescription)" +
            ")"
        }
        
        init? (from headers: HTTPHeaders) {
            guard let bucket = headers.first(name: "x-ratelimit-bucket"),
                  let limitStr = headers.first(name: "x-ratelimit-limit"),
                  let limit = Int(limitStr),
                  let remainingStr = headers.first(name: "x-ratelimit-remaining"),
                  let remaining = Int(remainingStr),
                  let resetStr = headers.first(name: "x-ratelimit-reset"),
                  let reset = Double(resetStr),
                  let resetAfterStr = headers.first(name: "x-ratelimit-reset-after"),
                  let resetAfter = Double(resetAfterStr)
            else { return nil }
            self.bucket = bucket
            self.limit = limit
            self.remaining = remaining
            self.reset = reset
            self.resetAfter = resetAfter
        }
        
        func canRequest() -> Bool {
            if remaining > 0 {
                return true
            } else {
                let now = Date().timeIntervalSince1970
                if reset < now {
                    return true
                } else {
                    return false
                }
            }
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.bucket)
        }
        
        static func == (lhs: Bucket, rhs: Bucket) -> Bool {
            lhs.bucket == rhs.bucket
        }
    }
    
    let label: String
    
    /// [Endpoint-ID: Bucket-ID]
    private var endpoints: [Int: String] = [:]
    
    /// [Bucket-ID: Bucket]
    private var buckets: [String: Bucket] = [:]
    
    /// To take care of the global rate limit.
    private var requestsThisSecond: (id: Int, count: Int) = (0, 0)
    
    /// Only 10K invalid requests allowed each 10 minutes.
    /// We keep track of 1K / 1 minute. Even that amount of bad requests is stills way too much.
    /// Fixed 10 minute intervals, which I'm not sure if it's the correct implementation.
    private var invalidRequestsIn1Minute: (id: Int, count: Int) = (0, 0)
    
    init(label: String) {
        self.label = label
    }
    
    private func currentGlobalRateLimitId() -> Int {
        Int(Date().timeIntervalSince1970)
    }
    
    private func current1MinutelyRateLimitId() -> Int {
        Int(Date().timeIntervalSince1970) / 60
    }
    
    private func check1MinutelyInvalidRequestsLimitAllows() -> Bool {
        let oneMinutelyId = self.current1MinutelyRateLimitId()
        if invalidRequestsIn1Minute.id == oneMinutelyId,
           invalidRequestsIn1Minute.count >= 1_000 {
            logger.warning("Hit HTTP Global Invalid Requests Limit.", metadata: [
                "label": .string(label)
            ])
            return false
        } else {
            return true
        }
    }
    
    private func globalRateLimitAllowsAndAddRecord() -> Bool {
        let globalId = self.currentGlobalRateLimitId()
        if self.requestsThisSecond.id == globalId {
            if self.requestsThisSecond.count >= DiscordGlobalConfiguration.globalRateLimit {
                logger.warning("Hit HTTP Global Rate-Limit.", metadata: [
                    "label": .string(label)
                ])
                return false
            } else {
                self.requestsThisSecond.count += 1
                return true
            }
        } else {
            self.requestsThisSecond = (globalId, 1)
            return true
        }
    }
    
    func canRequest(to endpoint: Endpoint) -> Bool {
        guard endpoint.countsAgainstGlobalRateLimit,
              check1MinutelyInvalidRequestsLimitAllows(),
              globalRateLimitAllowsAndAddRecord()
        else { return false }
        if let bucketId = self.endpoints[endpoint.id],
           let bucket = self.buckets[bucketId] {
            if bucket.canRequest() {
                return true
            } else {
                logger.warning("Hit HTTP Bucket Rate-Limit.", metadata: [
                    "label": .string(label),
                    "endpointId": .stringConvertible(endpoint.id),
                    "bucket": .stringConvertible(bucket)
                ])
                return false
            }
        } else {
            return true
        }
    }
    
    func include(endpoint: Endpoint, headers: HTTPHeaders, status: HTTPResponseStatus) {
        /// Add to invalid requests limit if needed.
        if [429, 403, 401].contains(status.code) {
            let id = self.current1MinutelyRateLimitId()
            if self.invalidRequestsIn1Minute.id == id {
                self.invalidRequestsIn1Minute.count += 1
            } else {
                self.invalidRequestsIn1Minute = (id, 1)
            }
        }
        /// Take care of the rate limit headers.
        guard let newBucket = Bucket(from: headers) else { return }
        if !(self.endpoints[endpoint.id] == newBucket.bucket) {
            self.endpoints[endpoint.id] = newBucket.bucket
        }
        self.buckets[newBucket.bucket] = newBucket
    }
}
