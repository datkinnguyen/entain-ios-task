import SwiftUI

/// A view modifier that conditionally applies full width frame to a view.
///
/// This modifier is useful for creating responsive layouts that need to
/// expand to full width in some contexts (e.g., vertical layouts) but not others.
struct ConditionalFullWidth: ViewModifier {
    let isFullWidth: Bool

    func body(content: Content) -> some View {
        if isFullWidth {
            content.frame(maxWidth: .infinity, alignment: .leading)
        } else {
            content
        }
    }
}

extension View {
    /// Conditionally applies full width frame to the view.
    ///
    /// - Parameter isFullWidth: Whether to apply full width frame
    /// - Returns: The modified view
    func conditionalFullWidth(_ isFullWidth: Bool) -> some View {
        modifier(ConditionalFullWidth(isFullWidth: isFullWidth))
    }
}
