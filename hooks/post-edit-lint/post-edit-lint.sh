#!/bin/bash
# Post-edit lint: runs a linter on changed files immediately after edits.
# Runs as a Claude Code PostToolUse hook after Edit/MultiEdit/Write.
#
# Env vars (set by Claude Code):
#   CLAUDE_FILE_PATH   - absolute path to the edited file
#   CLAUDE_PROJECT_DIR - absolute path to the project root
#
# Configuration (set in your environment or .env):
#   LINT_COMMAND        - linter command to run (default: "eslint")
#   LINT_ARGS           - extra arguments for the linter (default: "")
#   LINT_FILE_PATTERN   - regex for files to lint (default: "\.(ts|tsx|js|jsx)$")
#   LINT_SKIP_PATTERN   - regex for paths to skip (default: "node_modules|/dist/|\.next")
#
# Skip control:
#   SKIP_POST_EDIT_LINT - set to "1" to disable

set -o pipefail

FILE_PATH="${CLAUDE_FILE_PATH}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR}"

# Configurable linter (default: eslint)
LINT_COMMAND="${LINT_COMMAND:-eslint}"
LINT_ARGS="${LINT_ARGS:-}"
LINT_FILE_PATTERN="${LINT_FILE_PATTERN:-\.(ts|tsx|js|jsx)$}"
LINT_SKIP_PATTERN="${LINT_SKIP_PATTERN:-node_modules|/dist/|\.next}"

# Ensure node_modules binaries are in PATH
if [[ -n "$PROJECT_DIR" ]]; then
  export PATH="$PROJECT_DIR/node_modules/.bin:$PATH"
fi

# Skip if no file path or project dir
if [[ -z "$FILE_PATH" || -z "$PROJECT_DIR" ]]; then
  exit 0
fi

# Only check files matching the configured pattern
if [[ ! "$FILE_PATH" =~ $LINT_FILE_PATTERN ]]; then
  exit 0
fi

# Skip generated/vendored paths
if [[ "$FILE_PATH" =~ $LINT_SKIP_PATTERN ]]; then
  exit 0
fi

if [[ "${SKIP_POST_EDIT_LINT}" == "1" ]]; then
  exit 0
fi

LINT_OUTPUT=$($LINT_COMMAND $LINT_ARGS "$FILE_PATH" 2>&1)
LINT_EXIT=$?

if [[ $LINT_EXIT -ne 0 ]]; then
  # Strip noisy summary lines, keep only diagnostics
  echo "$LINT_OUTPUT" | grep -v '^\s*$' | grep -v '^Found '
  exit 1
fi

exit 0
