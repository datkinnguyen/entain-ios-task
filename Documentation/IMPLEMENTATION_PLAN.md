# NextToGoRaces - Complete Implementation Plan Export

**Project:** Next To Go Racing App
**Repository:** https://github.com/datkinnguyen/entain-ios-task
**Export Date:** 2026-02-06
**Target:** iOS 18.0+, Swift 6, Xcode 16+

---

## Project Overview

Build a native iOS app that displays the next 5 upcoming races from a racing API, with category filtering (Horse, Harness, Greyhound) and smart debounced refresh functionality.

### Technical Requirements
- **Language:** Swift 6 with strict concurrency checking
- **Deployment Target:** iOS 18.0+
- **Architecture:** Clean Architecture with Swift Package Manager
- **UI Framework:** SwiftUI with @Observable macro
- **Testing:** Unit tests, 80%+ coverage
- **CI/CD:** GitHub Actions with automated testing

### Architecture Layers
1. **Core** - Domain models and protocols
2. **Networking** - API client (actor-based)
3. **Repository** - Data fetching and business logic
4. **ViewModel** - State management with @Observable
5. **UI** - SwiftUI views and components
6. **App** - Main target with dependency injection

---

## Git Workflow

### Branch Strategy
- **Main branch:** `main` (protected)
- **Feature branches:** Use descriptive names that reflect the work
  - For specific tasks: `feature/task-N-description` (e.g., `feature/task-2-core-package`)
  - For other work: `feature/descriptive-name` (e.g., `feature/documentation-enhancement`, `feature/fix-memory-leak`)
  - For bug fixes: `fix/descriptive-name`
  - For refactoring: `refactor/descriptive-name`
- **PR required for all merges**

**Philosophy:** Branch names should clearly communicate what work is being done. The `task-N` format is useful for tracking planned tasks, but not required for all work.

### PR Workflow
1. Create feature branch from main with descriptive name
2. Implement changes
3. Run tests and SwiftLint
4. Create PR with descriptive title
5. Self-review changes (MANDATORY - see CODING_GUIDELINES.md)
6. Fix any issues found
7. Report PR URL and await approval
8. **DO NOT MERGE** - wait for manual approval

### Commit Message Format
```
<type>: <description>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Types:** feat, fix, refactor, test, docs, ci, chore

---

## Task Breakdown

### Task #1: Create project structure and Xcode workspace
**Status:** In Progress
**Branch:** `feature/task-1-project-structure`

**Git Workflow:**
1. Initialize git repository
2. Connect to remote: https://github.com/datkinnguyen/entain-ios-task
3. Create branch: feature/task-1-project-structure
4. Work on this branch

**Implementation:**
- Create NextToGoRaces.xcodeproj with iOS App template
- Configure Swift 6 language mode (SWIFT_VERSION = 6.0)
- Set deployment target to iOS 18.0 (IPHONEOS_DEPLOYMENT_TARGET = 18.0)
- Enable strict concurrency checking (SWIFT_STRICT_CONCURRENCY = complete)
- Create Packages/ directory for Swift packages
- Create .github/workflows/ directory for CI/CD
- Set up comprehensive .gitignore for Xcode projects:
  * xcuserdata
  * .DS_Store
  * DerivedData
  * *.xcworkspace (except Package.swift workspaces)
  * Pods/
  * .swiftpm/
  * Build/

**Verification:**
- Project opens in Xcode without errors
- Swift 6 mode is enabled
- iOS 18.0 deployment target set
- Directory structure in place

**PR Workflow:**
- Create PR with title: "feat: Initialize Xcode project and directory structure"
- Self-review all changes
- Fix any issues
- Report PR URL and await approval
- DO NOT MERGE

---

### Task #2: Create NextToGoCore Swift Package
**Status:** Pending
**Branch:** `feature/task-2-core-package`

**Description:**
Create the core domain models package.

**Implementation:**
- Initialize Swift Package: `Packages/NextToGoCore`
- Create `Race.swift` with Codable conformance and custom CodingKeys
- Create `RaceCategory.swift` enum with SF Symbol icons
- Create `RaceRepositoryProtocol.swift`
- Create `Date+Extensions.swift` for countdown formatting
- Create `AppConfiguration.swift` with centralized constants
- Add unit tests for Race model (expiry logic, category mapping)

**Files to Create:**
```
Packages/NextToGoCore/
├── Package.swift
└── Sources/
    └── NextToGoCore/
        ├── Models/
        │   ├── Race.swift
        │   └── RaceCategory.swift
        ├── Protocols/
        │   └── RaceRepositoryProtocol.swift
        ├── Extensions/
        │   └── Date+Extensions.swift
        └── Configuration/
            └── AppConfiguration.swift
