import SwiftUI

/// A view displaying loading state with a progress indicator.
///
/// Supports both full-screen and inline loading states with an optional message.
public struct LoadingView: View {

    // MARK: - Properties

    private let message: String

    // MARK: - Initialisation

    /// Creates a loading view.
    ///
    /// - Parameter message: Optional message to display below the spinner (defaults to "Loading...")
    public init(message: String = "Loading...") {
        self.message = message
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: RaceLayout.spacingL) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(.circular)

            Text(message)
                .font(RaceTypography.location)
                .foregroundStyle(RaceColors.locationText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RaceColors.listBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }

}

// MARK: - Previews

#Preview("Default Message") {
    LoadingView()
}

#Preview("Custom Message") {
    LoadingView(message: "Fetching next races...")
}

#Preview("Dark Mode") {
    LoadingView()
        .preferredColorScheme(.dark)
}
