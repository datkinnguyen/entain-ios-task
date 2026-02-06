import NextToGoViewModel
import SwiftUI

/// A view displaying an error state with a retry button using ContentUnavailableView.
///
/// Shows an error icon, message, and a button to retry the failed operation.
public struct ErrorView: View {

    // MARK: - Properties

    private let configuration: RacesViewModel.ErrorConfiguration
    private let viewModel: RacesViewModel

    // MARK: - Initialisation

    /// Creates an error view.
    ///
    /// - Parameters:
    ///   - configuration: The error state configuration
    ///   - viewModel: The view model for triggering retry
    public init(configuration: RacesViewModel.ErrorConfiguration, viewModel: RacesViewModel) {
        self.configuration = configuration
        self.viewModel = viewModel
    }

    // MARK: - Body

    public var body: some View {
        ContentUnavailableView(
            label: {
                Label(configuration.title, systemImage: configuration.iconName)
            },
            description: {
                Text(configuration.message)
            },
            actions: {
                Button(
                    action: {
                        Task {
                            await viewModel.refreshRaces()
                        }
                    },
                    label: {
                        Text(configuration.retryButtonText)
                    }
                )
                .buttonStyle(.borderedProminent)
                .accessibilityLabel(configuration.retryAccessibilityLabel)
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

}

// MARK: - Previews

#Preview("Network Error") {
    let mockRepository = MockRaceRepository()
    let viewModel = RacesViewModel(repository: mockRepository)
    let error = URLError(.notConnectedToInternet)
    let configuration = viewModel.errorConfiguration(for: error)
    return ErrorView(configuration: configuration, viewModel: viewModel)
}

#Preview("Generic Error") {
    let mockRepository = MockRaceRepository()
    let viewModel = RacesViewModel(repository: mockRepository)
    let error = NSError(domain: "TestError", code: -1, userInfo: [
        NSLocalizedDescriptionKey: "Failed to load races. Please try again."
    ])
    let configuration = viewModel.errorConfiguration(for: error)
    return ErrorView(configuration: configuration, viewModel: viewModel)
}

#Preview("Dark Mode") {
    let mockRepository = MockRaceRepository()
    let viewModel = RacesViewModel(repository: mockRepository)
    let error = URLError(.timedOut)
    let configuration = viewModel.errorConfiguration(for: error)
    return ErrorView(configuration: configuration, viewModel: viewModel)
        .preferredColorScheme(.dark)
}
