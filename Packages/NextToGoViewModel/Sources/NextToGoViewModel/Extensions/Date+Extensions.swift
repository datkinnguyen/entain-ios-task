import Foundation
import NextToGoCore

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

        // Format based on time value
        if minutes >= 5 || (minutes > 0 && seconds == 0) {
            (visualText, accessibilityText) = formatMinutesOnly(minutes: minutes, sign: sign)
        } else if minutes > 0 {
            (visualText, accessibilityText) = formatMinutesAndSeconds(minutes: minutes, seconds: seconds, sign: sign)
        } else {
            (visualText, accessibilityText) = formatSecondsOnly(seconds: seconds, sign: sign)
        }

        return TextConfiguration(text: visualText, accessibilityText: accessibilityText)
    }

    // MARK: - Private Helper Methods

    private func formatMinutesOnly(minutes: Int, sign: String) -> (visual: String, accessibility: String) {
        let visualFormat = Localization.string(
            forKey: "countdown.minutes.only",
            bundle: .module,
            comment: "Countdown format for minutes only"
        )
        let visualText = "\(sign)\(String(format: visualFormat, minutes))"

        let accessibilityKey = minutes == 1
            ? "countdown.accessibility.minute.singular"
            : "countdown.accessibility.minute.plural"
        let accessibilityFormat = Localization.string(
            forKey: accessibilityKey,
            bundle: .module,
            comment: "Accessibility countdown for minutes"
        )
        let accessibilityText = String(format: accessibilityFormat, minutes)

        return (visualText, accessibilityText)
    }

    private func formatMinutesAndSeconds(
        minutes: Int,
        seconds: Int,
        sign: String
    ) -> (visual: String, accessibility: String) {
        let visualFormat = Localization.string(
            forKey: "countdown.minutes.seconds",
            bundle: .module,
            comment: "Countdown format for minutes and seconds"
        )
        let visualText = "\(sign)\(String(format: visualFormat, minutes, seconds))"

        let accessibilityKey = minutes == 1
            ? "countdown.accessibility.minute.singular"
            : "countdown.accessibility.minute.plural"
        let accessibilityFormat = Localization.string(
            forKey: accessibilityKey,
            bundle: .module,
            comment: "Accessibility countdown for minutes"
        )
        let accessibilityText = String(format: accessibilityFormat, minutes)

        return (visualText, accessibilityText)
    }

    private func formatSecondsOnly(seconds: Int, sign: String) -> (visual: String, accessibility: String) {
        let visualFormat = Localization.string(
            forKey: "countdown.seconds.only",
            bundle: .module,
            comment: "Countdown format for seconds only"
        )
        let visualText = "\(sign)\(String(format: visualFormat, seconds))"

        let accessibilityKey = seconds == 1
            ? "countdown.accessibility.second.singular"
            : "countdown.accessibility.second.plural"
        let accessibilityFormat = Localization.string(
            forKey: accessibilityKey,
            bundle: .module,
            comment: "Accessibility countdown for seconds"
        )
        let accessibilityText = String(format: accessibilityFormat, seconds)

        return (visualText, accessibilityText)
    }

}
