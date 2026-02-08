import Foundation
import NextToGoCore
import Synchronization

// MARK: - Mock Race Repository

/// Handler-based mock repository for testing and previews.
///
/// This class provides a thread-safe approach to mocking the RaceRepositoryProtocol
/// using Swift 6's Mutex for type-safe synchronization.
///
/// ## Usage
/// ```swift
/// let mock = MockRaceRepository()
/// mock.fetchNextRacesHandler = { count, categories in
///     return mockRaces
/// }
/// // Or throw an error
/// mock.fetchNextRacesHandler = { _, _ in
///     throw NetworkError.timeout
/// }
/// ```
@available(macOS 15.0, iOS 18.0, *)
public final class MockRaceRepository: RaceRepositoryProtocol, Sendable {

    // MARK: - Type Aliases

    /// Handler type for fetchNextRaces method.
    public typealias FetchNextRacesHandler = @Sendable (Int, Set<RaceCategory>) async throws -> [Race]

    // MARK: - Error Types

    /// Error thrown when a handler is not set for a method.
    public enum MockError: LocalizedError {
        case handlerNotSet(String)
        case networkUnavailable

        public var errorDescription: String? {
            switch self {
            case .handlerNotSet(let methodName):
                return "Mock handler not set for \(methodName). Set the handler before calling this method."
            case .networkUnavailable:
                return "Unable to connect to the server. Please check your internet connection and try again."
            }
        }
    }

    // MARK: - Thread-Safe Storage

    private let _fetchNextRacesHandler: Mutex<FetchNextRacesHandler?>

    /// Handler for fetchNextRaces method.
    /// If not set, calling fetchNextRaces will throw MockError.handlerNotSet.
    /// Thread-safe access protected by Mutex.
    public var fetchNextRacesHandler: FetchNextRacesHandler? {
        get { _fetchNextRacesHandler.withLock { $0 } }
        set { _fetchNextRacesHandler.withLock { $0 = newValue } }
    }

    // MARK: - Initialisation

    /// Creates a new mock repository with no handlers set.
    ///
    /// You must set the appropriate handlers before calling protocol methods,
    /// or they will throw MockError.handlerNotSet.
    public init() {
        self._fetchNextRacesHandler = Mutex(nil)
    }

    // MARK: - RaceRepositoryProtocol

    public func fetchNextRaces(count: Int, categories: Set<RaceCategory>) async throws -> [Race] {
        guard let handler = fetchNextRacesHandler else {
            throw MockError.handlerNotSet("fetchNextRaces(count:categories:)")
        }

        return try await handler(count, categories)
    }

    // MARK: - Mock Data Helpers

    /// Creates mock races for testing.
    /// Returns races sorted by advertised start time, ready to be returned directly.
    ///
    /// - Parameter count: Number of races to create
    /// - Returns: Array of races sorted by advertised start time
    public static func makeMockRaces(count: Int) -> [Race] {
        let now = Date.now
        return (0..<count).map { index in
            Race(
                raceId: "race-\(index)",
                raceName: "Race \(index + 1)",
                raceNumber: index + 1,
                meetingName: "Meeting \(index + 1)",
                category: RaceCategory.allCases[index % 3],
                advertisedStart: now.addingTimeInterval(TimeInterval((index + 1) * 60))
            )
        }
    }

    /// Default mock races for SwiftUI previews.
    /// These races have various start times and categories for visual testing.
    /// Already sorted by advertised start time.
    public static let defaultPreviewRaces: [Race] = [
        Race(
            raceId: "5",
            raceName: "Night Race",
            raceNumber: 2,
            meetingName: "Sandown Park",
            category: .greyhound,
            advertisedStart: Date.now.addingTimeInterval(150)
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
            raceId: "1",
            raceName: "Melbourne Cup",
            raceNumber: 7,
            meetingName: "Flemington",
            category: .horse,
            advertisedStart: Date.now.addingTimeInterval(600)
        ),
        Race(
            raceId: "4",
            raceName: "Derby Stakes",
            raceNumber: 8,
            meetingName: "Randwick",
            category: .horse,
            advertisedStart: Date.now.addingTimeInterval(900)
        )
    ]
}
