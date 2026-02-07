import Foundation
import NextToGoCore
import NextToGoNetworking

/// Implementation of the race repository that fetches data from the API
public actor RaceRepositoryImpl: RaceRepositoryProtocol {
    private let apiClient: any APIClientProtocol

    /// Number of races to fetch from API (fetch more than requested to ensure enough after filtering)
    private let apiFetchMultiplier = 2

    /// Creates a new race repository with the specified API client
    /// - Parameter apiClient: The API client to use for network requests
    public init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    /// Fetches the next races to go based on the specified count and categories
    /// - Parameters:
    ///   - count: The maximum number of races to return
    ///   - categories: The set of race categories to filter by. Empty set returns all categories.
    /// - Returns: An array of up to `count` Race objects sorted by advertised start time
    /// - Throws: An error if the fetch operation fails
    public func fetchNextRaces(count: Int, categories: Set<RaceCategory>) async throws -> [Race] {
        // Fetch more races from API than requested to ensure we have enough after filtering
        // API doesn't support category filtering, so we need extra races
        let apiCount = count * apiFetchMultiplier
        let endpoint = APIEndpoint.nextRaces(count: apiCount)

        // Fetch data from API
        let response: RaceResponse = try await apiClient.fetch(endpoint)

        // Filter races by category (client-side filtering)
        // Empty categories means "all categories"
        // Note: Races with unknown categories are already filtered out during decoding
        let validRaces: [Race]
        if categories.isEmpty {
            validRaces = response.races
        } else {
            let categoryIds = categories.map { $0.id }
            validRaces = response.races.filter { race in
                categoryIds.contains(race.category.id)
            }
        }

        // Filter out expired races and sort by start time, then by race name
        // Note: Backend should not send expired races, but we filter client-side as defensive programming
        let activeRaces = validRaces
            .filter { !$0.isExpired }
            .sorted { lhs, rhs in
                if lhs.advertisedStart == rhs.advertisedStart {
                    return lhs.raceName < rhs.raceName
                }
                return lhs.advertisedStart < rhs.advertisedStart
            }

        // Cap the results to the requested count
        return Array(activeRaces.prefix(count))
    }
}
