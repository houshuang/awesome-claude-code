# PR Walkthrough

Generate beautiful, self-contained HTML walkthroughs that deeply explain pull requests and feature branches.

## What it does

When you ask Claude Code to explain a PR or feature branch, this skill produces a polished HTML page with an editorial design (warm paper theme, Instrument Serif headings, Source Serif body text). The walkthrough covers architecture, data flow, design decisions, tradeoffs, and extension patterns — not just a list of changed files.

The output is a single self-contained HTML file you can open in any browser and share with your team.

## Example usage

```
/pr-walkthrough
```

Or naturally:
- "Walk me through this PR"
- "Explain what this branch does"
- "Create a deep dive of the authentication feature"
- "Write up how this feature works for the team"

### What it produces

A `{topic}-walkthrough.html` file in the project root containing:
- Table of contents
- Architecture diagrams (CSS-based flow diagrams)
- Annotated code excerpts with syntax highlighting
- Callout boxes for key insights, patterns, tradeoffs, and warnings
- Layer diagrams showing how components connect
- Extension recipes for adding similar features

## Installation

Copy the `pr-walkthrough/` directory to your Claude Code skills folder:

```bash
# Global (available in all projects)
cp -r pr-walkthrough/ ~/.claude/skills/pr-walkthrough/

# Project-specific
cp -r pr-walkthrough/ .claude/skills/pr-walkthrough/
```

## Files

- `SKILL.md` — The skill prompt that guides Claude Code
- `templates/reference-walkthrough.html` — Reference HTML template demonstrating the design system, component library, and aesthetic
