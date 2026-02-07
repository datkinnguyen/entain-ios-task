import Foundation

extension Date {

    /// Returns a countdown configuration with both visual and accessibility text.
    /// Visual text uses abbreviated format ("5m"), while accessibility text uses full words ("5 minutes").
    /// Uses DST-aware time calculation and monospaced digits for consistent UI layout.
    ///
    /// - Parameter startDate: The reference date to calculate the interval from. Defaults to `Date.now`.
    ///                        This parameter allows for deterministic testing with static dates.
    /// - Returns: A TextConfiguration with visual and accessibility representations
    ///
    /// Examples:
    /// - Visual: "5m", Accessibility: "5 minutes"
    /// - Visual: "4m 59s", Accessibility: "4 minutes" (seconds omitted for VoiceOver)
    /// - Visual: "-2m 15s", Accessibility: "2 minutes" (seconds omitted for VoiceOver)
    /// - Visual: "5s", Accessibility: "5 seconds"
    public func countdownString(from startDate: Date = Date.now) -> TextConfiguration {
        // Use timeIntervalSince for DST-aware calculation
        let interval = self.timeIntervalSince(startDate)

        // Round to nearest second to avoid displaying 0 for too long
        let roundedInterval = round(interval)
        let absoluteInterval = abs(roundedInterval)

        let minutes = Int(absoluteInterval) / 60
        let seconds = Int(absoluteInterval) % 60

        // Show negative sign only when interval is negative AND has non-zero time
        // This prevents showing "-0s" or "-0m"
        let sign = (roundedInterval < 0 && (minutes > 0 || seconds > 0)) ? "-" : ""

        // Build visual text and accessibility text
        let visualText: String
        let accessibilityText: String

        // Format based on time value:
        // >= 5 minutes: show only minutes (e.g., "5m" / "5 minutes")
        // < 5 minutes with minutes > 0: show minutes and seconds (e.g., "4m 59s" / "4 minutes 59 seconds")
        // < 1 minute: show only seconds (e.g., "45s" / "45 seconds")
        if minutes >= 5 {
            // Visual: "5m"
            let visualFormat = Localization.string(
                forKey: "countdown.minutes.only",
                bundle: .module,
                comment: "Countdown format for minutes only"
            )
            visualText = "\(sign)\(String(format: visualFormat, minutes))"

            // Accessibility: "5 minutes"
            let accessibilityKey = minutes == 1 ? "countdown.accessibility.minute.singular" : "countdown.accessibility.minute.plural"
            let accessibilityFormat = Localization.string(
                forKey: accessibilityKey,
                bundle: .module,
                comment: "Accessibility countdown for minutes"
            )
            accessibilityText = String(format: accessibilityFormat, minutes)
        } else if minutes > 0 {
            if seconds == 0 {
                // Visual: "1m"
                let visualFormat = Localization.string(
                    forKey: "countdown.minutes.only",
                    bundle: .module,
                    comment: "Countdown format for minutes only"
                )
                visualText = "\(sign)\(String(format: visualFormat, minutes))"

                // Accessibility: "1 minute"
                let accessibilityKey = minutes == 1 ? "countdown.accessibility.minute.singular" : "countdown.accessibility.minute.plural"
                let accessibilityFormat = Localization.string(
                    forKey: accessibilityKey,
                    bundle: .module,
                    comment: "Accessibility countdown for minutes"
                )
                accessibilityText = String(format: accessibilityFormat, minutes)
            } else {
                // Visual: "4m 59s"
                let visualFormat = Localization.string(
                    forKey: "countdown.minutes.seconds",
                    bundle: .module,
                    comment: "Countdown format for minutes and seconds"
                )
                visualText = "\(sign)\(String(format: visualFormat, minutes, seconds))"

                // Accessibility: "4 minutes" (seconds omitted for VoiceOver clarity)
                let accessibilityKey = minutes == 1 ? "countdown.accessibility.minute.singular" : "countdown.accessibility.minute.plural"
                let accessibilityFormat = Localization.string(
                    forKey: accessibilityKey,
                    bundle: .module,
                    comment: "Accessibility countdown for minutes"
                )
                accessibilityText = String(format: accessibilityFormat, minutes)
            }
        } else {
            // Visual: "45s"
            let visualFormat = Localization.string(
                forKey: "countdown.seconds.only",
                bundle: .module,
                comment: "Countdown format for seconds only"
            )
            visualText = "\(sign)\(String(format: visualFormat, seconds))"

            // Accessibility: "45 seconds"
            let accessibilityKey = seconds == 1 ? "countdown.accessibility.second.singular" : "countdown.accessibility.second.plural"
            let accessibilityFormat = Localization.string(
                forKey: accessibilityKey,
                bundle: .module,
                comment: "Accessibility countdown for seconds"
            )
            accessibilityText = String(format: accessibilityFormat, seconds)
        }

        return TextConfiguration(text: visualText, accessibilityText: accessibilityText)
    }

}
