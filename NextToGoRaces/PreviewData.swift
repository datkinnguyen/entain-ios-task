//
//  PreviewData.swift
//  NextToGoRaces
//
//  Created by Claude on 2026-02-07.
//

import Foundation
import NextToGoCore
import NextToGoRepository
import NextToGoViewModel

#if DEBUG

/// Preview helpers for SwiftUI previews and testing
@MainActor
enum PreviewData {

    // MARK: - Sample Races

    /// Sample race for Horse Racing
    static let horseRace = Race(
        raceId: "preview-horse-1",
        raceName: "Melbourne Cup",
        raceNumber: 7,
        meetingName: "Flemington",
        category: .horse,
        advertisedStart: Date.now.addingTimeInterval(300) // 5 minutes from now
    )

    /// Sample race for Harness Racing
    static let harnessRace = Race(
        raceId: "preview-harness-1",
        raceName: "Pacing Stakes",
        raceNumber: 4,
        meetingName: "Menangle",
        category: .harness,
        advertisedStart: Date.now.addingTimeInterval(180) // 3 minutes from now
    )

    /// Sample race for Greyhound Racing
    static let greyhoundRace = Race(
        raceId: "preview-greyhound-1",
        raceName: "Sprint Final",
        raceNumber: 12,
        meetingName: "Wentworth Park",
        category: .greyhound,
        advertisedStart: Date.now.addingTimeInterval(120) // 2 minutes from now
    )

    /// Sample race that's about to start (urgent countdown)
    static let urgentRace = Race(
        raceId: "preview-urgent-1",
        raceName: "Final Sprint",
        raceNumber: 9,
        meetingName: "Sandown",
        category: .greyhound,
        advertisedStart: Date.now.addingTimeInterval(60) // 1 minute from now
    )

    /// Sample race that has already started (negative countdown)
    static let startedRace = Race(
        raceId: "preview-started-1",
        raceName: "Feature Race",
        raceNumber: 5,
        meetingName: "Randwick",
        category: .horse,
        advertisedStart: Date.now.addingTimeInterval(-30) // 30 seconds ago
    )

    /// Sample list of races for previews
    static let sampleRaces = [
        urgentRace,
        greyhoundRace,
        harnessRace,
        horseRace,
        Race(
            raceId: "preview-5",
            raceName: "Maiden Plate",
            raceNumber: 3,
            meetingName: "Caulfield",
            category: .horse,
            advertisedStart: Date.now.addingTimeInterval(600) // 10 minutes from now
        )
    ]

    // MARK: - Mock Repository

    /// Mock repository for previews that returns sample data
    final class MockRepository: RaceRepositoryProtocol {

        let races: [Race]

        init(races: [Race] = sampleRaces) {
            self.races = races
        }

        func fetchNextRaces(count: Int, categories: Set<RaceCategory>) async throws -> [Race] {
            // Simulate network delay
            try await Task.sleep(for: .milliseconds(500))

            // Filter by categories if specified
            if categories.isEmpty {
                return Array(races.prefix(count))
            } else {
                return races
                    .filter { categories.contains($0.category) }
                    .prefix(count)
                    .map { $0 }
            }
        }

    }

    // MARK: - Preview View Model

    /// Creates a view model configured for previews
    /// - Parameter races: The races to display (defaults to sample races)
    /// - Returns: A configured RacesViewModel for previews
    static func previewViewModel(races: [Race] = sampleRaces) -> RacesViewModel {
        let repository = MockRepository(races: races)
        return RacesViewModel(repository: repository)
    }

    /// Creates a view model with empty state
    static var emptyViewModel: RacesViewModel {
        let repository = MockRepository(races: [])
        return RacesViewModel(repository: repository)
    }

    /// Creates a view model with error state
    static var errorViewModel: RacesViewModel {
        let repository = ErrorRepository()
        return RacesViewModel(repository: repository)
    }

    // MARK: - Error Repository

    /// Mock repository that always throws an error
    private final class ErrorRepository: RaceRepositoryProtocol {

        func fetchNextRaces(count: Int, categories: Set<RaceCategory>) async throws -> [Race] {
            // Simulate network delay
            try await Task.sleep(for: .milliseconds(500))
            throw URLError(.notConnectedToInternet)
        }

    }

}

#endif
