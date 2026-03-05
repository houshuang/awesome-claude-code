# Ideas Tracker Pattern

A living document where project ideas are tracked with status markers. Unlike issue trackers, it stays in the repo as a plain markdown file that Claude Code reads and updates as part of its workflow.

## Why it's useful

In AI-assisted development, ideas surface constantly -- during bug fixes, code reviews, and feature work. Without a central place to capture them, they get lost in conversation history that Claude can't access in future sessions.

The ideas tracker solves this by being:
- **In-repo** -- Claude reads it automatically via CLAUDE.md
- **Append-only** -- Ideas are never deleted, only marked with status
- **Low-friction** -- Just add a bullet point, no issue template needed
- **Bidirectional** -- Both humans and AI agents add ideas

## Template

```markdown
# Project Name -- Ideas

> Living document. Add ideas as they emerge, never remove.
> Mark as [DONE], [DEFERRED], or [REJECTED] with reasoning.
> Every agent should add new ideas discovered during work.

---

## Category Name

### Idea Title
- Description of the idea
- Why it matters
- [DONE] Sub-idea that was completed
- [DEFERRED] Sub-idea postponed -- reason why
- Related: `path/to/relevant/code.py`

### Another Idea
- Description
- [REJECTED] -- reason it was rejected (e.g., "tested in Phase 2, poor results")

---

## Another Category

### ...
```

## Status markers

| Marker | Meaning |
|--------|---------|
| *(no marker)* | Open idea, not yet started |
| `[DONE]` | Implemented and shipped |
| `[DEFERRED]` | Postponed with reason (may revisit later) |
| `[REJECTED]` | Explicitly decided against, with reasoning |
| `[ACTIVE]` | Currently being worked on |

The reasoning after `[DEFERRED]` and `[REJECTED]` is critical. It prevents future agents from re-proposing rejected ideas without understanding why they were rejected.

## Rules for CLAUDE.md

Add these rules to ensure Claude maintains the ideas file:

```markdown
### IDEAS.md -- Always Update
The file `IDEAS.md` is the master record of ALL project ideas.
- Read at start of work
- Add new ideas discovered during development
- Never remove ideas -- mark with status
- Include reasoning when marking [DEFERRED] or [REJECTED]
```

## Real-world example

From a political program analysis project:

```markdown
## Taxonomy & Classification

- [DONE] 18-topic flat taxonomy: klima, energi, natur, transport, ...
  Validated in Phase 2, scaled in Phase 3.
- [DONE] Added forsvar, utenriks, justis for national coverage (18->21).
- Two-level sub-topics under most populated categories
  (klima > utslipp/tilpasning, transport > kollektiv/sykkel/vei).
  Would improve depth without full reclassification.
- [REJECTED] ManifestoBERTa for topic classification -- tested in Phase 2,
  "Foreign Special Relationships" dominated all programs (15-35%).
  MARPOR scheme designed for national manifestos, poor fit for local.

## Data Quality & Coverage

- [DONE] Filter 1,940 files to 259 programs. Phase 0.
- [DONE] Re-extract 27 encoding-broken kommuner. Phase 8.
- Gold standard manual annotation of 20-30 programs for validation.
- OCR Aurland program (scanned images on website). Found in Phase 9.
```

## Monitoring check-ins

Some ideas aren't tasks -- they're future checkpoints. Use dated markers:

```markdown
## Monitoring & Check-ins

- [2026-03-10] CHECK: Lapse rate for fast-graduated words.
  Expected <=2%. If higher, tighten graduation criteria.
  Query: words graduated since 2026-03-03 with times_seen <= 4.
```

## Organization tips

- **Group by theme**, not by date. Ideas about "search" go together regardless of when they were added.
- **Keep it flat**. Two levels of headers (category + idea title) is enough. Deeper nesting makes scanning hard.
- **New ideas at the bottom** of each section. This keeps related ideas together while preserving chronological order within a group.
- **Cross-reference code**. When an idea relates to specific files, link them: `Related: research/confusable-words-research.md`.

## Ideas tracker vs issue tracker

| | IDEAS.md | GitHub Issues |
|---|---|---|
| Audience | Developers + AI agents | Team + stakeholders |
| Granularity | Bullet points | Full descriptions with labels |
| Status model | 4 markers | Configurable workflows |
| AI accessibility | Direct file read | Requires API/tool |
| Best for | Capturing ideas during dev | Tracking committed work |

They complement each other. IDEAS.md captures everything quickly; promising ideas graduate to issues when they become committed work.
