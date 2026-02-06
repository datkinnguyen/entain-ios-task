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

                // Main content
                Group {
                    if viewModel.isLoading && viewModel.races.isEmpty {
                        LoadingView(message: "Loading races...")
                    } else if let error = viewModel.error, viewModel.races.isEmpty {
                        ErrorView(error: error) {
                            Task {
                                await viewModel.refreshRaces()
                            }
                        }
                    } else if viewModel.races.isEmpty {
                        emptyStateView
                    } else {
                        racesList
                    }
                }
            }
            .navigationTitle("Next To Go")
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
        ScrollView {
            LazyVStack(spacing: RaceLayout.spacingM) {
                ForEach(viewModel.races, id: \.raceId) { race in
                    RaceRowView(race: race, currentTime: currentTime)
                        .padding(.horizontal, RaceLayout.spacingL)
                }
            }
            .padding(.vertical, RaceLayout.spacingM)
        }
        .refreshable {
            await viewModel.refreshRaces()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: RaceLayout.spacingL) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 48))
                .foregroundStyle(.gray)
                .accessibilityHidden(true)

            Text("No races available")
                .font(RaceTypography.meetingName)
                .foregroundStyle(RaceColors.meetingNameText)

            Text("Try selecting different categories")
                .font(RaceTypography.location)
                .foregroundStyle(RaceColors.locationText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No races available. Try selecting different categories.")
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

// MARK: - Mock Repository

private final class MockRaceRepository: RaceRepositoryProtocol, @unchecked Sendable {

    private let races: [Race]
    private let shouldDelay: Bool

    init(races: [Race]? = nil, shouldDelay: Bool = false) {
        self.shouldDelay = shouldDelay
        self.races = races ?? [
            Race(
                raceId: "1",
                raceName: "Melbourne Cup",
                raceNumber: 7,
                meetingName: "Flemington",
                categoryId: RaceCategory.horse.id,
                advertisedStart: Date.now.addingTimeInterval(600)
            ),
            Race(
                raceId: "2",
                raceName: "Final Sprint",
                raceNumber: 3,
                meetingName: "Wentworth Park",
                categoryId: RaceCategory.greyhound.id,
                advertisedStart: Date.now.addingTimeInterval(240)
            ),
            Race(
                raceId: "3",
                raceName: "Trotters Special",
                raceNumber: 5,
                meetingName: "Menangle",
                categoryId: RaceCategory.harness.id,
                advertisedStart: Date.now.addingTimeInterval(420)
            )
        ]
    }

    func fetchNextRaces(count: Int, categories: Set<RaceCategory>) async throws -> [Race] {
        if shouldDelay {
            try? await Task.sleep(for: .seconds(2))
        }
        return Array(races.prefix(count))
    }

}
