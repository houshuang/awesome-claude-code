---
name: autoresearch
description: "Run automated experiment loops to optimize algorithms, parameters, or prompts. Two modes: 'grid' for systematic parameter sweeps with Optuna TPE + WilcoxonPruner, 'creative' for Karpathy-style LLM-proposed changes. Use when: optimizing algorithm parameters, tuning thresholds, prompt optimization, ablation studies, or any 'modify → measure → keep/discard' workflow. Triggers on: /autoresearch, 'optimize these parameters', 'run experiments', 'karpathy loop', 'ablation study', 'parameter sweep', 'tune this algorithm'."
user-invocable: true
allowed-tools:
  - Agent
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# Autoresearch — Automated Experiment Loops

Run systematic or creative experiment loops to optimize code. Based on the Karpathy autoresearch pattern (700 experiments in 48 hours) combined with Bayesian optimization best practices.

## Two Modes

### Mode 1: Grid (Parameter Optimization)

For when you have a **known parameter space** and want to find the optimal configuration.

**Strategy**: Single-parameter sweeps first (identify which params matter), then focused factorial grid on top 2-3 parameters. Optionally use Optuna TPE if installed.

**Best for**: threshold tuning, algorithm parameter sweeps, hyperparameter optimization.

### Mode 2: Creative (Karpathy Loop)

For when you want the **LLM to propose structural algorithmic changes** — new propagation strategies, different data structures, architectural tweaks.

The agent reads prior experiment results, proposes a single focused change, measures the scalar metric, and commits if improved or reverts if not.

**Best for**: algorithm improvement, prompt optimization, any case where the search space is open-ended and the LLM's reasoning about code can generate hypotheses humans wouldn't try.

### When to Use Which

| Signal | Use Grid | Use Creative |
|--------|----------|--------------|
| Known parameters with ranges | Yes | No |
| Open-ended "make this better" | No | Yes |
| Have a reference implementation (ceiling) | Grid first, creative if gap remains | Yes |
| Search space < 5000 configs | Full factorial viable | Overkill |
| Search space is continuous/infinite | Need discretization | Yes |
| Parameters might interact | Grid catches it | Creative misses it |

**Recommended sequence**: Grid first to understand the landscape and confirm defaults. Creative second to find structural improvements the grid can't explore. This is what we did for `knowledge_map` propagation — grid confirmed defaults were optimal, creative found the global sweep that grid couldn't search for.

## How to Use

The user provides:
1. **What to optimize** — the code/function/algorithm to improve
2. **How to measure** — the evaluation function or metric
3. **The mode** — grid or creative (Claude will suggest based on context)

Claude then:
1. Analyzes the code to identify the optimization target
2. Sets up the experiment infrastructure (eval harness + results log)
3. Runs the loop
4. Reports results and applies the best configuration

## Grid Mode Protocol

### Step 1: Define the Experiment

Read the target code and identify:
- **Parameters** to sweep (with ranges/values)
- **Evaluation function** that returns a scalar score (higher = better)
- **Evaluation contexts** (e.g., different test cases, graph topologies, data splits)
- **Known ceiling** (if any — e.g., an exact solver, ground truth labels)
- **Budget** — max number of evaluations

### Step 2: Write the Experiment Runner

Create `experiments/autoresearch_<name>.py` with this structure:

```python
#!/usr/bin/env python3
"""Autoresearch: <description>"""
import json, time, random
import numpy as np
from pathlib import Path

# Phase 1: Single-parameter sweeps
# Vary each parameter independently, others at default
# Identify which 2-3 parameters matter most
# KEY LEARNING: individual best values often don't combine well (interaction effects)

# Phase 2: Focused factorial grid on top parameters
# Full grid on the 2-3 params that matter (~64-256 configs)
# Fix unimportant params at their default values

# Phase 3: Validation
# Run best config N times to get confidence interval
# Compare against baseline and ceiling
# Ablation: vary each param while holding others fixed to confirm no negative interactions

# Phase 4: Report
# Save results to experiments/results/autoresearch_<name>.json
```

### Step 3: Run and Interpret

