import SwiftUI

/// Centralised typography styles for the Next To Go racing app.
///
/// Uses semantic text styles for proper Dynamic Type support and accessibility.
/// All fonts automatically scale based on user's preferred text size settings.
public enum RaceTypography {

    // MARK: - Text Styles

    /// Headline style for meeting name (automatically scales with Dynamic Type)
    public static let meetingName: Font = .headline

    /// Subheadline style for location text (automatically scales with Dynamic Type)
    public static let location: Font = .subheadline

    /// Monospaced subheadline for countdown timer (automatically scales with Dynamic Type)
    public static let countdown: Font = .subheadline.monospacedDigit()

    /// Semibold footnote for category chip labels (automatically scales with Dynamic Type)
    public static let categoryChip: Font = .footnote.weight(.semibold)

    /// Bold callout for race number (automatically scales with Dynamic Type)
    public static let raceNumber: Font = .callout.bold()

    /// Subheadline for error messages (automatically scales with Dynamic Type)
    public static let errorMessage: Font = .subheadline

    /// Headline style for section headers (automatically scales with Dynamic Type)
    public static let sectionHeader: Font = .headline

}
