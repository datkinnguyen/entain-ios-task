import NextToGoCore
import NextToGoViewModel
import SwiftUI

/// The main view displaying the list of upcoming races with category filtering.
///
/// Integrates all UI components and manages:
/// - Category filter chips
/// - List of race cards (maximum 5)
/// - Loading and error states
/// - Countdown timer updates via AsyncStream (every second)
/// - Pull-to-refresh functionality
public struct RacesListView: View {

    // MARK: - Properties

    @Bindable private var viewModel: RacesViewModel
    @AccessibilityFocusState private var focusedRaceId: String?

    // MARK: - Initialisation

    /// Creates a races list view.
    ///
    /// - Parameter viewModel: The view model managing race data and state
    public init(viewModel: RacesViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack {
            ZStack {
                // Full-height grey background
                RaceColors.listBackground
                    .ignoresSafeArea()

                // Main content - check empty first, then loading/error/success
                Group {
                    if viewModel.races.isEmpty {
                        if viewModel.isLoading {
                            loadingStateView
                        } else if let error = viewModel.error {
                            errorStateView(for: error)
                        } else {
                            emptyStateView
                        }
                    } else {
                        racesList
                    }
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    CategoryFilterView(
                        selectedCategories: $viewModel.selectedCategories,
                        viewModel: viewModel
                    )
                    .background(RaceColors.raceCardBackground)
                    Divider()
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .task {
                viewModel.startTasks()
            }
            .onDisappear {
                viewModel.stopTasks()
            }
        }
    }

    // MARK: - Subviews

    private var racesList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.races, id: \.raceId) { race in
                    RaceRowView(race: race, viewModel: viewModel)
                        .accessibilityFocused($focusedRaceId, equals: race.raceId)

                    if race.raceId != viewModel.races.last?.raceId {
                        Divider()
                            .padding(.horizontal, RaceLayout.cardPadding)
                    }
                }
            }
            .background(RaceColors.raceCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: RaceLayout.cardCornerRadius))
            .shadow(
                color: .black.opacity(RaceLayout.cardShadowOpacity),
                radius: RaceLayout.cardShadowRadius,
                y: RaceLayout.cardShadowY
            )
            .padding(.horizontal, RaceLayout.spacingL)
            .padding(.top, RaceLayout.spacingM)
        }
        .onChange(of: viewModel.races) { oldRaces, newRaces in
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(300))
                handleFocusAfterRaceListChange(oldRaces: oldRaces, newRaces: newRaces)
            }
        }
        .onChange(of: focusedRaceId) { _, newValue in
            // Update ViewModel when focus changes so it can track status changes
            viewModel.focusedRaceId = newValue
        }
        .onChange(of: viewModel.focusedRaceStatusChangeCounter) { _, _ in
            // Focused race's status changed - refocus to trigger VoiceOver announcement
            if let focusedId = focusedRaceId {
                refocusRace(focusedId)
            }
        }
    }

    private var loadingStateView: some View {
        VStack(spacing: RaceLayout.spacingL) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(.circular)

            Text(viewModel.loadingMessage)
                .font(RaceTypography.location)
                .foregroundStyle(RaceColors.locationText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RaceColors.listBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(viewModel.loadingMessage)
    }

    private var emptyStateView: some View {
        let config = viewModel.emptyConfiguration
        return ContentUnavailableView(
            label: {
                Label(config.title, systemImage: config.iconName)
            },
            description: {
                Text(config.message)
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel(config.accessibilityLabel)
    }

    private func errorStateView(for error: Error) -> some View {
        let config = viewModel.errorConfiguration(for: error)
        return ContentUnavailableView(
            label: {
                Label(config.title, systemImage: config.iconName)
            },
            description: {
                Text(config.message)
            },
            actions: {
                Button(
                    action: {
                        Task {
                            await viewModel.refreshRaces()
                        }
                    },
                    label: {
                        Text(config.retryButtonText)
                    }
                )
                .buttonStyle(.borderedProminent)
                .accessibilityLabel(config.retryAccessibilityLabel)
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - VoiceOver Focus Management

    /// Resets VoiceOver focus to the first race when the race list changes.
    ///
    /// This ensures focus always moves to the first item after any list update,
    /// preventing focus from jumping to the navigation title.
    private func handleFocusAfterRaceListChange(oldRaces: [Race], newRaces: [Race]) {
        // Use a small delay to ensure the state is updated before refocusing
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            // Reset focus to first race if the list changed
            if !newRaces.isEmpty && oldRaces != newRaces {
                focusedRaceId = newRaces.first?.raceId
                viewModel.focusedRaceId = newRaces.first?.raceId
            }
        }
    }

    /// Refocuses a race by clearing and restoring focus after a delay.
    ///
    /// - Parameter raceId: The race ID to refocus
    private func refocusRace(_ raceId: String) {
        focusedRaceId = nil
        // Use a small delay to ensure the state is updated before refocusing
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            focusedRaceId = raceId
        }
    }

}

// MARK: - Previews

#Preview("With Races") {
    let mockRepository = MockRaceRepository()
    let viewModel = RacesViewModel(repository: mockRepository)
    return RacesListView(viewModel: viewModel)
}

#Preview("Loading State") {
    let mockRepository = MockRaceRepository(shouldDelay: true)
    let viewModel = RacesViewModel(repository: mockRepository)
    Task {
        await viewModel.refreshRaces()
    }
    return RacesListView(viewModel: viewModel)
}

#Preview("Empty State") {
    let mockRepository = MockRaceRepository(races: [])
    let viewModel = RacesViewModel(repository: mockRepository)
    return RacesListView(viewModel: viewModel)
}

#Preview("Dark Mode") {
    let mockRepository = MockRaceRepository()
    let viewModel = RacesViewModel(repository: mockRepository)
    return RacesListView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
