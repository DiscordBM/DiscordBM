import struct Foundation.Date
import NIOConcurrencyHelpers
import NIOHTTP1

final class HTTPRateLimiter {
    
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
    
    private static let logger = DiscordGlobalConfiguration.makeLogger("HTTPRateLimiter")
    
    /// [Endpoint-ID: Bucket-ID]
    private var endpoints: [String: String] = [:]
    
    /// [Bucket-ID: Bucket]
    private var buckets: [String: Bucket] = [:]
    
    private let lock = Lock()
    
    init(label: String) {
        self.label = label
    }
    
    func canRequest(to endpointId: String) -> Bool {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        if let bucketId = self.endpoints[endpointId],
           let bucket = self.buckets[bucketId] {
            if bucket.canRequest() {
                return true
            } else {
                Self.logger.warning("Hit HTTP Rate-Limit.", metadata: [
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
        
        self.lock.lock()
        defer { self.lock.unlock() }
        
        if !(self.endpoints[endpointId] == newBucket.bucket) {
            self.endpoints[endpointId] = newBucket.bucket
        }
        self.buckets[newBucket.bucket] = newBucket
    }
}
