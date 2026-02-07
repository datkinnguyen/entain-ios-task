import Foundation
import NextToGoCore

/// Response wrapper for the Next to Go API race data
public struct RaceResponse: Decodable, Sendable {

    public let status: Int
    public let races: [Race]

    /// Public initializer for testing purposes
    /// - Parameters:
    ///   - status: HTTP status code
    ///   - races: Array of races
    public init(status: Int, races: [Race]) {
        self.status = status
        self.races = races
    }

    enum CodingKeys: String, CodingKey {
        case status
        case data
    }

    enum DataKeys: String, CodingKey {
        case raceSummaries = "race_summaries"
    }

    /// Custom decoder that unwraps the nested dictionary structure and converts to array
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Int.self, forKey: .status)

        // Decode nested data container
        let dataContainer = try container.nestedContainer(keyedBy: DataKeys.self, forKey: .data)

        // Decode race_summaries as a dictionary [String: Race]
        let raceSummaries = try dataContainer.decode([String: Race].self, forKey: .raceSummaries)

        // Convert dictionary values to array and sort by advertisedStart
        races = raceSummaries.values.sorted { $0.advertisedStart < $1.advertisedStart }
    }

}