Key decisions:
- **If improvement > 2%**: Apply the optimized parameters to the codebase
- **If improvement < 2%**: Current defaults are likely already good. Report but don't change.
- **If ceiling is close**: Algorithm is near-optimal for its architecture. Structural changes needed (→ creative mode).

### Grid Mode Pitfalls (from experience)

- **Individual-best ≠ combined-best**: In our propagation sweep, `prereq_threshold=0.6` was best individually but the combined config with all "best" individual params was -0.9% worse than defaults. Always validate the combination.
- **Don't average across contexts too early**: Different topologies/datasets may need different parameters. Check if there are genuine trade-offs before committing to one config.
- **Stochastic variance hides small effects**: With 30 trials, effects under ~1% are noise. Either increase trials or accept that the parameter doesn't matter at that level.

## Creative Mode Protocol

### Step 1: Setup

Create TWO files:
1. **Eval harness** (`experiments/autoresearch_eval.py`): outputs a single line like `SCORE=0.6661 CEILING=0.7209 GAP=0.0547`. Must be fast (<2 min), deterministic (fixed seeds), and measure what matters.
2. **Results log** (`experiments/autoresearch_results.tsv`): TSV with columns `iter, score, ceiling, gap, delta, status, description`. Initialize with baseline row.

### Step 2: The Loop

For each iteration (max 15-20):

1. **Read** the mutable code and `results.tsv` history
2. **Hypothesize**: based on error analysis of where the algorithm diverges from the ceiling/ground truth, propose ONE focused change
3. **Apply** the change
4. **Test**: run `pytest` on relevant tests first (catch regressions)
5. **Measure**: run the eval harness
6. **Decide**:
   - Score improved → `git commit -m "experiment: <description>"`
   - Score same or worse → `git checkout -- <file>` (revert)
7. **Log** to `results.tsv`
8. **Repeat** until 3 consecutive non-improvements (convergence signal)

### Step 3: Report

- Table of all experiments (kept vs discarded)
- Total improvement from baseline
- Which changes contributed most
- Error analysis: what the remaining gap looks like

### Creative Mode Learnings (from knowledge_map session)

**What worked**:
- **Global sweep** (+1.1%): The biggest single win came from realizing the heuristic only propagated locally per update, while the reference did global inference. Adding a global pass after each update closed the largest part of the gap.
- **Bidirectional propagation** (+0.6%): Adding a "lower nodes with unknown prereqs" path to the global sweep.
- **Widening the propagation band** (+0.3%): Including "basic" familiarity in upward propagation (was only "solid"/"deep").

**What didn't work**:
- **Geometric mean of prereqs** (-1.8%): Too permissive — one uncertain prereq should block, not be averaged out.
- **Backward inference from children** (0.0%): Evidence from unknown children was already captured by the global sweep.
- **Sibling inference** (0.0%): Too indirect — the prereqs-met propagation already handles the same cases.
- **Softening thresholds** (-5.4%): Changing "heard_of" behavior was catastrophic — the original conservative downward propagation was correct.

**Key insight**: The first 2-3 experiments tend to find the big structural wins. After that, diminishing returns set in fast. 3 out of 7 experiments succeeded (43% hit rate), consistent with the Karpathy pattern (~20-30% hit rate on mature code).

## Eval Harness Design

The eval harness is the most important piece. It must be:

1. **Fast** (<2 min per run). If your eval takes 10 min, you'll only run 6 experiments per hour.
2. **Deterministic** (fixed seeds). Same code must produce the same score.
3. **Representative** (multiple contexts). Test across different scenarios to avoid overfitting to one case.
4. **Single scalar output**. Parse with `grep SCORE` or similar.

