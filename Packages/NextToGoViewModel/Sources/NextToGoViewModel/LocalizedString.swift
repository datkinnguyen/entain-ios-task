import Foundation

/// Helper for accessing localized strings from the ViewModel package bundle
enum LocalizedString {

    // MARK: - Navigation

    static let navigationTitle = localized("navigation.title")

    // MARK: - Loading States

    static let loadingRaces = localized("loading.races")

    // MARK: - Empty States

    static let emptyTitle = localized("empty.title")
    static let emptyMessage = localized("empty.message")
    static let emptyAccessibility = localized("empty.accessibility")

    // MARK: - Error States

    static let errorTitle = localized("error.title")
    static let errorRetry = localized("error.retry")
    static let errorRetryAccessibility = localized("error.retry.accessibility")

    // MARK: - Countdown

    static let countdownStarted = localized("countdown.started")
    static let countdownStartingSoon = localized("countdown.starting_soon")
    static let countdownStartsIn = localized("countdown.starts_in")

    // MARK: - Race Display

    static let raceNumberPrefix = localized("race.number.prefix")

    // MARK: - Category

    static let categoryHorse = localized("category.horse")
    static let categoryHarness = localized("category.harness")
    static let categoryGreyhound = localized("category.greyhound")

    static let categoryHorseRacing = localized("category.horse.racing")
    static let categoryHarnessRacing = localized("category.harness.racing")
    static let categoryGreyhoundRacing = localized("category.greyhound.racing")

    static let categorySelectedHint = localized("category.selected.hint")
    static let categoryNotSelectedHint = localized("category.not_selected.hint")

    // MARK: - Helper

    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, bundle: .module, comment: "")
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
            format: localized("race.accessibility.format"),
            category, meeting, raceNumber, raceName, countdown
        )
    }

}
