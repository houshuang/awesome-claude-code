# prevent-main-commit

Prevents Claude Code from committing directly to the `main` branch. Forces it to create a feature branch first.

This only affects Claude Code — your regular git workflow is unaffected.

## Why

When Claude Code works autonomously, it may try to commit directly to `main`. This hook enforces a branch-based workflow, ensuring all changes go through feature branches (and ideally pull requests) before landing on main.

## Installation

1. Copy the script to your project:
   ```bash
   mkdir -p .claude/hooks
   cp prevent-main-commit.sh .claude/hooks/
   chmod +x .claude/hooks/prevent-main-commit.sh
   ```

2. Add the hook config to `.claude/settings.json` or `.claude/settings.local.json`:
   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "Bash",
           "command": ".claude/hooks/prevent-main-commit.sh"
         }
       ]
     }
   }
   ```

## Configuration

To protect a different branch (e.g. `master` or `develop`), change the branch name in the script:

```bash
if [ "$CURRENT_BRANCH" = "master" ]; then
```

## How it works

Runs as a `PreToolUse` hook on Bash commands. When it detects a `git commit` while on the `main` branch, it returns a `deny` decision with an explanation. Commands that create a new branch before committing (e.g. `git checkout -b feature && git commit`) are allowed through.
