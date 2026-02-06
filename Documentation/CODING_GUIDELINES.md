# Coding Guidelines

This document outlines the coding standards and best practices for the Next To Go iOS project.

## General Principles

### Swift Version
- Use Swift 6 with strict concurrency enabled
- Build with Xcode 16.2+ for latest Swift 6 features
- Use `.swiftLanguageMode(.v6)` in Package.swift
- Do NOT use `.enableUpcomingFeature("StrictConcurrency")` (redundant in Swift 6.0+)

### Language and Spelling
- Always use UK/AU English spelling throughout the codebase
  - Examples: `localised` (not `localized`), `centralised` (not `centralized`)
  - Applies to: code, comments, documentation, UI text

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

## Swift 6 Concurrency Best Practices

### Progressive Concurrency Adoption

> "Your apps should start by running all of their code on the main thread, and you can get really far with single-threaded code." — Apple WWDC 2025-268

**The Journey:**
```
Single-Threaded → Asynchronous → Concurrent → Actors
```

Only add complexity when profiling proves it's needed.

### When to Use Concurrency

**Stay single-threaded when:**
- All operations complete in < 16ms (60fps)
- UI feels responsive
- No user complaints about sluggishness

**Add async/await when:**
- High-latency operations (network, file I/O) block UI
- URLSession, database queries, file access

**Add background work when:**
- CPU-intensive work (image processing, parsing) freezes UI
- Instruments shows main thread busy

**Add actors when:**
- Too much main actor code causes contention
- Non-UI subsystems need independent state

### Actor Usage

```swift
// ✅ Use actors for non-UI subsystems
actor NetworkManager {
    var openConnections: [URL: Connection] = [:]

    func openConnection(for url: URL) -> Connection {
        // Actor-isolated state
    }
}

// ✅ Use @MainActor for UI code
@MainActor
class PlayerViewModel: ObservableObject {
    @Published var currentTrack: Track?
}

// ❌ Don't make every class an actor
actor MyViewModel: ObservableObject {  // ❌ UI code should be @MainActor
    @Published var state: State  // ❌ Won't work correctly
}
```

### Sendable Conformance

```swift
// ✅ Value types are Sendable
struct Track: Sendable {
    let id: String
    let title: String
}

// ✅ Actors are implicitly Sendable
actor NetworkManager {}

// ✅ @MainActor types are implicitly Sendable
@MainActor class ViewModel: ObservableObject {}

// ❌ Classes NOT Sendable by default
class MyImage {  // ❌ Don't share across actors
    var pixels: [Color]
}
```

### Delegate Callbacks Pattern (CRITICAL)

When `nonisolated` delegate methods need to update `@MainActor` state:

```swift
// ✅ CORRECT - Capture values BEFORE Task
nonisolated func delegate(_ param: SomeType) {
    // Step 1: Capture parameter values
    let value = param.value
    let status = param.status

    // Step 2: Task hop to MainActor
    Task { @MainActor in
        // Step 3: Safe to access self
        self.property = value
        print("Status: \(status)")
    }
}
```

### Background Work

```swift
// ✅ Use @concurrent for always-background work (Swift 6.2+)
@concurrent
func decodeImage(_ data: Data) async -> Image {
    // Always runs on background thread pool
    return Image()
}

// ✅ Use nonisolated for library APIs
nonisolated
func decodeImage(_ data: Data) -> Image {
    // Stays on caller's actor
    return Image()
}
```

### Weak Self in Tasks

```swift
// ✅ Weak capture for stored or long-running tasks
progressTask = Task { [weak self] in
    guard let self = self else { return }
    while !Task.isCancelled {
        await self.updateProgress()
    }
}
```

## SwiftUI Architecture Best Practices

### Property Wrapper Decision Tree

**Three questions to answer:**

1. **Does this model need to be STATE OF THE VIEW ITSELF?**
   - YES → Use `@State`
   - Examples: Form inputs, local toggles, sheet presentations

2. **Does this model need to be part of the GLOBAL ENVIRONMENT?**
   - YES → Use `@Environment`
   - Examples: User account, app settings, dependency injection

3. **Does this model JUST NEED BINDINGS?**
   - YES → Use `@Bindable`
   - Examples: Editing a model passed from parent

4. **None of the above?**
   - Use as plain property
   - `@Observable` handles observation automatically

### @Observable Usage

```swift
// ✅ Use @Observable for business logic
@Observable
class FoodTruckModel {
    var orders: [Order] = []
    var donuts = Donut.all

    var orderCount: Int {
        orders.count  // Computed properties work
    }

    func addDonut() {
        donuts.append(Donut())
    }
}

// ✅ View automatically tracks accessed properties
struct DonutMenu: View {
    let model: FoodTruckModel  // No wrapper needed!

    var body: some View {
        List {
            ForEach(model.donuts) { donut in
                Text(donut.name)  // Tracks model.donuts
            }
        }
    }
}
```

### ViewModels as Presentation Adapters

Use ViewModels for filtering, sorting, or view-specific logic:

