# Architecture

This document describes the technical architecture of the Next To Go iOS racing app.

**Last Updated:** 2026-02-08

## Overview

The app follows **Clean Architecture** principles with a modular approach using **Swift Package Manager**. Each package has a single responsibility and clear dependency boundaries. The architecture is production-ready with comprehensive test coverage and full accessibility support.

## Architecture Layers

```
┌─────────────────────────────────────────────┐
│         NextToGoRaces (App Target)          │
│         Dependency Injection                │
└────────────────┬────────────────────────────┘
                 │
┌────────────────┴────────────────────────────┐
│            NextToGoUI                        │
│         SwiftUI Views & Components          │
└────────────────┬────────────────────────────┘
                 │
┌────────────────┴────────────────────────────┐
│         NextToGoViewModel                    │
│      @Observable State Management           │
└────────────────┬────────────────────────────┘
                 │
┌────────────────┴────────────────────────────┐
│        NextToGoRepository                    │
│       Business Logic & Coordination         │
└────────┬──────────────────────┬─────────────┘
         │                      │
┌────────┴──────────┐  ┌────────┴─────────────┐
│ NextToGoNetworking│  │   NextToGoCore       │
│   API Client      │  │  Domain Models       │
│   (Actor-based)   │  │   & Protocols        │
└───────────────────┘  └──────────────────────┘
```

## Package Descriptions

### NextToGoCore
**Purpose:** Domain models and business rules
**Dependencies:** None

**Key Components:**
- Domain models (`Race`, `RaceCategory`)
- Protocol contracts (`RaceRepositoryProtocol`)
- Configuration (`AppConfiguration`)
- Utilities (`Localization`)

**Principles:**
- Pure Swift, no external dependencies
- No UI or networking concerns
- All types are `Sendable` for Swift 6 concurrency

### NextToGoNetworking
**Purpose:** Network communication layer
**Dependencies:** NextToGoCore

**Key Components:**
- Actor-based API client (`APIClient`)
- Endpoint definitions (`APIEndpoint`)
- Error types (`APIError`)
- Response models (`RaceResponse`)

**Features:**
- Actor-isolated for thread safety
- Configurable timeouts
- Comprehensive error handling
- Custom JSON decoding for nested API structures

### NextToGoRepository
**Purpose:** Data coordination and business logic
**Dependencies:** NextToGoCore, NextToGoNetworking

**Key Components:**
- Repository implementation (`RaceRepositoryImpl`)
- Testing utilities (`MockRaceRepository`)

**Responsibilities:**
- Coordinate between networking and domain layers
- Apply business rules (category filtering, sorting)
- Transform API responses to domain models

### NextToGoViewModel
**Purpose:** Presentation logic and state management
**Dependencies:** NextToGoCore, NextToGoRepository

**Key Components:**
- State management (`RacesViewModel`)
- Localisation helpers (`LocalizedString`)
- Display configuration utilities (`TextConfiguration`)
- UI formatting extensions (category, date)

**Features:**
- Uses `@Observable` macro (iOS 18+) for granular dependency tracking
- Structured concurrency with `Task`, `AsyncStream`, and `AsyncChannel`
- Debounced refresh using `AsyncChannel` (500ms delay)
- Countdown timer updates every second
- VoiceOver focus management with status change detection
- Comprehensive error handling with user-friendly messages
- Complete accessibility label generation

### NextToGoUI
**Purpose:** SwiftUI views and components
**Dependencies:** NextToGoCore, NextToGoViewModel

**Key Components:**
- Views (`RacesListView`, `RaceRowView`, `CategoryFilterView`, `CategoryChip`, `CountdownBadge`)
- Design system (`RaceColors`, `RaceTypography`, `RaceLayout`)
- Preview utilities (`PreviewHelpers`)

**Accessibility Features:**
- VoiceOver with comprehensive labels, hints, and traits
- Dynamic Type support (-3 to +12 text sizes)
- Adaptive layouts (horizontal ↔ vertical based on text size)
- WCAG AA colour contrast (4.5:1 minimum)
- 44pt+ minimum touch targets
- Focus management for status change announcements
- Dark mode support with adaptive colours

