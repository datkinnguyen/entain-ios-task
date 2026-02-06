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

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            Image(systemName: category.iconName)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 60, height: 60)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: RaceLayout.chipCornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityConfiguration(
            label: "\(category.accessibleLabel) racing",
            hint: isSelected ? "Selected, tap to deselect" : "Not selected, tap to select",
            traits: isSelected ? [.isButton, .isSelected] : [.isButton]
        )
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
