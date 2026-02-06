import Foundation

/// Centralized configuration constants for the Next To Go application.
public enum AppConfiguration {
    /// The base URL for the racing API
    public static let apiBaseURL = "https://api.neds.com.au/rest/v1/racing/"

    /// Time interval in seconds between automatic data refreshes
    public static let refreshInterval: TimeInterval = 60

    /// Time threshold in seconds after which a race is considered expired
    public static let expiryThreshold: TimeInterval = 60

    /// Debounce delay in milliseconds for user interactions
    public static let debounceDelay: Int = 500

    /// Maximum number of races to display in the list
    public static let maxRacesToDisplay: Int = 5
}
