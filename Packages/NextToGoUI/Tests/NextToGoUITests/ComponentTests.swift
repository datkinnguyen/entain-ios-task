import NextToGoCore
@testable import NextToGoUI
import NextToGoViewModel
import SwiftUI
import Testing

/// Unit tests for UI components to ensure they can be instantiated.
@Suite("Component Tests")
@MainActor
struct ComponentTests {

    @Test("CountdownBadge can be created")
    func countdownBadgeCanBeCreated() {
        _ = CountdownBadge(
            advertisedStart: Date.now.addingTimeInterval(600),
            currentTime: .now
        )
    }

    @Test("CategoryChip can be created")
    func categoryChipCanBeCreated() {
        _ = CategoryChip(
            category: .horse,
            isSelected: true
        ) {}
    }

    @Test("RaceRowView can be created")
    func raceRowViewCanBeCreated() {
        let race = Race(
            raceId: "test",
            raceName: "Test Race",
            raceNumber: 1,
            meetingName: "Test Meeting",
            categoryId: RaceCategory.horse.id,
            advertisedStart: Date.now.addingTimeInterval(600)
        )
        _ = RaceRowView(race: race)
    }

    @Test("CategoryFilterView can be created")
    func categoryFilterViewCanBeCreated() {
        @State var selectedCategories: Set<RaceCategory> = [.horse]
        _ = CategoryFilterView(selectedCategories: $selectedCategories)
    }

    @Test("LoadingView can be created")
    func loadingViewCanBeCreated() {
        _ = LoadingView()
    }

    @Test("ErrorView can be created")
    func errorViewCanBeCreated() {
        let error = NSError(domain: "Test", code: -1)
        _ = ErrorView(error: error) {}
    }

    @Test("RacesListView can be created")
    func racesListViewCanBeCreated() {
        let mockRepository = MockRaceRepository()
        let viewModel = RacesViewModel(repository: mockRepository)
        _ = RacesListView(viewModel: viewModel)
    }

}

// MARK: - Test Helpers

private extension ComponentTests {

    final class MockRaceRepository: RaceRepositoryProtocol, @unchecked Sendable {

        func fetchNextRaces(count: Int, categories: Set<RaceCategory>) async throws -> [Race] {
            []
        }

    }

}
