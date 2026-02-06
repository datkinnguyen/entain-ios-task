import Foundation

/// Represents a race with details including timing, category, and identification.
///
/// Races with unknown category IDs (not matching Horse, Harness, or Greyhound) will fail to decode
/// and be automatically filtered out from the results.
public struct Race: Decodable, Equatable, Sendable {

    public let raceId: String
    public let raceName: String
    public let raceNumber: Int
    public let meetingName: String
    public let category: RaceCategory
    public let advertisedStart: Date

    /// Returns true if the race started more than the configured expiry threshold ago
    public var isExpired: Bool {
        let expiryThreshold = AppConfiguration.expiryThreshold
        return advertisedStart.timeIntervalSince(Date.now) < -expiryThreshold
    }

    public init(
        raceId: String,
        raceName: String,
        raceNumber: Int,
        meetingName: String,
        category: RaceCategory,
        advertisedStart: Date
    ) {
        self.raceId = raceId
        self.raceName = raceName
        self.raceNumber = raceNumber
        self.meetingName = meetingName
        self.category = category
        self.advertisedStart = advertisedStart
    }

    // Custom decoding to handle nested advertised_start structure and category validation
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        raceId = try container.decode(String.self, forKey: .raceId)
        raceName = try container.decode(String.self, forKey: .raceName)
        raceNumber = try container.decode(Int.self, forKey: .raceNumber)
        meetingName = try container.decode(String.self, forKey: .meetingName)

        // Decode categoryId and convert to RaceCategory - fail if unknown category
        let categoryId = try container.decode(String.self, forKey: .categoryId)
        guard let decodedCategory = RaceCategory(id: categoryId) else {
            throw DecodingError.dataCorruptedError(
                forKey: .categoryId,
                in: container,
                debugDescription: "Unknown category ID: \(categoryId)"
            )
        }
        category = decodedCategory

        // Parse advertised_start which is { "seconds": Int }
        let advertisedStartContainer = try container.nestedContainer(
            keyedBy: AdvertisedStartKeys.self,
            forKey: .advertisedStart
        )
        let seconds = try advertisedStartContainer.decode(TimeInterval.self, forKey: .seconds)
        advertisedStart = Date(timeIntervalSince1970: seconds)
    }

    private enum CodingKeys: String, CodingKey {
        case raceId = "race_id"
        case raceName = "race_name"
        case raceNumber = "race_number"
        case meetingName = "meeting_name"
        case categoryId = "category_id"
        case advertisedStart = "advertised_start"
    }

    private enum AdvertisedStartKeys: String, CodingKey {
        case seconds
    }

}
