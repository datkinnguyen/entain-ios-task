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

    static let countdownStarted = localised("countdown.started")
    static let countdownStartingSoon = localised("countdown.starting_soon")
    static let countdownStartsIn = localised("countdown.starts_in")

    // MARK: - Race Display

    static let raceNumberPrefix = localised("race.number.prefix")

    // MARK: - Category

    static let categoryHorse = localised("category.horse")
    static let categoryHarness = localised("category.harness")
    static let categoryGreyhound = localised("category.greyhound")

    static let categoryHorseRacing = localised("category.horse.racing")
    static let categoryHarnessRacing = localised("category.harness.racing")
    static let categoryGreyhoundRacing = localised("category.greyhound.racing")

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
    ///   - raceNumber: The race number
    ///   - raceName: The race name
    ///   - countdown: The countdown string
    /// - Returns: Formatted accessibility label
    static func raceAccessibility(
        category: String,
        meeting: String,
        raceNumber: Int,
        raceName: String,
        countdown: String
    ) -> String {
        String(
            format: localised("race.accessibility.format"),
            category, meeting, raceNumber, raceName, countdown
        )
    }

}
