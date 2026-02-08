# MockRaceRepository Refactoring Summary

## Problem

The project had **two separate MockRaceRepository implementations** in different locations:

1. **Test Mock** (`RacesViewModelTests.swift:221`) - Private to unit tests
2. **Preview Mock** (`PreviewHelpers.swift:10`) - For SwiftUI previews

Both implementations suffered from the same design flaws:

### Issues with Old Approach

❌ **Not Scalable**: Fixed data/error behavior set in initializer
❌ **Not Flexible**: Cannot change behavior dynamically (e.g., "first call succeeds, second fails")
❌ **Code Duplication**: Two similar implementations to maintain
❌ **Limited Testing**: Hard to test edge cases or complex scenarios
❌ **Tight Coupling**: Behavior locked at initialization time, not call time

### Old Pattern Example

```swift
// ❌ Old inflexible pattern
let mock = MockRaceRepository(racesToReturn: mockRaces, shouldThrowError: false)
// Can't change behavior after initialization!
```

## Solution: Handler-Based Mock

Created a **single, handler-based MockRaceRepository** that:

✅ Uses **handler closures** for each protocol method
✅ Throws descriptive error if handler not set
✅ **Can be reused** by both tests AND previews
✅ Allows **dynamic behavior changes** during tests
✅ Provides **convenience helpers** for common scenarios
✅ Tracks **call counts** and **arguments** for verification

### New Pattern Example

```swift
// ✅ New flexible pattern
let mock = MockRaceRepository()

// Set initial behavior
mock.fetchNextRacesHandler = { count, categories in
    return mockRaces
}

// Later in test, change behavior dynamically
mock.fetchNextRacesHandler = { _, _ in
    throw NetworkError.timeout
}

// Or use convenience helpers
mock.setSuccessHandler(races: mockRaces)
mock.setErrorHandler(MockRaceRepository.MockError.networkUnavailable)
mock.setDelayedSuccessHandler(races: mockRaces, delay: .seconds(2))
```

## Implementation Details

### Location

**File**: `Packages/NextToGoViewModel/Sources/NextToGoViewModel/Testing/MockRaceRepository.swift`

This location makes it:
- ✅ Publicly accessible from both tests and previews
- ✅ Part of the NextToGoViewModel module (where the protocol is used)
- ✅ Clearly organized in a "Testing" subdirectory

### Key Features

#### 1. Handler-Based Design

```swift
public var fetchNextRacesHandler: (@Sendable (Int, Set<RaceCategory>) async throws -> [Race])?
```

Each protocol method has a corresponding handler closure. If the handler is not set, the method throws `MockError.handlerNotSet`.

#### 2. Call Tracking

```swift
public var fetchNextRacesCallCount: Int
public var lastFetchNextRacesArgs: (count: Int, categories: Set<RaceCategory>)?
```

Useful for verifying that methods were called with expected arguments.

#### 3. Convenience Helpers

```swift
mock.setSuccessHandler(races: mockRaces)
mock.setErrorHandler(error)
mock.setDelayedSuccessHandler(races: mockRaces, delay: .seconds(2))
mock.reset()
```

Common scenarios made easy with helper methods.

#### 4. Swift 6 Concurrency Safe

The mock is a `final class` marked `@unchecked Sendable` instead of an `actor`, allowing:
- ✅ Direct property access (no `await` needed for handlers)
- ✅ Compatible with Swift 6 strict concurrency mode
- ✅ Simple to use in both tests and previews

### Preview Helpers

**File**: `Packages/NextToGoUI/Sources/NextToGoUI/Preview/PreviewHelpers.swift`

Created convenience functions for common preview scenarios:

```swift
func createSuccessMockRepository() -> MockRaceRepository
func createErrorMockRepository() -> MockRaceRepository
func createDelayedMockRepository() -> MockRaceRepository
```

## Migration Changes

### Tests Updated

All test cases in `RacesViewModelTests.swift` were updated:

**Before**:
```swift
let repository = MockRaceRepository(racesToReturn: mockRaces)
```

**After**:
```swift
let repository = MockRaceRepository()
repository.setSuccessHandler(races: mockRaces)
```

### Previews Updated

All SwiftUI previews were updated to use the new helpers:

**Files Updated**:
- `RacesListView.swift` - 5 previews
- `RaceRowView.swift` - 4 previews
- `CategoryFilterView.swift` - 4 previews

**Before**:
```swift
let mockRepository = MockRaceRepository()
```

**After**:
```swift
let mockRepository = createSuccessMockRepository()
```

### Old Mocks Removed

Both old implementations were deleted:
- ❌ Removed from `RacesViewModelTests.swift` (lines 221-247)
- ❌ Removed from `PreviewHelpers.swift` (replaced with helper functions)

## Benefits

### For Testing

1. **Dynamic Behavior**: Change mock behavior during tests
   ```swift
   // First call succeeds
   mock.setSuccessHandler(races: mockRaces)
   await viewModel.refreshRaces()

   // Second call fails
   mock.setErrorHandler(NetworkError.timeout)
   await viewModel.refreshRaces()
   ```

2. **Verification**: Check calls and arguments
   ```swift
   #expect(mock.fetchNextRacesCallCount == 2)
   #expect(mock.lastFetchNextRacesArgs?.count == 5)
   ```

3. **Complex Scenarios**: Test edge cases easily
   ```swift
   mock.fetchNextRacesHandler = { count, categories in
       if categories.contains(.horse) {
           return horseRaces
       } else {
           return []
       }
   }
   ```

### For Previews

1. **Reusability**: One mock for all preview scenarios
2. **Clarity**: Helper functions make intent clear
3. **Flexibility**: Custom behavior when needed

## Verification

All changes verified:

✅ **Unit Tests**: All 21 tests pass
✅ **Build**: Project builds successfully
✅ **Swift 6**: Strict concurrency mode compliance

## Future Enhancements

Potential improvements:

1. **Additional Handlers**: As the protocol grows, add handlers for new methods
2. **More Helpers**: Add helpers for common test scenarios (e.g., `setPaginationHandler`)
3. **Assertion Helpers**: Add methods like `assertCalledOnce()` for cleaner tests
4. **Recording Mode**: Option to record actual API responses for realistic testing

## Conclusion

This refactoring demonstrates **best practices for mock design**:

- ✅ Single source of truth (one mock implementation)
- ✅ Handler-based flexibility
- ✅ Easy to use for common cases (convenience helpers)
- ✅ Powerful for complex cases (custom handlers)
- ✅ Thread-safe and Swift 6 compliant
- ✅ Well-documented with examples

The new MockRaceRepository is **scalable, testable, and maintainable** - ready for the project's future growth.
