# CLAUDE.md Template & Best Practices

A CLAUDE.md file is a project-level instruction file that Claude Code reads automatically at the start of every session. It's the single most important file for getting consistent, high-quality AI-assisted development.

## Why it matters

Without a CLAUDE.md, every Claude Code session starts from zero. Claude has to re-discover your tech stack, build commands, testing conventions, and code style -- wasting time and making inconsistent choices. A good CLAUDE.md eliminates this cold-start problem.

## Template

```markdown
# Project Name

## Project Overview
[1-3 sentences: what the project does, who it's for, key design philosophy]

## Tech Stack
- **Backend**: [language, framework, database]
- **Frontend**: [framework, build tool]
- **Infrastructure**: [hosting, CI/CD, deployment]

## Quick Start
\`\`\`bash
# Setup
[install dependencies command]
[environment setup]

# Run
[dev server command]

# Test
[test command]
\`\`\`

## Architecture
- **`src/`** -- [what's in this directory]
- **`lib/`** -- [what's in this directory]
- **`tests/`** -- [what's in this directory]
[Key architectural decisions, e.g. "SQLite in WAL mode, single-user, no auth"]

## Reference Docs
| Doc | Contents |
|-----|----------|
| `docs/architecture.md` | System design and ADRs |
| `docs/api-reference.md` | API endpoint reference |
[Point Claude to detailed docs so it doesn't have to grep for information]

## Critical Rules

### Build & Test
- [Package manager preferences, e.g. "Always use pnpm, never npx"]
- [Type checking commands]
- [How to verify changes before committing]

### Code Style
- [Language-specific conventions, e.g. "Python: type hints, pydantic models"]
- [Logging conventions]
- [Error handling patterns]
- [Import conventions]

### Git Workflow
- [Branch naming, e.g. "Branch prefix: sh/ for all branches"]
- [Commit conventions]
- [PR description rules, e.g. "No test plans or checklists in PR descriptions"]
- [When to use branches vs direct commits]

### Design Principles
- [Domain-specific rules that Claude must always follow]
- [Things Claude commonly gets wrong without guidance]

## Testing
\`\`\`bash
[How to run tests -- be specific]
[How to run a single test file]
[Integration/E2E test commands if different]
\`\`\`

## Deployment
\`\`\`bash
[Deploy commands]
[Post-deploy verification steps]
\`\`\`
```

## Best practices from real projects

### 1. Lead with critical rules

Put the most important constraints at the top. If Claude must never use `npx`, or must always rebase instead of merge, say it early and clearly:

```markdown
## CRITICAL RULES - READ FIRST

- Never add untracked files unless you added them or the user tells otherwise.
- **NEVER use `npx`** - always use `pnpm` or `pnpx` instead.
- **Always use `git rebase`** instead of `git merge`.
```

### 2. Point to detailed docs instead of inlining everything

Don't put your entire architecture in CLAUDE.md. Point Claude to the right file for the task:

```markdown
## Optional reading based on task

- `./docs/architecture.md` - Read when creating new services
- `./docs/secure_engineering.md` - Read when implementing auth or handling user data
- Use the `/frontend-design` skill when building React components
```

### 3. Include a "local context" rule for monorepos

In monorepos, sub-directories may have their own conventions:

```markdown
## Working with Code

When processing code in a specific path, **always read the local CLAUDE.md
or README.md file** in that directory first.
```

### 4. Document design principles, not just conventions

The most valuable CLAUDE.md entries are domain-specific rules that prevent common mistakes:

```markdown
## Design Principles
- **No bare word cards in review** -- ONLY sentences. Generate on-demand or skip.
- **Al-prefix is NOT a separate lemma** -- الكلب and كلب are the same lemma.
- **Be conservative with ElevenLabs TTS** -- costs real money. Only generate
  for sentences that will be shown.
```

### 5. Document the verification workflow

Tell Claude exactly how to check its own work:

```markdown
## Verifying changes

Each package should have these scripts:
- `test` -- runs testing verification

To fix formatting: `pnpm format`
To check all changes locally: `pnpm -w run check`
```

### 6. Include deployment commands

Claude can deploy for you, but only if it knows how:

```markdown
## Deployment
\`\`\`bash
ssh server "cd /opt/app && git pull && docker compose up -d --build"
\`\`\`
```

### 7. Add git discipline rules

Prevent silent reverts and accidental deletions:

```markdown
### Git Diff Discipline
Before every commit, run `git diff --stat HEAD` and review what changed. Watch for:
- **Append-only files shrinking** -- this means entries were deleted. NEVER acceptable.
- **Large service files with net deletions** -- verify removals are intentional.
- **Bundled commits touching >5 files** -- split or review each file individually.
```

## Hierarchy of CLAUDE.md files

Claude Code reads instructions from multiple levels (all are additive):

1. **`~/.claude/CLAUDE.md`** -- Global preferences (git conventions, PR style, personal workflow)
2. **`./CLAUDE.md`** or **`./.claude/CLAUDE.md`** -- Project-level instructions (checked into the repo)
3. **`./CLAUDE.local.md`** -- Your personal notes for this project (add it to `.gitignore`)
4. **`subdir/CLAUDE.md`** -- Loaded on demand when Claude reads files in that directory (useful for monorepo packages)
5. **`.claude/rules/*.md`** -- Topic-sized rule files, optionally scoped to file paths so they only load when relevant

Use global CLAUDE.md for cross-project preferences like branch naming or PR formatting. Use project CLAUDE.md for everything specific to that codebase. Run `/init` to generate a first draft from your codebase.

### Imports and AGENTS.md

A CLAUDE.md can pull in other files with `@path/to/file` imports, which keeps the main file short.

If your repo already has an `AGENTS.md` for other coding agents, recent Claude Code versions read it when there is no `CLAUDE.md` in the working directory or above it. If you have both, only `CLAUDE.md` loads by default, so add `@AGENTS.md` to your `CLAUDE.md` to share one set of instructions across tools.

## Anti-patterns to avoid

- **Too long** -- The docs recommend keeping each CLAUDE.md under about 200 lines; longer files cost context and reduce adherence. Move details into linked docs, imports or path-scoped `.claude/rules/`.
- **Too vague** -- "Write clean code" is useless. "Use type hints on all function signatures" is actionable.
- **Duplicating README** -- CLAUDE.md is for AI instructions, not human onboarding. Focus on rules and constraints, not tutorials.
- **Stale commands** -- If your build command changes, update CLAUDE.md. Stale instructions cause repeated failures.
