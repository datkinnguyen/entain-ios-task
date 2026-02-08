import Foundation
import NextToGoCore

extension RaceCategory {

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

    /// The accessibility label for this category with "racing" suffix (e.g., "Horse Racing")
    public var racingAccessibilityLabel: String {
        switch self {
        case .horse:
            return LocalizedString.categoryHorseRacingAccessibility
        case .harness:
            return LocalizedString.categoryHarnessRacingAccessibility
        case .greyhound:
            return LocalizedString.categoryGreyhoundRacingAccessibility
        }
    }

    /// The accessibility label for this category without "racing" suffix (e.g., "Horse")
    public var accessibilityLabel: String {
        switch self {
        case .horse:
            return LocalizedString.categoryHorseAccessibility
        case .harness:
            return LocalizedString.categoryHarnessAccessibility
        case .greyhound:
            return LocalizedString.categoryGreyhoundAccessibility
        }
    }

}
