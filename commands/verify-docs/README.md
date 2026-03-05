# /verify-docs

Verifies that documentation accurately describes the current codebase by detecting semantic drift — when docs describe behaviors, patterns, or structures that no longer match reality.

## Usage

```
/verify-docs src/auth          # Verify docs for a specific module
/verify-docs docs/api.md       # Verify a specific doc file
/verify-docs --all             # Full verification (expensive)
```

## What it does

1. Identifies relevant documentation files for the given path
2. Extracts claims about module structure, types, data flow, dependencies, and patterns
3. Spawns parallel sub-agents to verify each claim against the actual code
4. Generates a structured drift report categorized by severity (Minor, Moderate, Significant)
5. Offers to fix detected drift by updating the documentation

## Installation

Copy `verify-docs.md` to `.claude/commands/` in your project.
