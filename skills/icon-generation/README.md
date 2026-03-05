# Icon Generation

Generate app icons as PNG files from HTML/CSS designs using Chrome headless screenshots. No design tools needed — Claude Code designs the icon in HTML and renders it at exact pixel dimensions.

## What it does

When you need app icons (iOS, Android, web favicon), this skill:

1. Designs the icon as an HTML/CSS page with Google Fonts and pure CSS graphics
2. Uses Chrome headless mode to screenshot at exact pixel dimensions
3. Outputs properly sized PNGs ready for your project's asset directory

Supports all common icon sizes: 1024x1024 app icons, adaptive icons with safe-zone padding, and 48x48 favicons.

## Example usage

```
/icon-generation create an app icon with a blue gradient and the letter "A"
```

Or naturally:
- "Generate app icons for the project"
- "Create a favicon with our logo colors"
- "Make an adaptive icon for Android"

### Requirements

- Google Chrome installed (uses headless mode for screenshots)
- Network access for Google Fonts (or use local fonts offline)

## Installation

Copy the `icon-generation/` directory to your Claude Code skills folder:

```bash
# Global (available in all projects)
cp -r icon-generation/ ~/.claude/skills/icon-generation/

# Project-specific
cp -r icon-generation/ .claude/skills/icon-generation/
```

## Files

- `SKILL.md` — The skill prompt with HTML template, Chrome commands, and gotchas
