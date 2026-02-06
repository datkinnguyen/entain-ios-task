import Foundation

/// Centralised localisation helper for accessing localised strings.
///
/// This utility provides a consistent way to access localised strings across all packages.
/// Each package should use this helper with its own bundle to access its localised resources.
public enum Localization {

    /// Retrieves a localised string from the specified bundle.
    ///
    /// - Parameters:
    ///   - key: The key for the localised string
    ///   - bundle: The bundle containing the localised strings (defaults to .main)
    ///   - comment: A comment describing the context (defaults to empty string)
    /// - Returns: The localised string for the key, or the key itself if not found
    public static func string(
        forKey key: String,
        bundle: Bundle = .main,
        comment: String = ""
    ) -> String {
        NSLocalizedString(key, bundle: bundle, comment: comment)
    }

}
