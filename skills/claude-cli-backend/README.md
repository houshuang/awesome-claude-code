# claude-cli-backend — `claude -p` as an LLM backend

> Renamed from `claude-api` in September 2026: Claude Code now ships a built-in `/claude-api` skill for the Claude API and SDKs, and the old name collided with it.

Reference guide for using `claude -p` as a programmatic LLM backend. Covers subscription-login vs API-key tradeoffs, essential flags (`--bare`, `--effort`, `--json-schema`), a drop-in Python wrapper with parallel batch support, structured output patterns, and Agent SDK comparison.

## Installation

**As a plugin:**

```
/plugin marketplace add houshuang/awesome-claude-code
/plugin install claude-cli-backend@awesome-claude-code
```

**Or copy the folder** (from the repo root):

```bash
cp -r skills/claude-cli-backend ~/.claude/skills/   # all your projects
cp -r skills/claude-cli-backend .claude/skills/     # this project only
```
