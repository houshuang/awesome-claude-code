# Awesome Claude Code

A curated collection of **29 production-tested** Claude Code skills, hooks, commands, agents, and patterns — developed across 7,500+ Claude Code sessions.

These aren't toy examples. Every item here has been used daily in real projects (React/TypeScript apps, Python backends, mobile apps) and refined over months of heavy Claude Code usage.

## Quick Start

```bash
# Clone the repo
git clone https://github.com/houshuang/awesome-claude-code.git
cd awesome-claude-code

# Copy a skill to your global config
cp -r skills/frontend-design ~/.claude/skills/

# Copy a command to your project
cp commands/commit/commit.md .claude/commands/

# Copy a hook to your project
cp hooks/prevent-main-commit/prevent-main-commit.sh .claude/hooks/
# Then add the config from settings-snippet.json to your .claude/settings.json
```

## What's Inside

| # | Name | Category | Description |
|---|------|----------|-------------|
| 1 | [prevent-main-commit](hooks/prevent-main-commit/) | Hook | Blocks commits to main/master — forces feature branches |
| 2 | [post-edit-lint](hooks/post-edit-lint/) | Hook | Auto-lints files after every edit (configurable linter) |
| 3 | [pre-commit-quality-gate](hooks/pre-commit-quality-gate/) | Hook | Lints + typechecks staged files before commit |
| 4 | [pr-walkthrough](skills/pr-walkthrough/) | Skill | Generates beautiful HTML PR documentation |
| 5 | [visual-explainer](skills/visual-explainer/) | Skill | HTML diagrams, tables, and system visualizations |
| 6 | [frontend-design](skills/frontend-design/) | Skill | Anti-"AI slop" design principles for distinctive UI |
| 7 | [icon-generation](skills/icon-generation/) | Skill | App icons from HTML/CSS via Chrome headless |
| 8 | [useeffect-review](skills/useeffect-review/) | Skill | React useEffect audit — finds unnecessary effects |
| 9 | [playwright-e2e](skills/playwright-e2e/) | Skill | Playwright E2E testing best practices |
| 10 | [readme-writer](skills/readme-writer/) | Skill | Philosophy-driven README writing |
| 11 | [/catchup](commands/catchup/) | Command | Restore context after /clear |
| 12 | [/commit](commands/commit/) | Command | Smart grouped commits with good messages |
| 13 | [/review-branch](commands/review-branch/) | Command | Self-review all branch changes before PR |
| 14 | [/review-feedback](commands/review-feedback/) | Command | Evaluate and prioritize PR review comments |
| 15 | [/rebase-stack](commands/rebase-stack/) | Command | Manage PR stacks — keep branches in sync |
| 16 | [/research](commands/research/) | Command | Spawn parallel research agents for deep analysis |
| 17 | [/verify-docs](commands/verify-docs/) | Command | Detect documentation-code drift |
| 18 | [codebase-analyzer](agents/codebase-analyzer/) | Agent | Read-only "how does this work?" deep analysis |
| 19 | [codebase-locator](agents/codebase-locator/) | Agent | "Where is X?" super-search across the codebase |
| 20 | [code-reviewer](agents/code-reviewer/) | Agent | Structured review with severity tiers |
| 21 | [git-status-line](tools/git-status-line/) | Tool | Rich status line for Claude Code terminal |
| 22 | [claude-api](skills/claude-api/) | Skill | Full guide for `claude -p` as programmatic LLM backend |
| 23 | [autoresearch](skills/autoresearch/) | Skill | Karpathy-style experiment loops with Optuna |
| 24 | [calibration-eval](skills/calibration-eval/) | Skill | Human-in-the-loop evaluation page generator |
| 25 | [knowledge-probe](skills/knowledge-probe/) | Skill | Adaptive knowledge mapping with Bayesian inference |
| 26 | [CLAUDE.md Template](patterns/claude-md-template.md) | Pattern | Best practices for structuring CLAUDE.md |
| 27 | [Discovery Guide](patterns/discovery-guide.md) | Pattern | Making projects Claude-friendly |
| 28 | [Experiment Log](patterns/experiment-log.md) | Pattern | Append-only change tracking convention |
| 29 | [Ideas Tracker](patterns/ideas-tracker.md) | Pattern | Living ideas document with status markers |

## Categories

### Hooks

Hooks run automatically in response to Claude Code events — edits, commits, tool calls. They're the closest thing to "guardrails" for AI-assisted development.

- **[prevent-main-commit](hooks/prevent-main-commit/)** — Blocks direct commits to main/master. Simple but saves you from accidental pushes.
- **[post-edit-lint](hooks/post-edit-lint/)** — Runs your linter after every file edit. Claude sees the lint output and fixes issues immediately.
- **[pre-commit-quality-gate](hooks/pre-commit-quality-gate/)** — Runs lint + typecheck on staged files before commit. Catches errors early.

### Skills

Skills are prompt files that teach Claude Code specific capabilities. They're invoked with `/skill-name` or automatically based on context.

