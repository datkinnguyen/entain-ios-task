import NextToGoCore
import NextToGoViewModel
import SwiftUI

/// A row view displaying a race card with icon, meeting info, race number, and countdown.
///
/// This is a dumb component that receives all display data from the ViewModel.
/// All logic, calculations, and strings come from the ViewModel layer.
public struct RaceRowView: View {

    // MARK: - Properties

    private let race: Race
    private let viewModel: RacesViewModel

    // MARK: - Initialisation

    /// Creates a race row view.
    ///
    /// - Parameters:
    ///   - race: The race to display
    ///   - viewModel: The view model providing display data and current time
    public init(race: Race, viewModel: RacesViewModel) {
        self.race = race
        self.viewModel = viewModel
    }

    // MARK: - Body

    public var body: some View {
        ViewThatFits {
            // Horizontal layout - try this first
            horizontalLayout

            // Vertical layout - fallback for large text sizes
            verticalLayout
        }
        .padding(RaceLayout.cardPadding)
        .frame(minHeight: RaceLayout.raceRowHeight)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Layout Variants

    private var horizontalLayout: some View {
        HStack(spacing: RaceLayout.spacingM) {
            // Category icon
            Image(systemName: race.category.iconName)
                .font(.system(size: RaceLayout.categoryIconSize))
                .foregroundStyle(RaceColors.categoryIcon)
                .frame(width: RaceLayout.categoryIconSize, height: RaceLayout.categoryIconSize)
                .accessibilityHidden(true)

            // Meeting info and race details
            VStack(alignment: .leading, spacing: RaceLayout.spacingXS) {
                Text(race.meetingName)
                    .font(RaceTypography.meetingName)
                    .foregroundStyle(RaceColors.meetingNameText)

                Text(race.raceName)
                    .font(RaceTypography.location)
                    .foregroundStyle(RaceColors.locationText)
            }

            Spacer(minLength: RaceLayout.spacingM)

            // Race number
            Text(viewModel.raceNumberText(for: race))
                .font(RaceTypography.raceNumber)
                .foregroundStyle(RaceColors.meetingNameText)
                .lineLimit(1)

            // Countdown badge
            CountdownBadge(
                text: viewModel.countdownText(for: race),
                isUrgent: viewModel.isCountdownUrgent(for: race),
                accessibilityLabel: viewModel.countdownAccessibilityLabel(for: race)
            )
        }
    }

    private var verticalLayout: some View {
        VStack(spacing: RaceLayout.spacingM) {
            // Top row: Icon + Meeting info
            HStack(alignment: .top, spacing: RaceLayout.spacingM) {
                Image(systemName: race.category.iconName)
                    .font(.system(size: RaceLayout.categoryIconSize))
                    .foregroundStyle(RaceColors.categoryIcon)
                    .frame(width: RaceLayout.categoryIconSize, height: RaceLayout.categoryIconSize)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: RaceLayout.spacingXS) {
                    Text(race.meetingName)
                        .font(RaceTypography.meetingName)
                        .foregroundStyle(RaceColors.meetingNameText)

                    Text(race.raceName)
                        .font(RaceTypography.location)
                        .foregroundStyle(RaceColors.locationText)
                }

                Spacer(minLength: 0)
            }

            // Bottom row: Race number + Countdown
            HStack(spacing: RaceLayout.spacingM) {
                Text(viewModel.raceNumberText(for: race))
                    .font(RaceTypography.raceNumber)
                    .foregroundStyle(RaceColors.meetingNameText)
                    .lineLimit(1)

                Spacer(minLength: 0)

                CountdownBadge(
                    text: viewModel.countdownText(for: race),
                    isUrgent: viewModel.isCountdownUrgent(for: race),
                    accessibilityLabel: viewModel.countdownAccessibilityLabel(for: race)
                )
            }
        }
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        viewModel.raceAccessibilityLabel(for: race)
    }

}

// MARK: - Previews

#Preview("Horse Race") {
    let race = Race(
        raceId: "1",
        raceName: "Melbourne Cup",
        raceNumber: 7,
        meetingName: "Flemington",
        category: .horse,
        advertisedStart: Date.now.addingTimeInterval(600)
    )
    let mockRepository = MockRaceRepository()
    let viewModel = RacesViewModel(repository: mockRepository)
    return RaceRowView(race: race, viewModel: viewModel)
        .padding()
}

#Preview("Greyhound Race - Urgent") {
    let race = Race(
        raceId: "2",
        raceName: "Final Sprint",
        raceNumber: 3,
        meetingName: "Wentworth Park",
        category: .greyhound,
        advertisedStart: Date.now.addingTimeInterval(240)
    )
    let mockRepository = MockRaceRepository()
    let viewModel = RacesViewModel(repository: mockRepository)
    return RaceRowView(race: race, viewModel: viewModel)
        .padding()
}

#Preview("Harness Race - Started") {
    let race = Race(
        raceId: "3",
        raceName: "Trotters Special",
        raceNumber: 5,
        meetingName: "Menangle",
        category: .harness,
        advertisedStart: Date.now.addingTimeInterval(-90)
    )
    let mockRepository = MockRaceRepository()
    let viewModel = RacesViewModel(repository: mockRepository)
    return RaceRowView(race: race, viewModel: viewModel)
        .padding()
}

#Preview("Dark Mode") {
    let race = Race(
        raceId: "4",
        raceName: "Night Race",
        raceNumber: 8,
        meetingName: "Moonee Valley",
        category: .horse,
        advertisedStart: Date.now.addingTimeInterval(420)
    )
    let mockRepository = MockRaceRepository()
    let viewModel = RacesViewModel(repository: mockRepository)
    return RaceRowView(race: race, viewModel: viewModel)
        .padding()
        .preferredColorScheme(.dark)
}
