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

    /// Current time for countdown calculations (updated every second)
    public private(set) var currentTime: Date = .now

    // MARK: - Display Configurations

    /// Configuration for empty state display
    public struct EmptyConfiguration {
        public let title: String
        public let message: String
        public let iconName: String
        public let accessibilityLabel: String

        public init(title: String, message: String, iconName: String, accessibilityLabel: String) {
            self.title = title
            self.message = message
            self.iconName = iconName
            self.accessibilityLabel = accessibilityLabel
        }
    }

    /// Configuration for error state display
    public struct ErrorConfiguration {
        public let title: String
        public let message: String
        public let iconName: String
        public let retryButtonText: String
        public let retryAccessibilityLabel: String

        public init(
            title: String,
            message: String,
            iconName: String,
            retryButtonText: String,
            retryAccessibilityLabel: String
        ) {
            self.title = title
            self.message = message
            self.iconName = iconName
            self.retryButtonText = retryButtonText
            self.retryAccessibilityLabel = retryAccessibilityLabel
        }
    }

    // MARK: - Display Strings

    /// Navigation title for the races list
    public var navigationTitle: String { LocalizedString.navigationTitle }

    /// Loading message
    public var loadingMessage: String { LocalizedString.loadingRaces }

    /// Empty state configuration
    public var emptyConfiguration: EmptyConfiguration {
        EmptyConfiguration(
            title: LocalizedString.emptyTitle,
            message: LocalizedString.emptyMessage,
            iconName: "flag.checkered",
            accessibilityLabel: LocalizedString.emptyAccessibility
        )
    }

    /// Error state configuration
    /// - Parameter error: The error that occurred
    /// - Returns: Configuration for displaying the error
    public func errorConfiguration(for error: Error) -> ErrorConfiguration {
        ErrorConfiguration(
            title: LocalizedString.errorTitle,
            message: error.localizedDescription,
            iconName: "exclamationmark.triangle.fill",
            retryButtonText: LocalizedString.errorRetry,
            retryAccessibilityLabel: LocalizedString.errorRetryAccessibility
        )
    }

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

    /// Starts all background tasks (auto-refresh, expiry checking, countdown timer, and debounce handling)
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

                // Task 3: Countdown timer (updates current time every second)
                group.addTask { [weak self] in
                    await self?.runCountdownTimer()
                }

                // Task 4: Debounced refresh handler
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

    // MARK: - Race Display Methods

    /// Returns the race number display string (e.g., "R7")
    /// - Parameter race: The race
    /// - Returns: Formatted race number string
    public func raceNumberText(for race: Race) -> String {
        "\(LocalizedString.raceNumberPrefix)\(race.raceNumber)"
    }

    /// Returns the countdown display string for a race
    /// - Parameters:
    ///   - race: The race
    ///   - currentTime: The current time
    /// - Returns: Formatted countdown string
    public func countdownText(for race: Race, at currentTime: Date) -> String {
        race.advertisedStart.countdownString(from: currentTime)
    }

    /// Returns whether the countdown should show urgent state (≤5 minutes)
    /// - Parameters:
    ///   - race: The race
    ///   - currentTime: The current time
    /// - Returns: True if countdown is urgent
    public func isCountdownUrgent(for race: Race, at currentTime: Date) -> Bool {
        let interval = race.advertisedStart.timeIntervalSince(currentTime)
        return interval <= AppConfiguration.countdownUrgentThreshold
    }

    /// Returns the accessibility label for a countdown badge
    /// - Parameters:
    ///   - race: The race
    ///   - currentTime: The current time
    /// - Returns: Accessibility label
    public func countdownAccessibilityLabel(for race: Race, at currentTime: Date) -> String {
        let interval = race.advertisedStart.timeIntervalSince(currentTime)
        if interval < 0 {
            return LocalizedString.countdownStarted
        } else if isCountdownUrgent(for: race, at: currentTime) {
            return LocalizedString.countdownStartingSoon
        } else {
            return LocalizedString.countdownStartsIn
        }
    }

    /// Returns the accessibility label for a race row
    /// - Parameters:
    ///   - race: The race
    ///   - currentTime: The current time
    /// - Returns: Complete accessibility label
    public func raceAccessibilityLabel(for race: Race, at currentTime: Date) -> String {
        let categoryName = categoryDisplayName(for: race.category, withRacingSuffix: true)
        let countdown = countdownText(for: race, at: currentTime)
        return LocalizedString.raceAccessibility(
            category: categoryName,
            meeting: race.meetingName,
            raceNumber: race.raceNumber,
            raceName: race.raceName,
            countdown: countdown
        )
    }

    /// Returns the category display name
    /// - Parameters:
    ///   - category: The race category
    ///   - withRacingSuffix: Whether to include "racing" suffix
    /// - Returns: Category display name
    public func categoryDisplayName(for category: RaceCategory, withRacingSuffix: Bool = false) -> String {
        if withRacingSuffix {
            switch category {
            case .horse: return LocalizedString.categoryHorseRacing
            case .harness: return LocalizedString.categoryHarnessRacing
            case .greyhound: return LocalizedString.categoryGreyhoundRacing
            }
        } else {
            return category.accessibleLabel
        }
    }

    /// Returns the accessibility hint for a category chip
    /// - Parameter isSelected: Whether the category is selected
    /// - Returns: Accessibility hint
    public func categoryAccessibilityHint(isSelected: Bool) -> String {
        isSelected ? LocalizedString.categorySelectedHint : LocalizedString.categoryNotSelectedHint
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

    /// Runs the countdown timer that updates current time every second
    private func runCountdownTimer() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { break }
            currentTime = .now
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
