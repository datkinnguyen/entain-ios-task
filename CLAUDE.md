# Claude Instructions for Neds Task Project

## Session Initialization

When starting a new session for this project, automatically load and read the following files to understand the project context:

1. **README.md** - Project overview, requirements, and setup instructions
2. **Documentation/IMPLEMENTATION_PLAN.md** - Detailed implementation plan and architecture decisions

These files provide essential context about the project goals, architecture, and implementation approach.

## Code Quality and Self-Review

Before creating any pull request, **ALWAYS** run SwiftLint to ensure code quality:

```bash
swiftlint lint --strict
```

**Requirements:**
- All SwiftLint violations MUST be fixed before committing
- Zero violations, zero warnings in strict mode
- Follow the project's `.swiftlint.yml` configuration
- Run tests after fixing SwiftLint issues to ensure no breakage

**Self-Review Checklist:**
- [ ] SwiftLint passes with zero violations (`swiftlint lint --strict`)
- [ ] All tests pass (`swift test`)
- [ ] Code follows Swift 6 concurrency best practices
- [ ] No force unwrapping, force try, or force cast
- [ ] Imports are alphabetically sorted
- [ ] Functions are under 40 lines (excluding comments)
- [ ] Lines are under 120 characters
- [ ] Proper error handling implemented
