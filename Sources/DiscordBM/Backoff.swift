import Foundation
import NIOCore

/// Exponential backoff
actor Backoff {
    
    let base: Double
    let maxExponentiation: Int
    let coefficient: Double
    let minTimePast: TimeInterval
    var tryCount = 0
    var previousTry = Date.distantPast.timeIntervalSince1970
    
    init(
        base: Double,
        maxExponentiation: Int,
        coefficient: Double,
        minTimePast: TimeInterval
    ) {
        self.base = base
        self.maxExponentiation = maxExponentiation
        self.coefficient = coefficient
        self.minTimePast = minTimePast
    }
    
    /// Returns `nil` if can perform immediately,
    /// otherwise `TimeAmount` to wait before attempting to perform.
    /// Assumes you will definitely perform the task after calling this.
    func canPerformIn() -> TimeAmount? {
        let tryCount = self.tryCount
        let previousTry = self.previousTry
        self.tryCount += 1
        let now = Date().timeIntervalSince1970
        if tryCount == 0 {
            /// Even if the last connection was successful, don't try to connect too fast.
            let timePast = now - previousTry
            if timePast > minTimePast {
                return nil
            } else {
                let remaining = minTimePast - timePast
                let millis = Int64(remaining * 1_000)
                return .milliseconds(millis)
            }
        } else {
            let effectiveTryCount = min(tryCount, maxExponentiation)
            let factor = coefficient * pow(base, Double(effectiveTryCount))
            let timePast = now - previousTry
            let waitMore = factor - timePast
            if waitMore > 0 {
                let millis = Int64(waitMore * 1_000) + 1
                let waitTime = max(millis, Int64(minTimePast * 1_000))
                return .milliseconds(waitTime)
            } else {
                return nil
            }
        }
    }
    
    func resetTryCount() {
        tryCount = 0
    }
    
    func willTry() {
        previousTry = Date().timeIntervalSince1970
    }
    
    #if DEBUG
    func test_setTryCount(to newValue: Int) {
        tryCount = newValue
    }
    
    func test_setPreviousTry(to newValue: TimeInterval) {
        previousTry = newValue
    }
    #endif
}
