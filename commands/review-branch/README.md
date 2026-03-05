# /review-branch

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

Copy `review-branch.md` to `.claude/commands/` in your project.
