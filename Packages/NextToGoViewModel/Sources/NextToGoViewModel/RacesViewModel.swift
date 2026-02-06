import AsyncAlgorithms
import Foundation
import NextToGoCore

/// View model managing the state and business logic for the races list.
///
/// Responsibilities:
/// - Fetches races from the repository
/// - Manages category filtering
/// - Auto-refreshes races every 60 seconds
/// - Removes expired races every second
/// - Debounces refresh when race count drops below 5
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
                Task {
                    await refreshRaces()
                }
            }
        }
    }

    /// Loading state indicator
    public private(set) var isLoading = false

    /// Current error state, if any
    public private(set) var error: Error?

    // MARK: - Dependencies

    private let repository: RaceRepositoryProtocol

    // Tasks are nonisolated(unsafe) to allow access from deinit
    // Safe because Task.cancel() is thread-safe and we only cancel, never read task state
    @ObservationIgnored nonisolated(unsafe) private var autoRefreshTask: Task<Void, Never>?
    @ObservationIgnored nonisolated(unsafe) private var expiryCheckTask: Task<Void, Never>?
    @ObservationIgnored nonisolated(unsafe) private var debounceHandlerTask: Task<Void, Never>?

    // Channel for debounced refresh signals
    @ObservationIgnored nonisolated(unsafe) private var debounceChannel = AsyncChannel<Void>()

    // MARK: - Initialisation

    /// Creates a new RacesViewModel instance.
    ///
    /// - Parameter repository: The repository for fetching race data
    public init(repository: RaceRepositoryProtocol) {
        self.repository = repository
    }

    deinit {
        stopTasks()
    }

    // MARK: - Public Methods

    /// Starts all background tasks (auto-refresh and expiry checking)
    public func startTasks() {
        stopTasks()
        startAutoRefresh()
        startExpiryCheck()
        startDebounceHandler()
    }

    /// Stops all background tasks
    nonisolated public func stopTasks() {
        autoRefreshTask?.cancel()
        expiryCheckTask?.cancel()
        debounceHandlerTask?.cancel()
        debounceChannel.finish()
        autoRefreshTask = nil
        expiryCheckTask = nil
        debounceHandlerTask = nil
        debounceChannel = AsyncChannel<Void>()
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

    /// Starts the auto-refresh task that fetches new races every 60 seconds
    private func startAutoRefresh() {
        autoRefreshTask = Task { [weak self] in
            guard let self = self else { return }

            // Initial fetch
            await self.refreshRaces()

            // Subsequent refreshes
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(AppConfiguration.refreshInterval))
                guard !Task.isCancelled else { break }
                await self.refreshRaces()
            }
        }
    }

    /// Starts the expiry check task that removes expired races every second
    private func startExpiryCheck() {
        expiryCheckTask = Task { [weak self] in
            guard let self = self else { return }

            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }

                self.removeExpiredRaces()
            }
        }
    }

    /// Removes races that have expired (started more than 60 seconds ago)
    private func removeExpiredRaces() {
        let previousCount = races.count
        races.removeAll { $0.isExpired }

        // If we dropped below 5 races, schedule a debounced refresh
        if races.count < AppConfiguration.maxRacesToDisplay && races.count < previousCount {
            scheduleDebouncedRefresh()
        }
    }

    /// Starts the debounce handler that processes refresh signals with debouncing
    private func startDebounceHandler() {
        debounceHandlerTask = Task { [weak self] in
            guard let self = self else { return }

            // Use AsyncAlgorithms' debounce to handle refresh signals
            let debouncedSignals = debounceChannel.debounce(
                for: .milliseconds(AppConfiguration.debounceDelay)
            )

            for await _ in debouncedSignals {
                guard !Task.isCancelled else { break }
                await self.refreshRaces()
            }
        }
    }

    /// Sends a signal to trigger a debounced refresh
    private func scheduleDebouncedRefresh() {
        Task {
            await debounceChannel.send(())
        }
    }

}