└── Tests/
    └── NextToGoCoreTests/
        └── RaceTests.swift
```

**PR Title:** `feat: Add NextToGoCore package with domain models`

---

### Task #3: Create NextToGoNetworking Swift Package
**Status:** Pending
**Branch:** `feature/task-3-networking-package`

**Description:**
Create the networking layer package.

**Implementation:**
- Initialize Swift Package: `Packages/NextToGoNetworking`
- Add dependency on NextToGoCore
- Create `APIClient.swift` (actor-based, thread-safe)
- Create `APIEndpoint.swift` with racing endpoint
- Create `APIError.swift` with error types
- Create `RaceResponse.swift` (API response wrapper)
- Add unit tests with MockURLSession
- Test custom Decodable implementation

**Files to Create:**
```
Packages/NextToGoNetworking/
├── Package.swift
└── Sources/
    └── NextToGoNetworking/
        ├── APIClient.swift
        ├── APIEndpoint.swift
        ├── APIError.swift
        └── Models/
            └── RaceResponse.swift
└── Tests/
    └── NextToGoNetworkingTests/
        ├── APIClientTests.swift
        └── Mocks/
            └── MockURLSession.swift
```

**PR Title:** `feat: Add NextToGoNetworking package with API client`

---

### Task #4: Create NextToGoRepository Swift Package
**Status:** Pending
**Branch:** `feature/task-4-repository-package`

**Description:**
Create the repository layer package.

**Implementation:**
- Initialize Swift Package: `Packages/NextToGoRepository`
- Add dependencies on NextToGoCore and NextToGoNetworking
- Create `RaceRepositoryImpl.swift`
- Implement `fetchNextRaces` method
- Add error handling and retry logic
- Create unit tests with MockAPIClient
- Verify proper race sorting and filtering

**Files to Create:**
```
Packages/NextToGoRepository/
├── Package.swift
└── Sources/
    └── NextToGoRepository/
        └── RaceRepositoryImpl.swift
└── Tests/
    └── NextToGoRepositoryTests/
        ├── RaceRepositoryImplTests.swift
        └── Mocks/
            └── MockAPIClient.swift
```

**PR Title:** `feat: Add NextToGoRepository package with repository implementation`

---

### Task #5: Create NextToGoViewModel Swift Package
**Status:** Pending
**Branch:** `feature/task-5-viewmodel-package`

**Description:**
Create the ViewModel layer package.

**Implementation:**
- Initialize Swift Package: `Packages/NextToGoViewModel`
- Add dependency on NextToGoCore
- Create `RacesViewModel.swift` with @Observable macro
- Implement centralized refresh architecture:
  * Debounced refresh (500ms) prevents excessive API calls during rapid filter changes
  * All refresh triggers (category changes, expiry-based) use the same debounce logic
- Use structured concurrency to manage background tasks:
  * Countdown timer task: Updates countdown display every second using AsyncStream
  * Expiry check task: Removes expired races (>60 seconds after start) and triggers refresh
- Implement category filtering with immediate API refresh on filter change
- Add comprehensive unit tests for all scenarios:
  * Filter toggling
  * Race expiry
  * Debounce logic
  * Error handling

**Files to Create:**
```
Packages/NextToGoViewModel/
├── Package.swift
└── Sources/
    └── NextToGoViewModel/
        └── RacesViewModel.swift
