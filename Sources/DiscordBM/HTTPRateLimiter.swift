import struct Foundation.Date
import NIOHTTP1

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
    private var endpoints: [String: String] = [:]
    
    /// [Bucket-ID: Bucket]
    private var buckets: [String: Bucket] = [:]
    
    /// To take care of the global rate limit.
    private var requestsThisSecond: (second: Int, count: Int) = (0, 0)
    
    init(label: String) {
        self.label = label
    }
    
    private func globalRateLimitAllows() -> Bool {
        let now = Int(Date().timeIntervalSince1970)
        if self.requestsThisSecond.second == now {
            if self.requestsThisSecond.count >= DiscordGlobalConfiguration.globalRateLimit {
                logger.warning("Hit HTTP Global Rate-Limit.", metadata: [
                    "label": .string(label)
                ])
                return false
            } else {
                self.requestsThisSecond = (now, self.requestsThisSecond.count + 1)
                return true
            }
        } else {
            self.requestsThisSecond = (now, 1)
            return true
        }
    }
    
    func canRequest(to endpointId: String) -> Bool {
        guard globalRateLimitAllows() else { return false }
        if let bucketId = self.endpoints[endpointId],
           let bucket = self.buckets[bucketId] {
            if bucket.canRequest() {
                return true
            } else {
                logger.warning("Hit HTTP Bucket Rate-Limit.", metadata: [
                    "label": .string(label),
                    "endpointId": .string(endpointId),
                    "bucket": .stringConvertible(bucket)
                ])
                return false
            }
        } else {
            return true
        }
    }
    
    func include(endpointId: String, headers: HTTPHeaders) {
        guard let newBucket = Bucket(from: headers) else { return }
        if !(self.endpoints[endpointId] == newBucket.bucket) {
            self.endpoints[endpointId] = newBucket.bucket
        }
        self.buckets[newBucket.bucket] = newBucket
    }
}
