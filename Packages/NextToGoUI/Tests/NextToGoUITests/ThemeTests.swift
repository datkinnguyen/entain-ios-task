@testable import NextToGoUI
import Testing

/// Unit tests for theme components to ensure constants are properly defined.
@Suite("Theme Tests")
struct ThemeTests {

    @Test("RaceColors are defined")
    func raceColorsAreDefined() {
        // Test that all color constants are accessible
        _ = RaceColors.selectedChipBackground
        _ = RaceColors.selectedChipIcon
        _ = RaceColors.unselectedChipBackground
        _ = RaceColors.unselectedChipIcon
        _ = RaceColors.countdownUrgent
        _ = RaceColors.countdownNormal
        _ = RaceColors.countdownText
        _ = RaceColors.raceCardBackground
        _ = RaceColors.raceFlagBlue
        _ = RaceColors.meetingNameText
        _ = RaceColors.locationText
        _ = RaceColors.listBackground
        _ = RaceColors.separator
    }

    @Test("RaceTypography is defined")
    func raceTypographyIsDefined() {
        // Test that all typography constants are accessible
        _ = RaceTypography.meetingName
        _ = RaceTypography.location
        _ = RaceTypography.countdown
        _ = RaceTypography.categoryChip
        _ = RaceTypography.raceNumber
        _ = RaceTypography.errorMessage
        _ = RaceTypography.sectionHeader
    }

    @Test("RaceLayout is defined")
    func raceLayoutIsDefined() {
        // Test that all layout constants are accessible
        _ = RaceLayout.spacingXS
        _ = RaceLayout.spacingS
        _ = RaceLayout.spacingM
        _ = RaceLayout.spacingL
        _ = RaceLayout.spacingXL
        _ = RaceLayout.cardPadding
        _ = RaceLayout.chipPaddingHorizontal
        _ = RaceLayout.chipPaddingVertical
        _ = RaceLayout.countdownPaddingHorizontal
        _ = RaceLayout.countdownPaddingVertical
        _ = RaceLayout.raceRowHeight
        _ = RaceLayout.categoryIconSize
        _ = RaceLayout.raceFlagSize
        _ = RaceLayout.raceNumberSize
        _ = RaceLayout.countdownMinHeight
        _ = RaceLayout.cardCornerRadius
        _ = RaceLayout.chipCornerRadius
        _ = RaceLayout.cardShadowRadius
        _ = RaceLayout.cardShadowY
        _ = RaceLayout.cardShadowOpacity
    }

    @Test("Layout constants have reasonable values")
    func layoutConstantsHaveReasonableValues() {
        #expect(RaceLayout.raceRowHeight > 0)
        #expect(RaceLayout.categoryIconSize > 0)
        #expect(RaceLayout.raceFlagSize > 0)
        #expect(RaceLayout.cardCornerRadius > 0)
        #expect(RaceLayout.chipCornerRadius > 0)
    }

}