Template:
```python
#!/usr/bin/env python3
"""Eval harness for autoresearch. Outputs: SCORE=X.XXXX CEILING=X.XXXX GAP=X.XXXX"""
import random, numpy as np

# Define test contexts (multiple scenarios/topologies/datasets)
CONTEXTS = [make_context_1(), make_context_2(), ...]
K_VALUES = [3, 5, 8]
N_TRIALS = 30  # per context per K

rng = random.Random(42)  # FIXED seed for reproducibility

total_score = total_ceiling = n_evals = 0
for ctx in CONTEXTS:
    for K in K_VALUES:
        for trial in range(N_TRIALS):
            truth = generate_truth(ctx, seed=trial*7+13)
            assessed = rng.sample(list(truth.keys()), min(K, len(truth)))
            total_score += evaluate(ctx, truth, assessed, method="candidate")
            total_ceiling += evaluate(ctx, truth, assessed, method="reference")
            n_evals += 1

score = total_score / n_evals
ceiling = total_ceiling / n_evals
print(f"SCORE={score:.4f} CEILING={ceiling:.4f} GAP={ceiling-score:.4f}")
```

## Ideas for Future Autoresearch Targets

### In limbic

| Target | Mode | Metric | Ceiling |
|--------|------|--------|---------|
| FTS5 query strategy (OR vs AND vs phrase) | Grid | nDCG@10 on SciFact | Manual relevance judgments |
| Novelty score aggregation (mean vs max vs kNN density) | Creative | AUC on calibration pairs | Human novelty labels |
| Clustering threshold auto-selection | Grid | V-measure on labeled data | sklearn agglomerative |
| Document similarity field weights | Grid | Spearman on human-rated pairs | Human scores |
| Whitening epsilon selection per corpus | Grid | Isotropy metric (mean pairwise cosine) | Identity (raw) |
| NLI cascade thresholds per model | Grid | Classification accuracy | Human pair labels |
| Embedding model selection (new models) | Grid | Composite of accuracy + speed + cross-lingual | Best available |

### General use cases

| Target | Mode | Metric | Notes |
|--------|------|--------|-------|
| Prompt optimization | Creative | Task accuracy on eval set | LLM proposes prompt edits |
| Regex/parser rules | Creative | Precision + recall on test cases | Each experiment adds/modifies one rule |
| CSS/layout optimization | Creative | Lighthouse score or visual regression | Measure after each change |
| SQL query optimization | Grid | Query time on representative workload | Sweep index strategies |
| Rate limiting / backoff params | Grid | Success rate under load | Simulate concurrent requests |
| Feature flag thresholds | Grid | Business metric on historical data | Counterfactual evaluation |
| Compression/encoding params | Grid | Size × decode_speed tradeoff | Pareto front analysis |

### Multi-objective extensions

When a single scalar isn't enough:
1. **Pareto front**: Use Optuna multi-objective (`directions=["maximize", "maximize"]`) to find the frontier, then pick a point manually.
2. **Weighted composite**: `score = w1 * metric1 + w2 * metric2`. Works when you know the trade-off weights.
3. **Constraint + objective**: Optimize one metric subject to a minimum on another (e.g., maximize accuracy subject to latency < 100ms).

## Key Design Principles

1. **Single scalar metric** — eliminates ambiguity about what "better" means.
2. **Paired comparisons** — evaluate candidate and baseline on the SAME test instances. Halves variance.
3. **Git as memory** — commit winners, revert losers. History informs future hypotheses.
4. **Time-box evaluations** — each experiment takes roughly the same time, making results comparable.
5. **Log everything** — even failed experiments are informative.
6. **Diminishing returns** — 3 consecutive failures = convergence. Stop or switch strategies.
7. **Error analysis between modes** — after grid mode, analyze WHERE the algorithm fails vs ceiling. This tells you what structural change to try in creative mode.

## Example Invocations

```
/autoresearch optimize the propagation parameters in knowledge_map.py
/autoresearch tune the novelty scoring thresholds against the calibration set
/autoresearch creative: improve the clustering algorithm, measure V-measure on 20newsgroups
/autoresearch grid: sweep whiten_epsilon [0.01, 0.05, 0.1, 0.5, 1.0] measuring isotropy
/autoresearch creative: optimize the FTS5 query sanitization, measure recall on SciFact
/autoresearch grid: tune document_similarity field weights, measure Spearman on human pairs
```

## When NOT to Use

- **One-off parameter choice**: Just pick and test manually.
- **No metric available**: Define a scalar evaluation first.
- **Metric is expensive** (>5 min): Reduce eval set or use a proxy metric.
- **Code is untested**: Get tests passing first. The loop needs a stable baseline.
