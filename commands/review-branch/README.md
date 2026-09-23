# /review-branch

> **Superseded by the built-in `/code-review`** (alias `/review`), which reviews the current diff, a branch or a PR at a chosen effort level. Keep this command only if you want its specific output format.

Reviews the code changes in the current checked-out branch, providing structured feedback like a senior developer peer review.

## Usage

```
/review-branch
```

## What it does

1. Fetches latest from origin and identifies the base branch
2. Runs `git diff` and `git log` to gather the full set of changes
3. Reviews for correctness, style consistency, potential bugs, readability, test coverage, and documentation
4. Presents feedback organized by file with clear severity levels (critical blockers vs. suggestions)
5. Ends with an overall recommendation: "Looks good to merge", "Needs changes", or "Consider splitting"

Uses Opus for thorough, high-quality code review analysis.

## Installation

**As a plugin:**

```
/plugin marketplace add houshuang/awesome-claude-code
/plugin install review-branch@awesome-claude-code
```

**Or copy the file** (from the repo root). Files in `.claude/commands/` still work; Claude Code treats them as skills:

```bash
mkdir -p .claude/commands
cp commands/review-branch/review-branch.md .claude/commands/
```
