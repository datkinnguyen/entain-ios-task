import Foundation

/// Represents a race with details including timing, category, and identification.
public struct Race: Codable, Identifiable, Sendable {
    public let raceId: String
    public let raceName: String
    public let raceNumber: Int
    public let meetingName: String
    public let categoryId: String
    public let advertisedStart: Date

    public var id: String { raceId }

    /// Returns true if the race started more than the configured expiry threshold ago
    public var isExpired: Bool {
        let expiryThreshold = AppConfiguration.expiryThreshold
        return advertisedStart.timeIntervalSince(Date.now) < -expiryThreshold
    }

    enum CodingKeys: String, CodingKey {
        case raceId = "race_id"
        case raceName = "race_name"
        case raceNumber = "race_number"
        case meetingName = "meeting_name"
        case categoryId = "category_id"
        case advertisedStart = "advertised_start"
    }

    public init(
        raceId: String,
        raceName: String,
        raceNumber: Int,
        meetingName: String,
        categoryId: String,
        advertisedStart: Date
    ) {
        self.raceId = raceId
        self.raceName = raceName
        self.raceNumber = raceNumber
        self.meetingName = meetingName
        self.categoryId = categoryId
        self.advertisedStart = advertisedStart
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        raceId = try container.decode(String.self, forKey: .raceId)
        raceName = try container.decode(String.self, forKey: .raceName)
        raceNumber = try container.decode(Int.self, forKey: .raceNumber)
        meetingName = try container.decode(String.self, forKey: .meetingName)
        categoryId = try container.decode(String.self, forKey: .categoryId)

        // Parse advertised_start which is { "seconds": Int }
        let advertisedStartContainer = try container.nestedContainer(keyedBy: AdvertisedStartKeys.self, forKey: .advertisedStart)
        let seconds = try advertisedStartContainer.decode(TimeInterval.self, forKey: .seconds)
        advertisedStart = Date(timeIntervalSince1970: seconds)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(raceId, forKey: .raceId)
        try container.encode(raceName, forKey: .raceName)
        try container.encode(raceNumber, forKey: .raceNumber)
        try container.encode(meetingName, forKey: .meetingName)
        try container.encode(categoryId, forKey: .categoryId)

        // Encode advertised_start as { "seconds": Int }
        var advertisedStartContainer = container.nestedContainer(keyedBy: AdvertisedStartKeys.self, forKey: .advertisedStart)
        try advertisedStartContainer.encode(advertisedStart.timeIntervalSince1970, forKey: .seconds)
    }

    private enum AdvertisedStartKeys: String, CodingKey {
        case seconds
    }
}
