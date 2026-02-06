import SwiftUI

/// Centralised layout constants for the Next To Go racing app.
public enum RaceLayout {

    // MARK: - Spacing

    /// Extra small spacing (4pt)
    public static let spacingXS: CGFloat = 4

    /// Small spacing (8pt)
    public static let spacingS: CGFloat = 8

    /// Medium spacing (12pt)
    public static let spacingM: CGFloat = 12

    /// Large spacing (16pt)
    public static let spacingL: CGFloat = 16

    /// Extra large spacing (20pt)
    public static let spacingXL: CGFloat = 20

    // MARK: - Padding

    /// Standard padding for card content (16pt)
    public static let cardPadding: CGFloat = 16

    /// Padding for category chips (12pt horizontal, 8pt vertical)
    public static let chipPaddingHorizontal: CGFloat = 12
    public static let chipPaddingVertical: CGFloat = 8

    /// Padding for countdown badge (8pt horizontal, 4pt vertical)
    public static let countdownPaddingHorizontal: CGFloat = 8
    public static let countdownPaddingVertical: CGFloat = 4

    // MARK: - Sizing

    /// Race row height (70-80pt)
    public static let raceRowHeight: CGFloat = 75

    /// Category icon size (32x32pt)
    public static let categoryIconSize: CGFloat = 32

    /// Race flag icon size (24x24pt)
    public static let raceFlagSize: CGFloat = 24

    /// Race number badge size (32x32pt)
    public static let raceNumberSize: CGFloat = 32

    /// Minimum height for countdown badge
    public static let countdownMinHeight: CGFloat = 28

    /// Corner radius for cards
    public static let cardCornerRadius: CGFloat = 12

    /// Corner radius for chips and badges
    public static let chipCornerRadius: CGFloat = 8

    // MARK: - Shadow

    /// Shadow radius for race cards
    public static let cardShadowRadius: CGFloat = 4

    /// Shadow y-offset for race cards
    public static let cardShadowY: CGFloat = 2

    /// Shadow opacity for race cards
    public static let cardShadowOpacity: CGFloat = 0.1

}
