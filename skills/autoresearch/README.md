# autoresearch — Automated Experiment Loops

Run systematic or creative experiment loops to optimize code, algorithms, or prompts. Two modes:

- **Grid mode**: Systematic parameter sweeps using Optuna TPE + WilcoxonPruner. Single-parameter sweeps first, then focused factorial grid on the parameters that matter.
- **Creative mode**: Karpathy-style LLM-proposed structural changes. The agent reads prior results, hypothesizes a change, measures a scalar metric, and commits if improved or reverts if not.

Based on the Karpathy autoresearch pattern (700 experiments in 48 hours) combined with Bayesian optimization best practices.

## Install

```bash
cp -r skills/autoresearch ~/.claude/skills/
```

## Note

When using with [limbic](https://github.com/houshuang/limbic)-based metrics (e.g., knowledge map propagation, embedding quality), install limbic:

```bash
pip install git+https://github.com/houshuang/limbic.git
```
