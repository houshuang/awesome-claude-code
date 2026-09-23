# Awesome Claude Code

A curated collection of **29 production-tested** Claude Code skills, hooks, commands, agents, and patterns, refined over many months of daily Claude Code use.

These aren't toy examples. Every item here has been used in real projects (React/TypeScript apps, Python backends, mobile apps and data pipelines). The catalogue was last checked against Claude Code in September 2026; items that Claude Code now does natively are marked **superseded** rather than removed.

## Quick Start

The repo is a [plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces). Inside Claude Code:

```
/plugin marketplace add houshuang/awesome-claude-code
/plugin install pr-walkthrough@awesome-claude-code
```

Each hook, skill, command and agent is its own plugin, so you install only what you want. Plugin components are namespaced by plugin name: the `/commit` command installs as `/commit:commit`, and the `codebase-locator` agent as `codebase-locator:codebase-locator`. Skills also load on their own when Claude sees a matching request.

Prefer plain files? Copy them instead, and they keep their short names:

```bash
git clone https://github.com/houshuang/awesome-claude-code.git
cd awesome-claude-code

cp -r skills/pr-walkthrough ~/.claude/skills/          # a skill, for all projects
mkdir -p .claude/commands && cp commands/commit/commit.md .claude/commands/   # a command, one project
```

## What's Inside

| # | Name | Category | Description | Status |
|---|------|----------|-------------|--------|
| 1 | [prevent-main-commit](hooks/prevent-main-commit/) | Hook | Blocks commits to main/master — forces feature branches | Updated |
| 2 | [post-edit-lint](hooks/post-edit-lint/) | Hook | Lints each file after Claude edits it and feeds errors back | Updated |
| 3 | [pre-commit-quality-gate](hooks/pre-commit-quality-gate/) | Hook | Lints + typechecks staged files before Claude commits | Updated |
| 4 | [pr-walkthrough](skills/pr-walkthrough/) | Skill | Generates beautiful HTML PR documentation | Current |
| 5 | [visual-explainer](skills/visual-explainer/) | Skill | HTML diagrams, tables, and system visualizations | Current |
| 6 | [frontend-design](skills/frontend-design/) | Skill | Anti-"AI slop" design principles for distinctive UI | Superseded by the official plugin |
| 7 | [icon-generation](skills/icon-generation/) | Skill | App icons from HTML/CSS via Chrome headless | Updated |
| 8 | [useeffect-review](skills/useeffect-review/) | Skill | React useEffect audit — finds unnecessary effects | Current |
| 9 | [playwright-e2e](skills/playwright-e2e/) | Skill | Playwright E2E testing best practices | Current |
| 10 | [readme-writer](skills/readme-writer/) | Skill | Philosophy-driven README writing | Current |
| 11 | [/catchup](commands/catchup/) | Command | Restore context after /clear | Current |
| 12 | [/commit](commands/commit/) | Command | Smart grouped commits with good messages | Current |
| 13 | [/review-branch](commands/review-branch/) | Command | Self-review all branch changes before PR | Superseded by `/code-review` |
| 14 | [/review-feedback](commands/review-feedback/) | Command | Evaluate and prioritize PR review comments | Updated |
| 15 | [/rebase-stack](commands/rebase-stack/) | Command | Manage PR stacks — keep branches in sync | Current |
| 16 | [/research](commands/research/) | Command | Spawn parallel research agents for deep analysis | Updated |
| 17 | [/verify-docs](commands/verify-docs/) | Command | Detect documentation-code drift | Updated |
| 18 | [codebase-analyzer](agents/codebase-analyzer/) | Agent | Read-only "how does this work?" deep analysis | Updated |
| 19 | [codebase-locator](agents/codebase-locator/) | Agent | "Where is X?" super-search across the codebase | Superseded by the Explore agent |
| 20 | [code-reviewer](agents/code-reviewer/) | Agent | Structured review with severity tiers | Superseded by `/code-review` |
| 21 | [git-status-line](tools/git-status-line/) | Tool | Rich status line for Claude Code terminal | Updated |
| 22 | [claude-cli-backend](skills/claude-cli-backend/) | Skill | Full guide for `claude -p` as programmatic LLM backend | Updated (renamed from `claude-api`) |
| 23 | [autoresearch](skills/autoresearch/) | Skill | Karpathy-style experiment loops with Optuna | Current |
| 24 | [calibration-eval](skills/calibration-eval/) | Skill | Human-in-the-loop evaluation page generator | Updated |
| 25 | [knowledge-probe](skills/knowledge-probe/) | Skill | Adaptive knowledge mapping with Bayesian inference | Updated |
| 26 | [CLAUDE.md Template](patterns/claude-md-template.md) | Pattern | Best practices for structuring CLAUDE.md | Updated |
| 27 | [Discovery Guide](patterns/discovery-guide.md) | Pattern | Making projects Claude-friendly | Updated |
| 28 | [Experiment Log](patterns/experiment-log.md) | Pattern | Append-only change tracking convention | Current |
| 29 | [Ideas Tracker](patterns/ideas-tracker.md) | Pattern | Living ideas document with status markers | Current |

