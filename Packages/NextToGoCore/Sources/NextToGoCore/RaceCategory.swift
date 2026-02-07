import Foundation

/// Represents the category of a race with associated metadata.
public enum RaceCategory: String, Codable, CaseIterable, Sendable {

    case horse
    case greyhound
    case harness

    /// The unique identifier for this category used in API responses
    public var id: String {
        switch self {
        case .greyhound:
            return "9daef0d7-bf3c-4f50-921d-8e818c60fe61"
        case .harness:
            return "161d9be2-e909-4326-8c2c-35ed71fb460b"
        case .horse:
            return "4a2788f8-e825-4d36-9894-efd4baf1cfae"
        }
    }

    /// The custom icon name for this category from Assets catalog
    public var iconName: String {
        switch self {
        case .greyhound:
            return "greyhound-racing"
        case .harness:
            return "harness-racing"
        case .horse:
            return "horse-racing"
        }
    }

    /// The accessible label for this category (used in VoiceOver)
    public var accessibleLabel: String {
        switch self {
        case .greyhound:
            return "Greyhound Racing"
        case .harness:
            return "Harness Racing"
        case .horse:
            return "Horse Racing"
        }
    }

    /// Initialize from a category ID
    /// - Parameter id: The category UUID string
    /// - Returns: The matching RaceCategory, or nil if the ID is not recognised (unsupported categories are ignored)
    public init?(id: String) {
        switch id {
        case "9daef0d7-bf3c-4f50-921d-8e818c60fe61":
            self = .greyhound
        case "161d9be2-e909-4326-8c2c-35ed71fb460b":
            self = .harness
        case "4a2788f8-e825-4d36-9894-efd4baf1cfae":
            self = .horse
        default:
            return nil
        }
    }

}
