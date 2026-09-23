# /research

Conducts comprehensive codebase research by spawning parallel sub-agents, then synthesizes findings into a structured research document saved to `docs/research/`.

## Usage

```
/research
```

Then provide your research question when prompted. Examples:
- "How does the authentication flow work?"
- "What patterns are used for database access?"
- "Map out the event system architecture"

## What it does

1. Reads any files you mention directly
2. Decomposes your question into parallel research tasks
3. Spawns sub-agents (codebase-locator, codebase-analyzer) to investigate different aspects concurrently
4. Synthesizes all findings into a structured Markdown document with YAML frontmatter
5. Saves the document to `docs/research/YYYY-MM-DD-description.md`
6. Adds GitHub permalinks when possible
7. Handles follow-up questions by appending to the same document

The research is purely descriptive — it documents what exists without suggesting improvements.

## Works best with

- [codebase-locator agent](../../agents/codebase-locator/) — finds where code lives
- [codebase-analyzer agent](../../agents/codebase-analyzer/) — analyzes how code works

Without them it falls back to Claude Code's built-in Explore agent. The plugin install below includes both agents.

## Installation

**As a plugin:**

```
/plugin marketplace add houshuang/awesome-claude-code
/plugin install research@awesome-claude-code
```

**Or copy the file** (from the repo root). Files in `.claude/commands/` still work; Claude Code treats them as skills:

```bash
mkdir -p .claude/commands
cp commands/research/research.md .claude/commands/
```

The plugin includes the codebase-locator and codebase-analyzer agents. When copying by hand, also copy those two agents to `.claude/agents/`.
