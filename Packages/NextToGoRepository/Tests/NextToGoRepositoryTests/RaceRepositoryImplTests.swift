import Testing
import Foundation
import NextToGoCore
import NextToGoNetworking
@testable import NextToGoRepository

@Suite("RaceRepositoryImpl Tests")
struct RaceRepositoryImplTests {

    // MARK: - Helper Methods

    func createMockRaces() -> [Race] {
        let now = Date.now
        return [
            Race(
                raceId: "race1",
                raceName: "Race 1",
                raceNumber: 1,
                meetingName: "Meeting A",
                categoryId: RaceCategory.horse.id,
                advertisedStart: now.addingTimeInterval(300) // 5 minutes from now
            ),
            Race(
                raceId: "race2",
                raceName: "Race 2",
                raceNumber: 2,
                meetingName: "Meeting B",
                categoryId: RaceCategory.greyhound.id,
                advertisedStart: now.addingTimeInterval(600) // 10 minutes from now
            ),
            Race(
                raceId: "race3",
                raceName: "Race 3",
                raceNumber: 3,
                meetingName: "Meeting C",
                categoryId: RaceCategory.harness.id,
                advertisedStart: now.addingTimeInterval(150) // 2.5 minutes from now
            ),
            Race(
                raceId: "race4",
                raceName: "Race 4",
                raceNumber: 4,
                meetingName: "Meeting D",
                categoryId: RaceCategory.horse.id,
                advertisedStart: now.addingTimeInterval(900) // 15 minutes from now
            ),
            Race(
                raceId: "expired_race",
                raceName: "Expired Race",
                raceNumber: 5,
                meetingName: "Meeting E",
                categoryId: RaceCategory.horse.id,
                advertisedStart: now.addingTimeInterval(-120) // 2 minutes ago (expired)
            )
        ]
    }

    func createMockResponse(races: [Race]) -> RaceResponse {
        // Create a manual RaceResponse since it uses custom decoding
        // We'll use the raw JSON approach
        let raceSummaries = races.enumerated().reduce(into: [String: Any]()) { dict, item in
            let (index, race) = item
            dict["race\(index)"] = [
                "race_id": race.raceId,
                "race_name": race.raceName,
                "race_number": race.raceNumber,
                "meeting_name": race.meetingName,
                "category_id": race.categoryId,
                "advertised_start": ["seconds": race.advertisedStart.timeIntervalSince1970]
            ]
        }

        let json: [String: Any] = [
            "status": 200,
            "data": [
                "race_summaries": raceSummaries
            ]
        ]

        let data = try! JSONSerialization.data(withJSONObject: json)
        let decoder = JSONDecoder()
        return try! decoder.decode(RaceResponse.self, from: data)
    }

    // MARK: - Tests

    @Test("Fetch races with all categories returns all non-expired races")
    func fetchRacesWithAllCategories() async throws {
        let mockClient = MockAPIClient()
        let repository = RaceRepositoryImpl(apiClient: mockClient)

        let mockRaces = createMockRaces()
        let mockResponse = createMockResponse(races: mockRaces)

        await mockClient.configure { endpoint in
            return mockResponse
        }

        let result = try await repository.fetchNextRaces(count: 10, categories: [])

        // Should return 4 races (excluding the expired one)
        #expect(result.count == 4)

        // Should not include expired race
        #expect(!result.contains { $0.raceId == "expired_race" })

        // Should be sorted by advertised start time
        let sortedIds = result.map { $0.raceId }
        #expect(sortedIds == ["race3", "race1", "race2", "race4"])
    }

