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

}
