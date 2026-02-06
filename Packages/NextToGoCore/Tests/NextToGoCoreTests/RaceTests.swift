import Foundation
@testable import NextToGoCore
import Testing

@Suite("Race Model Tests")
struct RaceTests {

    @Test("Race initializes with correct properties")
    func testRaceInitialization() {
        let date = Date()
        let race = Self.makeRace(advertisedStart: date)

        #expect(race.raceId == "test-id")
        #expect(race.raceName == "Test Race")
        #expect(race.raceNumber == 1)
        #expect(race.meetingName == "Test Meeting")
        #expect(race.categoryId == RaceCategory.horse.id)
        #expect(race.advertisedStart == date)
    }

    @Test("Race is not expired when in the future")
    func testRaceNotExpired() {
        let futureDate = Date.now.addingTimeInterval(120) // 2 minutes in the future
        let race = Self.makeRace(advertisedStart: futureDate)

        #expect(!race.isExpired)
    }

    @Test("Race is expired when more than 60 seconds in the past")
    func testRaceExpired() {
        let pastDate = Date.now.addingTimeInterval(-120) // 2 minutes in the past
        let race = Self.makeRace(advertisedStart: pastDate)

        #expect(race.isExpired)
    }

    @Test("Race is not expired when less than 60 seconds in the past")
    func testRaceNotExpiredWithinThreshold() {
        let pastDate = Date.now.addingTimeInterval(-30)
        let race = Self.makeRace(advertisedStart: pastDate)
        #expect(!race.isExpired)
    }

    @Test("Race decodes from JSON with nested advertised_start")
    func testRaceDecoding() throws {
        let json = """
        {
            "race_id": "abc123",
            "race_name": "Melbourne Cup",
            "race_number": 7,
            "meeting_name": "Flemington",
            "category_id": "4a2788f8-e825-4d36-9894-efd4baf1cfae",
            "advertised_start": {
                "seconds": 1704067200
            }
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let race = try decoder.decode(Race.self, from: data)

        #expect(race.raceId == "abc123")
        #expect(race.raceName == "Melbourne Cup")
        #expect(race.raceNumber == 7)
        #expect(race.meetingName == "Flemington")
        #expect(race.categoryId == "4a2788f8-e825-4d36-9894-efd4baf1cfae")
        #expect(race.advertisedStart.timeIntervalSince1970 == 1704067200)
    }

    @Test("Race category mapping for horse racing")
    func testHorseCategoryMapping() {
        let race = Race(
            raceId: "test-id",
            raceName: "Test Race",
            raceNumber: 1,
            meetingName: "Test Meeting",
            categoryId: "4a2788f8-e825-4d36-9894-efd4baf1cfae",
            advertisedStart: Date.now
        )

        let category = RaceCategory(id: race.categoryId)
        #expect(category == .horse)
    }

    @Test("Race category mapping for greyhound racing")
    func testGreyhoundCategoryMapping() {
        let race = Race(
            raceId: "test-id",
            raceName: "Test Race",
            raceNumber: 1,
            meetingName: "Test Meeting",
            categoryId: "9daef0d7-bf3c-4f50-921d-8e818c60fe61",
            advertisedStart: Date.now
        )

        let category = RaceCategory(id: race.categoryId)
        #expect(category == .greyhound)
    }

    @Test("Race category mapping for harness racing")
    func testHarnessCategoryMapping() {
        let race = Race(
            raceId: "test-id",
            raceName: "Test Race",
            raceNumber: 1,
            meetingName: "Test Meeting",
            categoryId: "161d9be2-e909-4326-8c2c-35ed71fb460b",
            advertisedStart: Date.now
        )

        let category = RaceCategory(id: race.categoryId)
        #expect(category == .harness)
    }

    @Test("Race category returns nil for unsupported category ID")
    func testUnsupportedCategoryMapping() {
        let unsupportedId = "00000000-0000-0000-0000-000000000000"
        let category = RaceCategory(id: unsupportedId)

        #expect(category == nil)
    }
}

// MARK: - Test Helpers

private extension RaceTests {

    /// Helper function to create a Race with default values for testing
    /// - Parameters:
    ///   - raceId: The race identifier (default: "test-id")
    ///   - raceName: The race name (default: "Test Race")
    ///   - raceNumber: The race number (default: 1)
    ///   - meetingName: The meeting name (default: "Test Meeting")
    ///   - categoryId: The category identifier (default: horse)
    ///   - advertisedStart: The advertised start time (default: Date.now)
    /// - Returns: A Race instance with the specified or default values
    static func makeRace(
        raceId: String = "test-id",
        raceName: String = "Test Race",
        raceNumber: Int = 1,
        meetingName: String = "Test Meeting",
        categoryId: String = RaceCategory.horse.id,
        advertisedStart: Date = Date.now
    ) -> Race {

        Race(
            raceId: raceId,
            raceName: raceName,
            raceNumber: raceNumber,
            meetingName: meetingName,
            categoryId: categoryId,
            advertisedStart: advertisedStart
        )

    }

}
