import Foundation
import NextToGoCore
@testable import NextToGoNetworking
import Testing

@Suite("RaceResponse Tests")
struct RaceResponseTests {

    @Test("RaceResponse decodes valid JSON correctly")
    // swiftlint:disable:next function_body_length
    func testDecodeValidJSON() throws {
        // Given: Valid API response JSON
        let json = """
        {
            "status": 200,
            "data": {
                "race_summaries": {
                    "race-1": {
                        "race_id": "race-1",
                        "race_name": "Race 1",
                        "race_number": 1,
                        "meeting_name": "Meeting 1",
                        "category_id": "9daef0d7-bf3c-4f50-921d-8e818c60fe61",
                        "advertised_start": {
                            "seconds": 1706745600
                        }
                    },
                    "race-2": {
                        "race_id": "race-2",
                        "race_name": "Race 2",
                        "race_number": 2,
                        "meeting_name": "Meeting 2",
                        "category_id": "161d9be2-e909-4326-8c2c-35ed71fb460b",
                        "advertised_start": {
                            "seconds": 1706745700
                        }
                    }
                }
            }
        }
        """

        // When: Decoding JSON
        let decoder = JSONDecoder()
        let data = json.data(using: .utf8)!
        let response = try decoder.decode(RaceResponse.self, from: data)

        // Then: Response should be properly decoded
        #expect(response.status == 200)
        #expect(response.races.count == 2)

        // Verify first race
        let race1 = response.races[0]
        #expect(race1.raceId == "race-1")
        #expect(race1.raceName == "Race 1")
        #expect(race1.raceNumber == 1)
        #expect(race1.meetingName == "Meeting 1")
        #expect(race1.categoryId == "9daef0d7-bf3c-4f50-921d-8e818c60fe61")

        // Verify second race
        let race2 = response.races[1]
        #expect(race2.raceId == "race-2")
        #expect(race2.raceName == "Race 2")
        #expect(race2.raceNumber == 2)
        #expect(race2.meetingName == "Meeting 2")
        #expect(race2.categoryId == "161d9be2-e909-4326-8c2c-35ed71fb460b")
    }

    @Test("RaceResponse sorts races by advertised start")
    // swiftlint:disable:next function_body_length
    func testRacesSortedByAdvertisedStart() throws {
        // Given: API response with races in random order
        let json = """
        {
            "status": 200,
            "data": {
                "race_summaries": {
                    "race-3": {
                        "race_id": "race-3",
                        "race_name": "Race 3",
                        "race_number": 3,
                        "meeting_name": "Meeting 3",
                        "category_id": "9daef0d7-bf3c-4f50-921d-8e818c60fe61",
                        "advertised_start": {
                            "seconds": 1706745900
                        }
                    },
                    "race-1": {
                        "race_id": "race-1",
                        "race_name": "Race 1",
                        "race_number": 1,
                        "meeting_name": "Meeting 1",
                        "category_id": "161d9be2-e909-4326-8c2c-35ed71fb460b",
                        "advertised_start": {
                            "seconds": 1706745600
                        }
                    },
                    "race-2": {
                        "race_id": "race-2",
                        "race_name": "Race 2",
                        "race_number": 2,
                        "meeting_name": "Meeting 2",
                        "category_id": "4a2788f8-e825-4d36-9894-efd4baf1cfae",
                        "advertised_start": {
                            "seconds": 1706745700
                        }
                    }
                }
            }
        }
        """

        // When: Decoding JSON
        let decoder = JSONDecoder()
        let data = json.data(using: .utf8)!
        let response = try decoder.decode(RaceResponse.self, from: data)

        // Then: Races should be sorted by advertised start (earliest first)
        #expect(response.races.count == 3)
        #expect(response.races[0].raceId == "race-1")
        #expect(response.races[1].raceId == "race-2")
        #expect(response.races[2].raceId == "race-3")

        // Verify sorting order
        #expect(response.races[0].advertisedStart < response.races[1].advertisedStart)
        #expect(response.races[1].advertisedStart < response.races[2].advertisedStart)
    }

    @Test("RaceResponse decodes empty race summaries")
    func testDecodeEmptyRaceSummaries() throws {
        // Given: API response with empty race summaries
        let json = """
        {
            "status": 200,
            "data": {
                "race_summaries": {}
            }
        }
        """

        // When: Decoding JSON
        let decoder = JSONDecoder()
        let data = json.data(using: .utf8)!
        let response = try decoder.decode(RaceResponse.self, from: data)

        // Then: Response should have empty races array
        #expect(response.status == 200)
        #expect(response.races.isEmpty)
    }

    @Test("RaceResponse throws error on missing status")
    func testDecodeMissingStatus() throws {
        // Given: JSON missing status field
        let json = """
        {
            "data": {
                "race_summaries": {}
            }
        }
        """

        // When/Then: Decoding should throw error
        let decoder = JSONDecoder()
        let data = json.data(using: .utf8)!

        #expect(throws: DecodingError.self) {
            _ = try decoder.decode(RaceResponse.self, from: data)
        }
    }

    @Test("RaceResponse throws error on missing data")
    func testDecodeMissingData() throws {
        // Given: JSON missing data field
        let json = """
        {
            "status": 200
        }
        """

        // When/Then: Decoding should throw error
        let decoder = JSONDecoder()
        let data = json.data(using: .utf8)!

        #expect(throws: DecodingError.self) {
            _ = try decoder.decode(RaceResponse.self, from: data)
        }
    }

    @Test("RaceResponse throws error on missing race_summaries")
    func testDecodeMissingRaceSummaries() throws {
        // Given: JSON missing race_summaries field
        let json = """
        {
            "status": 200,
            "data": {}
        }
        """

        // When/Then: Decoding should throw error
        let decoder = JSONDecoder()
        let data = json.data(using: .utf8)!

        #expect(throws: DecodingError.self) {
            _ = try decoder.decode(RaceResponse.self, from: data)
        }
    }

    @Test("RaceResponse handles different status codes")
    func testDecodeDifferentStatusCodes() throws {
        // Given: API response with non-200 status
        let json = """
        {
            "status": 500,
            "data": {
                "race_summaries": {}
            }
        }
        """

        // When: Decoding JSON
        let decoder = JSONDecoder()
        let data = json.data(using: .utf8)!
        let response = try decoder.decode(RaceResponse.self, from: data)

        // Then: Status should be preserved
        #expect(response.status == 500)
        #expect(response.races.isEmpty)
    }
}
