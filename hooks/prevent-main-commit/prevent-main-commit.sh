#!/bin/bash
# Prevents Claude Code from committing directly to protected branches.
# This only affects Claude Code — regular git usage is unaffected.
#
# Configuration:
#   PROTECTED_BRANCHES - space-separated branch names (default: "main master")

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only intercept git commit commands
if ! echo "$COMMAND" | grep -qE '(^|&&|;|\|\|)\s*git commit'; then
  exit 0
fi

# If the command creates a new branch before committing, the commit won't
# land on main — allow it through.
if echo "$COMMAND" | grep -qE 'git (checkout -b|switch -c)'; then
  exit 0
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
PROTECTED_BRANCHES="${PROTECTED_BRANCHES:-main master}"

for branch in $PROTECTED_BRANCHES; do
  if [ "$CURRENT_BRANCH" = "$branch" ]; then
    jq -n --arg branch "$branch" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: "Cannot commit directly to \($branch). Create a feature branch first."
      }
    }'
    exit 0
  fi
done

exit 0
