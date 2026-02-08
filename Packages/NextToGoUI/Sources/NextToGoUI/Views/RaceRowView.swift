import NextToGoCore
import NextToGoRepository
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

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
        Group {
            if shouldUseVerticalLayout {
                verticalLayout
            } else {
                horizontalLayout
            }
        }
        .padding(RaceLayout.cardPadding)
        .frame(minHeight: RaceLayout.raceRowHeight)
        .accessibilityElement()
        .accessibilityLabel(viewModel.raceAccessibilityLabel(for: race))
        .accessibilityAddTraits(.isStaticText)
    }

    // MARK: - Layout Logic

    private var shouldUseVerticalLayout: Bool {
        dynamicTypeSize >= .accessibility1
    }

    // MARK: - Layout Variants

    private var horizontalLayout: some View {
        HStack(alignment: .center, spacing: RaceLayout.spacingM) {
            categoryIconView

            VStack(alignment: .leading, spacing: RaceLayout.spacingXS) {
                meetingNameText()
                raceNameText()
            }

            Spacer(minLength: RaceLayout.spacingM)

            raceNumberText
            countdownBadge
        }
    }

    private var verticalLayout: some View {
        HStack(alignment: .center, spacing: RaceLayout.spacingM) {
            categoryIconView

            VStack(alignment: .leading, spacing: RaceLayout.spacingXS) {
                meetingNameText(fullWidth: true)
                raceNameText(fullWidth: true)

                HStack(spacing: RaceLayout.spacingM) {
                    raceNumberText
                    Spacer(minLength: 0)
                    countdownBadge
                }
            }
        }
    }

    // MARK: - Reusable Components

    private var categoryIconView: some View {
        Image(race.category.iconName, bundle: .module)
            .resizable()
            .renderingMode(.template)
            .foregroundStyle(RaceColors.categoryIcon)
            .frame(width: RaceLayout.categoryIconSize, height: RaceLayout.categoryIconSize)
            .accessibilityHidden(true)
    }

    private func meetingNameText(fullWidth: Bool = false) -> some View {
        Text(race.meetingName)
            .font(RaceTypography.meetingName)
            .foregroundStyle(RaceColors.meetingNameText)
            .frame(maxWidth: fullWidth ? .infinity : nil, alignment: .leading)
    }

    private func raceNameText(fullWidth: Bool = false) -> some View {
        Text(race.raceName)
            .font(RaceTypography.location)
            .foregroundStyle(RaceColors.locationText)
            .frame(maxWidth: fullWidth ? .infinity : nil, alignment: .leading)
    }

    private var raceNumberText: some View {
        Text(viewModel.raceNumberText(for: race))
            .font(RaceTypography.raceNumber)
            .foregroundStyle(RaceColors.meetingNameText)
            .lineLimit(1)
    }

    private var countdownBadge: some View {
        CountdownBadge(
            text: viewModel.countdownText(for: race),
            isUrgent: viewModel.isCountdownUrgent(for: race)
        )
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
    let mockRepository = createSuccessMockRepository()
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
    let mockRepository = createSuccessMockRepository()
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
    let mockRepository = createSuccessMockRepository()
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
    let mockRepository = createSuccessMockRepository()
    let viewModel = RacesViewModel(repository: mockRepository)
    return RaceRowView(race: race, viewModel: viewModel)
        .padding()
        .preferredColorScheme(.dark)
}
