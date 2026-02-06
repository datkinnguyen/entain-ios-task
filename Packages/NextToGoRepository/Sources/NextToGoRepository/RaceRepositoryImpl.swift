import Foundation
import NextToGoCore
import NextToGoNetworking

/// Implementation of the race repository that fetches data from the API
public actor RaceRepositoryImpl: RaceRepositoryProtocol {
    private let apiClient: any APIClientProtocol

    /// Creates a new race repository with the specified API client
    /// - Parameter apiClient: The API client to use for network requests
    public init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    /// Fetches the next races to go based on the specified count and categories
    /// - Parameters:
    ///   - count: The maximum number of races to fetch
    ///   - categories: The set of race categories to filter by. Empty set means all categories.
    /// - Returns: An array of Race objects sorted by advertised start time
    /// - Throws: An error if the fetch operation fails
    public func fetchNextRaces(count: Int, categories: Set<RaceCategory>) async throws -> [Race] {
        // Empty categories means "all categories" - pass all category IDs to API
        let categoryIds = categories.isEmpty ? RaceCategory.allCases.map { $0.id } : categories.map { $0.id }

        // Create endpoint
        let endpoint = APIEndpoint.nextRaces(count: count, categoryIds: categoryIds)

        // Fetch data from API
        let response: RaceResponse = try await apiClient.fetch(endpoint)

        // Filter races by category (client-side validation)
        // Note: Races with unknown categories are already filtered out during decoding
        let validRaces = response.races.filter { race in
            categoryIds.contains(race.category.id)
        }

        // Filter out expired races and sort by start time
        // Note: Backend should not send expired races, but we filter client-side as defensive programming
        let activeRaces = validRaces
            .filter { !$0.isExpired }
            .sorted { $0.advertisedStart < $1.advertisedStart }

        return activeRaces
    }
}
