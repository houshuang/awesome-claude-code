# /commit

Creates well-structured git commits for changes made during the current session.

## Usage

```
/commit
```

## What it does

1. Reviews the conversation history to understand what was accomplished
2. Runs `git status` and `git diff` to see all changes
3. Groups related changes into logical commits
4. Writes clear, imperative-mood commit messages focused on "why"
5. Stages specific files (never uses `git add -A` or `git add .`)
6. Creates the commit(s) and shows the result

Uses Haiku for speed since this is a straightforward task.

## Installation

Copy `commit.md` to `.claude/commands/` in your project.
