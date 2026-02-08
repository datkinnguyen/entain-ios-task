import NextToGoCore
import NextToGoViewModel
import SwiftUI

/// A horizontal scrollable view of category filter chips.
///
/// Displays chips for all race categories (Horse, Harness, Greyhound) with
/// selection state. When a category is toggled, the view triggers an immediate
/// API refresh through the binding.
public struct CategoryFilterView: View {

    // MARK: - Properties

    @Binding private var selectedCategories: Set<RaceCategory>
    private let viewModel: RacesViewModel

    // MARK: - Initialisation

    /// Creates a category filter view.
    ///
    /// - Parameters:
    ///   - selectedCategories: Binding to the set of selected categories
    ///   - viewModel: The view model providing localized strings
    public init(selectedCategories: Binding<Set<RaceCategory>>, viewModel: RacesViewModel) {
        self._selectedCategories = selectedCategories
        self.viewModel = viewModel
    }

    // MARK: - Body

    public var body: some View {
        HStack {
            Spacer()
            HStack(spacing: RaceLayout.spacingL) {
                ForEach(RaceCategory.allCases, id: \.self) { category in
                    let isSelected = selectedCategories.contains(category)
                    CategoryChip(
                        category: category,
                        isSelected: isSelected,
                        accessibilityLabel: viewModel.categoryAccessibilityLabel(for: category),
                        accessibilityHint: viewModel.categoryAccessibilityHint(isSelected: isSelected)
                    ) {
                        toggleCategory(category)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, RaceLayout.spacingS)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(viewModel.categoryFiltersLabel)
    }

    // MARK: - Private Methods

    private func toggleCategory(_ category: RaceCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

}

// MARK: - Previews

#Preview("All Selected") {
    @Previewable @State var selectedCategories: Set<RaceCategory> = Set(RaceCategory.allCases)
    let mockRepository = MockRaceRepository()
    let viewModel = RacesViewModel(repository: mockRepository)
    CategoryFilterView(selectedCategories: $selectedCategories, viewModel: viewModel)
}

#Preview("Horse Selected") {
    @Previewable @State var selectedCategories: Set<RaceCategory> = [.horse]
    let mockRepository = MockRaceRepository()
    let viewModel = RacesViewModel(repository: mockRepository)
    CategoryFilterView(selectedCategories: $selectedCategories, viewModel: viewModel)
}

#Preview("Multiple Selected") {
    @Previewable @State var selectedCategories: Set<RaceCategory> = [.horse, .greyhound]
    let mockRepository = MockRaceRepository()
    let viewModel = RacesViewModel(repository: mockRepository)
    CategoryFilterView(selectedCategories: $selectedCategories, viewModel: viewModel)
}

#Preview("None Selected") {
    @Previewable @State var selectedCategories: Set<RaceCategory> = []
    let mockRepository = MockRaceRepository()
    let viewModel = RacesViewModel(repository: mockRepository)
    CategoryFilterView(selectedCategories: $selectedCategories, viewModel: viewModel)
}
