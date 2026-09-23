# post-edit-lint

Runs a linter on files immediately after Claude Code edits them. Catches lint errors at edit time instead of waiting until commit.

## Why

Without this hook, Claude Code may introduce lint errors that accumulate across multiple edits and are harder to fix later. By linting after every edit, Claude gets immediate feedback and can fix issues while the context is fresh.

Note: Typecheck is intentionally **not** run per-edit because intermediate states during multi-file changes produce false positives. Run typecheck before committing instead (see `pre-commit-quality-gate`).

## Installation

**As a plugin** (recommended):

```
/plugin marketplace add houshuang/awesome-claude-code
/plugin install post-edit-lint@awesome-claude-code
```

**Or copy it into one project:**

1. Copy the script to your project:
   ```bash
   mkdir -p .claude/hooks
   cp post-edit-lint.sh .claude/hooks/
   chmod +x .claude/hooks/post-edit-lint.sh
   ```

2. Add the hook config (also in `settings-snippet.json`) to `.claude/settings.json` or `.claude/settings.local.json`:
   ```json
   {
     "hooks": {
       "PostToolUse": [
         {
           "matcher": "Edit|Write",
           "hooks": [
             {
               "type": "command",
               "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/post-edit-lint.sh"
             }
           ]
         }
       ]
     }
   }
   ```

## Configuration

Configure via environment variables (set in your shell profile or `.env`):

| Variable | Default | Description |
|---|---|---|
| `LINT_COMMAND` | `eslint` | Linter command to run |
| `LINT_ARGS` | _(empty)_ | Extra arguments passed to the linter |
| `LINT_FILE_PATTERN` | `\.(ts\|tsx\|js\|jsx)$` | Regex matching files to lint |
| `LINT_SKIP_PATTERN` | `node_modules\|/dist/\|\.next` | Regex matching paths to skip |
| `SKIP_POST_EDIT_LINT` | _(unset)_ | Set to `1` to disable the hook entirely |

**Examples for different linters:**

```bash
# ESLint (default)
export LINT_COMMAND="eslint"

# Biome
export LINT_COMMAND="biome check"

# oxlint
export LINT_COMMAND="oxlint"
export LINT_ARGS="--deny-warnings"

# Ruff (Python)
export LINT_COMMAND="ruff check"
export LINT_FILE_PATTERN="\.(py)$"
```

## How it works

Runs as a `PostToolUse` hook after `Edit` and `Write`. Claude Code sends the event as JSON on stdin; the script reads the edited file from `tool_input.file_path`, checks it against the file pattern and skip pattern, then runs the configured linter. When the linter fails, the hook prints the diagnostics to stderr and exits with code 2, which is how a `PostToolUse` hook hands feedback back to Claude. Requires `jq`.
