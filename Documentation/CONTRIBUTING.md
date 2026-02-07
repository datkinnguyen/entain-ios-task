# Contributing Guide

Thank you for contributing to the Next To Go iOS racing app! This guide will help you understand our development workflow and standards.

## Getting Started

### Prerequisites
- macOS 14.0+
- Xcode 16.2+
- Swift 6.0+
- Git

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/datkinnguyen/entain-ios-task.git
   cd entain-ios-task
   ```

2. Open the project:
   ```bash
   open NextToGoRaces.xcodeproj
   ```

3. Build and run tests:
   ```bash
   swift test --package-path Packages/NextToGoCore
   swift test --package-path Packages/NextToGoNetworking
   ```

## Development Workflow

### Branch Strategy
- **main** - Protected branch, always stable
- **Feature branches** - Use descriptive names that reflect the work:
  - `feature/task-N-description` - For specific planned tasks
  - `feature/descriptive-name` - For other features (e.g., `feature/documentation-enhancement`)
  - `fix/description` - For bug fixes
  - `refactor/description` - For refactoring work
  - `docs/description` - For documentation-only changes

**Philosophy:** Branch names should clearly communicate what work is being done.

### Creating a Feature Branch
```bash
# Start from main
git checkout main
git pull origin main

# Create feature branch with descriptive name
git checkout -b feature/your-descriptive-name

# Examples:
# git checkout -b feature/task-3-repository-package
# git checkout -b feature/add-dark-mode-support
# git checkout -b fix/memory-leak-in-cache
# git checkout -b docs/update-architecture-guide
```

### ⚠️ Important: Working After Merged PRs

**If a PR has been merged and the branch deleted, ALWAYS create a NEW branch:**

```bash
# Pull latest main
git checkout main
git pull origin main

# Create NEW branch (not the old branch name)
git checkout -b fix/new-fix-description

# Make changes, commit, and push
git push -u origin fix/new-fix-description
```

**Why?** Once a branch is merged and deleted remotely, continuing on a local copy creates merge conflicts and confusion. Always start fresh from the latest `main`.

### Making Changes
1. **Make small, focused commits**
   ```bash
   git add <files>
   git commit -m "feat: Add feature description"
   ```

2. **Follow commit message format:**
   ```
   <type>: <description>

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
   ```

   **Types:**
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `refactor:` - Code refactoring
   - `test:` - Adding or updating tests
   - `docs:` - Documentation changes
   - `ci:` - CI/CD changes
   - `chore:` - Maintenance tasks

3. **Run tests before committing:**
   ```bash
   swift test --package-path Packages/NextToGoCore
   swift test --package-path Packages/NextToGoNetworking
   ```

### Creating a Pull Request

**Before creating any PR, you MUST complete the mandatory self-review process.**

See [CODING_GUIDELINES.md - PR Self-Review Process](./CODING_GUIDELINES.md#pr-self-review-process) for the complete checklist including:
- Self-review all code changes
- Run SwiftLint with zero violations
- Verify all tests pass
- Check documentation is up to date

Once self-review is complete:

```bash
git push -u origin <your-branch-name>
gh pr create --title "feat: Add feature description" --body "$(cat <<'EOF'
## Summary
- Brief description of changes
- Why these changes were made

## Test plan
- [ ] All unit tests pass
- [ ] Tested feature X manually
- [ ] Verified on simulator

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### PR Guidelines

**Size Limits:**
- Keep PRs under **500 lines** of changes
- Split large features into multiple PRs
- Each PR should be independently reviewable

**PR Structure:**
```markdown
## Summary
- What changed and why
- Link to related issues

## Test plan
- [ ] Unit tests added/updated
- [ ] All tests pass
- [ ] Manual testing completed

## Screenshots (if UI changes)
[Add screenshots here]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

**PR Checklist:**
- [ ] Self-reviewed all changes
- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] Follows coding guidelines
- [ ] PR size < 500 lines
- [ ] Descriptive commit messages

### Code Review Process
1. PR is created and self-reviewed
2. CI runs automatically (tests must pass)
3. Team reviews the code
4. Address review comments
5. PR is approved
6. **DO NOT MERGE** - maintainer will merge

## Coding Standards

**All code must follow [CODING_GUIDELINES.md](./CODING_GUIDELINES.md)** for:
- Swift 6 concurrency patterns (actors, Sendable, @MainActor)
- SwiftUI architecture (@Observable, property wrappers, ViewModels)
- Code structure and formatting
- Localisation rules (UK/AU English)
- Testing standards (Swift Testing framework)
- Performance optimisation patterns
- PR requirements and best practices

This is our single source of truth for all coding conventions.

## Testing

For detailed testing instructions, see [TESTING.md](./TESTING.md).

### Quick Test Commands
```bash
# Run all tests for a package
swift test --package-path Packages/NextToGoCore

