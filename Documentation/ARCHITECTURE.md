# Architecture

This document describes the technical architecture of the Next To Go iOS racing app.

## Overview

The app follows **Clean Architecture** principles with a modular approach using **Swift Package Manager**. Each package has a single responsibility and clear dependency boundaries.

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
**Key Types:**
- `Race` - Core domain model with `Decodable` conformance
- `RaceCategory` - Enum for race types (Horse, Harness, Greyhound)
- `RaceRepositoryProtocol` - Repository contract
- `AppConfiguration` - Centralised configuration constants
- `Date+Extensions` - Countdown formatting

**Principles:**
- Pure Swift, no external dependencies
- No UI or networking concerns
- All types are `Sendable` for Swift 6 concurrency

### NextToGoNetworking
**Purpose:** Network communication layer
**Dependencies:** NextToGoCore
**Key Types:**
- `APIClient` - Actor-based HTTP client for thread-safe networking
- `APIEndpoint` - Type-safe endpoint definitions
- `APIError` - Typed error handling
- `RaceResponse` - API response wrapper with custom decoding

**Features:**
- Actor-isolated for thread safety
- Configurable timeouts
- Explicit `CodingKeys` for all decodable types
- Comprehensive error handling

### NextToGoRepository
**Purpose:** Data coordination and business logic
**Dependencies:** NextToGoCore, NextToGoNetworking
**Key Types:**
- `RaceRepositoryImpl` - Implements `RaceRepositoryProtocol`
- Fetches races from API
- Applies business rules (filtering, sorting, expiry)

**Responsibilities:**
- Coordinate between networking and domain layers
- Apply race filtering logic
- Handle errors and retries

### NextToGoViewModel
**Purpose:** Presentation logic and state management
**Dependencies:** NextToGoCore, NextToGoRepository
**Key Types:**
- `RacesViewModel` - `@Observable` view model
- Auto-refresh every 60 seconds
- Race expiry checking every 1 second
- Category filtering with immediate refresh

**Features:**
- Uses `@Observable` macro (iOS 17+)
- Structured concurrency with `Task` and `AsyncStream`
- Debounced refresh when race count < 5 (500ms)
- Comprehensive error handling

### NextToGoUI
**Purpose:** SwiftUI views and components
**Dependencies:** NextToGoCore, NextToGoViewModel
**Key Components:**
- `RacesListView` - Main view with filters and race list
- `RaceRowView` - Individual race card
- `CategoryFilterView` - Filter chips
- `CountdownBadge` - Countdown timer display

**Design System:**
- Centralised theme (colors, typography, layout)
- Full accessibility support
- Dark mode support

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
User Action → ViewModel → Repository → APIClient → API
                ↓              ↓          ↓
             Update UI ← Transform ← Parse JSON
```

### Auto-Refresh Flow
```
Timer (60s) → ViewModel.refresh() → Repository.fetchNextRaces()
                      ↓
              Update Published State
                      ↓
                 SwiftUI Re-render
```

### Race Expiry Flow
```
Timer (1s) → Check advertised_start → Remove expired races
                                              ↓
                                      If count < 5, debounced refresh (500ms)
```

## Testing Strategy

### Unit Tests
- **Core:** Test domain models, expiry logic, category mapping
- **Networking:** Test API client with `MockURLProtocol`
- **Repository:** Test business logic with mocked dependencies
- **ViewModel:** Test state management and refresh logic

### Integration Tests
- Test end-to-end data flow
- Verify package integration

### Test Traits
- Use `.serialized` trait for tests sharing mutable static state
- Document why serialisation is needed

## Configuration

### AppConfiguration
Centralised constants in `NextToGoCore`:
- `apiBaseURL` - API endpoint
- `raceCount` - Number of races to fetch (10)
- `displayCount` - Number of races to display (5)
- `expiryThreshold` - Race expiry time (60s)
- `autoRefreshInterval` - Auto-refresh interval (60s)
- `expiryCheckInterval` - Expiry check interval (1s)
- `debounceDelay` - Debounce delay (0.5s)
- Network timeouts

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
- No retain cycles
- Proper task cancellation
- Efficient race filtering

### Network Efficiency
- Reuse URLSession
- Proper timeout configuration
- Minimal API calls

### UI Performance
- Efficient SwiftUI updates
- Lazy loading where appropriate
- Smooth animations

## Future Enhancements

Potential improvements:
- Offline support with local caching
- Race result history
- Push notifications for race starts
- Advanced filtering options
- Favourites functionality
- Share race information
- Landscape mode optimisation
