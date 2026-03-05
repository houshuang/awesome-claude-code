#!/bin/bash
# Prevents Claude Code from committing directly to the main branch.
# This only affects Claude Code — regular git usage is unaffected.

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

if [ "$CURRENT_BRANCH" = "main" ]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Cannot commit directly to main. Create a feature branch first."
    }
  }'
else
  exit 0
fi
