# useEffect Review

Reviews React code for correct `useEffect` usage, catching common anti-patterns and enforcing best practices from the official React documentation.

## What it does

When reviewing React components or writing new ones, this skill helps Claude Code:

- Identify unnecessary `useEffect` calls (derived state, event responses, chained updates)
- Enforce cleanup patterns for async operations and subscriptions
- Apply the core principle: useEffect is for syncing with external systems only
- Suggest correct alternatives (calculate during render, `useMemo`, event handlers, `key` prop)

Includes a decision flowchart, anti-pattern table, and required code patterns for async/fetch/subscription effects.

## Example usage

```
/useeffect-review check this component for useEffect issues
```

Or naturally:
- "Review the useEffect in UserProfile.tsx"
- "Is this useEffect necessary?"
- "Check my React hooks for anti-patterns"

### Example findings

```
ANTI-PATTERN: useEffect computing derived value
- Line 42: useEffect sets `fullName` from `firstName` + `lastName`
- Fix: Calculate during render: const fullName = `${firstName} ${lastName}`

MISSING CLEANUP: async fetch without AbortController
- Line 67: useEffect fetches data but doesn't abort on unmount
- Fix: Add AbortController with cleanup function
```

## Installation

**As a plugin:**

```
/plugin marketplace add houshuang/awesome-claude-code
/plugin install useeffect-review@awesome-claude-code
```

**Or copy the folder** (from the repo root):

```bash
cp -r skills/useeffect-review ~/.claude/skills/   # all your projects
cp -r skills/useeffect-review .claude/skills/     # this project only
```

## Files

- `SKILL.md` — The skill prompt with review checklist, anti-pattern table, required patterns, and decision flowchart
