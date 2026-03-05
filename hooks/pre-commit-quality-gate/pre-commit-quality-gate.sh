#!/bin/bash
# Pre-commit validation: lint and typecheck staged files before commit.
# Runs as a Claude Code PreToolUse hook on Bash commands containing "git commit".
# This only affects Claude Code — regular git usage is unaffected.
#
# Configuration (set in your environment or .env):
#   LINT_COMMAND      - linter command (default: "eslint")
#   LINT_ARGS         - extra arguments for the linter (default: "")
#   TYPECHECK_COMMAND - typecheck command template (default: "npx tsc --noEmit")
#                       Use {pkg_dir} as placeholder for package directory
#   PACKAGE_MANAGER   - package manager (default: "npm")
#   FILE_EXTENSIONS   - extensions to check, space-separated (default: "ts tsx js jsx")
#   MONOREPO_DIRS     - top-level monorepo directories, space-separated
#                       (default: "apps packages services tools")

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only intercept git commit commands
if ! echo "$COMMAND" | grep -qE '(^|&&|;|\|\|)\s*git commit'; then
  exit 0
fi

PROJECT_DIR=$(git rev-parse --show-toplevel 2>/dev/null)
if [[ -z "$PROJECT_DIR" ]]; then
  exit 0
fi

# Configuration with defaults
LINT_COMMAND="${LINT_COMMAND:-eslint}"
LINT_ARGS="${LINT_ARGS:-}"
TYPECHECK_COMMAND="${TYPECHECK_COMMAND:-npx tsc --noEmit}"
PACKAGE_MANAGER="${PACKAGE_MANAGER:-npm}"
FILE_EXTENSIONS="${FILE_EXTENSIONS:-ts tsx js jsx}"
MONOREPO_DIRS="${MONOREPO_DIRS:-apps packages services tools}"

# Ensure node_modules binaries are in PATH
export PATH="$PROJECT_DIR/node_modules/.bin:$PATH"

# Build git diff filter from file extensions
GIT_PATTERNS=""
for ext in $FILE_EXTENSIONS; do
  GIT_PATTERNS="$GIT_PATTERNS -- '*.$ext'"
done

# Get staged files (Added, Copied, Modified, Renamed)
STAGED_FILES=$(eval git diff --cached --name-only --diff-filter=ACMR $GIT_PATTERNS 2>/dev/null)

if [[ -z "$STAGED_FILES" ]]; then
  exit 0
fi

ERRORS=""

# --- Lint each staged file ---
while IFS= read -r file; do
  [[ -f "$PROJECT_DIR/$file" ]] || continue

  LINT_OUTPUT=$($LINT_COMMAND $LINT_ARGS "$PROJECT_DIR/$file" 2>&1)
  if [[ $? -ne 0 ]]; then
    LINT_FILTERED=$(echo "$LINT_OUTPUT" | grep -vE '^\s*$|^Found |^Finished ')
    ERRORS+="LINT: $file
$LINT_FILTERED

"
  fi
done <<< "$STAGED_FILES"

# --- Typecheck affected packages (monorepo support) ---
# Build the grep pattern from MONOREPO_DIRS
MONOREPO_PATTERN=$(echo "$MONOREPO_DIRS" | tr ' ' '|')
UNIQUE_PACKAGES=$(echo "$STAGED_FILES" \
  | grep -oE "^($MONOREPO_PATTERN)/[^/]+" \
  | sort -u)

while IFS= read -r PKG_DIR; do
  [[ -n "$PKG_DIR" && -f "$PROJECT_DIR/$PKG_DIR/package.json" ]] || continue

  PKG_NAME=$(jq -r '.name // empty' "$PROJECT_DIR/$PKG_DIR/package.json")
  [[ -n "$PKG_NAME" ]] || continue

  # Replace {pkg_dir} placeholder if present, otherwise run as-is with --filter
  if [[ "$TYPECHECK_COMMAND" == *"{pkg_dir}"* ]]; then
    TC_CMD="${TYPECHECK_COMMAND//\{pkg_dir\}/$PROJECT_DIR/$PKG_DIR}"
    TC_OUTPUT=$(cd "$PROJECT_DIR" && eval "$TC_CMD" 2>&1)
  else
    TC_OUTPUT=$(cd "$PROJECT_DIR" && $PACKAGE_MANAGER run --filter "$PKG_NAME" typecheck 2>&1)
  fi

  if [[ $? -ne 0 ]]; then
    TC_FILTERED=$(echo "$TC_OUTPUT" | grep -E '(error TS|\.tsx?:|\.jsx?:)' | head -30)
    if [[ -z "$TC_FILTERED" ]]; then
      TC_FILTERED="$TC_OUTPUT"
    fi
    ERRORS+="TYPECHECK ($PKG_NAME):
$TC_FILTERED

"
  fi
done <<< "$UNIQUE_PACKAGES"

if [[ -n "$ERRORS" ]]; then
  REASON="Pre-commit checks failed. Fix these errors before committing:

$ERRORS"
  jq -n --arg reason "$REASON" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
else
  exit 0
fi
