import SwiftUI

/// Centralised colour constants for the Next To Go racing app.
public enum RaceColors {

    // MARK: - Category Filter Colours

    /// Orange/red background for selected category chips (#FF5733)
    public static let selectedChipBackground = Color(red: 1.0, green: 0.341, blue: 0.2)

    /// White icon colour for selected category chips
    public static let selectedChipIcon = Color.white

    /// Adaptive background for unselected category chips (automatically adapts to dark mode)
    public static let unselectedChipBackground = Color(.systemGray5)

    /// Grey icon colour for unselected category chips (uses system secondary for proper contrast)
    public static let unselectedChipIcon = Color.secondary

    // MARK: - Countdown Colours

    /// Accent colour background for urgent countdown state (<5 minutes or started)
    public static let countdownUrgentBackground = Color.accentColor.opacity(0.15)

    /// Accent colour text for urgent countdown state
    public static let countdownUrgentText = Color.accentColor

    /// Adaptive background for normal countdown state when ≥5 minutes (automatically adapts to dark mode)
    public static let countdownNormal = Color(.systemGray6)

    /// Text colour for countdown badge (normal state)
    public static let countdownText = Color.primary

    // MARK: - Race Row Colours

    /// Adaptive background for race cards (automatically adapts to dark mode)
    public static let raceCardBackground = Color(.systemBackground)

    /// Dark/black colour for category icons in race rows
    public static let categoryIcon = Color.primary

    /// Blue colour for race flag icon
    public static let raceFlagBlue = Color.blue

    /// Primary text colour for meeting name
    public static let meetingNameText = Color.primary

    /// Secondary text colour for location/subtitle (automatically adapts to dark mode)
    public static let locationText = Color.secondary

    // MARK: - General Colours

    /// Adaptive background for the main list view (automatically adapts to dark mode)
    /// Uses secondarySystemBackground for better contrast with race cards in dark mode
    public static let listBackground = Color(.secondarySystemBackground)

    /// Adaptive separator colour for dividers (automatically adapts to dark mode)
    public static let separator = Color(.separator)

}