└── Tests/
    └── NextToGoViewModelTests/
        └── RacesViewModelTests.swift
```

**Key Logic:**
- **Countdown timer:** Updates every 1 second using AsyncStream for smooth countdown display
- **Expiry check:** Every 1 second, removes races where `advertised_start < now - 60s` and triggers refresh to fetch new races
- **Debounced refresh:** 500ms debounce prevents excessive API calls during rapid filter changes
- **Category filtering:** When toggled, triggers immediate API refresh (debounced)
- **Task management:** Background tasks (countdown timer, expiry check) use structured concurrency for safe lifecycle management

**PR Title:** `feat: Add NextToGoViewModel package with state management`

---

### Task #6: Create NextToGoUI Swift Package
**Status:** Pending
**Branch:** `feature/task-6-ui-package`

**Description:**
Create the UI components package with detailed UI/UX specifications.

**Implementation:**
- Initialize Swift Package: `Packages/NextToGoUI`
- Add dependencies on NextToGoCore and NextToGoViewModel

**Create Theme Components:**
- `RaceColors.swift` - All colour constants matching screenshot
- `RaceTypography.swift` - Font styles and sizes
- `RaceLayout.swift` - Spacing, padding, and layout constants

**Create Views:**
- `RacesListView.swift` - Main view with category filters and race list
- `RaceRowView.swift` - Race card with icon, meeting info, race number, countdown
- `CategoryFilterView.swift` - Horizontal scrollable category chips
- `CategoryChip.swift` - Individual filter chip with selection state
- `CountdownBadge.swift` - Countdown timer with red/gray state based on urgency (≤5min)
- `LoadingView.swift` - Full-screen and inline loading states
- `ErrorView.swift` - Error display with retry button

**UI Specifications:**
- **Category icons:**
  * Horse: `figure.equestrian.sports`
  * Greyhound: `dog.fill`
  * Harness: custom or variant
- **Selected chip:** Orange/red background (#FF5733), white icon
- **Unselected chip:** Light gray background (#E5E7EB), gray icon
- **Countdown urgent state:** Red background (#FF4444) when ≤5 minutes
- **Countdown normal state:** Light gray background (#F3F4F6) when >5 minutes
- **Race row:** White card with shadow, 70-80pt height, proper spacing
- **Category icon:** 32x32pt
- **Race flag:** 24x24pt blue
- **Typography:**
  * Meeting name: bold 17pt
  * Location: regular 14pt
  * Countdown: monospaced 15pt

**Behaviour:**
- Category change triggers immediate API refresh (not just client-side filtering)
- Countdown updates every second using AsyncStream
- Always display maximum 5 races
- Negative countdown for started races (e.g., "-1m 9s")

**Create Accessibility:**
- `View+Accessibility.swift` - Accessibility helpers and extensions
- VoiceOver labels for all interactive elements
- Dynamic Type support with scalable layouts
- Voice Control compatibility
- Reduced Motion support

**Files to Create:**
```
Packages/NextToGoUI/
├── Package.swift
└── Sources/
    └── NextToGoUI/
        ├── Theme/
        │   ├── RaceColors.swift
        │   ├── RaceTypography.swift
        │   └── RaceLayout.swift
        ├── Views/
        │   ├── RacesListView.swift
        │   ├── RaceRowView.swift
        │   ├── CategoryFilterView.swift
        │   ├── CategoryChip.swift
        │   ├── CountdownBadge.swift
        │   ├── LoadingView.swift
        │   └── ErrorView.swift
        └── Accessibility/
            └── View+Accessibility.swift
└── Tests/
    └── NextToGoUITests/
        └── (unit tests)
