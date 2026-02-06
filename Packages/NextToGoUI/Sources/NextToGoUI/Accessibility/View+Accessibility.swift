import SwiftUI

// MARK: - View Accessibility Extensions

extension View {

    /// Adds comprehensive accessibility support to a view.
    ///
    /// - Parameters:
    ///   - label: The accessibility label describing the view
    ///   - hint: Optional hint providing usage guidance
    ///   - value: Optional value representing the current state
    ///   - traits: Accessibility traits for the view
    /// - Returns: The modified view with accessibility attributes
    public func accessibilityConfiguration(
        label: String,
        hint: String? = nil,
        value: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        self
            .accessibilityLabel(label)
            .modifier(OptionalAccessibilityHint(hint: hint))
            .modifier(OptionalAccessibilityValue(value: value))
            .accessibilityAddTraits(traits)
    }

    /// Marks the view as an accessibility container with a label.
    ///
    /// - Parameter label: The label for the container
    /// - Returns: The modified view
    public func accessibilityContainer(label: String) -> some View {
        self
            .accessibilityElement(children: .contain)
            .accessibilityLabel(label)
    }

    /// Applies reduced motion-aware animations.
    ///
    /// When Reduce Motion is enabled, uses simpler animations or removes them entirely.
    ///
    /// - Parameters:
    ///   - animation: The animation to apply
    ///   - reducedAnimation: Optional simplified animation for reduced motion (defaults to nil)
    /// - Returns: The modified view
    public func reducedMotionAnimation(
        _ animation: Animation,
        reducedAnimation: Animation? = nil
    ) -> some View {
        modifier(ReducedMotionAnimationModifier(
            animation: animation,
            reducedAnimation: reducedAnimation
        ))
    }

}

// MARK: - View Modifiers

private struct OptionalAccessibilityHint: ViewModifier {

    let hint: String?

    func body(content: Content) -> some View {
        if let hint = hint {
            content.accessibilityHint(hint)
        } else {
            content
        }
    }

}

private struct OptionalAccessibilityValue: ViewModifier {

    let value: String?

    func body(content: Content) -> some View {
        if let value = value {
            content.accessibilityValue(value)
        } else {
            content
        }
    }

}

private struct ReducedMotionAnimationModifier: ViewModifier {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation
    let reducedAnimation: Animation?

    func body(content: Content) -> some View {
        if reduceMotion {
            content.animation(reducedAnimation, value: UUID())
        } else {
            content.animation(animation, value: UUID())
        }
    }

}

// MARK: - Accessibility Constants

/// Accessibility constants and utilities for the Next To Go app.
public enum AccessibilityConstants {

    /// Minimum touch target size for interactive elements (44x44pt per Apple HIG)
    public static let minimumTouchTarget: CGFloat = 44

    /// Recommended spacing between interactive elements for better touch accuracy
    public static let interactiveSpacing: CGFloat = 8

}