    @Test("Fetch races with specific category filters correctly")
    func fetchRacesWithSpecificCategory() async throws {
        let mockClient = MockAPIClient()
        let repository = RaceRepositoryImpl(apiClient: mockClient)

        let mockRaces = createMockRaces()
        let mockResponse = createMockResponse(races: mockRaces)

        await mockClient.configure { endpoint in
            return mockResponse
        }

        let result = try await repository.fetchNextRaces(
            count: 10,
            categories: [.horse]
        )

        // Should return only horse races (excluding expired)
        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.categoryId == RaceCategory.horse.id })

        // Should be sorted by advertised start time
        let sortedIds = result.map { $0.raceId }
        #expect(sortedIds == ["race1", "race4"])
    }

    @Test("Fetch races with multiple categories filters correctly")
    func fetchRacesWithMultipleCategories() async throws {
        let mockClient = MockAPIClient()
        let repository = RaceRepositoryImpl(apiClient: mockClient)

        let mockRaces = createMockRaces()
        let mockResponse = createMockResponse(races: mockRaces)

        await mockClient.configure { endpoint in
            return mockResponse
        }

        let result = try await repository.fetchNextRaces(
            count: 10,
            categories: [.horse, .harness]
        )

        // Should return horse and harness races (excluding expired)
        #expect(result.count == 3)

        let categoryIds = Set(result.map { $0.categoryId })
        #expect(categoryIds == Set([RaceCategory.horse.id, RaceCategory.harness.id]))

        // Should be sorted by advertised start time
        let sortedIds = result.map { $0.raceId }
        #expect(sortedIds == ["race3", "race1", "race4"])
    }

    @Test("Fetch races excludes expired races")
    func fetchRacesExcludesExpired() async throws {
        let mockClient = MockAPIClient()
        let repository = RaceRepositoryImpl(apiClient: mockClient)

        let now = Date.now
        let expiredRaces = [
            Race(
                raceId: "expired1",
                raceName: "Expired 1",
                raceNumber: 1,
                meetingName: "Meeting A",
                categoryId: RaceCategory.horse.id,
                advertisedStart: now.addingTimeInterval(-120) // 2 minutes ago
            ),
            Race(
                raceId: "expired2",
                raceName: "Expired 2",
                raceNumber: 2,
                meetingName: "Meeting B",
                categoryId: RaceCategory.horse.id,
                advertisedStart: now.addingTimeInterval(-61) // Just over 1 minute ago
            ),
            Race(
                raceId: "active",
                raceName: "Active",
                raceNumber: 3,
                meetingName: "Meeting C",
                categoryId: RaceCategory.horse.id,
                advertisedStart: now.addingTimeInterval(300) // 5 minutes from now
            )
        ]

        let mockResponse = createMockResponse(races: expiredRaces)

        await mockClient.configure { endpoint in
            return mockResponse
        }

        let result = try await repository.fetchNextRaces(count: 10, categories: [])

        // Should only return the active race
        #expect(result.count == 1)
        #expect(result.first?.raceId == "active")
    }

    @Test("Fetch races with no matching categories returns empty")
    func fetchRacesWithNoMatchingCategories() async throws {
        let mockClient = MockAPIClient()
        let repository = RaceRepositoryImpl(apiClient: mockClient)

        // Create races with only horse category
        let horseRaces = [
            Race(
                raceId: "race1",
                raceName: "Race 1",
                raceNumber: 1,
                meetingName: "Meeting A",
                categoryId: RaceCategory.horse.id,
                advertisedStart: Date.now.addingTimeInterval(300)
            )
        ]

        let mockResponse = createMockResponse(races: horseRaces)

        await mockClient.configure { endpoint in
            return mockResponse
        }

        // Request only greyhound races
        let result = try await repository.fetchNextRaces(
            count: 10,
            categories: [.greyhound]
        )

        // Should return empty array
        #expect(result.isEmpty)
    }

    @Test("Fetch races passes correct endpoint parameters")
    func fetchRacesPassesCorrectParameters() async throws {
        let mockClient = MockAPIClient()
        let repository = RaceRepositoryImpl(apiClient: mockClient)

        let mockResponse = createMockResponse(races: [])

        await mockClient.configure { endpoint in
            // Verify the endpoint is correct
            if case .nextRaces(let count, let categoryIds) = endpoint {
                #expect(count == 10)
                #expect(categoryIds == [RaceCategory.horse.id, RaceCategory.greyhound.id])
            } else {
                Issue.record("Expected nextRaces endpoint")
            }
            return mockResponse
        }

        _ = try await repository.fetchNextRaces(
            count: 10,
            categories: [.horse, .greyhound]
        )

        let callCount = await mockClient.fetchCallCount
        #expect(callCount == 1)
    }

    @Test("Fetch races with empty categories passes nil to endpoint")
    func fetchRacesWithEmptyCategoriesPassesNil() async throws {
        let mockClient = MockAPIClient()
        let repository = RaceRepositoryImpl(apiClient: mockClient)

        let mockResponse = createMockResponse(races: [])

        await mockClient.configure { endpoint in
            // Verify categoryIds is nil when no categories specified
            if case .nextRaces(let count, let categoryIds) = endpoint {
                #expect(count == 10)
                #expect(categoryIds == nil)
            } else {
                Issue.record("Expected nextRaces endpoint")
            }
            return mockResponse
        }

        _ = try await repository.fetchNextRaces(count: 10, categories: [])

        let callCount = await mockClient.fetchCallCount
        #expect(callCount == 1)
    }

    @Test("Fetch races sorts by advertised start time correctly")
    func fetchRacesSortsByStartTime() async throws {
        let mockClient = MockAPIClient()
        let repository = RaceRepositoryImpl(apiClient: mockClient)

        let now = Date.now
        // Create races in random order
        let unsortedRaces = [
            Race(
                raceId: "race3",
                raceName: "Race 3",
                raceNumber: 3,
                meetingName: "Meeting C",
                categoryId: RaceCategory.horse.id,
                advertisedStart: now.addingTimeInterval(900) // 15 min
            ),
            Race(
                raceId: "race1",
                raceName: "Race 1",
                raceNumber: 1,
                meetingName: "Meeting A",
                categoryId: RaceCategory.horse.id,
                advertisedStart: now.addingTimeInterval(150) // 2.5 min
            ),
            Race(
                raceId: "race2",
                raceName: "Race 2",
                raceNumber: 2,
                meetingName: "Meeting B",
                categoryId: RaceCategory.horse.id,
                advertisedStart: now.addingTimeInterval(300) // 5 min
            )
        ]

        let mockResponse = createMockResponse(races: unsortedRaces)

        await mockClient.configure { endpoint in
            return mockResponse
        }

        let result = try await repository.fetchNextRaces(count: 10, categories: [])

        // Should be sorted by start time (earliest first)
        #expect(result.count == 3)
        #expect(result[0].raceId == "race1") // 2.5 min
        #expect(result[1].raceId == "race2") // 5 min
        #expect(result[2].raceId == "race3") // 15 min
    }
}

// MARK: - MockAPIClient Extension

extension MockAPIClient {
    func configure(handler: @escaping (APIEndpoint) async throws -> Any) {
        self.fetchHandler = handler
    }
}
