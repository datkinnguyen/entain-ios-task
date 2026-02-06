import AsyncAlgorithms
import Foundation
import NextToGoCore

/// View model managing the state and business logic for the races list.
///
/// Responsibilities:
/// - Fetches races from the repository
/// - Manages category filtering
/// - Auto-refreshes races at configurable intervals
/// - Removes expired races every second
/// - Debounces all refresh requests to prevent excessive API calls
@MainActor
@Observable
public final class RacesViewModel {

    // MARK: - Published State

    /// The list of races to display (maximum 5, sorted by advertised start time)
    public private(set) var races: [Race] = []

    /// Currently selected race categories for filtering
    public var selectedCategories: Set<RaceCategory> = Set(RaceCategory.allCases) {
        didSet {
            if selectedCategories != oldValue {
                scheduleRefresh()
            }
        }
    }

    /// Loading state indicator
    public private(set) var isLoading = false

    /// Current error state, if any
    public private(set) var error: Error?

    // MARK: - Dependencies

    private let repository: RaceRepositoryProtocol

    // Background tasks managed by TaskGroup
    @ObservationIgnored private var backgroundTask: Task<Void, Never>?

    // Channel for debounced refresh signals
    @ObservationIgnored private var refreshChannel = AsyncChannel<Void>()

    // MARK: - Initialisation

    /// Creates a new RacesViewModel instance.
    ///
    /// - Parameter repository: The repository for fetching race data
    public init(repository: RaceRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Methods

    /// Starts all background tasks (auto-refresh, expiry checking, and debounce handling)
    public func startTasks() {
        stopTasks()

        backgroundTask = Task { [weak self] in
            guard let self = self else { return }

            await withTaskGroup(of: Void.self) { group in
                // Task 1: Auto-refresh timer
                group.addTask { [weak self] in
                    await self?.runAutoRefresh()
                }

                // Task 2: Expiry check
                group.addTask { [weak self] in
                    await self?.runExpiryCheck()
                }

                // Task 3: Debounced refresh handler
                group.addTask { [weak self] in
                    await self?.runDebounceHandler()
                }

                // Wait for all tasks to complete (they run indefinitely until cancelled)
                await group.waitForAll()
            }
        }
    }

    /// Stops all background tasks
    public func stopTasks() {
        backgroundTask?.cancel()
        backgroundTask = nil
        refreshChannel.finish()
        refreshChannel = AsyncChannel<Void>()
    }

    /// Manually refreshes the race data
    public func refreshRaces() async {
        isLoading = true
        error = nil

        do {
            let fetchedRaces = try await repository.fetchNextRaces(
                count: AppConfiguration.maxRacesToDisplay,
                categories: selectedCategories
            )
            races = Array(fetchedRaces.prefix(AppConfiguration.maxRacesToDisplay))
        } catch {
            self.error = error
        }

        isLoading = false
    }

    // MARK: - Private Methods

    /// Schedules a debounced refresh by sending a signal to the refresh channel
    private func scheduleRefresh() {
        Task {
            await refreshChannel.send(())
        }
    }

    /// Runs the auto-refresh task that schedules refreshes at regular intervals
    private func runAutoRefresh() async {
        // Initial refresh
        scheduleRefresh()

        // Subsequent refreshes
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(AppConfiguration.refreshInterval))
            guard !Task.isCancelled else { break }
            scheduleRefresh()
        }
    }

    /// Runs the expiry check task that removes expired races every second
    private func runExpiryCheck() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { break }
            removeExpiredRaces()
        }
    }

    /// Removes races that have expired (started more than 60 seconds ago)
    private func removeExpiredRaces() {
        let previousCount = races.count
        races.removeAll { $0.isExpired }

        // If we dropped below 5 races, schedule a refresh
        if races.count < AppConfiguration.maxRacesToDisplay && races.count < previousCount {
            scheduleRefresh()
        }
    }

    /// Runs the debounce handler that processes all refresh signals with debouncing
    private func runDebounceHandler() async {
        // Use AsyncAlgorithms' debounce to handle all refresh signals
        let debouncedSignals = refreshChannel.debounce(
            for: .milliseconds(AppConfiguration.debounceDelay)
        )

        for await _ in debouncedSignals {
            guard !Task.isCancelled else { break }
            await refreshRaces()
        }
    }

}
