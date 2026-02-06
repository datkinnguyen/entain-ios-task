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
    ///   - categories: The set of race categories to filter by
    /// - Returns: An array of Race objects sorted by advertised start time
    /// - Throws: An error if the fetch operation fails
    public func fetchNextRaces(count: Int, categories: Set<RaceCategory>) async throws -> [Race] {
        // Build category IDs for API filter
        let categoryIds = categories.isEmpty ? nil : categories.map { $0.id }

        // Create endpoint
        let endpoint = APIEndpoint.nextRaces(count: count, categoryIds: categoryIds)

        // Fetch data from API
        let response: RaceResponse = try await apiClient.fetch(endpoint)

        // Filter races by category (client-side validation)
        let validRaces = response.races.filter { race in
            // If no categories specified, include all races
            guard !categories.isEmpty else { return true }

            // Check if race belongs to one of the selected categories
            return categories.contains { $0.id == race.categoryId }
        }

        // Filter out expired races and sort by start time
        let activeRaces = validRaces
            .filter { !$0.isExpired }
            .sorted { $0.advertisedStart < $1.advertisedStart }

        return activeRaces
    }
}
