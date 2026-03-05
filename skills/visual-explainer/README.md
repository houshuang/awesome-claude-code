# Visual Explainer

Generate beautiful, self-contained HTML pages that visually explain systems, code changes, plans, and data. Supports architecture diagrams, flowcharts, sequence diagrams, data tables, dashboards, and more.

*Created by [nicobailon](https://github.com/nicobailon) — MIT licensed.*

## What it does

This skill replaces ASCII art and terminal tables with polished HTML visualizations. When loaded, Claude Code will automatically generate HTML pages for:

- Architecture and system diagrams (CSS Grid cards or Mermaid)
- Flowcharts and pipelines (Mermaid with hand-drawn or classic styles)
- Sequence diagrams, ER diagrams, state machines, mind maps
- Data tables, comparisons, and audit matrices
- Dashboards with KPI cards and Chart.js visualizations
- Timelines and roadmap views

It also **proactively** renders tabular data as HTML instead of ASCII tables when the data has 4+ rows or 3+ columns.

Every output is a single self-contained `.html` file that opens in any browser. Supports light/dark themes, responsive layouts, and animations.

## Example usage

```
/visual-explainer show me the architecture of this project
```

Or naturally:
- "Draw a diagram of the auth flow"
- "Compare these two approaches in a table"
- "Show the database schema"
- "Create a dashboard of the test results"

The skill outputs an HTML file to `~/.agent/diagrams/` and opens it in the browser automatically.

## Installation

Copy the `visual-explainer/` directory to your Claude Code skills folder:

```bash
# Global (available in all projects)
cp -r visual-explainer/ ~/.claude/skills/visual-explainer/

# Project-specific
cp -r visual-explainer/ .claude/skills/visual-explainer/
```

## Files

- `SKILL.md` — The skill prompt
- `templates/architecture.html` — Reference template for CSS Grid architecture diagrams
- `templates/mermaid-flowchart.html` — Reference template for Mermaid-based diagrams with zoom controls
- `templates/data-table.html` — Reference template for styled data tables with KPI cards
- `references/css-patterns.md` — Reusable CSS patterns for layout, connectors, theming, animations, and overflow protection
- `references/libraries.md` — CDN library guide (Mermaid, Chart.js, anime.js, Google Fonts) with theming instructions
- `references/responsive-nav.md` — Sticky sidebar TOC (desktop) / horizontal scrollable bar (mobile) pattern
