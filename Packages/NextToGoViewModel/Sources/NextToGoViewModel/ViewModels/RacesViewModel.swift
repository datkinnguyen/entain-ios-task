import AsyncAlgorithms
import Foundation
import NextToGoCore

/// View model managing the state and business logic for the races list.
///
/// Responsibilities:
/// - Fetches races from the repository
/// - Manages category filtering
/// - Refreshes races when expired races are detected
/// - Updates countdown timer every second
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
    public private(set) var isLoading = true

    /// Current error state, if any
    public private(set) var error: Error?

    /// Current time for countdown calculations (updated every second)
    public private(set) var currentTime: Date = .now

    /// Counter that increments when the focused race's status changes (normal → urgent → started)
    /// Used by the view to detect status changes and trigger VoiceOver announcements
    public private(set) var focusedRaceStatusChangeCounter: Int = 0

    /// ID of the currently focused race (set by the view)
    public var focusedRaceId: String?

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

    // MARK: - Dependencies

    private let repository: RaceRepositoryProtocol

    @ObservationIgnored private var backgroundTask: Task<Void, Never>?
    @ObservationIgnored private var refreshChannel = AsyncChannel<Void>()
    @ObservationIgnored private var previousFocusedRaceStatus: (isUrgent: Bool, hasStarted: Bool)?

    // MARK: - Initialisation

    /// Creates a new RacesViewModel instance.
    ///
    /// - Parameter repository: The repository for fetching race data
    public init(repository: RaceRepositoryProtocol) {
        self.repository = repository
    }

}

// MARK: - Lifecycle

extension RacesViewModel {

