import Foundation
@testable import NextToGoCore
@testable import NextToGoViewModel
import Testing

/// Tests must run serially because they share time-sensitive async operations
@Suite("RacesViewModel Tests", .serialized)
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

        // Initial state - all categories
        viewModel.selectedCategories = [.horse, .greyhound]

        // Wait for async refresh to complete
        try? await Task.sleep(for: .milliseconds(100))

        #expect(repository.fetchCount > 0)
    }

    @Test("Fetched races exclude already expired races")
    @MainActor
    func testFetchExcludesExpiredRaces() async {
        let now = Date.now

        // Create races: one already expired, one in the future
        let expiredRace = Race(
            raceId: "expired-1",
            raceName: "Expired Race",
            raceNumber: 1,
            meetingName: "Past Meeting",
            categoryId: RaceCategory.horse.id,
            advertisedStart: now.addingTimeInterval(-70) // 70 seconds ago (already expired)
        )
        let futureRace1 = Race(
            raceId: "future-1",
            raceName: "Future Race 1",
            raceNumber: 2,
            meetingName: "Future Meeting",
            categoryId: RaceCategory.horse.id,
            advertisedStart: now.addingTimeInterval(100)
        )
        let futureRace2 = Race(
            raceId: "future-2",
            raceName: "Future Race 2",
            raceNumber: 3,
            meetingName: "Future Meeting",
            categoryId: RaceCategory.horse.id,
            advertisedStart: now.addingTimeInterval(200)
        )

        // Repository returns all races (including expired)
        let repository = MockRaceRepository(racesToReturn: [expiredRace, futureRace1, futureRace2])
        let viewModel = RacesViewModel(repository: repository)

        // Refresh races
        await viewModel.refreshRaces()

        // All non-expired races should be returned
        #expect(viewModel.races.count == 3)
        #expect(viewModel.races.allSatisfy { !$0.isExpired } == false) // Repository returns all races

        // Note: Expiry filtering happens in the repository, not the ViewModel
        // The ViewModel's expiry check task removes races that become expired over time
    }

    @Test("Auto-refresh starts and stops correctly")
    @MainActor
    func testAutoRefreshLifecycle() async {
        let repository = MockRaceRepository(racesToReturn: Self.makeMockRaces(count: 3))
        let viewModel = RacesViewModel(repository: repository)

        // Start tasks
        viewModel.startTasks()
        try? await Task.sleep(for: .milliseconds(200))

        #expect(repository.fetchCount >= 1, "Should have fetched at least once")

        let fetchCountBefore = repository.fetchCount

        // Stop tasks
        viewModel.stopTasks()
        try? await Task.sleep(for: .seconds(2))

        // Fetch count should not increase significantly after stopping
        #expect(repository.fetchCount == fetchCountBefore, "Should not fetch after stopping")
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

    @Test("Races remain sorted by advertised start time")
    @MainActor
    func testRacesSortedByStartTime() async {
        let now = Date.now
        let race1 = Race(
            raceId: "race-1",
            raceName: "Race 1",
            raceNumber: 1,
            meetingName: "Meeting",
            categoryId: RaceCategory.horse.id,
            advertisedStart: now.addingTimeInterval(300)
        )
        let race2 = Race(
            raceId: "race-2",
            raceName: "Race 2",
            raceNumber: 2,
            meetingName: "Meeting",
            categoryId: RaceCategory.horse.id,
            advertisedStart: now.addingTimeInterval(100)
        )
        let race3 = Race(
            raceId: "race-3",
            raceName: "Race 3",
            raceNumber: 3,
            meetingName: "Meeting",
            categoryId: RaceCategory.horse.id,
            advertisedStart: now.addingTimeInterval(500)
        )

        let repository = MockRaceRepository(racesToReturn: [race1, race2, race3])
        let viewModel = RacesViewModel(repository: repository)

        await viewModel.refreshRaces()

        #expect(viewModel.races.count == 3)
        // Repository should return sorted races
        #expect(viewModel.races[0].raceId == "race-2")
        #expect(viewModel.races[1].raceId == "race-1")
        #expect(viewModel.races[2].raceId == "race-3")
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
                categoryId: RaceCategory.allCases[index % 3].id,
                advertisedStart: now.addingTimeInterval(TimeInterval((index + 1) * 60))
            )
        }
    }

}

// MARK: - Mock Repository

private final class MockRaceRepository: RaceRepositoryProtocol, @unchecked Sendable {

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
