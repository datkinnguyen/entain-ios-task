import SwiftUI

/// Centralised color constants for the Next To Go racing app.
public enum RaceColors {

    // MARK: - Category Filter Colors

    /// Orange/red background for selected category chips (#FF5733)
    public static let selectedChipBackground = Color(red: 1.0, green: 0.341, blue: 0.2)

    /// White icon color for selected category chips
    public static let selectedChipIcon = Color.white

    /// Light gray background for unselected category chips (#E5E7EB)
    public static let unselectedChipBackground = Color(red: 0.898, green: 0.906, blue: 0.922)

    /// Gray icon color for unselected category chips
    public static let unselectedChipIcon = Color.gray

    // MARK: - Countdown Colors

    /// Light red/pink background for urgent countdown state (<5 minutes or started)
    public static let countdownUrgentBackground = Color(red: 1.0, green: 0.9, blue: 0.9)

    /// Red text color for urgent countdown state
    public static let countdownUrgentText = Color(red: 0.8, green: 0.2, blue: 0.2)

    /// Light grey background for normal countdown state when ≥5 minutes
    public static let countdownNormal = Color(red: 0.95, green: 0.95, blue: 0.95)

    /// Text color for countdown badge (normal state)
    public static let countdownText = Color.primary

    // MARK: - Race Row Colors

    /// White background for race cards
    #if canImport(UIKit)
    public static let raceCardBackground = Color(uiColor: .systemBackground)
    #else
    public static let raceCardBackground = Color(.white)
    #endif

    /// Dark/black color for category icons in race rows
    public static let categoryIcon = Color.primary

    /// Blue color for race flag icon
    public static let raceFlagBlue = Color.blue

    /// Primary text color for meeting name
    public static let meetingNameText = Color.primary

    /// Secondary text color for location
    public static let locationText = Color.secondary

    // MARK: - General Colors

    /// Background color for the main list view
    #if canImport(UIKit)
    public static let listBackground = Color(uiColor: .systemGroupedBackground)
    #else
    public static let listBackground = Color(.gray).opacity(0.1)
    #endif

    /// Separator color for dividers
    #if canImport(UIKit)
    public static let separator = Color(uiColor: .separator)
    #else
    public static let separator = Color.gray.opacity(0.3)
    #endif

}
