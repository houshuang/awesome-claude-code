---
name: pr-walkthrough
description: Generate a detailed, pedagogical HTML walkthrough of a PR or feature branch. Use when the user wants to understand, document, or share how a PR works — covering architecture, data flow, design decisions, tradeoffs, and extension patterns. Triggers on requests like "walk me through this PR", "explain this branch", "write up how this feature works", "create a walkthrough".
---

# PR Walkthrough Generator

Generate a self-contained HTML page that deeply explains a PR or feature branch — not just what changed, but *why*, *how it connects*, and *what patterns it establishes* for future work.

## When to Use

- User asks to understand or explain a PR / branch / feature
- User wants a shareable document about how something works
- User wants to document architecture decisions for the team
- User says "walkthrough", "deep dive", "explain this PR", "write up how this works"

## Workflow

### 1. Research the PR Thoroughly

Read **everything** before writing a single line of HTML. The quality of the walkthrough depends entirely on depth of understanding.

**Gather context in parallel:**
- `git log --oneline main..HEAD` — commit history and narrative arc
- `git diff --stat main..HEAD` — scope and affected areas
- `git diff --name-only main..HEAD` — file list for categorization
- `gh pr view --json title,body,url` — PR description if available

**Read all changed files that matter.** Not just the diff — read the full files to understand context. Prioritize:
1. New files (these ARE the feature)
2. Interface/type definitions (these define the contracts)
3. Wiring/glue code (how things connect)
4. UI components (what users see)
5. Configuration and infrastructure changes

**Understand the threading.** Trace data flow from entry point to leaf. For backend features, trace from route handler through service layers to the actual operation. For AI/tool features, trace from registration through execution context to the tool itself.

### 2. Plan the Narrative

Structure as a **teaching document**, not a changelog. The reader should understand:

1. **The big picture** — What problem does this solve? What's the before/after?
2. **The architecture** — What are the layers? How do they relate?
3. **The key abstraction** — What's the central interface or pattern?
4. **The implementation** — Walk through each component, building understanding incrementally
5. **The wiring** — How do the pieces connect at runtime? Trace the full path.
6. **The UX** — What does the user see and do?
7. **The extension story** — How would you add a similar feature? What's the recipe?
8. **The tradeoffs** — What alternatives existed? Why was this approach chosen?
9. **The limitations** — What doesn't it do yet? What are natural next steps?

Not every section applies to every PR. Adapt the structure. A pure refactoring PR needs different sections than a new feature PR.

### 3. Write the HTML

Read the reference template at `./templates/reference-walkthrough.html` before generating. It demonstrates the exact aesthetic, component library, and patterns to use.

**Aesthetic direction: Editorial / Technical Paper.** The walkthrough should feel like a well-typeset technical article — a mix of long-form explanation, annotated code, and clear diagrams. Think: a Stripe engineering blog post or a well-written RFC.

#### Design System

**Typography:**
- Display font: `Instrument Serif` (headings) — elegant, editorial feel
- Body font: `Source Serif 4` — readable long-form text
- Mono font: `DM Mono` — code, labels, metadata
- Load all from Google Fonts

**Color palette (warm paper theme):**
```css
--ink: #1a1a18;        /* primary text */
--paper: #f5f0e8;      /* page background */
--paper-warm: #ede7db;  /* secondary surfaces */
--accent: #c23616;     /* emphasis, new items, key callouts */
--blue: #2d5f8a;       /* insights, links */
--green: #3a7d44;      /* patterns, success, strings */
--purple: #6a4c93;     /* tradeoffs */
--orange: #d4820a;     /* warnings, keywords */
--gray: #8a8578;       /* secondary text, metadata */
```

Each semantic color has a `-dim` variant at ~15% opacity for backgrounds.

#### Component Library

Use these components (all demonstrated in the reference template):

**Section structure:**
- Section number as small mono kicker (`01`, `02`, ...)
- `h2` with display font and bottom border
- `h3` for subsections, `h4` for small mono labels

**Code blocks (`<pre>`):**
- Dark background (`var(--ink)`), left accent border
- File label badge in top-right corner (`.file-label`)
- Syntax highlighting via span classes: `.keyword`, `.string`, `.type`, `.fn`, `.comment`
- Keep code excerpts focused — show the essential 5-15 lines, not the whole file

**Diagrams (`.diagram-container`):**
- White background with thin border
- Rainbow gradient top strip (accent → blue → green → purple)
- Mono label at top

**Flow diagrams (`.flow`):**
- Vertical flow with `.flow-row` containing `.flow-box` elements
- Boxes color-coded by role: `.accent`, `.blue`, `.green`, `.purple`, `.orange`, `.filled`
- Arrow separators (`.flow-arrow`) and notes (`.flow-note`) between rows
- Each box can have a `<small>` subtitle

**Layer diagrams (`.layer-stack`):**
- Horizontal rows with label + items
- Items tagged `.new` get a red "NEW" badge

**Callouts (`.callout`):**
- Four types: `.insight` (blue), `.warning` (orange), `.pattern` (green), `.tradeoff` (purple)
- Mono label at top, then explanation text
- Use for key takeaways that deserve visual emphasis

**Comparison tables (`.comparison`):**
- Mono uppercase headers
- First column as `.label-cell` (bold mono)
- Clean bottom-border rows

**File trees (`.file-tree`):**
- Mono text with `.dir`, `.file`, `.new-file` classes
- Indent levels via `.indent`, `.indent-2`

**Table of contents (`.toc`):**
- Two-column layout with numbered entries
- "Contents" label as positioned pseudo-element

#### Content Principles

**Show real code, not pseudocode.** Extract actual code from the PR files. Trim to the essential lines. Add syntax highlighting spans.

**Annotate, don't just describe.** After a code block, explain *why* it's designed that way, not just *what* it does.

**Use diagrams for flow, text for reasoning.** Flow diagrams show *how things connect*. Prose explains *why they connect that way*.

**Callouts for key insights.** If you find yourself writing "importantly" or "note that" in prose, extract it into a callout box instead.

**Be opinionated about tradeoffs.** Don't just list alternatives — explain why the chosen approach was right for this context, and when the alternative would be better.

### 4. Deliver

**Output location:** Write to the project root as `{topic}-walkthrough.html` (e.g., `github-integration-walkthrough.html`).

**Open in browser:**
- macOS: `open path/to/walkthrough.html`

**Tell the user:**
- The file path
- A summary of sections covered
- That the file is in the repo root and they may want to gitignore or delete it

## Quality Checks

Before delivering, verify:
- **Completeness:** Does every new file/concept get explained? Did you miss any layer?
- **Flow:** Can someone unfamiliar with the codebase follow the narrative from section 1 to the end?
- **Code accuracy:** Are code excerpts real (from the actual files), not invented?
- **Diagram clarity:** Do flow diagrams actually trace the real runtime path?
- **Tradeoff depth:** Did you go beyond "we could have done X instead" to explain *why* the choice was made?
- **Extension recipe:** Could a developer follow your recipe to add a similar feature?
