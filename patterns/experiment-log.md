# Experiment Log Pattern

An append-only log where developers record what they changed, why, and what happened. Serves as institutional memory for both humans and AI assistants.

## Why it's useful

When Claude Code starts a new session, it has no memory of previous sessions. An experiment log provides:

1. **Context for decisions** -- Why was this approach chosen over alternatives?
2. **History of what was tried** -- Prevents re-trying failed approaches.
3. **Baseline measurements** -- What did metrics look like before this change?
4. **Rollback guidance** -- If something breaks, what was the previous state?

For AI-assisted development specifically, the experiment log prevents the most common failure mode: an AI agent re-implementing something that was already tried and rejected, or accidentally reverting a deliberate change.

## Template

```markdown
# Experiment Log

[Description of what this log covers. One sentence.]

---

## YYYY-MM-DD: [Short title of what changed]

### Problem / Hypothesis
[What problem are we solving, or what hypothesis are we testing?]

### Approach
[What we did and why we chose this approach.]

### Changes
- `path/to/file.py` -- [what changed in this file]
- `path/to/other.py` -- [what changed]

### Results
[What happened. Metrics if applicable. Did it work?]

### Status
[Deployed / Collecting data / Rolled back / Superseded by entry X]

---
```

## Rules

### Append-only -- never delete entries

This is the most critical rule. Old entries provide context even when they describe failed experiments. Mark entries as superseded rather than removing them.

CLAUDE.md should enforce this:

```markdown
### Experiment Tracking
- `experiment-log.md` is **append-only** -- NEVER delete existing entries
- New entries go at the top (after the header)
- Add entry BEFORE making algorithm changes
```

### New entries at the top

Most recent entries first. This way Claude sees the latest context when reading the file, even if it only reads the first N lines.

### Write before you code

Add the experiment log entry *before* making the change. This forces you to articulate the hypothesis and expected outcome, which catches bad ideas early.

### Link to analysis artifacts

If the experiment produced reports, charts, or analysis scripts, link them from the entry:

```markdown
### Analysis
- Report: `research/analysis-2026-03-03.html`
- Script: `scripts/analyze_intro_experiment.py --db data/app.db`
- Raw data: `research/experiment-data-2026-03-03.json`
```

## Git discipline integration

Add a rule to your CLAUDE.md to prevent AI agents from accidentally deleting log entries:

```markdown
### Git Diff Discipline
Before every commit, run `git diff --stat HEAD`. Watch for:
- **Append-only files shrinking** (experiment-log.md, IDEAS.md)
  -- this means entries were deleted. NEVER acceptable.
```

## Real-world example

From a language learning app's experiment log:

```markdown
## 2026-03-03: A/B Experiment -- Intro Card vs Sentence-First Acquisition

### Hypothesis
Showing a word info card before a word's first sentence review creates
a memory anchor that speeds up acquisition, compared to encountering
the word cold in a sentence.

### Design
- **Group A**: Control -- first exposure is in a sentence
- **Group B**: Info card shown before first sentence
- **Assignment**: Random 50/50 per word, stored in experiment_group column

### Metrics
1. Reviews to graduation
2. First-sentence accuracy (% correct on first review)
3. Time to graduation (calendar days)

### Files Changed
- models.py -- added experiment_group column
- acquisition_service.py -- random group assignment
- sentence_selector.py -- experiment intro card building
- analyze_intro_experiment.py -- analysis script

### Status
Deployed 2026-03-03. Collecting data.

### Analysis
Run after 2+ days: `python3 scripts/analyze_intro_experiment.py`
```

## Where to put it

- Small projects: `experiment-log.md` in the repo root
- Larger projects: `docs/experiment-log.md` or `research/experiment-log.md`
- Reference it from CLAUDE.md so Claude knows to check it and append to it
