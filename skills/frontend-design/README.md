# Frontend Design

Create distinctive, production-grade frontend interfaces that avoid generic AI aesthetics. Guides Claude Code toward bold design choices with real typography, intentional color palettes, and memorable visual identity.

## What it does

When building any web interface — landing pages, dashboards, React components, HTML/CSS layouts — this skill pushes Claude Code to make intentional design decisions instead of defaulting to generic templates. It enforces:

- Distinctive typography from Google Fonts (never Inter/Roboto/Arial)
- Cohesive color palettes with semantic CSS variables
- Meaningful animations and micro-interactions
- Unexpected layouts with asymmetry and visual hierarchy
- Atmospheric backgrounds (gradients, textures, patterns)

Works with any frontend framework: plain HTML/CSS/JS, React, Vue, Svelte, etc.

## Example usage

```
/frontend-design build a landing page for a developer tool
```

Or naturally:
- "Build a dashboard for monitoring API usage"
- "Create a pricing page with a dark theme"
- "Design a settings panel for the app"

Claude Code will ask clarifying questions about purpose and audience, then commit to a specific aesthetic direction before writing code.

## Installation

Copy the `frontend-design/` directory to your Claude Code skills folder:

```bash
# Global (available in all projects)
cp -r frontend-design/ ~/.claude/skills/frontend-design/

# Project-specific
cp -r frontend-design/ .claude/skills/frontend-design/
```

## Files

- `SKILL.md` — The skill prompt