```

**PR Title:** `feat: Add NextToGoUI package with SwiftUI components`

---

### Task #7: Create main app target and dependency injection
**Status:** Pending
**Branch:** `feature/task-7-main-app`

**Description:**
Set up the main application.

**Implementation:**
- Create `NextToGoRacesApp.swift` with @main
- Create `DependencyContainer.swift` for DI
- Wire up all packages
- Create `PreviewData.swift` for SwiftUI previews
- Configure app icon and display name
- Test app launches successfully
- Verify all packages integrate correctly

**Files to Create:**
```
NextToGoRaces/
├── NextToGoRacesApp.swift
├── DependencyContainer.swift
├── PreviewData.swift
└── Assets.xcassets/
    └── AppIcon.appiconset/
```

**Dependency Injection Pattern:**
```swift
// DependencyContainer.swift
@MainActor
final class DependencyContainer: ObservableObject {
    let apiClient: APIClient
    let repository: RaceRepositoryProtocol

    init() {
        self.apiClient = APIClient()
        self.repository = RaceRepositoryImpl(apiClient: apiClient)
    }
}
```

**PR Title:** `feat: Add main app target with dependency injection`

---

### Task #8: Configure SwiftLint and code quality tools
**Status:** Pending
**Branch:** `feature/task-8-swiftlint`

**Description:**
Set up linting and formatting.

**Implementation:**
- Create `.swiftlint.yml` with strict rules
- Configure rules for Swift 6 concurrency
- Add build phase to Xcode project for SwiftLint
- Run SwiftLint and fix any violations
- Document linting standards in code

**SwiftLint Rules to Enable:**
- line_length: 120
- type_body_length: 300
- function_body_length: 40
- cyclomatic_complexity: 10
- file_length: 400
- trailing_whitespace
- colon
- comma
- opening_brace
- unused_optional_binding
- force_cast
- force_try

**Files to Create:**
```
.swiftlint.yml
```

**PR Title:** `chore: Add SwiftLint configuration and fix violations`

---

### Task #9: Set up GitHub Actions CI/CD pipeline
**Status:** Pending
**Branch:** `feature/task-9-ci-cd`

**Description:**
Create CI/CD workflows.

**Implementation:**
- Create `.github/workflows/ci.yml`
- Configure jobs: lint, test, build
- Set up iOS 18.0 simulator testing
- Configure code coverage upload to Codecov
- Test workflow runs successfully
- Add status badges to README

**Workflow Jobs:**
1. **Lint:** Run SwiftLint on all code
2. **Test:** Run all unit tests
3. **Build:** Build app for simulator and device
4. **Coverage:** Upload code coverage to Codecov

**Files to Create:**
```
.github/
└── workflows/
    └── ci.yml
