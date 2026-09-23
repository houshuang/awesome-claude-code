# /review-feedback

Analyzes PR review feedback for validity before implementing fixes. Prevents blindly applying every suggestion — instead, critically evaluates each piece of feedback.

## Usage

```
/review-feedback The reviewer says we need to add null checks to the parser
/review-feedback                  # Reads feedback from the PR automatically
```

## What it does

1. Parses the review feedback (from argument or PR comments)
2. Reads the referenced code to understand the current implementation
3. For each piece of feedback, evaluates:
   - Is the problem real?
   - Is the suggested fix appropriate?
   - Is it worth the complexity?
4. Presents a verdict for each item: "Valid — will fix", "Valid concern, different fix", or "Not valid — recommend pushing back"
5. Implements valid fixes and provides pushback rationale for invalid ones

## Installation

**As a plugin:**

```
/plugin marketplace add houshuang/awesome-claude-code
/plugin install review-feedback@awesome-claude-code
```

**Or copy the file** (from the repo root). Files in `.claude/commands/` still work; Claude Code treats them as skills:

```bash
mkdir -p .claude/commands
cp commands/review-feedback/review-feedback.md .claude/commands/
```
