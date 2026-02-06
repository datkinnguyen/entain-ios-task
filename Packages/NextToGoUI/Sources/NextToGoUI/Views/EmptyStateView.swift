import NextToGoViewModel
import SwiftUI

/// A view displaying an empty state using ContentUnavailableView.
///
/// Shows an icon, title, and message when no content is available.
public struct EmptyStateView: View {

    // MARK: - Properties

    private let configuration: RacesViewModel.EmptyConfiguration

    // MARK: - Initialisation

    /// Creates an empty state view.
    ///
    /// - Parameter configuration: The empty state configuration
    public init(configuration: RacesViewModel.EmptyConfiguration) {
        self.configuration = configuration
    }

    // MARK: - Body

    public var body: some View {
        ContentUnavailableView(
            label: {
                Label(configuration.title, systemImage: configuration.iconName)
            },
            description: {
                Text(configuration.message)
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel(configuration.accessibilityLabel)
    }

}

// MARK: - Previews

#Preview("Empty State") {
    let configuration = RacesViewModel.EmptyConfiguration(
        title: "No races available",
        message: "Try selecting different categories",
        iconName: "flag.checkered",
        accessibilityLabel: "No races available. Try selecting different categories."
    )
    return EmptyStateView(configuration: configuration)
}
