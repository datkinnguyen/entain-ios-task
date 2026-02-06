import Foundation
import NextToGoCore

/// Response wrapper for the Next to Go API race data
public struct RaceResponse: Decodable {
    public let status: Int
    public let races: [Race]

    enum CodingKeys: String, CodingKey {
        case status
        case data
    }

    enum DataKeys: String, CodingKey {

        case raceSummaries

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
