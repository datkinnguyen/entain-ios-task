import Foundation
import NextToGoCore
import NextToGoRepository
import NextToGoViewModel

// MARK: - Preview Helpers

/// Creates a mock repository configured for success scenarios in previews.
func createSuccessMockRepository() -> MockRaceRepository {
    let mock = MockRaceRepository()
    mock.fetchNextRacesHandler = { count, _ in
        Array(MockRaceRepository.defaultPreviewRaces.prefix(count))
    }
    return mock
}

/// Creates a mock repository configured for empty scenarios in previews.
func createEmptyMockRepository() -> MockRaceRepository {
    let mock = MockRaceRepository()
    mock.fetchNextRacesHandler = { _, _ in [] }
    return mock
}

/// Creates a mock repository configured for error scenarios in previews.
func createErrorMockRepository() -> MockRaceRepository {
    let mock = MockRaceRepository()
    mock.fetchNextRacesHandler = { _, _ in
        throw MockRaceRepository.MockError.networkUnavailable
    }
    return mock
}

/// Creates a mock repository configured with delayed responses in previews.
func createDelayedMockRepository() -> MockRaceRepository {
    let mock = MockRaceRepository()
    mock.fetchNextRacesHandler = { count, _ in
        try? await Task.sleep(for: .seconds(2))
        return Array(MockRaceRepository.defaultPreviewRaces.prefix(count))
    }
    return mock
}
