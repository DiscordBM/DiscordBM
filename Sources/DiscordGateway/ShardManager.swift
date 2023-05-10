import DiscordModels

actor ShardManager {
    /// [BucketIndex: Continuations]
    private var waiters = [Int: [CheckedContinuation<Void, Never>]]()
    private var connectedShards = Set<Int>()

    private init() { }

    static let shared = ShardManager()

    /// Wait until the other required shards have connected.
    func waitForOtherShards(shard: IntPair, maxConcurrency: Int) async {
        let bucketIndex = shard.first / maxConcurrency
        if bucketIndex == 0 {
            return
        } else {
            /// If other shards are already connected, return immediately.
            let lastBucketIndex = bucketIndex - 1
            let start = lastBucketIndex * maxConcurrency
            let end = start + maxConcurrency
            let inBuckets = start..<end
            if inBuckets.allSatisfy({ self.connectedShards.contains($0) }) {
                return
            } else {
                /// If other shards are **not** already connected, wait.
                await withCheckedContinuation {
                    self.waiters[bucketIndex, default: []].append($0)
                }
            }
        }
    }

    /// To be used when a shard has received "ready".
    func connected(shard: IntPair, maxConcurrency: Int) {
        self.connectedShards.insert(shard.first)
        let bucketIndex = shard.first / maxConcurrency
        let start = bucketIndex * maxConcurrency
        let end = start + maxConcurrency
        let inBuckets = start..<end
        if inBuckets.allSatisfy({ self.connectedShards.contains($0) }) {
            /// All shards in bucket have connected. Tell the waiters of the next bucket index.
            for waiter in self.waiters[bucketIndex + 1] ?? [] {
                waiter.resume()
            }
        }
    }

    /// To be used when a shard is manually disconnected.
    func disconnected(shard: IntPair, maxConcurrency _: Int) {
        self.connectedShards.remove(shard.first)
    }
}
