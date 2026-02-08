import Foundation
import NextToGoCore

/// Helper for accessing localized strings from the ViewModel package bundle
enum LocalizedString {

    // MARK: - Navigation

    static let navigationTitle = localised("navigation.title")

    // MARK: - Loading States

    static let loadingRaces = localised("loading.races")

    // MARK: - Empty States

    static let emptyTitle = localised("empty.title")
    static let emptyMessage = localised("empty.message")
    static let emptyAccessibility = localised("empty.accessibility")

    // MARK: - Error States

    static let errorTitle = localised("error.title")
    static let errorRetry = localised("error.retry")
    static let errorRetryAccessibility = localised("error.retry.accessibility")

    // MARK: - Countdown

    /// Returns "started" accessibility text (no time specified)
    static var countdownStarted: String {
        localised("countdown.started")
    }

    /// Formats "starting soon in X" accessibility text
    static func countdownStartingSoon(time: String) -> String {
        String(format: localised("countdown.starting_soon.format"), time)
    }

    /// Formats "starts in X" accessibility text
    static func countdownStartsIn(time: String) -> String {
        String(format: localised("countdown.starts_in.format"), time)
    }

    // MARK: - Race Display

    static let raceNumberPrefix = localised("race.number.prefix")

    // MARK: - Category Accessibility Labels

    static let categoryHorseAccessibility = localised("category.horse.accessibility")
    static let categoryHarnessAccessibility = localised("category.harness.accessibility")
    static let categoryGreyhoundAccessibility = localised("category.greyhound.accessibility")

    static let categoryHorseRacingAccessibility = localised("category.horse.racing.accessibility")
    static let categoryHarnessRacingAccessibility = localised("category.harness.racing.accessibility")
    static let categoryGreyhoundRacingAccessibility = localised("category.greyhound.racing.accessibility")

    static let categoryFiltersLabel = localised("category.filters.label")
    static let categorySelectedHint = localised("category.selected.hint")
    static let categoryNotSelectedHint = localised("category.not_selected.hint")

    // MARK: - Helper

    private static func localised(_ key: String) -> String {
        Localization.string(forKey: key, bundle: .module)
    }

    /// Formats race accessibility label
    /// - Parameters:
    ///   - category: The race category name
    ///   - meeting: The meeting name
    ///   - raceName: The race name
    ///   - raceNumber: The race number
    ///   - countdown: The countdown string
    /// - Returns: Formatted accessibility label
    static func raceAccessibility(
        category: String,
        meeting: String,
        raceName: String,
        raceNumber: Int,
        countdown: String
    ) -> String {
        String(
            format: localised("race.accessibility.format"),
            category, meeting, raceName, raceNumber, countdown
        )
    }

}
