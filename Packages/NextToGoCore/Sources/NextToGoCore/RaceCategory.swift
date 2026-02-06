import Foundation

/// Represents the category of a race with associated metadata.
public enum RaceCategory: String, Codable, CaseIterable, Sendable {
    case greyhound
    case harness
    case horse

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

    /// The SF Symbol icon name for this category
    public var iconName: String {
        switch self {
        case .greyhound:
            return "dog.fill"
        case .harness:
            return "figure.walk"
        case .horse:
            return "figure.equestrian.sports"
        }
    }

    /// Display name for the category
    public var displayName: String {
        rawValue.capitalized
    }

    /// Initialize from a category ID
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