## Swift 6 Concurrency

### Actor Isolation
- `APIClient` is an actor for thread-safe networking
- All networking operations are actor-isolated
- No manual locks or queues needed

### Sendable Conformance
- All domain models conform to `Sendable`
- Data can safely cross actor boundaries
- Compiler-enforced data race safety

### Structured Concurrency
- Use `Task` for asynchronous work
- Use `AsyncStream` for continuous updates
- Proper cancellation handling

### MainActor
- ViewModels use `@MainActor` for UI updates
- SwiftUI views automatically isolated to main actor

## Data Flow

### Race Fetching Flow
```
User Action (category change, retry, etc.)
         ↓
ViewModel.scheduleRefresh()
         ↓
AsyncChannel debounced (500ms)
         ↓
Repository.fetchNextRaces()
         ↓
APIClient fetches and decodes JSON
         ↓
Repository filters by category and sorts
         ↓
Update races array (@Observable)
         ↓
SwiftUI re-renders affected views
```

### Countdown Timer Flow
```
AsyncStream Timer (1s interval)
         ↓
Update currentTime in ViewModel
         ↓
SwiftUI observes change and re-renders countdown displays
```

## Testing Strategy

The app uses **Swift Testing** framework (not XCTest) with comprehensive unit test coverage across all packages.

### Unit Tests by Package
- **NextToGoCore:** Domain models, expiry logic, category mapping
- **NextToGoNetworking:** API client, endpoints, error handling, response decoding, concurrent requests
- **NextToGoRepository:** Business logic, category filtering, race sorting, error propagation
- **NextToGoViewModel:** State management, debouncing, countdown timer, display formatting, VoiceOver focus

### Test Patterns
- **Mocking:** `MockURLProtocol` for network testing, `MockRaceRepository` for ViewModel tests
- **Actor Testing:** Tests verify actor-isolated API calls work correctly
- **Concurrency:** Tests use `await` for async operations, verify proper cancellation
- **Serialization:** `.serialized` trait used for tests sharing `MockURLProtocol.requestHandler`
- **Error Testing:** Uses exact error types (`APIError.self`, `DecodingError.self`), never generic `Error.self`

### CI/CD Integration
- **GitHub Actions:** Automated testing on every PR and push to main
- **Pre-commit:** SwiftLint + all tests must pass before commit
- **Zero Violations:** SwiftLint strict mode enforced (0 warnings, 0 errors)

## Configuration

### AppConfiguration
Centralised constants in `NextToGoCore/Configuration/AppConfiguration.swift`:
- `apiBaseURL` - API endpoint URL
- `expiryThreshold` - Race expiry time threshold (60s)
- `countdownUrgentThreshold` - Urgent countdown threshold (300s / 5 minutes)
- `debounceDelay` - Debounce delay for refresh requests (500ms)
- `maxRacesToDisplay` - Maximum races to display (5)
- `networkRequestTimeout` - Network request timeout (30s)
- `networkResourceTimeout` - Network resource timeout (60s)

## Error Handling

### Typed Errors
- `APIError` for networking issues
- `DecodingError` for JSON parsing
- User-friendly error messages

### Error Scenarios
- Network unavailable
- Invalid response
- Decoding failure
- Timeout

### User Experience
- Show error messages with retry option
- Graceful degradation
- Clear feedback

## Performance Considerations

### Memory Management
- No retain cycles (verified with Instruments)
- Proper task cancellation using structured concurrency
- Weak self captures in long-running tasks

### Network Efficiency
- Reuse URLSession across requests
- Configurable timeout (30s default)
- Debounced API calls (500ms) prevent excessive requests

### UI Performance
- Efficient SwiftUI updates using `@Observable` (granular tracking)
- Adaptive layouts switch based on Dynamic Type size
- Countdown updates use monospaced digits to prevent layout shifts
- View bodies execute in < 1ms (profiled with Instruments SwiftUI template)
