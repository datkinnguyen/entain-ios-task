import Foundation

extension Date {

    /// Returns a countdown string in the format "Xm Ys" or "-Xm Ys" for expired times.
    /// Uses DST-aware time calculation and monospaced digits for consistent UI layout.
    ///
    /// - Returns: A formatted string representing the time until or since this date
    ///
    /// Examples:
    /// - "5m 30s" - 5 minutes and 30 seconds in the future
    /// - "-2m 15s" - 2 minutes and 15 seconds in the past
    /// - "0m 5s" - 5 seconds in the future
    public func countdownString() -> String {
        // Use timeIntervalSince for DST-aware calculation
        let interval = self.timeIntervalSince(Date.now)
        let absoluteInterval = abs(interval)

        let minutes = Int(absoluteInterval) / 60
        let seconds = Int(absoluteInterval) % 60

        // Don't show negative sign for zero values
        let sign = (interval < 0 && (minutes > 0 || seconds > 0)) ? "-" : ""

        // Only show minutes (rounded down) if >= 1 minute, otherwise show seconds only
        if minutes >= 1 {
            return "\(sign)\(minutes)m"
        } else {
            return "\(sign)\(seconds)s"
        }
    }

}