```swift
// ✅ ViewModel as presentation adapter
@Observable
class PetStoreViewModel {
    let petStore: PetStore  // Domain model
    var searchText: String = ""

    var filteredPets: [Pet] {
        guard !searchText.isEmpty else { return petStore.myPets }
        return petStore.myPets.filter { $0.name.contains(searchText) }
    }
}

// ❌ Don't add ViewModels to simple views
struct SimpleView: View {
    let pet: Pet  // Just display it directly
    var body: some View {
        Text(pet.name)
    }
}
```

### Anti-Pattern: Logic in View Bodies

```swift
// ❌ NEVER do this
struct ProductListView: View {
    let products: [Product]

    var body: some View {
        let formatter = NumberFormatter()  // ❌ Created every render!
        formatter.numberStyle = .currency

        let sorted = products.sorted { $0.price > $1.price }  // ❌ Sorted every render!

        return List(sorted) { product in
            Text("\(product.name): \(formatter.string(from: product.price)!)")
        }
    }
}

// ✅ Extract to ViewModel
@Observable
class ProductListViewModel {
    let products: [Product]
    private let formatter = NumberFormatter()

    var sortedProducts: [Product] {
        products.sorted { $0.price > $1.price }
    }

    init(products: [Product]) {
        self.products = products
        formatter.numberStyle = .currency
    }

    func formattedPrice(_ product: Product) -> String {
        formatter.string(from: product.price as NSNumber) ?? "$0.00"
    }
}
```

## SwiftUI Performance Best Practices

### Rule 1: Keep View Bodies Fast

**View bodies must complete before frame deadline (16.67ms @ 60fps)**

```swift
// ❌ Expensive operations in body
var body: some View {
    let formatter = DateFormatter()  // ❌ Milliseconds per creation
    formatter.dateStyle = .short

    let sorted = data.sorted()  // ❌ O(n log n) every render
    let result = heavyComputation()  // ❌ Blocks frame
}

// ✅ Cache expensive operations
@Observable
class ViewModel {
    private let formatter = DateFormatter()  // Created once
    var sortedData: [Item] { data.sorted() }  // Computed property
    private(set) var result: Int = 0  // Pre-computed
}
```

### Rule 2: Update Only When Needed

**Design data flow to update views only when necessary:**

```swift
// ❌ Whole array dependency
@Observable
class ModelData {
    var items: [Item]  // All views depend on entire array

    func isFavorite(_ item: Item) -> Bool {
        items.contains(item)  // ❌ Accessing whole array
    }
}

// ✅ Granular dependencies
@Observable
class ModelData {
    private(set) var itemViewModels: [Item.ID: ItemViewModel]
}

@Observable
class ItemViewModel {
    var isFavorite: Bool = false  // Each view depends only on this
}
```

### Rule 3: Careful with Environment

**Never store frequently-changing values in environment:**

```swift
// ❌ DON'T DO THIS
.environment(\.scrollOffset, scrollOffset)  // ❌ 60+ updates/second

// ✅ Use direct parameters
ChildView(scrollOffset: scrollOffset)
```

**Environment is great for:**
- Color scheme
- Locale
- Accessibility settings
- Other stable values

### Rule 4: Profile Before Optimising

**Use Instruments 26 SwiftUI template:**
1. Check Long View Body Updates lane
2. Use Time Profiler for expensive operations
3. Use Cause & Effect Graph for unnecessary updates
4. Verify fixes with new traces

## Localisation

### User-Facing Strings
- ALL end-user facing text that appears in the UI must be localised using `Localizable.strings`
- Localisation is only allowed in two packages:
  - **NextToGoCore** - for domain-level strings (e.g., countdown formats)
  - **NextToGoViewModel** - for presentation-level strings
- Never add localisation to other packages

```swift
// Correct - using localised strings
let format = NSLocalizedString("countdown.minutes.only", bundle: .module, comment: "Countdown format for minutes only")

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
- Add a comment explaining why serialisation is needed

```swift
/// Tests must run serially because they share MockURLProtocol.requestHandler
@Suite("APIClient Tests", .serialized)
struct APIClientTests {
    // tests
}
```

### Test Assertions
- Verify complete expected values rather than checking parts separately
- Avoid trivial tests that only verify type conformance or obvious behaviour
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

### PR Self-Review Process
**MANDATORY:** Before creating any PR, you MUST:
1. **Self-review all code changes** - Review every file, every line changed
2. **Fix all issues found** - Address any problems, inconsistencies, or violations of these guidelines
3. **Verify tests pass** - Run the full test suite locally
4. **Check documentation** - Ensure all docs are up to date
5. **Only then create the PR** - Submit for team review

This self-review process prevents wasted review cycles and ensures high-quality submissions.

### PR Best Practices
- Keep PRs focused on a single concern
- Include tests with the code they test
- Update documentation in the same PR as code changes
- Ensure all tests pass before creating PR
- Use descriptive commit messages following the format:
  ```
  <type>: <description>

  Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
  ```

## Architecture

### Package Dependencies
Follow clean architecture principles with these dependency rules:
- **NextToGoCore** - No dependencies, pure domain models
- **NextToGoNetworking** - Depends on Core only
- **NextToGoRepository** - Depends on Core and Networking
- **NextToGoViewModel** - Depends on Core and Repository
- **NextToGoUI** - Depends on Core and ViewModel

### Concurrency Architecture
- Use Swift 6 strict concurrency
- Mark types as `Sendable` when crossing actor boundaries
- Use `nonisolated(unsafe)` sparingly and only for test code or known-safe scenarios
- Document why `nonisolated(unsafe)` is used when necessary
- Use actors for non-UI subsystems (network manager, cache, database)
- Use `@MainActor` for all UI-facing code

## Code Quality

### Comments and Documentation
- Use doc comments (`///`) for public APIs
- Keep comments concise and focused on "why" not "what"
- Update comments when code changes
- Remove outdated or redundant comments
- Avoid over-commenting obvious code

