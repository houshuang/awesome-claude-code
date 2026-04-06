# calibration-eval — Human-in-the-Loop Evaluation Pages

Generate interactive, self-contained HTML evaluation pages for collecting human ground-truth judgments on structured data. Supports four eval types: rate items, compare A vs B, threshold calibration, and automated extraction recall scoring. Keyboard-driven UI with localStorage persistence and clipboard export.

## Install

```bash
cp -r skills/calibration-eval ~/.claude/skills/
```

## Dependencies

Uses [limbic](https://github.com/houshuang/limbic) (`limbic.amygdala`) for calibration metrics and data preparation (pair classification, LLM judge validation, intra-rater reliability).

```bash
pip install git+https://github.com/houshuang/limbic.git
```
