# Codebase Locator Agent

Locates files, directories, and components relevant to a feature or task. A "Super Grep/Glob/LS" — use it when you need to find where code lives across a codebase.

## When to use

- You need to find all files related to a feature before making changes
- You want to understand the directory structure for a specific area
- You need to locate tests, configs, and docs alongside implementation files
- A single grep/glob isn't enough — you need a comprehensive search

## How it works

The agent uses Grep, Glob, and LS to systematically search the codebase. It thinks about naming conventions, language-specific directory structures, and related terms to find everything relevant. Results are organized by purpose (implementation, tests, config, types, docs).

Key principle: it finds **where** code lives without reading or analyzing **what** it does.

## Output

Produces structured file listings organized by:
- Implementation files
- Test files
- Configuration
- Type definitions
- Related directories
- Entry points

## Installation

Copy `codebase-locator.md` to `.claude/agents/` in your project.
