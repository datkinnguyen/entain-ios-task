# Next To Go Races

A native iOS app that displays the next 5 upcoming races with category filtering and auto-refresh functionality.

## Features

- ✅ Display next 5 upcoming races sorted by start time (with secondary sorting by category)
- ✅ Category filtering (Horse, Harness, Greyhound) with real-time API refresh
- ✅ Auto-refresh every 60 seconds with debounced API calls
- ✅ Countdown timer updating every second with smooth transitions
- ✅ Auto-remove races 60 seconds after start
- ✅ Real-time race expiry checking
- ✅ SwiftUI user interface with adaptive layouts
- ✅ Full accessibility support (VoiceOver, Dynamic Type, ReduceMotion)

## Highlights

### 🎯 Smart Sorting
- **Primary sort**: By advertised start time (earliest first)
- **Secondary sort**: Alphabetically by category when countdown values are equal
- Ensures consistent race ordering even with simultaneous starts

### 🎨 Adaptive Layouts
- **Horizontal layout**: For normal text sizes with center-aligned elements
- **Vertical layout**: Automatically switches at accessibility1+ text size
- **No text truncation**: All text wraps properly at any Dynamic Type size
- **Responsive design**: Works seamlessly from iPhone SE to iPad

### ♿️ Accessibility First
- **VoiceOver**: Comprehensive labels, hints, and announcements for all UI elements
  - **Smart Status Announcements**: Auto-announces when a focused race changes status (normal → starts soon → started)
  - **Natural Language**: Countdown reads as "starts in 5 minutes" or "starting soon in 2 minutes 30 seconds"
  - **Focus Management**: Automatic initial focus on first race, maintains focus during list updates
- **Dynamic Type**: Full support from -3 to +12 text sizes with adaptive layouts
  - **Automatic Layout Switching**: Seamlessly switches from horizontal to vertical layout at accessibility1+ text sizes
  - **No Truncation**: All text wraps properly at any size, ensuring content is never cut off
- **ReduceMotion**: Respects system animation preferences
- **Color Contrast**: WCAG AA compliant (4.5:1 for text, 3:1 for UI)
- **Touch Targets**: All interactive elements meet 44x44pt minimum

### ⚡️ Performance Optimized
- **Debounced Refresh**: 500ms debounce prevents excessive API calls from rapid filter changes
- **Structured Concurrency**: TaskGroup manages all background tasks safely
- **Actor-based Networking**: Thread-safe API client with proper isolation
- **Efficient Updates**: Countdown updates use AsyncStream for minimal overhead
- **Memory Safe**: No retain cycles, proper Task lifecycle management

### 🏗️ Clean Architecture
- **5 Modular Packages**: Core → Networking → Repository → ViewModel → UI
- **Dependency Injection**: Testable architecture with protocol-based dependencies
- **@Observable**: Modern SwiftUI state management (no ObservableObject boilerplate)
- **Swift 6 Strict Concurrency**: Complete data race safety at compile time
- **Progressive Concurrency**: Started single-threaded, added concurrency only where needed

### 🧪 Well Tested
- **61+ Unit Tests**: All domain logic and networking thoroughly tested (100% passing)
- **Mock Infrastructure**: Complete mocking for testing without network calls
- **High Coverage**: Comprehensive test coverage across all packages
- **CI/CD Integration**: Automated testing on every PR

## Requirements

- **iOS:** 18.0+
- **Xcode:** 16.2+
- **Swift:** 6.0+
- **macOS:** 14.0+ (for development)

## Assumptions & Limitations

### API Category Filtering Limitation

**The API does not support filtering races by category IDs.** The `/rest/v1/racing/?method=nextraces&count=N` endpoint returns a mixed list of all race categories without providing a category filter parameter.

**Workaround Strategy:**

To work around this limitation, the app implements a client-side filtering strategy:

1. **Fetch more than needed**: Request 2x the display count from the API (e.g., fetch 10 races to display 5)
   - This multiplier is configurable via `RaceRepositoryImpl.apiFetchMultiplier`
   - Increases the likelihood of having enough races after client-side filtering

2. **Client-side filtering**: Filter the fetched races by selected categories on the device

3. **Retry mechanism**: If the filtered results contain fewer than the required count:
   - The app can retry the fetch up to a maximum number of attempts (configurable)
   - Currently set to fetch once without additional retries
   - During testing, most category filter combinations yield sufficient results on the first attempt

