# /rebase-stack

Rebases a stack of dependent PRs onto a target branch, trickling changes down through the entire chain.

## Usage

```
/rebase-stack          # Rebases onto main
/rebase-stack develop  # Rebases onto develop
```

## What it does

1. Discovers the PR stack by walking the `baseRefName` chain from your current branch back to the target using `gh pr list`
2. Shows the full stack and asks for confirmation before proceeding
3. Rebases each branch sequentially from bottom to top
4. Handles local branches on top of the stack (warns about uncommitted changes or unpushed commits)
5. Force-pushes all branches with `--force-with-lease`
6. Reports results with a summary table

Stops immediately on conflicts — never auto-resolves.

## Prerequisites

- [GitHub CLI (`gh`)](https://cli.github.com/) must be installed and authenticated
- PRs must be created with `gh pr create` so the base branch metadata is available

## Installation

**As a plugin:**

```
/plugin marketplace add houshuang/awesome-claude-code
/plugin install rebase-stack@awesome-claude-code
```

**Or copy the file** (from the repo root). Files in `.claude/commands/` still work; Claude Code treats them as skills:

```bash
mkdir -p .claude/commands
cp commands/rebase-stack/rebase-stack.md .claude/commands/
```