# Run specific test suite
swift test --filter "Race Model Tests"
```

### Writing Tests
```swift
@Suite("My Feature Tests")
struct MyFeatureTests {

    @Test("Feature works correctly")
    func testFeature() {
        let result = Self.makeTestData()
        #expect(result.isValid)
    }
}

// MARK: - Test Helpers

private extension MyFeatureTests {

    static func makeTestData() -> Data {
        // Helper implementation
    }
}
```

### Test Requirements
- Test all public APIs
- Test edge cases
- Test error scenarios
- Use mocks for external dependencies
- Add descriptive test names

## Documentation

### Doc Comments
Use doc comments (`///`) for all public APIs:

```swift
/// Fetches the next races from the API
/// - Parameter count: Number of races to fetch
/// - Returns: Array of Race objects sorted by start time
/// - Throws: APIError if the request fails
public func fetchNextRaces(count: Int) async throws -> [Race] {
    // Implementation
}
```

### README Updates
Update README.md when:
- Adding new features
- Changing setup instructions
- Updating requirements
- Adding new dependencies

### Architecture Documentation
Update ARCHITECTURE.md when:
- Adding new packages
- Changing package dependencies
- Modifying data flow
- Introducing new patterns

## Package Development

### Creating a New Package
```bash
# Create package directory
mkdir -p Packages/NewPackageName
cd Packages/NewPackageName

# Initialize package
swift package init --type library
```

### Package Structure
```
Packages/PackageName/
├── Package.swift
├── Sources/
│   └── PackageName/
│       └── Source files
└── Tests/
    └── PackageNameTests/
        └── Test files
```

### Package.swift Template
```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PackageName",
    platforms: [
        .iOS(.v18),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PackageName",
            targets: ["PackageName"]
        ),
    ],
    dependencies: [
        .package(path: "../DependencyPackage")
    ],
    targets: [
        .target(
            name: "PackageName",
            dependencies: ["DependencyPackage"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "PackageNameTests",
            dependencies: ["PackageName"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
    ]
)
```

## Accessibility

All code must meet WCAG AA accessibility standards. See [ACCESSIBILITY.md](./ACCESSIBILITY.md) for:
- Complete accessibility requirements and testing procedures
- VoiceOver, Dynamic Type, and Voice Control support
- Colour contrast standards (WCAG AA 4.5:1)
- Accessibility testing tools and checklists

### Quick Reference
```swift
Text("Race Name")
    .accessibilityLabel("Race name: Melbourne Cup")
    .accessibilityHint("Tap to view race details")
```

For comprehensive accessibility guidelines, see [ACCESSIBILITY.md](./ACCESSIBILITY.md).

## Common Issues

### Build Failures
**Issue:** "error: upcoming feature 'StrictConcurrency' is already enabled"
**Fix:** Remove `.enableUpcomingFeature("StrictConcurrency")` from Package.swift

**Issue:** "No such module 'ModuleName'"
**Fix:** Clean build folder (⌘⇧K) and rebuild

### Test Failures
**Issue:** Tests fail with race conditions
**Fix:** Add `.serialized` trait to test suite

**Issue:** Tests fail with concurrency errors
**Fix:** Use `await` for actor-isolated calls

### Git Issues
**Issue:** Merge conflicts
**Fix:** Merge main into feature branch and resolve conflicts
```bash
git checkout <your-branch-name>
git merge main
# Resolve conflicts
git commit
```

## Getting Help

### Resources
- [CODING_GUIDELINES.md](./CODING_GUIDELINES.md) - Coding standards
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Technical architecture
- [TESTING.md](./TESTING.md) - Testing guide
- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

### Asking Questions
- Open an issue with the `question` label
- Provide context and what you've tried
- Include relevant code snippets

## License

This project is MIT licensed. See LICENSE file for details.
