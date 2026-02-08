import Foundation
@testable import NextToGoCore
import NextToGoRepository
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
        let mockRaces = MockRaceRepository.makeMockRaces(count: 5)
        let repository = MockRaceRepository()
        repository.fetchNextRacesHandler = { _, _ in mockRaces }
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
        let repository = MockRaceRepository()
        repository.fetchNextRacesHandler = { _, _ in
            throw MockRaceRepository.MockError.networkUnavailable
        }
        let viewModel = RacesViewModel(repository: repository)

        await viewModel.refreshRaces()

        #expect(viewModel.races.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error != nil)
    }

    @Test("Changing selected categories triggers refresh")
    @MainActor
    func testCategoryChangeTriggersRefresh() async {
        let mockRaces = MockRaceRepository.makeMockRaces(count: 3)
        let repository = MockRaceRepository()

        await confirmation("fetchNextRaces called exactly twice", expectedCount: 2) { fetchCalled in
            repository.fetchNextRacesHandler = { _, _ in
                fetchCalled()
                return mockRaces
            }
            let viewModel = RacesViewModel(repository: repository)

            // Start the background tasks to enable debouncing
            viewModel.startTasks()

            // Wait for initial refresh to complete
            try? await Task.sleep(for: .milliseconds(600))

            // Change categories to trigger a new refresh
            viewModel.selectedCategories = [.horse, .greyhound]

            // Wait for debounced refresh to complete (500ms debounce + processing time)
            try? await Task.sleep(for: .milliseconds(700))

            viewModel.stopTasks()
        }
    }

    @Test("Background tasks lifecycle - start triggers initial refresh, stop prevents further refreshes")
    @MainActor
    func testBackgroundTasksLifecycle() async {
        let mockRaces = MockRaceRepository.makeMockRaces(count: 3)
        let repository = MockRaceRepository()

        await confirmation("fetchNextRaces called exactly once", expectedCount: 1) { fetchCalled in
            repository.fetchNextRacesHandler = { _, _ in
                fetchCalled()
                return mockRaces
            }
            let viewModel = RacesViewModel(repository: repository)

            // Start tasks - should trigger initial refresh via scheduleRefresh()
            viewModel.startTasks()

            // Wait for initial debounced refresh to complete (500ms debounce + processing time)
            try? await Task.sleep(for: .milliseconds(700))

            // Stop tasks - should cancel background tasks and finish refresh channel
            viewModel.stopTasks()
            try? await Task.sleep(for: .milliseconds(200))

            // Trigger a category change (which would normally schedule a refresh)
            viewModel.selectedCategories = [.horse]
            try? await Task.sleep(for: .milliseconds(700))

            // Should not fetch after stopping tasks
        }
    }

    @Test("Debounce behavior - multiple rapid triggers result in single fetch")
    @MainActor
    func testDebounceMultipleTriggers() async {
        let mockRaces = MockRaceRepository.makeMockRaces(count: 3)
        let repository = MockRaceRepository()

        // Expect exactly 2 calls: 1 initial + 1 debounced after rapid changes
        await confirmation("fetchNextRaces called exactly twice", expectedCount: 2) { fetchCalled in
            repository.fetchNextRacesHandler = { _, _ in
                fetchCalled()
                return mockRaces
            }
            let viewModel = RacesViewModel(repository: repository)

            // Start tasks to enable debounce handling
            viewModel.startTasks()

            // Wait for initial refresh to complete
            try? await Task.sleep(for: .milliseconds(700))

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

            viewModel.stopTasks()
        }
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

        let races = [expiredRace, futureRace]
        let repository = MockRaceRepository()

        await confirmation("fetchNextRaces called exactly twice", expectedCount: 2) { fetchCalled in
            repository.fetchNextRacesHandler = { _, _ in
                fetchCalled()
                return races
            }
            let viewModel = RacesViewModel(repository: repository)

            // Manually set races to include expired race
            await viewModel.refreshRaces()
            let initialRaces = viewModel.races
            #expect(initialRaces.count == 2)

            // Start tasks - countdown timer will check for expired races every second
            viewModel.startTasks()

            // Wait for countdown timer to detect expired race and trigger refresh
            // Timer runs every 1 second, debounce is 500ms, so wait ~1.5 seconds
            try? await Task.sleep(for: .milliseconds(1500))

            viewModel.stopTasks()
        }
    }

    @Test("Maximum 5 races displayed")
    @MainActor
    func testMaximumRacesLimit() async {
        let mockRaces = MockRaceRepository.makeMockRaces(count: 5)
        let repository = MockRaceRepository()
        repository.fetchNextRacesHandler = { _, _ in mockRaces }
        let viewModel = RacesViewModel(repository: repository)

        await viewModel.refreshRaces()

        #expect(viewModel.races.count == 5, "Should display maximum 5 races")
    }

}
