import Foundation

/// Protocol defining the contract for fetching race data.
public protocol RaceRepositoryProtocol: Sendable {

    /// Fetches the next races to go based on the specified count and categories.
    ///
    /// - Parameters:
    ///   - count: The maximum number of races to return (implementation may fetch more from API to ensure enough races)
    ///   - categories: The set of race categories to filter by. Empty set returns all categories.
    /// - Returns: An array of up to `count` Race objects sorted by advertised start time
    /// - Throws: An error if the fetch operation fails
    func fetchNextRaces(count: Int, categories: Set<RaceCategory>) async throws -> [Race]

}
