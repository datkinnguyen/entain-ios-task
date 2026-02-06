# Coding Guidelines

This document outlines the coding standards and best practices for the Next To Go iOS project.

## General Principles

### Swift Version
- Use Swift 6 with strict concurrency enabled
- Enable upcoming Swift features as appropriate

### Language and Spelling
- Always use UK/AU English spelling throughout the codebase
  - Examples: `localised` (not `localized`), `centralised` (not `centralized`)

## Code Structure

### Type Definitions
- Always add a newline after a type definition (protocol, class, struct) and before the closing brace
- **Exception:** Enums with only cases and no computed properties or functions do not need extra newlines

```swift
// Correct
public struct Race: Decodable {

    public let raceId: String
    public let raceName: String

}

// Correct - enum with only cases
public enum RaceCategory: String {
    case greyhound
    case harness
    case horse
}

// Correct - enum with computed properties needs newlines
public enum RaceCategory: String {

    case greyhound
    case harness
    case horse

    public var id: String {
        // implementation
    }

}
```

## Localisation

### User-Facing Strings
- ALL end-user facing text that appears in the UI must be localised using `Localizable.strings`
- Localisation is only allowed in two packages:
  - **NextToGoCore** - for domain-level strings (e.g., countdown formats)
  - **NextToGoViewModel** - for presentation-level strings
- Never add localisation to other packages

```swift
// Correct - using localised strings
let format = NSLocalizedString("countdown.minutes.only", comment: "Countdown format for minutes only")

// Incorrect - hardcoded user-facing string
let format = "%dm"
```

### Countdown String Formats
User-facing countdown strings must use these localised keys:
- `countdown.minutes.only` - Format: "%dm"
- `countdown.minutes.seconds` - Format: "%dm %ds"
- `countdown.seconds.only` - Format: "%ds"

## Testing

### Test Helper Functions
- Helper functions in test files should always be placed in a private extension at the bottom of the file

```swift
@Suite("My Tests")
struct MyTests {

    @Test("Some test")
    func testSomething() {
        let object = Self.makeObject()
        // test implementation
    }

}

// MARK: - Test Helpers

private extension MyTests {

    static func makeObject() -> MyObject {
        // helper implementation
    }

}
```

### Test Isolation
- Tests that share mutable static state (e.g., MockURLProtocol) must use the `.serialized` trait
- Add a comment explaining why serialization is needed

```swift
/// Tests must run serially because they share MockURLProtocol.requestHandler
@Suite("APIClient Tests", .serialized)
struct APIClientTests {
    // tests
}
```

### Test Assertions
- Verify complete expected values rather than checking parts separately
- Avoid trivial tests that only verify type conformance or obvious behavior
- **Always use exact error types** when testing error throwing, never use generic `Error.self`

```swift
// Correct - verify complete URL
#expect(url?.absoluteString == "https://api.example.com/path?param=value")

// Incorrect - checking parts separately
#expect(url?.absoluteString.contains("path") == true)
#expect(url?.absoluteString.contains("param=value") == true)

// Correct - use exact error type
#expect(throws: DecodingError.self) {
    try decoder.decode(MyType.self, from: data)
}

#expect(throws: APIError.self) {
    try await apiClient.fetch(.endpoint)
}

// Incorrect - using generic Error type
#expect(throws: Error.self) {  // ❌ Too generic
    try decoder.decode(MyType.self, from: data)
}
```

## Pull Requests

### PR Size Limits
- Split work into multiple PRs when changes exceed **500 lines**
- Each PR should represent a logical, reviewable unit of work that can be independently tested and merged
- Breaking down large features:
  - PR 1: Core infrastructure and models
  - PR 2: Business logic and services
  - PR 3: UI components and views
  - PR 4: Tests and documentation

### PR Best Practices
- Keep PRs focused on a single concern
- Include tests with the code they test
- Update documentation in the same PR as code changes
- Ensure all tests pass before creating PR

## Architecture

### Package Dependencies
Follow clean architecture principles with these dependency rules:
- **NextToGoCore** - No dependencies, pure domain models
- **NextToGoNetworking** - Depends on Core only
- **NextToGoRepository** - Depends on Core and Networking
- **NextToGoViewModel** - Depends on Core and Repository
- **NextToGoUI** - Depends on Core and ViewModel

### Concurrency
- Use Swift 6 strict concurrency
- Mark types as `Sendable` when crossing actor boundaries
- Use `nonisolated(unsafe)` sparingly and only for test code or known-safe scenarios
- Document why `nonisolated(unsafe)` is used when necessary

## Code Quality

### Comments and Documentation
- Use doc comments (`///`) for public APIs
- Keep comments concise and focused on "why" not "what"
- Update comments when code changes
- Remove outdated or redundant comments

### Error Handling
- Use typed errors over generic Error
- Provide meaningful error messages
- Don't silently swallow errors with `try?` unless truly optional

### Property Wrappers
- Use `@Observable` instead of `ObservableObject` (iOS 17+)
- Use `@State` instead of `@StateObject` with `@Observable` types
- Use `@MainActor` for UI-related types

## Conventions

### Naming
- Use clear, descriptive names
- Avoid abbreviations unless industry-standard
- Prefix test functions with `test`
- Use `make` prefix for test helper factory functions (e.g., `makeRace()`)

### File Organization
- One type per file (exceptions for tightly-coupled types)
- Group related files in directories
- Keep test files parallel to source files

### Imports
- Import only what you need
- Use `@testable` only in test targets
- Group imports: system frameworks first, then external dependencies, then internal modules
