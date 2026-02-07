# Claude Instructions for Neds Task Project

## Session Initialisation

When starting a new session for this project, automatically load and read the following files to understand the project context:

1. **README.md** - Project overview, requirements, and setup instructions
2. **Documentation/CONTRIBUTING.md** - Contribution workflow, branch strategy, PR process (REQUIRED for code generation)
3. **Documentation/CODING_GUIDELINES.md** - All coding conventions, best practices, and rules

These files provide essential context about the project goals, architecture, and implementation approach.

**CRITICAL:** Before generating any code, always consult CONTRIBUTING.md for the current workflow and process requirements.

## Important Rules

### Code Generation Workflow

**ALWAYS reference Documentation/CONTRIBUTING.md before and during code generation.**

When generating, modifying, or reviewing code:
1. **Check CONTRIBUTING.md** for current workflow requirements
2. Follow the branch strategy and PR process defined there
3. Ensure all pre-commit requirements are met
4. Follow the commit message format specified
5. Reference CODING_GUIDELINES.md for coding standards
6. Reference TESTING.md for testing requirements
7. Reference ACCESSIBILITY.md for accessibility requirements

**Documentation Hierarchy:**
- **CONTRIBUTING.md** - Workflow, process, and how to contribute (START HERE)
- **CODING_GUIDELINES.md** - Coding standards and patterns
- **TESTING.md** - Testing strategy and commands
- **ACCESSIBILITY.md** - Accessibility requirements
- **ARCHITECTURE.md** - Technical architecture

### Coding Conventions

**ALL coding conventions, best practices, and development rules MUST be documented in Documentation/CODING_GUIDELINES.md.**

This includes but is not limited to:
- Code style and formatting
- Architecture patterns
- Localization practices
- Accessibility guidelines
- Testing conventions
- Security practices

Do NOT add coding guidelines to this file (CLAUDE.md). CLAUDE.md is only for session initialisation and project-specific instructions for Claude.
