import NextToGoCore
import SwiftUI

/// A row view displaying a race card with icon, meeting info, race number, and countdown.
///
/// Displays comprehensive race information including:
/// - Category icon (32x32pt)
/// - Race flag icon (24x24pt blue)
/// - Meeting name (bold 17pt)
/// - Race number badge
/// - Countdown badge with dynamic state
public struct RaceRowView: View {

    // MARK: - Properties

    private let race: Race
    private let category: RaceCategory?
    private let currentTime: Date

    // MARK: - Initialisation

    /// Creates a race row view.
    ///
    /// - Parameters:
    ///   - race: The race to display
    ///   - currentTime: The current time for countdown calculation (defaults to Date.now)
    public init(race: Race, currentTime: Date = .now) {
        self.race = race
        self.category = RaceCategory(id: race.categoryId)
        self.currentTime = currentTime
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: RaceLayout.spacingM) {
            // Category icon
            if let category = category {
                Image(systemName: category.iconName)
                    .font(.system(size: RaceLayout.categoryIconSize))
                    .foregroundStyle(RaceColors.selectedChipBackground)
                    .frame(width: RaceLayout.categoryIconSize, height: RaceLayout.categoryIconSize)
                    .accessibilityHidden(true)
            }

            // Meeting info and race number
            VStack(alignment: .leading, spacing: RaceLayout.spacingXS) {
                HStack(spacing: RaceLayout.spacingS) {
                    // Race flag
                    Image(systemName: "flag.fill")
                        .font(.system(size: RaceLayout.raceFlagSize))
                        .foregroundStyle(RaceColors.raceFlagBlue)
                        .accessibilityHidden(true)

                    // Meeting name
                    Text(race.meetingName)
                        .font(RaceTypography.meetingName)
                        .foregroundStyle(RaceColors.meetingNameText)
                        .lineLimit(1)
                }

                // Race number
                HStack(spacing: RaceLayout.spacingXS) {
                    Text("R\(race.raceNumber)")
                        .font(RaceTypography.raceNumber)
                        .foregroundStyle(RaceColors.meetingNameText)

                    Text(race.raceName)
                        .font(RaceTypography.location)
                        .foregroundStyle(RaceColors.locationText)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Countdown badge
            CountdownBadge(advertisedStart: race.advertisedStart, currentTime: currentTime)
        }
        .padding(RaceLayout.cardPadding)
        .frame(height: RaceLayout.raceRowHeight)
        .background(RaceColors.raceCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: RaceLayout.cardCornerRadius))
        .shadow(
            color: .black.opacity(RaceLayout.cardShadowOpacity),
            radius: RaceLayout.cardShadowRadius,
            y: RaceLayout.cardShadowY
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        let categoryName = category?.rawValue.capitalized ?? "Unknown"
        let countdown = race.advertisedStart.countdownString(from: currentTime)
        return """
            \(categoryName) racing, \(race.meetingName), Race \(race.raceNumber), \
            \(race.raceName), starts in \(countdown)
            """
    }

}

// MARK: - Previews

#Preview("Horse Race") {
    let race = Race(
        raceId: "1",
        raceName: "Melbourne Cup",
        raceNumber: 7,
        meetingName: "Flemington",
        categoryId: RaceCategory.horse.id,
        advertisedStart: Date.now.addingTimeInterval(600)
    )
    return RaceRowView(race: race)
        .padding()
}

#Preview("Greyhound Race - Urgent") {
    let race = Race(
        raceId: "2",
        raceName: "Final Sprint",
        raceNumber: 3,
        meetingName: "Wentworth Park",
        categoryId: RaceCategory.greyhound.id,
        advertisedStart: Date.now.addingTimeInterval(240)
    )
    return RaceRowView(race: race)
        .padding()
}

#Preview("Harness Race - Started") {
    let race = Race(
        raceId: "3",
        raceName: "Trotters Special",
        raceNumber: 5,
        meetingName: "Menangle",
        categoryId: RaceCategory.harness.id,
        advertisedStart: Date.now.addingTimeInterval(-90)
    )
    return RaceRowView(race: race)
        .padding()
}

#Preview("Dark Mode") {
    let race = Race(
        raceId: "4",
        raceName: "Night Race",
        raceNumber: 8,
        meetingName: "Moonee Valley",
        categoryId: RaceCategory.horse.id,
        advertisedStart: Date.now.addingTimeInterval(420)
    )
    return RaceRowView(race: race)
        .padding()
        .preferredColorScheme(.dark)
}