```

**Trigger Conditions:**
- Push to main
- Pull request to main
- Manual workflow dispatch

**PR Title:** `ci: Add GitHub Actions CI/CD pipeline`

---

### Task #10: Create comprehensive documentation
**Status:** Pending
**Branch:** `feature/task-10-documentation`

**Description:**
Write all documentation files.

**Documentation Files:**
1. **README.md** - Overview, setup, architecture summary
2. **ARCHITECTURE.md** - Detailed technical architecture
3. **AGENTS.md** - Dual-purpose: project-specific + general iOS patterns
4. **CLAUDE.md** - Dual-purpose: project integration + general best practices
5. **IMPLEMENTATION_PLAN.md** - User-facing version of the plan
6. **TESTING.md** - Testing strategy, running tests, coverage
7. **ACCESSIBILITY.md** - Accessibility features, compliance
8. **SKILLS_PLUGINS.md** - Recommended tools and setup
9. **CONTRIBUTING.md** - Contribution guidelines

**Content Requirements:**
- Include code examples
- Add architecture diagrams
- Document best practices
- Provide setup instructions
- List testing procedures
- Explain design decisions

**Files to Create:**
```
README.md
ARCHITECTURE.md
AGENTS.md
CLAUDE.md
IMPLEMENTATION_PLAN.md
TESTING.md
ACCESSIBILITY.md
SKILLS_PLUGINS.md
CONTRIBUTING.md
```

**PR Title:** `docs: Add comprehensive project documentation`

---

### Task #11: Run full test suite and verify functionality
**Status:** Pending
**Branch:** N/A (testing phase)

**Description:**
Final testing and verification.

**Testing Checklist:**

**Automated Tests:**
- [ ] Run all unit tests across all packages
- [ ] Verify code coverage ≥80%
- [ ] Run SwiftLint with no warnings
- [ ] Build app for simulator
- [ ] Build app for device

**Manual Testing:**
- [ ] Launch app, verify 5 races display
- [ ] Test category filtering (all combinations)
- [ ] Test rapid filter changes, verify debouncing works
- [ ] Verify race expiry and removal (60s after start)
- [ ] Verify countdown timer updates every second
- [ ] Test accessibility with VoiceOver
- [ ] Test different Dynamic Type sizes
- [ ] Test error scenarios (network off)
- [ ] Test loading states
- [ ] Test empty states

**Performance Testing:**
- [ ] Verify no memory leaks (Instruments)
- [ ] Check CPU usage during countdown updates
- [ ] Verify smooth scrolling
- [ ] Test on iPhone SE (small screen)
- [ ] Test on iPad (large screen)

**Accessibility Testing:**
- [ ] VoiceOver navigation (test all interactive elements)
- [ ] VoiceOver announcements for countdown updates
- [ ] Voice Control commands
- [ ] Dynamic Type (all sizes from -3 to +12)
- [ ] Reduced Motion (verify animations respect system setting)
- [ ] Colour contrast (WCAG AA compliance)

**Performance Profiling:**
- [ ] Profile with Instruments (Time Profiler)
- [ ] Check countdown timer performance impact
- [ ] Verify no excessive CPU usage during countdown updates
- [ ] Profile memory usage over time
- [ ] Check for memory leaks with Memory Graph Debugger
- [ ] Verify proper Task lifecycle management

**Code Review:**
- [ ] Review Task usage in RacesViewModel
- [ ] Verify all Tasks are necessary
- [ ] Check for proper Task cancellation on cleanup
- [ ] Audit for potential race conditions
- [ ] Review actor isolation patterns

**Action Items:**
- Generate code coverage report
- Fix any issues found
- Document test results
- Document performance metrics

---

### Task #12: Polish and final review
**Status:** Pending
**Branch:** N/A (review phase)

**Description:**
Final polish before submission.

**Review Checklist:**

**Code Quality:**
- [ ] Review all code for quality and consistency
- [ ] Ensure consistent naming conventions
- [ ] Verify all TODO comments are addressed
- [ ] Check code comments and documentation
- [ ] Verify error handling is comprehensive
- [ ] Check for unused code/imports

**Documentation:**
- [ ] Ensure all documentation is complete
- [ ] Verify README is accurate
- [ ] Check all links work
- [ ] Review architecture diagrams
- [ ] Verify setup instructions work

**Testing:**
- [ ] Final SwiftLint check
- [ ] All tests passing
- [ ] Code coverage ≥80%
- [ ] No memory leaks
- [ ] Performance is acceptable

**Accessibility:**
- [ ] VoiceOver works correctly
- [ ] Dynamic Type is supported
- [ ] Colour contrast meets WCAG AA
- [ ] Reduced Motion is respected
- [ ] Voice Control is compatible

**Final Actions:**
- [ ] Create submission checklist
- [ ] Prepare testing instructions for reviewer
- [ ] Write deployment notes
- [ ] Document known issues (if any)
- [ ] Create release notes

---

## API Details

**Endpoint:** `https://api.neds.com.au/rest/v1/racing/?method=nextraces&count=10`

**Response Structure:**
```json
{
  "status": 200,
  "data": {
    "race_summaries": {
      "race-id-1": {
        "race_id": "string",
        "race_name": "string",
        "race_number": int,
        "meeting_name": "string",
        "category_id": "string",
        "advertised_start": {
          "seconds": int
        }
      }
    }
  }
}
```

**Category IDs:**
- `9daef0d7-bf3c-4f50-921d-8e818c60fe61` - Greyhound Racing
- `161d9be2-e909-4326-8c2c-35ed71fb460b` - Harness Racing
- `4a2788f8-e825-4d36-9894-efd4baf1cfae` - Horse Racing