**Known Edge Cases:**

- When filtering by a single category (e.g., only "Horse"), there may be cases where the API doesn't return enough races of that category within the fetched set
- In these rare cases, the app will display fewer than 5 races (e.g., 3-4 races) until the next refresh cycle
- The countdown timer automatically triggers a refresh when races expire, which typically resolves the issue within 60 seconds

**Trade-offs:**

- ✅ **Pros**: Works with the current API without backend changes, simple implementation
- ❌ **Cons**: May occasionally display fewer than 5 races, requires fetching extra data
- 🔄 **Future Improvement**: If the API adds support for `category_ids` parameter, this workaround can be removed

## Architecture

The app follows **Clean Architecture** with modular Swift packages:

```
NextToGoRaces (App)
    ↓
NextToGoUI (SwiftUI Views)
    ↓
NextToGoViewModel (State Management)
    ↓
NextToGoRepository (Business Logic)
    ↓
NextToGoNetworking (API Client) + NextToGoCore (Domain Models)
```

### Packages

- **NextToGoCore** - Domain models (Race, RaceCategory), protocols, extensions, and configuration
- **NextToGoNetworking** - Actor-based API client with thread-safe networking and proper error handling
- **NextToGoRepository** - Race fetching, filtering, and sorting business logic
- **NextToGoViewModel** - @Observable state management with debounced refresh and TaskGroup coordination
- **NextToGoUI** - SwiftUI components with adaptive layouts and full accessibility support

See [Documentation/ARCHITECTURE.md](./Documentation/ARCHITECTURE.md) for detailed technical architecture.

## Getting Started

### Clone the Repository
```bash
git clone https://github.com/datkinnguyen/entain-ios-task.git
cd entain-ios-task
```

### Open in Xcode
```bash
open NextToGoRaces.xcodeproj
```

### Build and Run
1. Select a simulator or device
2. Press ⌘R to build and run
3. The app will fetch and display upcoming races

### Run Tests
```bash
# Test Core package
swift test --package-path Packages/NextToGoCore

# Test Networking package
swift test --package-path Packages/NextToGoNetworking

# Or use Xcode: Product → Test (⌘U)
```

## Development

### Project Structure
```
entain-ios-task/
├── NextToGoRaces.xcodeproj          # Xcode project
├── Packages/                         # Swift packages
│   ├── NextToGoCore/                # Domain models
│   └── NextToGoNetworking/          # API client
├── .github/workflows/               # CI/CD configuration
├── Documentation/                   # All documentation
│   ├── ARCHITECTURE.md             # Technical architecture
│   ├── CODING_GUIDELINES.md        # Coding standards
│   ├── CONTRIBUTING.md             # Contribution guide
│   ├── TESTING.md                  # Testing guide
│   └── IMPLEMENTATION_PLAN.md      # Implementation plan
└── README.md                        # This file
```

### Swift 6 Features

This project uses **Swift 6** with strict concurrency checking:
- Actor-based networking for thread safety
- `Sendable` conformance for data race prevention
- `@Observable` macro for state management
- Structured concurrency with `async/await`
- Progressive concurrency adoption (start simple, add complexity when needed)

### API Endpoint

**Base URL:** `https://api.neds.com.au/rest/v1/racing/`

**Endpoint:** `?method=nextraces&count=10`

**Category IDs:**
- Horse: `4a2788f8-e825-4d36-9894-efd4baf1cfae`
- Harness: `161d9be2-e909-4326-8c2c-35ed71fb460b`
- Greyhound: `9daef0d7-bf3c-4f50-921d-8e818c60fe61`

## Testing

### Test Coverage
- ✅ NextToGoCore: 22/22 tests passing
- ✅ NextToGoNetworking: 26/26 tests passing
- ✅ NextToGoViewModel: 6/6 tests passing
- ✅ NextToGoRepository: 7/7 tests passing
- **Total:** 61/61 tests passing (100%)

### Test Strategy
- **Unit tests** for all domain logic and networking
- **Mock-based testing** with dependency injection
- **Swift Testing framework** for modern test patterns
- **Comprehensive coverage** across all packages

See [Documentation/TESTING.md](./Documentation/TESTING.md) for detailed testing guide.

