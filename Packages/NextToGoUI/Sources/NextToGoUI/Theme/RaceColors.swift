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

    /// Red background for urgent countdown state when ≤5 minutes (#FF4444)
    public static let countdownUrgent = Color(red: 1.0, green: 0.267, blue: 0.267)

    /// Light gray background for normal countdown state when >5 minutes (#F3F4F6)
    public static let countdownNormal = Color(red: 0.953, green: 0.957, blue: 0.965)

    /// Text color for countdown badge
    public static let countdownText = Color.primary

    // MARK: - Race Row Colors

    /// White background for race cards
    #if canImport(UIKit)
    public static let raceCardBackground = Color(uiColor: .systemBackground)
    #else
    public static let raceCardBackground = Color(.white)
    #endif

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
