import Foundation
import NextToGoCore

extension RaceCategory {

    /// The accessibility label for this category with "racing" suffix (e.g., "Horse Racing")
    public var racingAccessibilityLabel: String {
        switch self {
        case .horse:
            return LocalizedString.categoryHorseRacing
        case .harness:
            return LocalizedString.categoryHarnessRacing
        case .greyhound:
            return LocalizedString.categoryGreyhoundRacing
        }
    }

}