    /// Starts all background tasks (countdown timer and debounce handling)
    public func startTasks() {
        stopTasks()
        scheduleRefresh()

        backgroundTask = Task { [weak self] in
            guard let self = self else { return }

            await withTaskGroup(of: Void.self) { group in
                group.addTask { [weak self] in
                    await self?.runCountdownTimer()
                }

                group.addTask { [weak self] in
                    await self?.runDebounceHandler()
                }

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

    /// Schedules a debounced refresh by sending a signal to the refresh channel.
    /// Safe to call multiple times - debounce prevents excessive API calls.
    /// Preferred method for external callers (e.g., UI retry buttons).
    public func scheduleRefresh() {
        Task { [refreshChannel] in
            await refreshChannel.send(())
        }
    }

    /// Manually refreshes the race data
    ///
    /// Note: External callers should use `scheduleRefresh()` instead to benefit from debouncing.
    /// This method is internal and called by the debounce handler.
    func refreshRaces() async {
        isLoading = true
        error = nil

        do {
            races = try await repository.fetchNextRaces(
                count: AppConfiguration.maxRacesToDisplay,
                categories: selectedCategories
            )
        } catch {
            self.error = error
        }

        isLoading = false
    }

}

// MARK: - Display Strings

extension RacesViewModel {

    /// Navigation title for the races list
    public var navigationTitle: String {
        LocalizedString.navigationTitle
    }

    /// Loading message
    public var loadingMessage: String {
        LocalizedString.loadingRaces
    }

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

}

// MARK: - Race Display

extension RacesViewModel {

    /// Returns the race number display string (e.g., "R7")
    /// - Parameter race: The race
    /// - Returns: Formatted race number string
    public func raceNumberText(for race: Race) -> String {
        "\(LocalizedString.raceNumberPrefix)\(race.raceNumber)"
    }

    /// Returns the countdown display string for a race (visual text only)
    /// - Parameter race: The race
    /// - Returns: Formatted countdown string for display
    public func countdownText(for race: Race) -> String {
        countdownConfiguration(for: race).text
    }

    /// Returns whether the countdown should show urgent state (≤5 minutes or started)
    /// - Parameter race: The race
    /// - Returns: True if countdown is urgent
    public func isCountdownUrgent(for race: Race) -> Bool {
        let interval = race.advertisedStart.timeIntervalSince(currentTime)
        return interval <= AppConfiguration.countdownUrgentThreshold
    }

    /// Returns the accessibility label for a race row
    /// - Parameter race: The race
    /// - Returns: Complete accessibility label with natural-sounding countdown
    public func raceAccessibilityLabel(for race: Race) -> String {
        let categoryName: String
        switch race.category {
        case .horse:
            categoryName = LocalizedString.categoryHorseRacingAccessibility
        case .harness:
            categoryName = LocalizedString.categoryHarnessRacingAccessibility
        case .greyhound:
            categoryName = LocalizedString.categoryGreyhoundRacingAccessibility
        }

        let interval = race.advertisedStart.timeIntervalSince(currentTime)
        let config = countdownConfiguration(for: race)

        let countdown: String
        if interval < 0 {
            countdown = LocalizedString.countdownStarted
        } else if isCountdownUrgent(for: race) {
            countdown = LocalizedString.countdownStartingSoon(time: config.accessibilityText)
        } else {
            countdown = LocalizedString.countdownStartsIn(time: config.accessibilityText)
        }

        return LocalizedString.raceAccessibility(
            category: categoryName,
            meeting: race.meetingName,
            raceName: race.raceName,
            raceNumber: race.raceNumber,
            countdown: countdown
        )
    }

}

// MARK: - Category Display

extension RacesViewModel {

    /// Returns the accessibility label for a category chip
    /// - Parameter category: The race category
    /// - Returns: Accessibility label (e.g., "Horse", "Harness", "Greyhound")
    public func categoryAccessibilityLabel(for category: RaceCategory) -> String {
        switch category {
        case .horse:
            return LocalizedString.categoryHorseAccessibility
        case .harness:
            return LocalizedString.categoryHarnessAccessibility
        case .greyhound:
            return LocalizedString.categoryGreyhoundAccessibility
        }
    }

    /// Returns the accessibility hint for a category chip
    /// - Parameter isSelected: Whether the category is selected
    /// - Returns: Accessibility hint
    public func categoryAccessibilityHint(isSelected: Bool) -> String {
        isSelected ? LocalizedString.categorySelectedHint : LocalizedString.categoryNotSelectedHint
    }

    /// Returns the accessibility label for the category filters container
    public var categoryFiltersLabel: String {
        LocalizedString.categoryFiltersLabel
    }

}

// MARK: - Private Helpers

private extension RacesViewModel {

    /// Returns the countdown text configuration for a race
    /// - Parameter race: The race
    /// - Returns: Text configuration with visual and accessibility text
    func countdownConfiguration(for race: Race) -> TextConfiguration {
        race.advertisedStart.countdownString(from: currentTime)
    }

    /// Checks for expired races and triggers refresh if any are found.
    /// Does not remove races directly - lets the refresh fetch new data.
    func checkForExpiredRaces() {
        if races.contains(where: { $0.isExpired }) {
            scheduleRefresh()
        }
    }

    /// Checks if the focused race's status has changed and increments counter if so
    func checkFocusedRaceStatusChange() {
        guard let focusedId = focusedRaceId,
              let focusedRace = races.first(where: { $0.raceId == focusedId }) else {
            previousFocusedRaceStatus = nil
            return
        }

        let isUrgent = isCountdownUrgent(for: focusedRace)
        let interval = focusedRace.advertisedStart.timeIntervalSince(currentTime)
        let hasStarted = interval < 0

        let currentStatus = (isUrgent: isUrgent, hasStarted: hasStarted)

        if let previousStatus = previousFocusedRaceStatus {
            if previousStatus.isUrgent != currentStatus.isUrgent ||
               previousStatus.hasStarted != currentStatus.hasStarted {
                focusedRaceStatusChangeCounter = (focusedRaceStatusChangeCounter + 1) % 2
            }
        }

        previousFocusedRaceStatus = currentStatus
    }

}

// MARK: - Background Tasks

private extension RacesViewModel {

    /// Runs the countdown timer that updates current time every second.
    /// Also checks for expired races and focused race status changes.
    func runCountdownTimer() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { break }
            currentTime = .now

            checkForExpiredRaces()
            checkFocusedRaceStatusChange()
        }
    }

    /// Runs the debounce handler that processes all refresh signals with debouncing
    func runDebounceHandler() async {
        let debouncedSignals = refreshChannel.debounce(
            for: .milliseconds(AppConfiguration.debounceDelay)
        )

        for await _ in debouncedSignals {
            guard !Task.isCancelled else { break }
            await refreshRaces()
        }
    }

}