## Categories

### Hooks

Hooks run automatically in response to Claude Code events — edits, commits, tool calls. They're the closest thing to "guardrails" for AI-assisted development: instructions in CLAUDE.md are advice, while a `PreToolUse` hook can actually block an action.

- **[prevent-main-commit](hooks/prevent-main-commit/)** — Blocks direct commits to main/master (configurable). Simple but saves you from accidental pushes.
- **[post-edit-lint](hooks/post-edit-lint/)** — Runs your linter after every file edit. Claude sees the lint output and fixes issues immediately.
- **[pre-commit-quality-gate](hooks/pre-commit-quality-gate/)** — Runs lint + typecheck on staged files before commit. Catches errors early.

### Skills

Skills are folders with a `SKILL.md` that teach Claude Code a specific capability. You invoke them with `/skill-name`, or Claude loads them automatically when a request matches the skill's description.

- **[pr-walkthrough](skills/pr-walkthrough/)** — Generates pedagogical HTML walkthroughs of PRs with architecture diagrams, data flow, and design decisions. Great for knowledge sharing.
- **[visual-explainer](skills/visual-explainer/)** — Creates self-contained HTML pages that visually explain systems with diagrams, comparison tables, and styled layouts. A snapshot of [nicobailon's skill](https://github.com/nicobailon/visual-explainer); upstream has newer versions.
- **[frontend-design](skills/frontend-design/)** — *Superseded:* an older copy of Anthropic's skill. Install the official one with `/plugin install frontend-design@claude-plugins-official`.
- **[icon-generation](skills/icon-generation/)** — Generates app icons by rendering HTML/CSS and screenshotting with Chrome headless. No Figma needed.
- **[useeffect-review](skills/useeffect-review/)** — Audits React useEffect usage. Finds unnecessary effects, missing dependencies, and suggests improvements.
- **[playwright-e2e](skills/playwright-e2e/)** — Best practices for writing Playwright E2E tests with smart selectors and error handling.
- **[readme-writer](skills/readme-writer/)** — Writes READMEs with a philosophy-first approach. Focuses on the "why" before the "how".
- **[claude-cli-backend](skills/claude-cli-backend/)** — Full reference for using `claude -p` as a programmatic LLM backend. Covers subscription-login vs API-key tradeoffs, `--bare`, essential flags, a Python wrapper, structured output, and Agent SDK comparison. (Renamed from `claude-api`, which now collides with Claude Code's built-in `/claude-api` skill.)
- **[autoresearch](skills/autoresearch/)** — Automated experiment loops in two modes: grid (Optuna TPE parameter sweeps) and creative (Karpathy-style LLM-proposed changes). Measures a scalar metric, commits winners, reverts losers.
- **[calibration-eval](skills/calibration-eval/)** — Generates interactive HTML evaluation pages for collecting human ground-truth judgments. Supports rating, A/B comparison, threshold calibration, and extraction recall. Depends on [limbic](https://github.com/houshuang/limbic).
- **[knowledge-probe](skills/knowledge-probe/)** — Adaptive knowledge mapping via interactive HTML assessment with Bayesian belief propagation. Generates personalized explainers based on what the user knows. Depends on [limbic](https://github.com/houshuang/limbic).

### Commands

Slash commands you invoke with `/command-name`. Claude Code has merged custom commands into skills: a file in `.claude/commands/` still works and behaves like a skill, but new work is better written as a skill folder.

- **[/catchup](commands/catchup/)** — Restores context after `/clear`. Reads recent git history and key files to get back up to speed.
- **[/commit](commands/commit/)** — Analyzes changes and creates logical, well-grouped commits with descriptive messages.
- **[/review-branch](commands/review-branch/)** — *Superseded by the built-in `/code-review`.* Self-reviews all changes on the current branch before you open a PR.
- **[/review-feedback](commands/review-feedback/)** — Evaluates PR review comments, categorizes by severity, and helps you address them efficiently.
- **[/rebase-stack](commands/rebase-stack/)** — Manages stacked PRs. Keeps dependent branches rebased and in sync.
- **[/research](commands/research/)** — Spawns parallel research agents to deeply analyze parts of the codebase or documentation.
- **[/verify-docs](commands/verify-docs/)** — Detects drift between documentation and code. Finds outdated descriptions and missing updates.

### Agents

Subagent definitions for `.claude/agents/`. These are specialized Claude Code instances with constrained tools that Claude can delegate to.

- **[codebase-analyzer](agents/codebase-analyzer/)** — Read-only agent that explains how things work. Deep analysis without touching code.
- **[codebase-locator](agents/codebase-locator/)** — *Superseded by the built-in Explore agent.* Finds files, functions, and patterns across the codebase.
- **[code-reviewer](agents/code-reviewer/)** — *Superseded by the built-in `/code-review` for diffs and PRs.* Structured code review with severity tiers (critical/major/minor/nit).

### Tools

Standalone scripts and utilities.

- **[git-status-line](tools/git-status-line/)** — Custom status line showing model, branch, changes and context usage in Claude Code.

### Patterns

Documented conventions (not installable files) for organizing AI-friendly projects.

- **[CLAUDE.md Template](patterns/claude-md-template.md)** — Best practices for structuring your project's CLAUDE.md file, including imports, `.claude/rules/` and AGENTS.md.
- **[Discovery Guide](patterns/discovery-guide.md)** — How to make your project easily discoverable by Claude Code.
- **[Experiment Log](patterns/experiment-log.md)** — Append-only change log that helps both humans and AI understand project evolution.
- **[Ideas Tracker](patterns/ideas-tracker.md)** — Living document for tracking ideas with `[DONE]`, `[DEFERRED]`, `[REJECTED]` status markers.

## Newer work

Newer skills live in their own repositories:

- **[limbic skills](https://github.com/houshuang/limbic/tree/main/skills)** — Skills for running larger agent jobs:
  - **packet-worker** — apply a codebook or extract structured records across many documents with stateless, budgeted model calls
  - **thin-worker-brief** — brief subagents so they don't spend tokens rediscovering the project
  - **coordinator-hygiene** — keep a long-running coordinating thread cheap, and its destructive commands safe
  - **drive** — turn a long, open-ended request into a bounded plan before spawning any workers
- **[design-explorer](https://github.com/houshuang/design-explorer)** — Generates diverse design mockups and collects feedback in a full-screen carousel with keyboard voting, notes and optional voice.

## Installation

### As plugins (recommended)

```
/plugin marketplace add houshuang/awesome-claude-code
/plugin install <name>@awesome-claude-code
```

Every hook, skill, command and agent in the table is a plugin with the same name, except `frontend-design` (use the official plugin) and `git-status-line` (a `statusLine` setting, which plugins can't provide). `/research` pairs with the `codebase-locator` and `codebase-analyzer` plugins, and falls back to the built-in Explore agent without them.

### By copying files

#### Skills
```bash
# Global (available in all projects)
cp -r skills/skill-name ~/.claude/skills/

# Project-specific
cp -r skills/skill-name .claude/skills/
```

#### Commands
```bash
# Project-specific (recommended)
mkdir -p .claude/commands
cp commands/command-name/command-name.md .claude/commands/
```

#### Agents
```bash
# Project-specific (or ~/.claude/agents/ for all projects)
mkdir -p .claude/agents
cp agents/agent-name/agent-name.md .claude/agents/
```

#### Hooks
```bash
# Copy the script
mkdir -p .claude/hooks
cp hooks/hook-name/hook-name.sh .claude/hooks/

# Add the config from settings-snippet.json to your settings file:
# .claude/settings.json (project) or ~/.claude/settings.json (global)
```

The hook scripts need `jq`.

### Patterns
Patterns are guides — read them and adapt to your project. Some can be copied directly as templates.

## About

These items were developed by [Stian Håklev](https://github.com/houshuang) across multiple production projects, including React/TypeScript apps, Python backends, and React Native mobile apps.

Browse the collection visually at the [catalogue page](https://321-seminar.pages.dev/catalogue.html).

## License

MIT