- **[pr-walkthrough](skills/pr-walkthrough/)** — Generates pedagogical HTML walkthroughs of PRs with architecture diagrams, data flow, and design decisions. Great for knowledge sharing.
- **[visual-explainer](skills/visual-explainer/)** — Creates self-contained HTML pages that visually explain systems with diagrams, comparison tables, and styled layouts.
- **[frontend-design](skills/frontend-design/)** — Produces distinctive, production-grade frontend UI. Fights the generic "AI look" with specific design principles.
- **[icon-generation](skills/icon-generation/)** — Generates app icons by rendering HTML/CSS and screenshotting with Chrome headless. No Figma needed.
- **[useeffect-review](skills/useeffect-review/)** — Audits React useEffect usage. Finds unnecessary effects, missing dependencies, and suggests improvements.
- **[playwright-e2e](skills/playwright-e2e/)** — Best practices for writing Playwright E2E tests with smart selectors and error handling.
- **[readme-writer](skills/readme-writer/)** — Writes READMEs with a philosophy-first approach. Focuses on the "why" before the "how".
- **[claude-api](skills/claude-api/)** — Full reference for using `claude -p` as a programmatic LLM backend. Covers Max plan vs API key tradeoffs, essential flags, Python wrapper, structured output, and Agent SDK comparison.
- **[autoresearch](skills/autoresearch/)** — Automated experiment loops in two modes: grid (Optuna TPE parameter sweeps) and creative (Karpathy-style LLM-proposed changes). Measures a scalar metric, commits winners, reverts losers.
- **[calibration-eval](skills/calibration-eval/)** — Generates interactive HTML evaluation pages for collecting human ground-truth judgments. Supports rating, A/B comparison, threshold calibration, and extraction recall. Depends on [limbic](https://github.com/houshuang/limbic).
- **[knowledge-probe](skills/knowledge-probe/)** — Adaptive knowledge mapping via interactive HTML assessment with Bayesian belief propagation. Generates personalized explainers based on what the user knows. Depends on [limbic](https://github.com/houshuang/limbic).

### Commands

Custom slash commands you invoke with `/command-name`. Copy the `.md` file to `.claude/commands/` in your project.

- **[/catchup](commands/catchup/)** — Restores context after `/clear`. Reads recent git history and key files to get back up to speed.
- **[/commit](commands/commit/)** — Analyzes changes and creates logical, well-grouped commits with descriptive messages.
- **[/review-branch](commands/review-branch/)** — Self-reviews all changes on the current branch. Finds bugs, style issues, and improvements before you open a PR.
- **[/review-feedback](commands/review-feedback/)** — Evaluates PR review comments, categorizes by severity, and helps you address them efficiently.
- **[/rebase-stack](commands/rebase-stack/)** — Manages stacked PRs. Keeps dependent branches rebased and in sync.
- **[/research](commands/research/)** — Spawns parallel research agents to deeply analyze parts of the codebase or documentation.
- **[/verify-docs](commands/verify-docs/)** — Detects drift between documentation and code. Finds outdated descriptions and missing updates.

### Agents

Agent definitions for `.claude/agents/`. These are specialized Claude Code instances with constrained capabilities.

- **[codebase-analyzer](agents/codebase-analyzer/)** — Read-only agent that explains how things work. Deep analysis without touching code.
- **[codebase-locator](agents/codebase-locator/)** — Super-search agent. Finds files, functions, and patterns across the entire codebase.
- **[code-reviewer](agents/code-reviewer/)** — Structured code review with severity tiers (critical/major/minor/nit).

### Tools

Standalone scripts and utilities.

- **[git-status-line](tools/git-status-line/)** — Rich status line showing branch, changes, and project info in Claude Code.

### Patterns

Documented conventions (not installable files) for organizing AI-friendly projects.

- **[CLAUDE.md Template](patterns/claude-md-template.md)** — Best practices for structuring your project's CLAUDE.md file.
- **[Discovery Guide](patterns/discovery-guide.md)** — How to make your project easily discoverable by Claude Code.
- **[Experiment Log](patterns/experiment-log.md)** — Append-only change log that helps both humans and AI understand project evolution.
- **[Ideas Tracker](patterns/ideas-tracker.md)** — Living document for tracking ideas with `[DONE]`, `[DEFERRED]`, `[REJECTED]` status markers.

## Installation

### Skills
```bash
# Global (available in all projects)
cp -r skills/skill-name ~/.claude/skills/

# Project-specific
cp -r skills/skill-name .claude/skills/
```

### Commands
```bash
# Project-specific (recommended)
cp commands/command-name/command-name.md .claude/commands/
```

### Agents
```bash
# Project-specific
cp agents/agent-name/agent-name.md .claude/agents/
```

### Hooks
```bash
# Copy the script
cp hooks/hook-name/hook-name.sh .claude/hooks/

# Add the config from settings-snippet.json to your settings file:
# .claude/settings.json (project) or ~/.claude/settings.json (global)
```

### Patterns
Patterns are guides — read them and adapt to your project. Some can be copied directly as templates.

## About

These items were developed by [Stian Håklev](https://github.com/houshuang) across multiple production projects, including React/TypeScript apps, Python backends, and React Native mobile apps. They represent patterns that survived daily use across 7,500+ Claude Code sessions.

Browse the collection visually at the [catalogue page](https://321-seminar.pages.dev/catalogue.html).

## License

MIT
