# Frontend Design

> **Superseded by Anthropic's official `frontend-design` plugin**, which this is an older copy of. Install that instead: `/plugin install frontend-design@claude-plugins-official`. This copy stays for reference.

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

Use the official plugin:

```
/plugin install frontend-design@claude-plugins-official
```

This older copy can still be installed with `cp -r skills/frontend-design ~/.claude/skills/`.

## Files

- `SKILL.md` — The skill prompt
