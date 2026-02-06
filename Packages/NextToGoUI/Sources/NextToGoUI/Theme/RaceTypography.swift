import SwiftUI

/// Centralised typography styles for the Next To Go racing app.
public enum RaceTypography {

    // MARK: - Text Styles

    /// Bold 17pt font for meeting name
    public static let meetingName: Font = .system(size: 17, weight: .bold)

    /// Regular 14pt font for location
    public static let location: Font = .system(size: 14, weight: .regular)

    /// Monospaced 15pt font for countdown timer
    public static let countdown: Font = .system(size: 15, weight: .regular).monospacedDigit()

    /// Bold 14pt font for category chip labels
    public static let categoryChip: Font = .system(size: 14, weight: .semibold)

    /// Bold 16pt font for race number
    public static let raceNumber: Font = .system(size: 16, weight: .bold)

    /// Regular 15pt font for error messages
    public static let errorMessage: Font = .system(size: 15, weight: .regular)

    /// Bold 17pt font for section headers
    public static let sectionHeader: Font = .system(size: 17, weight: .bold)

}