---

## Technical Standards

### Swift 6 Requirements
- Enable strict concurrency checking
- Use `@MainActor` for UI types
- Use `actor` for shared mutable state
- Use `Sendable` conformance where appropriate
- Avoid `@unchecked Sendable` unless necessary

### Code Style
- Use SwiftUI for all UI
- Use @Observable instead of ObservableObject
- Use async/await for asynchronous code
- Use structured concurrency (Task, AsyncStream)
- Avoid Combine framework
- No third-party dependencies (except testing)

### Testing Standards
- Unit test coverage ≥80%
- Test all edge cases
- Use mocks for external dependencies
- Test Swift 6 concurrency patterns

### Accessibility Standards
- Support VoiceOver
- Support Dynamic Type
- Support Voice Control
- Support Reduced Motion
- Meet WCAG AA colour contrast
- Provide meaningful accessibility labels

---

## Success Criteria

### Functional Requirements
- ✅ Display next 5 races sorted by start time
- ✅ Category filtering (Horse, Harness, Greyhound)
- ✅ Smart debounced refresh prevents excessive API calls
- ✅ Remove races 60 seconds after start
- ✅ Countdown timer updates every second
- ✅ Display negative countdown for started races

### Technical Requirements
- ✅ Swift 6 with strict concurrency
- ✅ iOS 18.0+ deployment target
- ✅ Clean Architecture with SPM packages
- ✅ SwiftUI with @Observable
- ✅ Unit test coverage ≥80%
- ✅ SwiftLint with no warnings
- ✅ GitHub Actions CI/CD

### Quality Requirements
- ✅ No memory leaks
- ✅ Smooth performance
- ✅ Comprehensive documentation
- ✅ Full accessibility support
- ✅ Error handling for all scenarios
- ✅ Clean, maintainable code

---

## Project Timeline

**Estimated Duration:** 12-16 hours

| Task | Duration | Dependencies |
|------|----------|--------------|
| Task #1 | 1h | None |
| Task #2 | 1.5h | Task #1 |
| Task #3 | 2h | Task #2 |
| Task #4 | 1.5h | Task #2, #3 |
| Task #5 | 2h | Task #2 |
| Task #6 | 3h | Task #2, #5 |
| Task #7 | 1h | Task #2-6 |
| Task #8 | 0.5h | Task #7 |
| Task #9 | 1h | Task #8 |
| Task #10 | 1.5h | All tasks |
| Task #11 | 2h | All tasks |
| Task #12 | 1h | Task #11 |

---

## Notes for Implementation

### Important Reminders
1. **Never merge PRs without approval** - All PRs require manual review
2. **Follow git workflow strictly** - One feature branch per task
3. **Run tests before creating PR** - All tests must pass
4. **Fix SwiftLint violations** - No warnings allowed
5. **Document as you go** - Add inline comments for complex logic
6. **Test accessibility** - VoiceOver must work properly
7. **Handle errors gracefully** - User-friendly error messages
8. **Keep packages focused** - Single responsibility principle

### Common Pitfalls to Avoid
- Don't use ObservableObject (use @Observable)
- Don't use Combine (use async/await)
- Don't skip unit tests (aim for 80%+ coverage)
- Don't ignore SwiftLint warnings (fix them all)
- Don't hardcode values (use AppConfiguration)
- Don't forget accessibility labels
- Don't merge PRs without approval

### Best Practices
- Use dependency injection for testability
- Keep view models independent of SwiftUI
- Use actors for thread-safe networking
- Test edge cases (empty, error, loading states)
- Write descriptive commit messages
- Review your own PR before requesting review
- Update documentation when code changes
- Use preview data for SwiftUI previews

---

## Contact and Support

**Repository:** https://github.com/datkinnguyen/entain-ios-task
**Export Date:** 2026-02-06
**Generated by:** Claude Sonnet 4.5

---

*This implementation plan is comprehensive and ready to be used in any new project folder. Simply follow the tasks in order, creating feature branches and PRs as described.*
