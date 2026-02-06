import Foundation
import NextToGoCore
import NextToGoNetworking
@testable import NextToGoRepository
import Testing

@Suite("RaceRepositoryImpl Tests")
struct RaceRepositoryImplTests {

    // MARK: - Tests

    @Test("Fetch races with all categories returns all non-expired races")
    func fetchRacesWithAllCategories() async throws {
        let mockClient = MockAPIClient()
        let repository = RaceRepositoryImpl(apiClient: mockClient)

        let mockRaces = createMockRaces()
        let mockResponse = createMockResponse(races: mockRaces)

        await mockClient.configure { _ in
            return mockResponse
        }

        let result = try await repository.fetchNextRaces(count: 10, categories: [])

        // Should return 4 races (excluding the expired one)
        #expect(result.count == 4)

        // Should not include expired race
        // Note: Backend should never send expired races, but we verify client-side filtering works correctly
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

        await mockClient.configure { _ in
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

        await mockClient.configure { _ in
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

        await mockClient.configure { _ in
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
                // Compare as sets since order doesn't matter
                let expectedIds = Set([RaceCategory.horse.id, RaceCategory.greyhound.id])
                #expect(Set(categoryIds ?? []) == expectedIds)
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

    @Test("Fetch races with empty categories passes all category IDs to endpoint")
    func fetchRacesWithEmptyCategoriesPassesAllCategories() async throws {
        let mockClient = MockAPIClient()
        let repository = RaceRepositoryImpl(apiClient: mockClient)

        let mockResponse = createMockResponse(races: [])

        await mockClient.configure { endpoint in
            // Verify all category IDs are passed when categories set is empty
            if case .nextRaces(let count, let categoryIds) = endpoint {
                #expect(count == 10)
                // Empty categories means "all categories" - should pass all category IDs
                let allCategoryIds = Set(RaceCategory.allCases.map { $0.id })
                #expect(Set(categoryIds ?? []) == allCategoryIds)
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

        await mockClient.configure { _ in
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

// MARK: - Test Helpers

private extension RaceRepositoryImplTests {

    // swiftlint:disable:next function_parameter_count
    func createRace(
        id: String,
        name: String,
        number: Int,
        meeting: String,
        category: RaceCategory,
        offset: TimeInterval
    ) -> Race {
        Race(
            raceId: id,
            raceName: name,
            raceNumber: number,
            meetingName: meeting,
            categoryId: category.id,
            advertisedStart: Date.now.addingTimeInterval(offset)
        )
    }

    func createMockRaces() -> [Race] {
        [
            createRace(
                id: "race1", name: "Race 1", number: 1, meeting: "Meeting A",
                category: .horse, offset: 300
            ),
            createRace(
                id: "race2", name: "Race 2", number: 2, meeting: "Meeting B",
                category: .greyhound, offset: 600
            ),
            createRace(
                id: "race3", name: "Race 3", number: 3, meeting: "Meeting C",
                category: .harness, offset: 150
            ),
            createRace(
                id: "race4", name: "Race 4", number: 4, meeting: "Meeting D",
                category: .horse, offset: 900
            ),
            // Note: Backend should never send expired races, but we include this
            // to verify client-side filtering works correctly as defensive programming
            createRace(
                id: "expired_race", name: "Expired Race", number: 5, meeting: "Meeting E",
                category: .horse, offset: -120
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

        guard let data = try? JSONSerialization.data(withJSONObject: json),
              let response = try? JSONDecoder().decode(RaceResponse.self, from: data) else {
            fatalError("Failed to create mock response - invalid test data")
        }
        return response
    }
}

// MARK: - MockAPIClient Extension

extension MockAPIClient {
    func configure(handler: @escaping (APIEndpoint) async throws -> Any) {
        self.fetchHandler = handler
    }
}
