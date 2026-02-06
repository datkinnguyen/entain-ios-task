import Foundation

/// Centralised configuration constants for the Next To Go application.
public enum AppConfiguration {

    /// The base URL for the racing API
    public static let apiBaseURL = "https://api.neds.com.au/rest/v1/racing/"

    /// Time interval in seconds between automatic data refreshes
    public static let refreshInterval: TimeInterval = 60

    /// Time threshold in seconds after which a race is considered expired
    public static let expiryThreshold: TimeInterval = 60

    /// Time threshold in seconds for countdown urgent state (≤5 minutes)
    public static let countdownUrgentThreshold: TimeInterval = 300

    /// Debounce delay in milliseconds for user interactions
    public static let debounceDelay: Int = 500

    /// Number of races to load from the API (load more to ensure we always have enough)
    public static let numberOfRacesToLoad: Int = 10

    /// Maximum number of races to display in the list (always show top 5)
    public static let maxRacesToDisplay: Int = 5

    /// Network request timeout in seconds
    public static let networkRequestTimeout: TimeInterval = 30

    /// Network resource timeout in seconds
    public static let networkResourceTimeout: TimeInterval = 60

}
