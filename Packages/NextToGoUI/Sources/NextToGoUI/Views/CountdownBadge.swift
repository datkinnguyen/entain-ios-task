import SwiftUI

/// A badge displaying a countdown timer with visual state based on urgency.
///
/// This is a dumb component that receives all display data from its parent.
/// All logic and calculations are performed in the ViewModel layer.
public struct CountdownBadge: View {

    // MARK: - Properties

    private let text: String
    private let isUrgent: Bool
    private let accessibilityLabel: String

    // MARK: - Initialisation

    /// Creates a countdown badge.
    ///
    /// - Parameters:
    ///   - text: The countdown text to display
    ///   - isUrgent: Whether to show urgent state (red background)
    ///   - accessibilityLabel: The accessibility label
    public init(text: String, isUrgent: Bool, accessibilityLabel: String) {
        self.text = text
        self.isUrgent = isUrgent
        self.accessibilityLabel = accessibilityLabel
    }

    // MARK: - Body

    public var body: some View {
        Text(text)
            .font(RaceTypography.countdown)
            .foregroundStyle(isUrgent ? .white : RaceColors.countdownText)
            .padding(.horizontal, RaceLayout.countdownPaddingHorizontal)
            .padding(.vertical, RaceLayout.countdownPaddingVertical)
            .frame(minHeight: RaceLayout.countdownMinHeight)
            .background(isUrgent ? RaceColors.countdownUrgent : RaceColors.countdownNormal)
            .clipShape(RoundedRectangle(cornerRadius: RaceLayout.chipCornerRadius))
            .accessibilityLabel(accessibilityLabel)
            .accessibilityValue(text)
    }

}

// MARK: - Previews

#Preview("Normal State") {
    CountdownBadge(
        text: "10m 0s",
        isUrgent: false,
        accessibilityLabel: "Race starts in"
    )
    .padding()
}

#Preview("Urgent State") {
    CountdownBadge(
        text: "4m 0s",
        isUrgent: true,
        accessibilityLabel: "Race starting soon"
    )
    .padding()
}

#Preview("Negative State") {
    CountdownBadge(
        text: "-1m 30s",
        isUrgent: true,
        accessibilityLabel: "Race started"
    )
    .padding()
}
