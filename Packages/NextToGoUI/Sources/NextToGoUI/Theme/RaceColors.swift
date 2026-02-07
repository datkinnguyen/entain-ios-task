import SwiftUI

/// Centralised color constants for the Next To Go racing app.
public enum RaceColors {

    // MARK: - Category Filter Colors

    /// Orange/red background for selected category chips (#FF5733)
    public static let selectedChipBackground = Color(red: 1.0, green: 0.341, blue: 0.2)

    /// White icon color for selected category chips
    public static let selectedChipIcon = Color.white

    /// Adaptive background for unselected category chips (automatically adapts to dark mode)
    public static let unselectedChipBackground = Color(.systemGray5)

    /// Gray icon color for unselected category chips (uses system secondary for proper contrast)
    public static let unselectedChipIcon = Color.secondary

    // MARK: - Countdown Colors

    /// Accent color background for urgent countdown state (<5 minutes or started)
    public static let countdownUrgentBackground = Color.accentColor.opacity(0.15)

    /// Accent color text for urgent countdown state
    public static let countdownUrgentText = Color.accentColor

    /// Adaptive background for normal countdown state when ≥5 minutes (automatically adapts to dark mode)
    public static let countdownNormal = Color(.systemGray6)

    /// Text color for countdown badge (normal state)
    public static let countdownText = Color.primary

    // MARK: - Race Row Colors

    /// Adaptive background for race cards (automatically adapts to dark mode)
    public static let raceCardBackground = Color(.systemBackground)

    /// Dark/black color for category icons in race rows
    public static let categoryIcon = Color.primary

    /// Blue color for race flag icon
    public static let raceFlagBlue = Color.blue

    /// Primary text color for meeting name
    public static let meetingNameText = Color.primary

    /// Secondary text color for location/subtitle (automatically adapts to dark mode)
    public static let locationText = Color.secondary

    // MARK: - General Colors

    /// Adaptive background for the main list view (automatically adapts to dark mode)
    public static let listBackground = Color(.systemGroupedBackground)

    /// Adaptive separator color for dividers (automatically adapts to dark mode)
    public static let separator = Color(.separator)

}
