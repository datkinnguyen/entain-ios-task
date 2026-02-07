# Testing Guide

This document describes the testing strategy and how to run tests for the Next To Go iOS app.

## Overview

The app uses **Swift Testing** framework (not XCTest) with a target of **≥80% code coverage**. All tests follow strict concurrency checking with Swift 6.

## Test Types

### Unit Tests
Test individual components in isolation with mocked dependencies.

**Packages with Unit Tests:**
- `NextToGoCore` - Domain models and extensions
- `NextToGoNetworking` - API client and networking logic
- `NextToGoRepository` - Business logic
- `NextToGoViewModel` - State management

### Integration Tests
Test interaction between packages (planned for future tasks).

## Running Tests

### Run All Tests
```bash
# From project root
swift test --package-path Packages/NextToGoCore
swift test --package-path Packages/NextToGoNetworking

# Or from Xcode
# Product → Test (⌘U)
```

### Run Specific Test Suite
```bash
# Swift Testing uses @Suite attribute
swift test --filter "Race Model Tests"
```

### Run Specific Test
```bash
swift test --filter "Race is not expired when in the future"
```

### Check Code Coverage
```bash
# Using Xcode
# Product → Test (⌘U)
# View → Navigators → Show Report Navigator (⌘9)
# Select test report → Coverage tab
```

## Test Structure

### Swift Testing Framework
We use **Swift Testing** (not XCTest) with these features:

**Test Suites:**
```swift
@Suite("Race Model Tests")
struct RaceTests {

    @Test("Race initialises with correct properties")
    func testRaceInitialisation() {
        let race = Self.makeRace()
        #expect(race.raceId == "test-id")
    }
}
```

**Test Traits:**
```swift
// Serialised execution for tests sharing mutable state
@Suite("APIClient Tests", .serialized)
struct APIClientTests {
    // Tests run serially
}
```

**Expectations:**
```swift
// Use #expect instead of XCTAssert
#expect(value == expected)
#expect(array.isEmpty)
#expect(!condition)

// Error testing
#expect(throws: APIError.self) {
    try await apiClient.fetch(.endpoint)
}
```

## Test Organisation

### Test Helper Functions
Place helper functions in a private extension at the bottom of the test file:

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

### Naming Conventions
- Test functions: Descriptive sentence case (e.g., `"Race is expired when more than 60 seconds in the past"`)
- Helper functions: Use `make` prefix (e.g., `makeRace()`, `makeAPIClient()`)
- Mock types: Use `Mock` prefix (e.g., `MockURLProtocol`, `MockAPIClient`)

## Package-Specific Tests

### NextToGoCore Tests

**RaceTests.swift**
- Race initialisation
- Expiry logic (60-second threshold)
- Decodable conformance
- Category mapping

**DateExtensionsTests.swift**
- Countdown string formatting
- DST-aware calculations
- Negative time display
- Localised string usage

**Key Test Cases:**
```swift
// Expiry logic
@Test("Race is expired when more than 60 seconds in the past")
func testRaceExpired() {
    let pastDate = Date.now.addingTimeInterval(-120)
    let race = Self.makeRace(advertisedStart: pastDate)
    #expect(race.isExpired)
}

// Countdown formatting
@Test("Countdown string for past date shows negative time")
func testCountdownNegative() {
    let past = Date.now.addingTimeInterval(-125) // -2m 5s
    let countdown = past.countdownString()
    #expect(countdown.hasPrefix("-"))
}
```

### NextToGoNetworking Tests

**APIClientTests.swift**
- Successful fetch and decoding
- Network error handling
- Invalid response handling
- Concurrent request safety

**APIEndpointTests.swift**
- URL building
- Query parameter handling
- Category ID filtering

**APIErrorTests.swift**
- Error descriptions
- LocalizedError conformance

**RaceResponseTests.swift**
- JSON decoding
- Race sorting by advertised start
- Missing field handling
- Empty response handling

**Key Features:**
```swift
// Actor-isolated testing
@Suite("APIClient Tests", .serialized)
struct APIClientTests {

    @Test("Fetch successfully decodes valid response")
    func testFetchSuccess() async throws {
        // Setup MockURLProtocol
        // Test actor-isolated API call
    }
}
```

### MockURLProtocol Pattern
```swift
final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
```

## Test Best Practices

### Coding Guidelines

**Always use exact error types:**
```swift
// ✅ Correct
#expect(throws: APIError.self) {
    try await apiClient.fetch(.endpoint)
}

// ❌ Incorrect - too generic
#expect(throws: Error.self) {
    try await apiClient.fetch(.endpoint)
}
```

**Verify complete values:**
```swift
// ✅ Correct
#expect(url?.absoluteString == "https://api.example.com/path?param=value")

// ❌ Incorrect - checking parts separately
#expect(url?.absoluteString.contains("path") == true)
#expect(url?.absoluteString.contains("param=value") == true)
```

**Use .serialized for shared mutable state:**
```swift
/// Tests must run serially because they share MockURLProtocol.requestHandler
@Suite("APIClient Tests", .serialized)
struct APIClientTests {
    // Tests that modify static MockURLProtocol.requestHandler
}
```

### Test Coverage Goals

**Minimum Coverage:**
- Core domain logic: 95%+
- Networking layer: 90%+
- Repository layer: 85%+
- ViewModel layer: 85%+
- UI layer: 70%+

**What to Test:**
- All public APIs
- Edge cases (empty, nil, extreme values)
- Error paths
- Concurrent access (where applicable)
- Expiry and timing logic

**What NOT to Test:**
- Private implementation details
- Third-party framework code
- Generated code (e.g., SwiftUI previews)
- Trivial getters/setters

## Continuous Integration

### GitHub Actions
Tests run automatically on:
- Every PR to `main`
- Every push to `main`
- Manual workflow dispatch

**CI Workflow:**
1. Checkout code
2. Select Xcode 16.2
3. Run Swift tests for each package
4. Report results

### Local Pre-commit
Before creating a PR:
```bash
# Run all tests
swift test --package-path Packages/NextToGoCore
swift test --package-path Packages/NextToGoNetworking

# Verify all pass
echo "✓ All tests passing"
```

## Debugging Tests

### Print Debug Info
```swift
@Test("Debug test")
func testDebug() async {
    let race = Self.makeRace()
    print("Race: \(race)")  // Prints to console
    #expect(race.raceId == "test-id")
}
```

### Xcode Test Navigator
- View → Navigators → Show Test Navigator (⌘6)
- See all tests grouped by suite
- Click diamond to run individual test
- See pass/fail indicators

### Test Failures
When a test fails:
1. Read the failure message
2. Check the expected vs actual values
3. Review the test implementation
4. Fix the code or test as appropriate
5. Re-run to verify fix

## Future Testing Plans

### Integration Tests
- End-to-end data flow
- Package integration
- Real API testing (staging)

## Resources

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [Swift Concurrency Testing](https://developer.apple.com/documentation/swift/concurrency)
- Project: [CODING_GUIDELINES.md](./CODING_GUIDELINES.md)
