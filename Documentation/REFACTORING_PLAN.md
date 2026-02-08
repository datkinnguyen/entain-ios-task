# Architecture Refactoring Plan

**Date:** 2026-02-08
**Status:** PROPOSED - Awaiting Review
**Related:** Recent Date+Extensions refactoring (commit 47fd647)

---

## Context

Following the successful refactoring of `Date+Extensions` from Core to ViewModel layer, a comprehensive architecture review identified additional opportunities to improve separation of concerns across the package structure.

**Principle:** Core package should contain **only domain logic**, never presentation or UI concerns.

---

## Priority 1: Critical (Same Pattern as Date+Extensions)

### Refactor 1.1: Move `TextConfiguration` from Core to ViewModel

**Current Location:**
`Packages/NextToGoCore/Sources/NextToGoCore/Configuration/TextConfiguration.swift`

**Target Location:**
`Packages/NextToGoViewModel/Sources/NextToGoViewModel/Utilities/TextConfiguration.swift`

**Why:**
- Pure presentation type (distinguishes visual vs accessibility text)
- No domain model should care about UI rendering vs VoiceOver
- Used exclusively by Date+Extensions (presentation logic)
- Violates clean architecture: Core = domain, never presentation

**Impact:**
- Update imports in Date+Extensions
- Update test imports
- Create Utilities folder in NextToGoViewModel

**Estimated Effort:** 30 minutes

---

### Refactor 1.2: Extract `RaceCategory.accessibleLabel` from Core

**Current Implementation:**
```swift
// In NextToGoCore/Sources/NextToGoCore/Models/RaceCategory.swift
public var accessibleLabel: String {
    switch self {
    case .greyhound: return "Greyhound Racing"
    case .harness: return "Harness Racing"
    case .horse: return "Horse Racing"
    }
}
```

**Problem:**
- User-facing UI text in Core domain model
- Should be localized (not hardcoded)
- Presentation concern masquerading as domain logic

**Proposed Solution:**

**Option A - Localized Helper in ViewModel (Recommended):**

```swift
// NextToGoViewModel/Sources/NextToGoViewModel/Utilities/CategoryPresentation.swift
extension RaceCategory {
    public var displayName: String {
        switch self {
        case .greyhound: return LocalizedString.categoryGreyhound
        case .harness: return LocalizedString.categoryHarness
        case .horse: return LocalizedString.categoryHorse
        }
    }

    public var displayNameWithRacing: String {
        switch self {
        case .greyhound: return LocalizedString.categoryGreyhoundRacing
        case .harness: return LocalizedString.categoryHarnessRacing
        case .horse: return LocalizedString.categoryHorseRacing
        }
    }
}
```

**Option B - Direct Replacement in RacesViewModel:**

Replace all `category.accessibleLabel` calls with ViewModel method:
```swift
// In RacesViewModel
private func categoryDisplayName(for category: RaceCategory, withRacingSuffix: Bool = false) -> String {
    // Already exists! Just update callsites.
}
```

**Impact:**
- Remove `accessibleLabel` from RaceCategory
- Update all callsites (mostly in RacesViewModel)
- Localized strings already exist in ViewModel

**Estimated Effort:** 45 minutes

---

## Priority 2: Important (Separation of Concerns)

### Refactor 2.1: Extract `RaceCategory.iconName` to UI Layer

**Current Implementation:**
```swift
// In NextToGoCore/Sources/NextToGoCore/Models/RaceCategory.swift
public var iconName: String {
    switch self {
    case .greyhound: return "greyhound-racing"
    case .harness: return "harness-racing"
    case .horse: return "horse-racing"
    }
}
```

**Problem:**
- Asset references are UI implementation details
- Core layer shouldn't know about asset catalog structure
- Tight coupling between domain model and UI assets

**Proposed Solution:**

Create UI presentation mapper:
```swift
// NextToGoUI/Sources/NextToGoUI/Utilities/CategoryPresentation.swift
extension RaceCategory {
    /// Returns the SF Symbol name for this category
    var iconName: String {
        switch self {
        case .greyhound: return "greyhound-racing"
        case .harness: return "harness-racing"
        case .horse: return "horse-racing"
        }
    }
}
```

**Impact:**
- Remove `iconName` from Core
- Add extension to NextToGoUI
- Update imports in CategoryChip and RaceRowView
- **No behavior change** - just better separation

**Estimated Effort:** 30 minutes

---

## Priority 3: Nice to Have (Organization)

