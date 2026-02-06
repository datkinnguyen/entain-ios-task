import SwiftUI

/// A view displaying an error state with a retry button.
///
/// Shows an error icon, message, and a button to retry the failed operation.
public struct ErrorView: View {

    // MARK: - Properties

    private let error: Error
    private let retryAction: () -> Void

    // MARK: - Initialisation

    /// Creates an error view.
    ///
    /// - Parameters:
    ///   - error: The error to display
    ///   - retryAction: Closure called when the retry button is tapped
    public init(error: Error, retryAction: @escaping () -> Void) {
        self.error = error
        self.retryAction = retryAction
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: RaceLayout.spacingL) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            VStack(spacing: RaceLayout.spacingS) {
                Text("Something went wrong")
                    .font(RaceTypography.meetingName)
                    .foregroundStyle(RaceColors.meetingNameText)

                Text(error.localizedDescription)
                    .font(RaceTypography.errorMessage)
                    .foregroundStyle(RaceColors.locationText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, RaceLayout.spacingXL)
            }

            Button(action: retryAction) {
                HStack(spacing: RaceLayout.spacingS) {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .font(RaceTypography.categoryChip)
                .foregroundStyle(.white)
                .padding(.horizontal, RaceLayout.spacingXL)
                .padding(.vertical, RaceLayout.spacingM)
                .background(RaceColors.selectedChipBackground)
                .clipShape(RoundedRectangle(cornerRadius: RaceLayout.chipCornerRadius))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Retry loading races")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RaceColors.listBackground)
        .accessibilityElement(children: .contain)
    }

}

// MARK: - Previews

#Preview("Network Error") {
    ErrorView(error: URLError(.notConnectedToInternet)) {}
}

#Preview("Generic Error") {
    ErrorView(error: NSError(domain: "TestError", code: -1, userInfo: [
        NSLocalizedDescriptionKey: "Failed to load races. Please try again."
    ])) {}
}

#Preview("Dark Mode") {
    ErrorView(error: URLError(.timedOut)) {}
        .preferredColorScheme(.dark)
}
