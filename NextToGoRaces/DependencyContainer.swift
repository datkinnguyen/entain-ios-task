//
//  DependencyContainer.swift
//  NextToGoRaces
//

import Foundation
import NextToGoCore
import NextToGoNetworking
import NextToGoRepository
import NextToGoViewModel

/// Main dependency injection container for the application.
///
/// Manages the lifecycle and dependencies of core application components:
/// - APIClient for network requests
/// - RaceRepository for data fetching
/// - RacesViewModel for state management
@MainActor
final class DependencyContainer {

    // MARK: - Properties

    /// The shared API client instance
    let apiClient: APIClient

    /// The race repository implementation
    let repository: RaceRepositoryProtocol

    /// The races view model
    let racesViewModel: RacesViewModel

    // MARK: - Initialisation

    /// Creates a new dependency container with default production dependencies.
    init() {
        self.apiClient = APIClient()
        self.repository = RaceRepositoryImpl(apiClient: apiClient)
        self.racesViewModel = RacesViewModel(repository: repository)
    }

    /// Creates a dependency container with custom dependencies for testing.
    ///
    /// - Parameters:
    ///   - apiClient: Custom API client (for testing)
    ///   - repository: Custom repository implementation (for testing)
    init(
        apiClient: APIClient,
        repository: RaceRepositoryProtocol
    ) {
        self.apiClient = apiClient
        self.repository = repository
        self.racesViewModel = RacesViewModel(repository: repository)
    }

}
