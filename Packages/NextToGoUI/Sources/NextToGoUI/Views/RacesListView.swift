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
    @State private var currentTime: Date = .now

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
            VStack(spacing: 0) {
                // Category filters
                CategoryFilterView(selectedCategories: $viewModel.selectedCategories)
                    .background(RaceColors.raceCardBackground)

                Divider()

                // Main content - check empty first, then loading/error/success
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
            .navigationTitle(viewModel.navigationTitle)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .background(RaceColors.listBackground)
            .task {
                viewModel.startTasks()
                await startCountdownTimer()
            }
            .onDisappear {
                viewModel.stopTasks()
            }
        }
    }

    // MARK: - Subviews

    private var racesList: some View {
        List {
            ForEach(viewModel.races, id: \.raceId) { race in
                RaceRowView(race: race, viewModel: viewModel, currentTime: currentTime)
                    .listRowInsets(EdgeInsets(
                        top: RaceLayout.spacingS,
                        leading: RaceLayout.spacingL,
                        bottom: RaceLayout.spacingS,
                        trailing: RaceLayout.spacingL
                    ))
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
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

    // MARK: - Private Methods

    /// Starts the countdown timer that updates every second via AsyncStream
    private func startCountdownTimer() async {
        for await _ in AsyncStream<Void>.makeStream(interval: 1.0) {
            currentTime = .now
        }
    }

}

// MARK: - AsyncStream Extension

extension AsyncStream where Element == Void {

    /// Creates a timer stream that emits at regular intervals.
    ///
    /// - Parameter interval: The time interval in seconds between emissions
    /// - Returns: An async stream that emits void values at the specified interval
    static func makeStream(interval: TimeInterval) -> AsyncStream<Void> {
        AsyncStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    continuation.yield(())
                    try? await Task.sleep(for: .seconds(interval))
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
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