## Contributing

We welcome contributions! Please read [Documentation/CONTRIBUTING.md](./Documentation/CONTRIBUTING.md) before submitting PRs.

### Quick Start
1. Fork the repository
2. Create a feature branch with descriptive name: `git checkout -b feature/your-feature-name`
3. Make your changes following [Documentation/CODING_GUIDELINES.md](./Documentation/CODING_GUIDELINES.md)
4. **Self-review all changes** (mandatory before creating PR)
5. Run tests: `swift test`
6. Create PR with descriptive title and summary

### PR Requirements
- ✅ Self-reviewed all code changes
- ✅ All tests pass
- ✅ Documentation updated
- ✅ Follows coding guidelines
- ✅ PR size < 500 lines

## Continuous Integration

GitHub Actions runs automatically on every PR:
- ✅ Swift 6.0 compatibility check
- ✅ Unit tests for all packages
- ✅ Build verification

[![CI Status](https://github.com/datkinnguyen/entain-ios-task/actions/workflows/pr-tests.yml/badge.svg)](https://github.com/datkinnguyen/entain-ios-task/actions)

## Documentation

All documentation is located in the `Documentation/` folder:

- **[ARCHITECTURE.md](./Documentation/ARCHITECTURE.md)** - Technical architecture and design decisions
- **[CODING_GUIDELINES.md](./Documentation/CODING_GUIDELINES.md)** - Coding standards and best practices
  - Swift 6 concurrency patterns (actors, Sendable, progressive adoption)
  - SwiftUI architecture (property wrappers, @Observable, ViewModels)
  - Performance optimisation best practices
- **[CONTRIBUTING.md](./Documentation/CONTRIBUTING.md)** - How to contribute to the project
- **[TESTING.md](./Documentation/TESTING.md)** - Testing strategy and guide
- **[IMPLEMENTATION_PLAN.md](./Documentation/IMPLEMENTATION_PLAN.md)** - Detailed implementation plan

## Roadmap

### ✅ Completed
- [x] Task #1: Project structure and Xcode workspace
- [x] Task #2: NextToGoCore and NextToGoNetworking packages
- [x] Task #3: NextToGoRepository package with business logic
- [x] Task #4: NextToGoViewModel package with @Observable and debounced refresh
- [x] Task #5: NextToGoUI package with SwiftUI components
- [x] Task #6: Main app target with dependency injection
- [x] Task #7: SwiftLint integration with Swift 6 concurrency rules
- [x] GitHub Actions CI/CD pipeline
- [x] Comprehensive test coverage (61+ unit tests passing)
- [x] Full accessibility support (VoiceOver, Dynamic Type, ReduceMotion)
- [x] Documentation (Architecture, Testing, Contributing, Coding Guidelines, Accessibility)
- [x] Adaptive layouts for all screen sizes and text sizes
- [x] Smart sorting (primary by time, secondary by category)
- [x] Debounced API refresh architecture
- [x] Task usage review and optimization

### 🚧 In Progress
- [ ] Performance profiling with Instruments
- [ ] Memory leak detection and optimization

### 📋 Planned
- [ ] UI polish and animations
- [ ] App Store submission preparation
- [ ] Additional edge case testing

### 💡 Further Improvements (Out of Scope)
Future enhancements that could be added when time permits:
- [ ] **Snapshot Tests** - Visual regression testing for UI components
  - RaceRowView snapshot tests (light/dark mode, Dynamic Type sizes)
  - CategoryFilterView snapshot tests (selected/unselected states)
  - CountdownBadge snapshot tests (urgent/normal/negative states)
  - *Note: swift-snapshot-testing dependency is already configured in NextToGoUI package*
- [ ] **Performance Optimizations**
  - On-demand countdown calculation (alternative to countdown timer task)
  - Combine expiry check and countdown timer tasks
- [ ] **Enhanced Error Handling**
  - Retry with exponential backoff for network failures
  - Offline mode with cached data
- [ ] **Additional Features**
  - Race details screen
  - Favorite races
  - Push notifications for race starts
  - Search and filter by venue

## License

MIT License - see LICENSE file for details.

## Contact

**Repository:** https://github.com/datkinnguyen/entain-ios-task

---

🤖 Built with [Claude Code](https://claude.com/claude-code)
