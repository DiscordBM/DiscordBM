import Foundation
import NIOCore

/// Exponential backoff
actor Backoff {
    
    let base: Double
    let maxExponentiation: Int
    let coefficient: Double
    let minBackoff: TimeInterval
    var tryCount = 0
    var previousTry = Date.distantPast.timeIntervalSince1970
    
    init(
        base: Double,
        maxExponentiation: Int,
        coefficient: Double,
        minBackoff: TimeInterval
    ) {
        self.base = base
        self.maxExponentiation = maxExponentiation
        self.coefficient = coefficient
        self.minBackoff = minBackoff
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
            if timePast > minBackoff {
                return nil
            } else {
                let remaining = minBackoff - timePast
                let millis = Int64(remaining * 1_000)
                return .milliseconds(millis)
            }
        } else {
            let effectiveTryCount = min(tryCount, maxExponentiation)
            let factor = coefficient * pow(base, Double(effectiveTryCount))
            let timePast = now - previousTry
            let calculatedWait = factor - timePast
            let minRequiredWait = minBackoff - timePast
            let toWait = max(calculatedWait, minRequiredWait)
            if toWait > 0 {
                let millis = Int64(toWait * 1_000) + 1
                return .milliseconds(millis)
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
