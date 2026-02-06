import Testing
import Foundation
@testable import NextToGoCore

@Suite("Race Model Tests")
struct RaceTests {

    @Test("Race initializes with correct properties")
    func testRaceInitialization() {
        let date = Date()
        let race = Race(
            raceId: "test-id",
            raceName: "Test Race",
            raceNumber: 1,
            meetingName: "Test Meeting",
            categoryId: RaceCategory.horse.id,
            advertisedStart: date
        )

        #expect(race.raceId == "test-id")
        #expect(race.raceName == "Test Race")
        #expect(race.raceNumber == 1)
        #expect(race.meetingName == "Test Meeting")
        #expect(race.categoryId == RaceCategory.horse.id)
        #expect(race.advertisedStart == date)
        #expect(race.id == "test-id")
    }

    @Test("Race is not expired when in the future")
    func testRaceNotExpired() {
        let futureDate = Date.now.addingTimeInterval(120) // 2 minutes in the future
        let race = Race(
            raceId: "test-id",
            raceName: "Test Race",
            raceNumber: 1,
            meetingName: "Test Meeting",
            categoryId: RaceCategory.horse.id,
            advertisedStart: futureDate
        )

        #expect(!race.isExpired)
    }

    @Test("Race is expired when more than 60 seconds in the past")
    func testRaceExpired() {
        let pastDate = Date.now.addingTimeInterval(-120) // 2 minutes in the past
        let race = Race(
            raceId: "test-id",
            raceName: "Test Race",
            raceNumber: 1,
            meetingName: "Test Meeting",
            categoryId: RaceCategory.horse.id,
            advertisedStart: pastDate
        )

        #expect(race.isExpired)
    }

    @Test("Race is not expired at the 60 second threshold")
    func testRaceNotExpiredAt60Seconds() {
        // Use 59 seconds to avoid timing issues between date creation and expiry check
        let pastDate = Date.now.addingTimeInterval(-59) // 59 seconds in the past
        let race = Race(
            raceId: "test-id",
            raceName: "Test Race",
            raceNumber: 1,
            meetingName: "Test Meeting",
            categoryId: RaceCategory.horse.id,
            advertisedStart: pastDate
        )

        #expect(!race.isExpired)
    }

    @Test("Race is not expired when less than 60 seconds in the past")
    func testRaceNotExpiredWithinThreshold() {
        let pastDate = Date.now.addingTimeInterval(-30) // 30 seconds in the past
        let race = Race(
            raceId: "test-id",
            raceName: "Test Race",
            raceNumber: 1,
            meetingName: "Test Meeting",
            categoryId: RaceCategory.horse.id,
            advertisedStart: pastDate
        )

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

    @Test("Race encodes to JSON with nested advertised_start")
    func testRaceEncoding() throws {
        let date = Date(timeIntervalSince1970: 1704067200)
        let race = Race(
            raceId: "abc123",
            raceName: "Melbourne Cup",
            raceNumber: 7,
            meetingName: "Flemington",
            categoryId: RaceCategory.horse.id,
            advertisedStart: date
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(race)
        let json = String(data: data, encoding: .utf8)!

        #expect(json.contains("\"race_id\":\"abc123\""))
        #expect(json.contains("\"race_name\":\"Melbourne Cup\""))
        #expect(json.contains("\"race_number\":7"))
        #expect(json.contains("\"meeting_name\":\"Flemington\""))
        #expect(json.contains("\"category_id\":\"4a2788f8-e825-4d36-9894-efd4baf1cfae\""))
        #expect(json.contains("\"advertised_start\":{\"seconds\":1704067200"))
    }

    @Test("Race roundtrip encoding and decoding")
    func testRaceRoundtrip() throws {
        let originalDate = Date(timeIntervalSince1970: 1704067200)
        let originalRace = Race(
            raceId: "test-123",
            raceName: "Test Race",
            raceNumber: 5,
            meetingName: "Test Meeting",
            categoryId: RaceCategory.greyhound.id,
            advertisedStart: originalDate
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(originalRace)

        let decoder = JSONDecoder()
        let decodedRace = try decoder.decode(Race.self, from: data)

        #expect(decodedRace.raceId == originalRace.raceId)
        #expect(decodedRace.raceName == originalRace.raceName)
        #expect(decodedRace.raceNumber == originalRace.raceNumber)
        #expect(decodedRace.meetingName == originalRace.meetingName)
        #expect(decodedRace.categoryId == originalRace.categoryId)
        #expect(decodedRace.advertisedStart == originalRace.advertisedStart)
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
}
