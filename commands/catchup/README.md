# /catchup

Reads all changed files in the current git branch to get Claude up to speed after a `/clear` command or starting a new session.

## Usage

```
/catchup              # Uses "main" as the base branch
/catchup develop      # Uses "develop" as the base branch
```

## What it does

1. Identifies the current branch and finds where it diverged from the base branch
2. Lists all changed files (committed and uncommitted)
3. Reads each changed file systematically, prioritizing types/interfaces first, then core logic, then tests
4. Provides a comprehensive summary including branch context, change categories, and current state
5. Flags any incomplete work, TODOs, or potential issues

This is especially useful after running `/clear` to free up context — it lets Claude rebuild its understanding of what you're working on.

## Installation

Copy `catchup.md` to `.claude/commands/` in your project.
