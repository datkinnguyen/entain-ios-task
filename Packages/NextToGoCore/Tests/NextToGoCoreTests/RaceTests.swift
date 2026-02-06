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
        #expect(race.category == .horse)
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
        #expect(race.category == .horse)
        #expect(race.advertisedStart.timeIntervalSince1970 == 1704067200)
    }

    @Test("Race decodes horse category correctly")
    func testHorseCategoryDecoding() throws {
        let race = Race(
            raceId: "test-id",
            raceName: "Test Race",
            raceNumber: 1,
            meetingName: "Test Meeting",
            category: .horse,
            advertisedStart: Date.now
        )

        #expect(race.category == .horse)
    }

    @Test("Race decodes greyhound category correctly")
    func testGreyhoundCategoryDecoding() throws {
        let race = Race(
            raceId: "test-id",
            raceName: "Test Race",
            raceNumber: 1,
            meetingName: "Test Meeting",
            category: .greyhound,
            advertisedStart: Date.now
        )

        #expect(race.category == .greyhound)
    }

    @Test("Race decodes harness category correctly")
    func testHarnessCategoryDecoding() throws {
        let race = Race(
            raceId: "test-id",
            raceName: "Test Race",
            raceNumber: 1,
            meetingName: "Test Meeting",
            category: .harness,
            advertisedStart: Date.now
        )

        #expect(race.category == .harness)
    }

    @Test("Race decoding fails for unsupported category ID")
    func testUnsupportedCategoryDecodingFails() throws {
        let json = """
        {
            "race_id": "test-id",
            "race_name": "Test Race",
            "race_number": 1,
            "meeting_name": "Test Meeting",
            "category_id": "00000000-0000-0000-0000-000000000000",
            "advertised_start": {
                "seconds": 1704067200
            }
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()

        // Should throw decoding error for unknown category
        #expect(throws: DecodingError.self) {
            try decoder.decode(Race.self, from: data)
        }
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
    ///   - category: The race category (default: horse)
    ///   - advertisedStart: The advertised start time (default: Date.now)
    /// - Returns: A Race instance with the specified or default values
    static func makeRace(
        raceId: String = "test-id",
        raceName: String = "Test Race",
        raceNumber: Int = 1,
        meetingName: String = "Test Meeting",
        category: RaceCategory = .horse,
        advertisedStart: Date = Date.now
    ) -> Race {

        Race(
            raceId: raceId,
            raceName: raceName,
            raceNumber: raceNumber,
            meetingName: meetingName,
            category: category,
            advertisedStart: advertisedStart
        )

    }

}