### Error Handling
- Use typed errors over generic Error
- Provide meaningful error messages
- Don't silently swallow errors with `try?` unless truly optional
- Handle errors at appropriate boundaries

### Property Wrappers
- Use `@Observable` instead of `ObservableObject` (iOS 17+)
- Use `@State` instead of `@StateObject` with `@Observable` types
- Use `@MainActor` for UI-related types
- Follow property wrapper decision tree (see SwiftUI Architecture section)

## Conventions

### Naming
- Use clear, descriptive names
- Avoid abbreviations unless industry-standard
- Prefix test functions with descriptive sentences
- Use `make` prefix for test helper factory functions (e.g., `makeRace()`)
- Boolean properties should read like questions: `isExpired`, `hasAward`

### File Organisation
- One type per file (exceptions for tightly-coupled types)
- Group related files in directories
- Keep test files parallel to source files
- Use `// MARK: -` to separate logical sections

### Imports
- Import only what you need
- Use `@testable` only in test targets
- Group imports: system frameworks first, then external dependencies, then internal modules

## Performance Optimisation

### When to Optimise
1. Profile first with Instruments
2. Identify bottlenecks with data
3. Apply targeted optimisations
4. Verify improvements with profiling

### Common Optimisations
- Cache formatters (DateFormatter, NumberFormatter)
- Move expensive computations to model layer
- Use computed properties for derived state
- Avoid creating objects in view bodies
- Use granular dependencies for collection updates

### Anti-Patterns to Avoid
- ❌ Creating formatters in view bodies
- ❌ Heavy computations in view bodies
- ❌ Whole array dependencies when only one item changes
- ❌ Frequently-changing environment values
- ❌ Premature optimisation without profiling data

## Security and Safety

### Data Race Prevention
- Use Swift 6 strict concurrency checking
- Rely on compiler to catch data races
- Use actors for shared mutable state
- Mark types as `Sendable` appropriately

### Input Validation
- Validate at system boundaries (user input, external APIs)
- Trust internal code and framework guarantees
- Avoid defensive programming within trusted boundaries

### Sensitive Data
- Never log sensitive data
- Use Keychain for credentials
- Avoid hardcoding secrets
- Validate all external inputs

## Pressure Scenarios

### When Deadlines Conflict with Quality

**If pressured to skip best practices:**
1. Acknowledge the deadline
2. Show time comparison (proper approach vs quick fix)
3. Offer compromise (80% now, 20% as documented tech debt)
4. Only accept if truly out of time with explicit ticket

**When to profile instead of guessing:**
- Production performance issues
- User complaints about sluggishness
- Unclear root cause

**Time cost of guessing wrong:**
- 24-hour App Store review delay
- Continued user suffering
- Reputational damage

**Time cost of profiling right:**
- 25 minutes diagnostic
- Targeted fix
- Confident deployment

## Quick Reference

### Swift 6 Concurrency Decision Tree

```
Starting new feature?
└─ Is UI responsive with all operations on main thread?
   ├─ YES → Stay single-threaded
   └─ NO → Continue...
       └─ Do you have high-latency operations? (network, file I/O)
          ├─ YES → Add async/await
          └─ NO → Continue...
              └─ Do you have CPU-intensive work?
                 ├─ YES → Add @concurrent or nonisolated
                 └─ NO → Continue...
                     └─ Is main actor contention causing slowdowns?
                        └─ YES → Extract subsystem to actor
```

### SwiftUI Property Wrapper Decision Tree

```
Which property wrapper?
├─ View owns the state? → @State
├─ App-wide environment? → @Environment
├─ Just need bindings? → @Bindable
└─ None of above? → Plain property
```

### Performance Optimisation Checklist

- [ ] Build in Release mode
- [ ] Profile with Instruments SwiftUI template
- [ ] Check Long View Body Updates lane
- [ ] Use Time Profiler for expensive operations
- [ ] Use Cause & Effect Graph for unnecessary updates
- [ ] Verify fixes with new trace

---

**See Also:**
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Technical architecture details
- [TESTING.md](./TESTING.md) - Testing strategy and guide
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Contribution workflow
