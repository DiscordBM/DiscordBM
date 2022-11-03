import Foundation
import NIOCore

actor SerialQueue {
    
    var lastSend: Date
    let waitTime: TimeAmount
    let logger = DiscordGlobalConfiguration.makeLogger("DiscordSerialQueue")
    
    init(waitTime: TimeAmount) {
        /// Setting `lastSend` to sometime in the past that is not way too far.
        let waitSeconds = Double(waitTime.nanoseconds) / 1_000_000_000
        self.lastSend = Date().addingTimeInterval(-waitSeconds * 2)
        self.waitTime = waitTime
    }
    
    func reset() {
        let waitSeconds = Double(waitTime.nanoseconds) / 1_000_000_000
        self.lastSend = Date().addingTimeInterval(-waitSeconds * 2)
    }
    
    nonisolated func perform(_ task: @escaping @Sendable () -> Void) {
        Task { await self._perform(task) }
    }
    
    private func _perform(_ task: @escaping @Sendable () -> Void) {
        if let performIn = canPerformIn() {
            queueTask(task, in: performIn)
        } else {
            self.lastSend = Date()
            task()
        }
    }
    
    private func canPerformIn() -> TimeAmount? {
        let now = Date().timeIntervalSince1970
        let past = now - self.lastSend.timeIntervalSince1970
        let pastNanos = Int64(past * 1_000_000_000)
        let waitMore = waitTime.nanoseconds - pastNanos
        return waitMore > 0 ? .nanoseconds(waitMore) : nil
    }
    
    private func queueTask(_ task: @escaping @Sendable () -> Void, in wait: TimeAmount) {
        Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(wait.nanoseconds))
            } catch {
                logger.warning("Unexpected SerialQueue failure")
                return
            }
            self.perform(task)
        }
    }
}
