import NextToGoCore
import SwiftUI

/// A badge displaying a countdown timer with visual state based on urgency.
///
/// The badge shows a red background when the countdown is ≤5 minutes (urgent state),
/// and a light gray background when >5 minutes (normal state). Supports negative
/// countdowns for races that have already started.
public struct CountdownBadge: View {

    // MARK: - Properties

    private let advertisedStart: Date
    private let currentTime: Date

    // MARK: - Initialisation

    /// Creates a countdown badge.
    ///
    /// - Parameters:
    ///   - advertisedStart: The race start time
    ///   - currentTime: The current time for countdown calculation (defaults to Date.now)
    public init(advertisedStart: Date, currentTime: Date = .now) {
        self.advertisedStart = advertisedStart
        self.currentTime = currentTime
    }

    // MARK: - Computed Properties

    /// Returns true if the countdown is ≤5 minutes (urgent state)
    private var isUrgent: Bool {
        let interval = advertisedStart.timeIntervalSince(currentTime)
        return interval <= 300 // 5 minutes in seconds
    }

    private var backgroundColor: Color {
        isUrgent ? RaceColors.countdownUrgent : RaceColors.countdownNormal
    }

    private var textColor: Color {
        isUrgent ? .white : RaceColors.countdownText
    }

    // MARK: - Body

    public var body: some View {
        Text(advertisedStart.countdownString(from: currentTime))
            .font(RaceTypography.countdown)
            .foregroundStyle(textColor)
            .padding(.horizontal, RaceLayout.countdownPaddingHorizontal)
            .padding(.vertical, RaceLayout.countdownPaddingVertical)
            .frame(minHeight: RaceLayout.countdownMinHeight)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: RaceLayout.chipCornerRadius))
            .accessibilityLabel(countdownAccessibilityLabel)
            .accessibilityValue(advertisedStart.countdownString(from: currentTime))
    }

    // MARK: - Accessibility

    private var countdownAccessibilityLabel: String {
        let interval = advertisedStart.timeIntervalSince(currentTime)
        if interval < 0 {
            return "Race started"
        } else if isUrgent {
            return "Race starting soon"
        } else {
            return "Race starts in"
        }
    }

}

// MARK: - Previews

#Preview("Normal State") {
    CountdownBadge(
        advertisedStart: Date.now.addingTimeInterval(600),
        currentTime: .now
    )
    .padding()
}

#Preview("Urgent State") {
    CountdownBadge(
        advertisedStart: Date.now.addingTimeInterval(240),
        currentTime: .now
    )
    .padding()
}

#Preview("Negative State") {
    CountdownBadge(
        advertisedStart: Date.now.addingTimeInterval(-90),
        currentTime: .now
    )
    .padding()
}
