import NextToGoCore
import SwiftUI

/// A horizontal scrollable view of category filter chips.
///
/// Displays chips for all race categories (Horse, Harness, Greyhound) with
/// selection state. When a category is toggled, the view triggers an immediate
/// API refresh through the binding.
public struct CategoryFilterView: View {

    // MARK: - Properties

    @Binding private var selectedCategories: Set<RaceCategory>

    // MARK: - Initialisation

    /// Creates a category filter view.
    ///
    /// - Parameter selectedCategories: Binding to the set of selected categories
    public init(selectedCategories: Binding<Set<RaceCategory>>) {
        self._selectedCategories = selectedCategories
    }

    // MARK: - Body

    public var body: some View {
        HStack {
            Spacer()
            HStack(spacing: RaceLayout.spacingL) {
                ForEach(RaceCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategories.contains(category)
                    ) {
                        toggleCategory(category)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, RaceLayout.spacingS)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Race category filters")
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
    return CategoryFilterView(selectedCategories: $selectedCategories)
}

#Preview("Horse Selected") {
    @Previewable @State var selectedCategories: Set<RaceCategory> = [.horse]
    return CategoryFilterView(selectedCategories: $selectedCategories)
}

#Preview("Multiple Selected") {
    @Previewable @State var selectedCategories: Set<RaceCategory> = [.horse, .greyhound]
    return CategoryFilterView(selectedCategories: $selectedCategories)
}

#Preview("None Selected") {
    @Previewable @State var selectedCategories: Set<RaceCategory> = []
    return CategoryFilterView(selectedCategories: $selectedCategories)
}
