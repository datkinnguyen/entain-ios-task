import NextToGoCore
import SwiftUI

/// A chip component for category filtering with selected/unselected states.
///
/// Displays an icon and label for a race category. When selected, shows an orange/red
/// background with white icon. When unselected, shows a light gray background with
/// gray icon.
public struct CategoryChip: View {

    // MARK: - Properties

    private let category: RaceCategory
    private let isSelected: Bool
    private let action: () -> Void

    // MARK: - Initialisation

    /// Creates a category filter chip.
    ///
    /// - Parameters:
    ///   - category: The race category to display
    ///   - isSelected: Whether the category is currently selected
    ///   - action: Closure called when the chip is tapped
    public init(
        category: RaceCategory,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.category = category
        self.isSelected = isSelected
        self.action = action
    }

    // MARK: - Computed Properties

    private var backgroundColor: Color {
        isSelected ? RaceColors.selectedChipBackground : RaceColors.unselectedChipBackground
    }

    private var iconColor: Color {
        isSelected ? RaceColors.selectedChipIcon : RaceColors.unselectedChipIcon
    }

    private var categoryLabel: String {
        switch category {
        case .horse:
            return "Horse"
        case .harness:
            return "Harness"
        case .greyhound:
            return "Greyhound"
        }
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            HStack(spacing: RaceLayout.spacingS) {
                Image(systemName: category.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)

                Text(categoryLabel)
                    .font(RaceTypography.categoryChip)
                    .foregroundStyle(iconColor)
            }
            .padding(.horizontal, RaceLayout.chipPaddingHorizontal)
            .padding(.vertical, RaceLayout.chipPaddingVertical)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: RaceLayout.chipCornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(categoryLabel) racing")
        .accessibilityHint(isSelected ? "Selected, tap to deselect" : "Not selected, tap to select")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

}

// MARK: - Previews

#Preview("Selected State") {
    HStack(spacing: RaceLayout.spacingM) {
        CategoryChip(category: .horse, isSelected: true) {}
        CategoryChip(category: .harness, isSelected: true) {}
        CategoryChip(category: .greyhound, isSelected: true) {}
    }
    .padding()
}

#Preview("Unselected State") {
    HStack(spacing: RaceLayout.spacingM) {
        CategoryChip(category: .horse, isSelected: false) {}
        CategoryChip(category: .harness, isSelected: false) {}
        CategoryChip(category: .greyhound, isSelected: false) {}
    }
    .padding()
}

#Preview("Mixed State") {
    HStack(spacing: RaceLayout.spacingM) {
        CategoryChip(category: .horse, isSelected: true) {}
        CategoryChip(category: .harness, isSelected: false) {}
        CategoryChip(category: .greyhound, isSelected: true) {}
    }
    .padding()
}
