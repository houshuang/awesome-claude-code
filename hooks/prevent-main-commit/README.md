# prevent-main-commit

Prevents Claude Code from committing directly to `main` or `master`. Forces it to create a feature branch first.

This only affects Claude Code — your regular git workflow is unaffected.

## Why

When Claude Code works autonomously, it may try to commit directly to `main`. This hook enforces a branch-based workflow, ensuring all changes go through feature branches (and ideally pull requests) before landing on main.

## Installation

**As a plugin** (recommended):

```
/plugin marketplace add houshuang/awesome-claude-code
/plugin install prevent-main-commit@awesome-claude-code
```

**Or copy it into one project:**

1. Copy the script to your project:
   ```bash
   mkdir -p .claude/hooks
   cp prevent-main-commit.sh .claude/hooks/
   chmod +x .claude/hooks/prevent-main-commit.sh
   ```

2. Add the hook config (also in `settings-snippet.json`) to `.claude/settings.json` or `.claude/settings.local.json`:
   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "Bash",
           "hooks": [
             {
               "type": "command",
               "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/prevent-main-commit.sh"
             }
           ]
         }
       ]
     }
   }
   ```

## Configuration

Set `PROTECTED_BRANCHES` (space-separated) to protect other branches. The default is `main master`:

```bash
export PROTECTED_BRANCHES="main master develop"
```

## How it works

Runs as a `PreToolUse` hook on Bash commands. When it detects a `git commit` while on a protected branch, it returns a `deny` decision with an explanation. Commands that create a new branch before committing (e.g. `git checkout -b feature && git commit`) are allowed through.

Requires `jq`.
