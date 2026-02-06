import Foundation

extension Date {

    /// Returns a countdown string in the format "Xm Ys" or "-Xm Ys" for expired times.
    /// Uses DST-aware time calculation and monospaced digits for consistent UI layout.
    ///
    /// - Parameter startDate: The reference date to calculate the interval from. Defaults to `Date.now`.
    ///                        This parameter allows for deterministic testing with static dates.
    /// - Returns: A formatted string representing the time until or since this date
    ///
    /// Examples:
    /// - "5m" - 5 minutes or more in the future (seconds omitted when >= 5 minutes)
    /// - "4m 59s" - Less than 5 minutes in the future (shows both minutes and seconds)
    /// - "-2m 15s" - 2 minutes and 15 seconds in the past
    /// - "5s" - 5 seconds in the future (minutes omitted when 0)
    public func countdownString(from startDate: Date = Date.now) -> String {
        // Use timeIntervalSince for DST-aware calculation
        let interval = self.timeIntervalSince(startDate)
        let absoluteInterval = abs(interval)

        let minutes = Int(absoluteInterval) / 60
        let seconds = Int(absoluteInterval) % 60

        // Don't show negative sign for zero values
        let sign = (interval < 0 && (minutes > 0 || seconds > 0)) ? "-" : ""

        // Format based on time value:
        // >= 5 minutes: show only minutes (e.g., "5m")
        // < 5 minutes with minutes > 0: show minutes and seconds, but omit seconds if 0 (e.g., "4m 59s" or "1m")
        // < 1 minute: show only seconds (e.g., "45s")
        if minutes >= 5 {
            let format = NSLocalizedString("countdown.minutes.only", bundle: .module, comment: "Countdown format for minutes only")
            return "\(sign)\(String(format: format, minutes))"
        } else if minutes > 0 {
            if seconds == 0 {
                let format = NSLocalizedString("countdown.minutes.only", bundle: .module, comment: "Countdown format for minutes only")
                return "\(sign)\(String(format: format, minutes))"
            } else {
                let format = NSLocalizedString("countdown.minutes.seconds", bundle: .module, comment: "Countdown format for minutes and seconds")
                return "\(sign)\(String(format: format, minutes, seconds))"
            }
        } else {
            let format = NSLocalizedString("countdown.seconds.only", bundle: .module, comment: "Countdown format for seconds only")
            return "\(sign)\(String(format: format, seconds))"
        }
    }

}
