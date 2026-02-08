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
        #expect(viewModel.isLoading == true) // Initially true, expecting to load
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

    @Test("Background tasks lifecycle - start triggers initial refresh, stop prevents further refreshes")
    @MainActor
    func testBackgroundTasksLifecycle() async {
        let repository = MockRaceRepository(racesToReturn: Self.makeMockRaces(count: 3))
        let viewModel = RacesViewModel(repository: repository)

        // Start tasks - should trigger initial refresh via scheduleRefresh()
        viewModel.startTasks()

        // Wait for initial debounced refresh to complete (500ms debounce + processing time)
        try? await Task.sleep(for: .milliseconds(700))

        let initialFetchCount = await repository.fetchCount
        #expect(initialFetchCount >= 1, "Should have fetched at least once after starting tasks")

        // Stop tasks - should cancel background tasks and finish refresh channel
        viewModel.stopTasks()
        try? await Task.sleep(for: .milliseconds(200))

        // Trigger a category change (which would normally schedule a refresh)
        viewModel.selectedCategories = [.horse]
        try? await Task.sleep(for: .milliseconds(700))

        // Fetch count should not increase after stopping tasks
        let finalFetchCount = await repository.fetchCount
        #expect(finalFetchCount == initialFetchCount, "Should not fetch after stopping tasks")
    }

    @Test("Debounce behavior - multiple rapid triggers result in single fetch")
    @MainActor
    func testDebounceMultipleTriggers() async {
        let repository = MockRaceRepository(racesToReturn: Self.makeMockRaces(count: 3))
        let viewModel = RacesViewModel(repository: repository)

        // Start tasks to enable debounce handling
        viewModel.startTasks()

        // Wait for initial refresh to complete
        try? await Task.sleep(for: .milliseconds(700))
        let initialFetchCount = await repository.fetchCount

        // Trigger multiple rapid category changes (each calls scheduleRefresh())
        viewModel.selectedCategories = [.horse]
        try? await Task.sleep(for: .milliseconds(100))
        viewModel.selectedCategories = [.horse, .greyhound]
        try? await Task.sleep(for: .milliseconds(100))
        viewModel.selectedCategories = [.greyhound]
        try? await Task.sleep(for: .milliseconds(100))
        viewModel.selectedCategories = [.horse, .harness]

        // Wait for debounce delay (500ms) + processing time
        try? await Task.sleep(for: .milliseconds(700))

        let finalFetchCount = await repository.fetchCount
        // Should only have ONE additional fetch despite 4 rapid triggers
        #expect(
            finalFetchCount == initialFetchCount + 1,
            "Debounce should consolidate multiple rapid triggers into single fetch"
        )

        viewModel.stopTasks()
    }

    @Test("Expired race detection triggers refresh")
    @MainActor
    func testExpiredRaceTriggersRefresh() async {
        // Create races where one will expire during the test
        let now = Date.now
        let expiredRace = Race(
            raceId: "expired",
            raceName: "Expired Race",
            raceNumber: 1,
            meetingName: "Test Meeting",
            category: .horse,
            advertisedStart: now.addingTimeInterval(-65) // Started 65 seconds ago (expired)
        )
        let futureRace = Race(
            raceId: "future",
            raceName: "Future Race",
            raceNumber: 2,
            meetingName: "Test Meeting",
            category: .horse,
            advertisedStart: now.addingTimeInterval(300)
        )

        let repository = MockRaceRepository(racesToReturn: [expiredRace, futureRace])
        let viewModel = RacesViewModel(repository: repository)

        // Manually set races to include expired race
        await viewModel.refreshRaces()
        let initialRaces = viewModel.races
        #expect(initialRaces.count == 2)

        let initialFetchCount = await repository.fetchCount

        // Start tasks - countdown timer will check for expired races every second
        viewModel.startTasks()

        // Wait for countdown timer to detect expired race and trigger refresh
        // Timer runs every 1 second, debounce is 500ms, so wait ~2 seconds
        try? await Task.sleep(for: .seconds(2))

        let finalFetchCount = await repository.fetchCount
        // Should have triggered at least one additional fetch due to expired race detection
        #expect(finalFetchCount > initialFetchCount, "Expired race should trigger refresh")

        viewModel.stopTasks()
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

        // Return races sorted by advertised start time, capped at requested count
        return Array(racesToReturn.sorted { $0.advertisedStart < $1.advertisedStart }.prefix(count))
    }

    enum MockError: Error {
        case fetchFailed
    }

}