### Refactor 3.1: Reorganize `Localization` Helper

**Current Location:**
`Packages/NextToGoCore/Sources/NextToGoCore/Configuration/Localization.swift`

**Target Location:**
`Packages/NextToGoCore/Sources/NextToGoCore/Utilities/Localization.swift`

**Why:**
- Currently in `Configuration/` folder implies it's a config item
- It's actually a utility function used across packages
- Better semantic organization

**Impact:**
- Create `Utilities/` folder in Core
- Move `Localization.swift`
- Update imports in affected files

**Estimated Effort:** 15 minutes

---

## Implementation Order

**Recommended sequence (if approved):**

1. **TextConfiguration Move** (30 min)
   - Simplest, clearest violation
   - Minimal dependencies

2. **RaceCategory.accessibleLabel Removal** (45 min)
   - Already have localized strings in ViewModel
   - ViewModel already has helper methods
   - High impact on architecture clarity

3. **RaceCategory.iconName Extraction** (30 min)
   - Creates UI-specific presentation mapping
   - Completes RaceCategory cleanup

4. **Localization Reorganization** (15 min) *(Optional)*
   - Polish, improves organization
   - Low priority

**Total Estimated Effort:** 2 hours (excluding optional item)

---

## Benefits Summary

### Architecture
- ✅ Proper separation of concerns (domain vs presentation vs UI)
- ✅ Core layer truly domain-focused (no UI knowledge)
- ✅ Consistent with existing CODING_GUIDELINES.md
- ✅ Follows clean architecture principles

### Maintainability
- ✅ Easier to localize (all UI text in presentation layer)
- ✅ Clearer boundaries between packages
- ✅ Domain models independent of UI implementation

### Testing
- ✅ Core models completely UI-agnostic (easier to test)
- ✅ Presentation logic isolated and testable
- ✅ No coupling between domain and asset catalog

---

## Risks & Mitigation

### Risk 1: Breaking Changes to Core Package
**Mitigation:**
- All changes are internal refactoring
- Public API remains compatible via ViewModel extensions
- Comprehensive test coverage exists (61/61 passing)

### Risk 2: Import Updates Across Packages
**Mitigation:**
- Small codebase (easy to update all callsites)
- Compiler will catch all broken imports
- Each refactor is isolated (can be done incrementally)

### Risk 3: Merge Conflicts with Other Work
**Mitigation:**
- Current branch is `refactor/move-date-extensions-to-viewmodel`
- Each refactor can be a separate PR
- Small, focused changes minimize conflict surface

---

## Testing Strategy

For each refactor:

1. **Pre-refactor:** Run all tests (verify baseline)
   ```bash
   swift test
   ```

2. **Post-refactor:** Run all tests (verify no regression)
   ```bash
   swift test
   ```

3. **Build verification:** Ensure all packages build
   ```bash
   xcodebuild -scheme "NextToGo" clean build
   ```

4. **Manual testing:** Launch app, verify UI unchanged

---

## Open Questions

1. **Should we do all refactors in one PR or separate PRs?**
   - Recommendation: Separate PRs for easier review
   - Each follows the same pattern as Date+Extensions PR

2. **Should we extract iconName now or defer?**
   - Pro defer: Less urgent than text-related issues
   - Pro now: Completes the RaceCategory cleanup entirely

3. **Should we move Localization to Utilities/?**
   - Minor organization improvement
   - Could defer to future "organization cleanup" PR

---

## Success Criteria

✅ All tests passing after each refactor
✅ SwiftLint violations remain at 0
✅ No behavior changes (app functions identically)
✅ Core package has no UI/presentation knowledge
✅ ViewModel layer owns all presentation logic
✅ Documentation updated (ARCHITECTURE.md if needed)

---

## Related Documents

- [ARCHITECTURE.md](./ARCHITECTURE.md) - Clean architecture package structure
- [CODING_GUIDELINES.md](./CODING_GUIDELINES.md) - Localization rules (lines 559-562)
- [CONTRIBUTING.md](./CONTRIBUTING.md) - PR workflow

---

## Approval Required

Please review this plan and approve:

- [ ] Proceed with all Priority 1 refactors
- [ ] Proceed with Priority 2 refactors
- [ ] Proceed with Priority 3 refactors
- [ ] Defer all refactors
- [ ] Selective approval (specify which items)

**Comments:**

---

**Author:** Claude Code
**Reviewer:** @datkinnguyen
**Status:** Awaiting Review
