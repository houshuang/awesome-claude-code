# git-status-line

A shell script for Claude Code's `userPromptStatusLine` hook that shows git repository status, model info, and context usage in a single line.

## What it shows

```
Claude 3.5 Sonnet on main [+2 ~1 ?3] ↑1 in my-project | 42% ctx
```

- **Model name** — which model is active
- **Branch** — current git branch (or short SHA if detached)
- **Status indicators** — `+staged`, `~modified`, `-deleted`, `?untracked`
- **Remote status** — `↑ahead`, `↓behind`, `↕diverged`
- **Clean indicator** — `✓` when working tree is clean
- **Directory** — basename of current working directory
- **Context usage** — percentage of context window used

## Installation

1. Copy `git-status-line.sh` somewhere on your machine:
   ```bash
   cp git-status-line.sh ~/.claude/git-status-line.sh
   chmod +x ~/.claude/git-status-line.sh
   ```

2. Add to your Claude Code settings (`~/.claude/settings.json`):
   ```json
   {
     "hooks": {
       "UserPromptSubmit": [
         {
           "matcher": "",
           "hooks": [
             {
               "type": "command",
               "command": "~/.claude/git-status-line.sh"
             }
           ]
         }
       ]
     }
   }
   ```

## Requirements

- `bash`
- `jq` (for parsing the JSON input from Claude Code)
- `git`

## How it works

Claude Code pipes JSON context to the hook via stdin, containing:
- `workspace.current_dir` — the current working directory
- `model.display_name` / `model.id` — the active model
- `context_window.used_percentage` — how full the context is

The script parses `git status --porcelain` output to count staged, modified, deleted, and untracked files, and checks `git rev-list` to determine ahead/behind status relative to the upstream branch.

## Non-git directories

When not inside a git repository, shows a simplified line:

```
Claude 3.5 Sonnet in my-project | 42% ctx
```
