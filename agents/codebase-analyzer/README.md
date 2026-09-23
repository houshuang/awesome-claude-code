# Codebase Analyzer Agent

Analyzes codebase implementation details with surgical precision. Traces data flow, documents patterns, and explains how code works — all with exact file:line references.

## When to use

- You need to understand how a specific feature or component works
- You want to trace data flow through the system
- You need to document implementation details for a research task
- You want to understand architectural patterns in use

## How it works

The agent reads files, traces function calls step by step, and produces structured documentation of the implementation. It uses the Read, Grep and Glob tools to explore the codebase.

Key principle: it **documents** what exists without critiquing or suggesting improvements. Think of it as a technical writer, not a code reviewer.

## Output

Produces structured analysis with:
- Overview and entry points
- Core implementation details with file:line references
- Data flow traces
- Key patterns and configuration
- Error handling documentation

## Installation

**As a plugin:**

```
/plugin marketplace add houshuang/awesome-claude-code
/plugin install codebase-analyzer@awesome-claude-code
```

**Or copy the file** (from the repo root):

```bash
mkdir -p .claude/agents
cp agents/codebase-analyzer/codebase-analyzer.md .claude/agents/   # or ~/.claude/agents/ for all projects
```
