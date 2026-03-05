# README Writer

Write README documentation that builds mental models and captures design decisions, rather than duplicating what TypeScript IntelliSense already provides.

## What it does

When documenting a package or library, this skill guides Claude Code to focus on what matters:

- Architecture and component relationships (with Mermaid diagrams)
- Design decisions and the reasoning behind them
- Non-obvious behaviors, tradeoffs, and key concepts
- State machines, data flow, and integration points

It explicitly avoids:
- API reference lists (function signatures, parameter types)
- Basic usage examples obvious from types
- Anything a developer can get by hovering in their IDE

## Example usage

```
/readme-writer document this package
```

Or naturally:
- "Write a README for the sync engine"
- "Document how the auth module works"
- "Create documentation for this library"

### What it produces

A focused README with architecture diagrams, design decision explanations, and key concepts -- the information that would otherwise require reading through the entire codebase to understand.

## Installation

Copy the `readme-writer/` directory to your Claude Code skills folder:

```bash
# Global (available in all projects)
cp -r readme-writer/ ~/.claude/skills/readme-writer/

# Project-specific
cp -r readme-writer/ .claude/skills/readme-writer/
```

## Files

- `SKILL.md` — The skill prompt with writing guidelines, structure template, and quality checks
