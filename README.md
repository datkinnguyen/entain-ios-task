# Next To Go Races

A native iOS app that displays the next 5 upcoming races with category filtering and auto-refresh functionality.

## Features

- ✅ Display next 5 upcoming races sorted by start time
- ✅ Category filtering (Horse, Harness, Greyhound)
- ✅ Auto-refresh every 60 seconds
- ✅ Countdown timer updating every second
- ✅ Auto-remove races 60 seconds after start
- ✅ Real-time race expiry checking
- ⏳ SwiftUI user interface (coming soon)
- ⏳ Full accessibility support (coming soon)

## Requirements

- **iOS:** 18.0+
- **Xcode:** 16.2+
- **Swift:** 6.0+
- **macOS:** 14.0+ (for development)

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

- **NextToGoCore** - Domain models, protocols, and configuration
- **NextToGoNetworking** - Actor-based API client with thread-safe networking
- **NextToGoRepository** - Data fetching and business logic (coming soon)
- **NextToGoViewModel** - @Observable state management (coming soon)
- **NextToGoUI** - SwiftUI components (coming soon)

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
- **Total:** 48/48 tests passing

### Test Strategy
- **Unit tests** for all domain logic and networking
- **Snapshot tests** for UI components (planned)
- **Integration tests** for end-to-end flows (planned)
- **Target coverage:** ≥80%

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
- [x] GitHub Actions CI/CD pipeline
- [x] Comprehensive test coverage (48 tests)
- [x] Documentation (Architecture, Testing, Contributing, Coding Guidelines)

### 🚧 In Progress
- [ ] Task #3: NextToGoRepository package
- [ ] Task #4: NextToGoViewModel package
- [ ] Task #5: NextToGoUI package
- [ ] Task #6: Main app target with dependency injection

### 📋 Planned
- [ ] SwiftLint integration
- [ ] Snapshot testing
- [ ] Accessibility features
- [ ] UI polish and animations
- [ ] App Store submission preparation

## License

MIT License - see LICENSE file for details.

## Contact

**Repository:** https://github.com/datkinnguyen/entain-ios-task

---

🤖 Built with [Claude Code](https://claude.com/claude-code)
