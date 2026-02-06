import Foundation

/// Represents a race with details including timing, category, and identification.
/// Note: Encodable conformance is provided for testing purposes only
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

    // Custom decoding to handle nested advertised_start structure
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

    private enum CodingKeys: String, CodingKey {

        case raceId, raceName, raceNumber, meetingName, categoryId, advertisedStart

    }

    private enum AdvertisedStartKeys: String, CodingKey {

        case seconds

    }

}
