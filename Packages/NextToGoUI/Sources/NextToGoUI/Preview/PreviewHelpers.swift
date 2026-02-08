import Foundation
import NextToGoCore

// MARK: - Preview Helpers

/// Mock repository for SwiftUI previews and development.
///
/// This actor provides thread-safe mock data for previewing UI components.
/// Only included in preview builds, not production code.
actor MockRaceRepository: RaceRepositoryProtocol {

    // MARK: - Properties

    private let races: [Race]
    private let shouldDelay: Bool
    private let shouldThrowError: Bool

    // MARK: - Initialisation

    /// Creates a mock race repository.
    ///
    /// - Parameters:
    ///   - races: Optional array of races to return (uses defaults if nil)
    ///   - shouldDelay: Whether to simulate network delay
    ///   - shouldThrowError: Whether to throw an error when fetching
    init(races: [Race]? = nil, shouldDelay: Bool = false, shouldThrowError: Bool = false) {
        self.shouldDelay = shouldDelay
        self.shouldThrowError = shouldThrowError
        self.races = races ?? Self.defaultMockRaces
    }

    // MARK: - RaceRepositoryProtocol

    func fetchNextRaces(count: Int, categories: Set<RaceCategory>) async throws -> [Race] {
        if shouldDelay {
            try? await Task.sleep(for: .seconds(2))
        }

        if shouldThrowError {
            throw MockError.networkUnavailable
        }

        return Array(races.prefix(count))
    }

    // MARK: - Error Types

    enum MockError: LocalizedError {
        case networkUnavailable

        var errorDescription: String? {
            "Unable to connect to the server. Please check your internet connection and try again."
        }
    }

    // MARK: - Mock Data

    private static let defaultMockRaces: [Race] = [
        Race(
            raceId: "1",
            raceName: "Melbourne Cup",
            raceNumber: 7,
            meetingName: "Flemington",
            category: .horse,
            advertisedStart: Date.now.addingTimeInterval(600)
        ),
        Race(
            raceId: "2",
            raceName: "Final Sprint",
            raceNumber: 3,
            meetingName: "Wentworth Park",
            category: .greyhound,
            advertisedStart: Date.now.addingTimeInterval(240)
        ),
        Race(
            raceId: "3",
            raceName: "Trotters Special",
            raceNumber: 5,
            meetingName: "Menangle",
            category: .harness,
            advertisedStart: Date.now.addingTimeInterval(420)
        ),
        Race(
            raceId: "4",
            raceName: "Derby Stakes",
            raceNumber: 8,
            meetingName: "Randwick",
            category: .horse,
            advertisedStart: Date.now.addingTimeInterval(900)
        ),
        Race(
            raceId: "5",
            raceName: "Night Race",
            raceNumber: 2,
            meetingName: "Sandown Park",
            category: .greyhound,
            advertisedStart: Date.now.addingTimeInterval(150)
        )
    ]

}
