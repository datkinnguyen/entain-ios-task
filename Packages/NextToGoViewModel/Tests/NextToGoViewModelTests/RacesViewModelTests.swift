import Foundation
@testable import NextToGoCore
@testable import NextToGoViewModel
import Testing

@Suite("RacesViewModel Tests")
struct RacesViewModelTests {

    @Test("Initial state is empty with all categories selected")
    @MainActor
    func testInitialState() {
        let repository = MockRaceRepository()
        let viewModel = RacesViewModel(repository: repository)

        #expect(viewModel.races.isEmpty)
        #expect(viewModel.selectedCategories == Set(RaceCategory.allCases))
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }

    @Test("Refresh races fetches from repository")
    @MainActor
    func testRefreshRaces() async {
        let mockRaces = Self.makeMockRaces(count: 5)
        let repository = MockRaceRepository(racesToReturn: mockRaces)
        let viewModel = RacesViewModel(repository: repository)

        await viewModel.refreshRaces()

        #expect(viewModel.races.count == 5)
        #expect(viewModel.races == mockRaces, "Races should match mock data from repository")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }

    @Test("Refresh races handles repository errors")
    @MainActor
    func testRefreshRacesError() async {
        let repository = MockRaceRepository(shouldThrowError: true)
        let viewModel = RacesViewModel(repository: repository)

        await viewModel.refreshRaces()

        #expect(viewModel.races.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error != nil)
    }

    @Test("Changing selected categories triggers refresh")
    @MainActor
    func testCategoryChangeTriggersRefresh() async {
        let mockRaces = Self.makeMockRaces(count: 3)
        let repository = MockRaceRepository(racesToReturn: mockRaces)
        let viewModel = RacesViewModel(repository: repository)

        // Start the background tasks to enable debouncing
        viewModel.startTasks()

        // Wait for initial refresh to complete
        try? await Task.sleep(for: .milliseconds(600))

        let initialFetchCount = await repository.fetchCount

        // Change categories to trigger a new refresh
        viewModel.selectedCategories = [.horse, .greyhound]

        // Wait for debounced refresh to complete (500ms debounce + processing time)
        try? await Task.sleep(for: .milliseconds(700))

        let finalFetchCount = await repository.fetchCount
        #expect(finalFetchCount > initialFetchCount, "Category change should trigger a new refresh")

        viewModel.stopTasks()
    }

    @Test("Auto-refresh starts and stops correctly")
    @MainActor
    func testAutoRefreshLifecycle() async {
        let repository = MockRaceRepository(racesToReturn: Self.makeMockRaces(count: 3))
        let viewModel = RacesViewModel(repository: repository)

        // Start tasks
        viewModel.startTasks()

        // Wait for initial debounced refresh to complete (500ms debounce + processing time)
        try? await Task.sleep(for: .milliseconds(700))

        let initialFetchCount = await repository.fetchCount
        #expect(initialFetchCount >= 1, "Should have fetched at least once")

        // Stop tasks
        viewModel.stopTasks()
        try? await Task.sleep(for: .seconds(2))

        // Fetch count should not increase after stopping
        let finalFetchCount = await repository.fetchCount
        #expect(finalFetchCount == initialFetchCount, "Should not fetch after stopping")
    }

    @Test("Maximum 5 races displayed")
    @MainActor
    func testMaximumRacesLimit() async {
        let mockRaces = Self.makeMockRaces(count: 10)
        let repository = MockRaceRepository(racesToReturn: mockRaces)
        let viewModel = RacesViewModel(repository: repository)

        await viewModel.refreshRaces()

        #expect(viewModel.races.count == 5, "Should display maximum 5 races")
    }

}

// MARK: - Test Helpers

private extension RacesViewModelTests {

    static func makeMockRaces(count: Int) -> [Race] {
        let now = Date.now
        return (0..<count).map { index in
            Race(
                raceId: "race-\(index)",
                raceName: "Race \(index + 1)",
                raceNumber: index + 1,
                meetingName: "Meeting \(index + 1)",
                category: RaceCategory.allCases[index % 3],
                advertisedStart: now.addingTimeInterval(TimeInterval((index + 1) * 60))
            )
        }
    }

}

// MARK: - Mock Repository

private actor MockRaceRepository: RaceRepositoryProtocol {

    private let racesToReturn: [Race]
    private let shouldThrowError: Bool
    private(set) var fetchCount = 0

    init(racesToReturn: [Race] = [], shouldThrowError: Bool = false) {
        self.racesToReturn = racesToReturn
        self.shouldThrowError = shouldThrowError
    }

    func fetchNextRaces(count: Int, categories: Set<RaceCategory>) async throws -> [Race] {
        fetchCount += 1

        if shouldThrowError {
            throw MockError.fetchFailed
        }

        // Return races sorted by advertised start time
        return racesToReturn.sorted { $0.advertisedStart < $1.advertisedStart }
    }

    enum MockError: Error {
        case fetchFailed
    }

}
