# Discovery Guide: Making Projects Claude-Friendly

How to structure a project so that a fresh Claude Code session can find and use the right information without manual guidance.

## The problem

When Claude Code opens a new session, it starts with zero context about your project. It needs to quickly discover:
- What the project does
- How to build/run/test it
- Where the key files are
- What skills or workflows are available

Without intentional discoverability, Claude wastes turns grepping around, reading wrong files, and making incorrect assumptions.

## The discovery flow

```
User request
  |
  v
Claude checks .claude/ directory
  |
  v
Finds CLAUDE.md / PROJECT_INSTRUCTIONS.md
  |
  v
Instructions point to relevant skills
  |
  v
Skills provide detailed workflows
  |
  v
Successful execution
```

## Core principles

### 1. Multiple entry points

Don't rely on a single file. Create redundant paths to the same information:

- **CLAUDE.md** -- Primary entry point (auto-loaded by Claude Code)
- **README.md** -- Secondary (Claude often reads this when exploring)
- **`.claude/skills/*.md`** -- Task-specific workflows
- **`examples/`** -- Working code that demonstrates patterns

### 2. Keyword-rich naming

Name files using terms that match how users describe tasks:

```
# Good -- matches natural language queries
.claude/skills/process-data.md
.claude/skills/deploy-production.md
examples/csv-to-parquet-pipeline.ts

# Bad -- requires knowledge of project internals
.claude/skills/pipeline-v2.md
.claude/skills/ops.md
```

### 3. Trigger-based routing

In your CLAUDE.md, list explicit triggers that route Claude to the right skill:

```markdown
## Quick Recognition Triggers

If the user asks about ANY of these tasks:
- **Processing data** -> Load `data-pipeline` skill
- **Deploying to production** -> Load `deploy` skill
- **Running tests** -> Load `testing` skill
```

### 4. Hierarchical guidance

Each level of documentation should point to the next:

```
CLAUDE.md
  -> "Load data-pipeline skill for ETL tasks"
    -> Skill has complete API docs and workflows
      -> Points to examples/ for working code
        -> Examples reference back to skill for edge cases
```

### 5. Cross-references everywhere

Every documentation file should reference related files:

```markdown
## Related
- Full API docs: `.claude/skills/data-pipeline.md`
- Working example: `examples/csv-to-parquet.ts`
- Architecture: `docs/architecture.md`
```

## Implementation checklist

### CLAUDE.md (required)
- [ ] Project overview (what it does, in 2-3 sentences)
- [ ] Quick start commands (build, test, run)
- [ ] Trigger-to-skill routing table
- [ ] Key file locations
- [ ] Critical rules and constraints

### README.md (recommended)
- [ ] Section header like "For Claude Code Users -- Start Here"
- [ ] Points to CLAUDE.md or skills for AI-assisted workflows
- [ ] Working examples with clear descriptions

### Skills directory (for complex projects)
- [ ] One skill per major workflow
- [ ] Descriptive filenames matching user query terms
- [ ] Each skill is self-contained with all needed context
- [ ] Helper skills that redirect to the main one (for discoverability)

### Examples directory (optional but valuable)
- [ ] Named to match common query patterns
- [ ] Comments reference which skill/doc to read
- [ ] Actually runnable (not pseudo-code)

## Testing discoverability

Run this mental test for each major workflow:

> If a fresh Claude Code session is asked to [do X], what path does it take to find the right instructions?

Walk through each step. If any step requires guessing or extensive file search, add a pointer. The goal is that Claude reaches the right instructions in 1-2 file reads, not 10.

## Redundancy is a feature

It feels wrong to repeat information across multiple files. Resist the urge to DRY your documentation. For AI discoverability, intentional redundancy across entry points is far better than a single source of truth that Claude might not find.

The cost of a redundant pointer is one extra line of text. The cost of Claude not finding the right instructions is a failed session.
