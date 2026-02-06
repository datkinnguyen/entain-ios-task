import Foundation

/// Protocol defining the contract for fetching race data.
public protocol RaceRepositoryProtocol: Sendable {

    /// Fetches the next races to go based on the specified count and categories.
    ///
    /// - Parameters:
    ///   - count: The maximum number of races to fetch
    ///   - categories: The set of race categories to filter by
    /// - Returns: An array of Race objects sorted by advertised start time
    /// - Throws: An error if the fetch operation fails
    func fetchNextRaces(count: Int, categories: Set<RaceCategory>) async throws -> [Race]

}
