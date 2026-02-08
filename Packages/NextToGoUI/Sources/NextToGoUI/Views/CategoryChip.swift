import NextToGoCore
import NextToGoViewModel
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
    private let accessibilityLabel: String
    private let accessibilityHint: String
    private let action: () -> Void

    // MARK: - Initialisation

    /// Creates a category filter chip.
    ///
    /// - Parameters:
    ///   - category: The race category to display
    ///   - isSelected: Whether the category is currently selected
    ///   - accessibilityLabel: The accessibility label for VoiceOver users
    ///   - accessibilityHint: The accessibility hint for VoiceOver users
    ///   - action: Closure called when the chip is tapped
    public init(
        category: RaceCategory,
        isSelected: Bool,
        accessibilityLabel: String,
        accessibilityHint: String,
        action: @escaping () -> Void
    ) {
        self.category = category
        self.isSelected = isSelected
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
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
            Image(category.iconName, bundle: .module)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(iconColor)
                .padding(RaceLayout.categoryChipInternalPadding)
                .frame(width: RaceLayout.categoryChipSize, height: RaceLayout.categoryChipSize)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: RaceLayout.chipCornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : [.isButton])
    }

}

// MARK: - Previews

#Preview("Selected State") {
    HStack(spacing: RaceLayout.spacingM) {
        CategoryChip(
            category: .horse,
            isSelected: true,
            accessibilityLabel: "Horse",
            accessibilityHint: "Tap to deselect"
        ) {}
        CategoryChip(
            category: .harness,
            isSelected: true,
            accessibilityLabel: "Harness",
            accessibilityHint: "Tap to deselect"
        ) {}
        CategoryChip(
            category: .greyhound,
            isSelected: true,
            accessibilityLabel: "Greyhound",
            accessibilityHint: "Tap to deselect"
        ) {}
    }
    .padding()
}

#Preview("Unselected State") {
    HStack(spacing: RaceLayout.spacingM) {
        CategoryChip(
            category: .horse,
            isSelected: false,
            accessibilityLabel: "Horse",
            accessibilityHint: "Tap to select"
        ) {}
        CategoryChip(
            category: .harness,
            isSelected: false,
            accessibilityLabel: "Harness",
            accessibilityHint: "Tap to select"
        ) {}
        CategoryChip(
            category: .greyhound,
            isSelected: false,
            accessibilityLabel: "Greyhound",
            accessibilityHint: "Tap to select"
        ) {}
    }
    .padding()
}

#Preview("Mixed State") {
    HStack(spacing: RaceLayout.spacingM) {
        CategoryChip(
            category: .horse,
            isSelected: true,
            accessibilityLabel: "Horse",
            accessibilityHint: "Tap to deselect"
        ) {}
        CategoryChip(
            category: .harness,
            isSelected: false,
            accessibilityLabel: "Harness",
            accessibilityHint: "Tap to select"
        ) {}
        CategoryChip(
            category: .greyhound,
            isSelected: true,
            accessibilityLabel: "Greyhound",
            accessibilityHint: "Tap to deselect"
        ) {}
    }
    .padding()
}
