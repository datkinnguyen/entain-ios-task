import Foundation

/// Configuration for text that may have different visual and accessibility representations.
///
/// Use this type when the same content needs to be displayed differently for
/// sighted users versus VoiceOver users. For example, "5m" displays compactly
/// but should be spoken as "5 minutes".
public struct TextConfiguration {
    /// The text to display visually in the UI
    public let text: String

    /// The text to be read by VoiceOver (defaults to the same as text)
    public let accessibilityText: String

    /// Creates a text configuration with separate visual and accessibility text.
    ///
    /// - Parameters:
    ///   - text: The text to display visually
    ///   - accessibilityText: The text for VoiceOver (defaults to text)
    public init(text: String, accessibilityText: String? = nil) {
        self.text = text
        self.accessibilityText = accessibilityText ?? text
    }
}
