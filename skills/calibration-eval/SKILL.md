---
name: calibration-eval
description: "Generate interactive HTML evaluation pages for collecting human ground-truth judgments on structured data from any project. Use when a project needs calibration data, quality audits, inter-rater evaluation, algorithm tuning, or ground truth labeling. Triggers on: /calibration-eval, 'evaluate these', 'need ground truth', 'calibration data', 'quality audit', 'rate these', 'human evaluation', 'label these items'."
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# Calibration Eval — Human-in-the-Loop Ground Truth Collection

Generate a self-contained HTML evaluation page from structured data. The user opens it in the browser, rates items with keyboard shortcuts, and pastes the results back to Claude for analysis.

## When to Use This

Any time a project needs human judgment to calibrate, validate, or tune an algorithm:

| Scenario | Example |
|----------|---------|
| **Extraction quality** | "Are these claims well-formed? Rate good/bad/trivial" |
| **Classification accuracy** | "Did the model classify these correctly?" |
| **Relevance judgment** | "Is this evidence relevant to this claim?" |
| **Comparison** | "Which output is better, A or B?" |
| **Threshold tuning** | "At what similarity score do these stop being duplicates?" |
| **Checkworthiness** | "Which of these are worth fact-checking?" |
| **Coverage audit** | "What did the system miss?" |

## The Four Eval Types

### Type 1: Rate Items
Each item gets rated on one or more dimensions. Fast sequential flow.
```
Items: [{id, content, context?, system_output?}]
Dimensions: [{name, options: [{key, label, color}]}]
```
Example: Rate extracted claims as good/trivial/not-a-claim.

### Type 2: Compare A vs B
Two system outputs per item. User judges which is better.
```
Items: [{id, content, output_a, output_b, context?}]
```
Example: Flat search vs structured search verdicts.

### Type 3: Threshold Calibration
Items ordered by a score. User marks the cutoff where quality drops.
```
Items: [{id, content, score, system_output?}] (sorted by score desc)
```
Example: At what cosine similarity do duplicates stop being real?

### Type 4: Extraction Recall (Automated)
Measures how well an extraction pipeline captures known-important items. No HTML page — this is an automated scorer using an LLM judge.
```
Ground truth: [{id, text, type?, notes?}]
Extraction: [{id, text}] or typed dict with claims/concepts/cases/etc.
```
Output: `SCORE=X.XXXX` (weighted: exact=1.0, partial=0.5, miss=0.0) + per-item breakdown.

Example: Does the argument extraction capture all 24 human-flagged claims?

**Tool**: `python3 ~/.claude/skills/shared/eval_recall.py ground_truth.json extraction.json`

**When to use Type 4 vs Type 1:**
- Use Type 4 when you have a ground truth set and want to measure pipeline coverage automatically (e.g., during autoresearch optimization loops)
- Use Type 1 when you need humans to create the ground truth in the first place (e.g., first calibration pass on a new chapter)
- Typical workflow: Type 1 to create ground truth → Type 4 to measure/optimize → Type 1 to validate on new data

## Data Preparation

Before generating the HTML, prepare the evaluation data as JSON. The data source varies by project — common patterns:

### From a database/graph (otak, petrarca)
```python
# Sample N items, stratified by type/score/category
import json, random
items = []  # populated from DB queries
# Stratify: don't just take top-N, sample across the distribution
random.shuffle(items)
with open('/tmp/calibration-data.json', 'w') as f:
    json.dump(items, f)
```

### From pipeline output (batch results, extraction logs)
```python
# Read from staging files or JSONL logs
items = []
for line in open('data/ingestion/pipeline.jsonl'):
    record = json.loads(line)
    items.append({...})
```

### From comparison data (A/B experiments)
```python
# Pair outputs from two strategies/models
items = [{"id": i, "content": claim, "output_a": result_a, "output_b": result_b}
         for i, (claim, result_a, result_b) in enumerate(zip(claims, results_a, results_b))]
```

**Critical**: Sample strategically, not randomly:
- **Disagreement-first**: Show items where the system is least confident or where two methods disagree (most informative per human minute)
- **Stratified**: Ensure coverage across categories, scores, types
- **Manageable size**: 30-80 items is the sweet spot. Under 30 = noisy estimates. Over 100 = evaluator fatigue

## Shared Eval Harness

All eval pages are built using the **shared eval harness** at `~/.claude/skills/shared/`. This provides keyboard-driven rating, localStorage persistence, clipboard copy, and JSON export — no need to generate HTML from scratch.

### Assembler command

```bash
python3 ~/.claude/skills/shared/build_eval.py CONFIG_FILE DATA_FILE OUTPUT_FILE
```

Or with inline JSON:
```bash
python3 ~/.claude/skills/shared/build_eval.py \
  --config '{"title":"...","type":"rate","storageKey":"...","dimensions":[...]}' \
  --data '[{"id":1,"content":"..."},...]' \
  -o /tmp/eval.html
```

### Config schema

```json
{
  "title": "Extraction Quality Audit",
  "type": "rate",                    // "rate" | "compare" | "threshold"
  "storageKey": "calibration-otak-2026-03-22-extraction",
  "autoAdvance": true,               // move to next after primary rating
  "clipboardMaxLabel": 60,           // truncate content in clipboard output
  "allowNotes": true,
  "noteLabel": "What's wrong?",
  "notePlaceholder": "Describe the issue...",
  "noteOnlyWhen": {                  // only show note input for bad ratings
    "dimension": "quality",
    "values": ["bad"]
  },
  "dimensions": [
    {
      "name": "quality",
      "label": "Is this a good claim?",
      "options": [
        {"value": "good", "label": "Good", "color": "green"},
        {"value": "bad", "label": "Bad", "color": "red"},
        {"value": "trivial", "label": "Trivial", "color": "faint"}
      ]
    },
    {
      "name": "relevance",
      "label": "Is the evidence relevant?",
      "showWhen": {"dimension": "quality", "values": ["good"]},
      "options": [
        {"value": "relevant", "label": "Relevant", "color": "green"},
        {"value": "partial", "label": "Somewhat", "color": "yellow"},
        {"value": "wrong", "label": "Wrong topic", "color": "red"}
      ]
    }
  ]
}
```

### Data item schema

```json
// Type: rate
{"id": 1, "content": "The claim text", "meta": "Source: paper.pdf", "output": "System classification", "output_label": "System says", "context": "Optional background text"}

// Type: compare
{"id": 1, "content": "The item being judged", "output_a": "Strategy A result", "output_b": "Strategy B result", "label_a": "Flat search", "label_b": "Structured search"}

// Context can also be structured:
{"id": 1, "content": "...", "context": [{"label": "Source", "text": "..."}, {"label": "Transcript", "text": "..."}]}
```

### Gold questions (self-consistency checks)

Add `goldItems` to config to interleave known-answer items for drift detection:

```json
{
  "goldItems": [
    {"id": "gold_1", "content": "Well-formed claim with source", "expected": {"quality": "good"}},
    {"id": "gold_2", "content": "Two claims merged into one with no source", "expected": {"quality": "bad"}}
  ]
}
```

Gold items appear at random positions, look identical to regular items, and don't count toward progress. The clipboard output includes a self-consistency section. If gold accuracy drops below 85%, you're fatigued or drifting — stop and recalibrate.

### Limbic integration

Use `limbic.amygdala` to prepare data and validate results:

```python
# Export uncertain pairs for human review
from limbic.amygdala.cluster import classify_pairs_with_confidence, format_for_eval_harness
confident, uncertain = classify_pairs_with_confidence(pairs, texts)
eval_data = format_for_eval_harness(uncertain, texts)
# → write eval_data as JSON, build eval page

# After human eval: validate whether LLM judge is trustworthy
from limbic.amygdala.calibrate import validate_llm_judge
result = validate_llm_judge(human_labels, llm_labels)
# → result["recommendation"] = "trustworthy" / "moderate" / "unreliable"

# Measure your own consistency across sessions
from limbic.amygdala.calibrate import intra_rater_reliability
result = intra_rater_reliability(first_pass_labels, second_pass_labels)
# → result["quality"] = "excellent" / "acceptable" / "concerning"
```

### Built-in keyboard shortcuts

| Key | Action |
|-----|--------|
| `1-9` | Primary dimension options |
| `q/w/e/r/t/y` | Secondary dimension options |
| `a/s/d/f/g/h` | Tertiary dimension options |
| `←/→` | Navigate items |
| `Backspace` | Go back |
| `Space` | Skip |
| `c` | Copy results to clipboard |
| `e` | Export full JSON |
| `f` | Toggle unrated-only filter |

### Clipboard output format

Compact, token-efficient. Includes summary stats, notes/corrections, items rated negatively, and a raw JSON block with just IDs + ratings (no content repeated).

## Workflow

### Step 1: Understand the evaluation need

Ask yourself:
- What type of evaluation? (Rate / Compare / Threshold)
- What dimensions? (quality, relevance, accuracy, etc.)
- What options per dimension? (binary, 3-way, 5-point)
- What context does the evaluator need to see?
- How many items? (aim for 30-80)

### Step 2: Prepare the data

Write a script or use the REPL to extract and prepare items as JSON. Save to `/tmp/calibration-data.json`.

**Sampling strategy**:
- If the goal is to estimate overall quality: random stratified sample
- If the goal is to find problems: oversample low-confidence / disagreement items
- If the goal is threshold tuning: sample evenly across the score range

### Step 3: Build the eval page

```bash
python3 ~/.claude/skills/shared/build_eval.py \
  /tmp/calibration-config.json /tmp/calibration-data.json \
  /tmp/calibration-eval.html
```

For project-specific evals, save to `research/eval-[description]-[date].html` in the project.

### Step 4: Open and instruct

```bash
open /tmp/calibration-eval.html
```

Tell the user:
1. What they're evaluating and why
2. The keyboard shortcuts (just the main ones: number keys + arrows + c)
3. How many items (set expectations: "~45 items, should take 5-10 minutes")
4. What to do when done: "Press C to copy results, then paste them back here"

### Step 5: Process results

When the user pastes back:
1. Parse the summary stats
2. Focus on corrections and BAD-rated items — these are the actionable signal
3. The raw JSON block has every rating keyed by item ID — parse it for programmatic use
4. Recommend next action: fix the N worst items? adjust threshold? re-run with modified prompt?

## Research-Backed Guidelines

### Sample Size Decision Table

| Goal | Minimum | Comfortable | Source |
|------|---------|-------------|--------|
| Estimate accuracy ±10% | 50 | 100 | Wald/Wilson CI |
| Estimate accuracy ±5% | 200 | 400 | Wald/Wilson CI |
| Stable Cohen's kappa (2 raters) | 50 | 100 | Bujang & Baharum 2017 |
| Compare two systems | 400/system | 800/system | McNemar's test |
| Quick "is it broken?" check | 30 | 50 | CLT minimum |

### The Cascade: When NOT to Use Human Eval

Before building an eval page, check whether cheaper methods suffice. Use the **cascade pattern** (from LLM-as-judge research, validated in Petrarca/otak):

```
[Stage 1: Rules/embeddings]  — free, instant, handles ~60% of items
    |
    ambiguous items only ↓
[Stage 2: NLI cross-encoder or LLM judge]  — ~$0.001/item, handles ~25%
    |
    uncertain items only ↓
[Stage 3: Human eval via this skill]  — 30-120s/item, handles ~15%
```

**Decision: Use human eval when:**
- You need ground truth for a new task where no automated judge exists yet
- LLM judges disagree with each other (the "disagreement set" — 15-25% of items)
- Task involves subjective judgment, cultural context, or factual accuracy
- You need to calibrate/validate an LLM judge (the "Bootstrap Protocol": 100-item gold set)

**Skip human eval when:**
- Automated inter-rater agreement (two LLMs) > 85% and kappa > 0.7
- Task is well-defined with clear heuristic rules
- You only need a rough signal (±10% accuracy is fine)

### Fatigue Management

Research shows annotation quality follows a predictable curve (Parikh 2022, TOEFL iBT studies):

| Phase | Items | Quality |
|-------|-------|---------|
| Warm-up | 1-15 | Slightly lower (calibrating) |
| Peak | 15-100 | Best data |
| Degradation | 100-200 | Subtle shortcuts, central tendency bias |
| Failure | 200+ | Random responding, anchoring |

**Rules:**
- **40-60 items** per session for complex judgment (quality, relevance)
- **80-120 items** for simple categorical (claim_type, yes/no)
- **Hard ceiling: 90 minutes** regardless of task
- Break every 40 items for complex tasks
- The harness tracks timing and shows "~Xmin left" to set expectations

### Single-Expert Rater Protocol

When you (the developer) are the sole evaluator — the most common case:

1. **Write a codebook BEFORE labeling.** Define each category with positive, negative, and borderline examples. Forces precision.
2. **Blind yourself to system identity** when comparing A vs B. Shuffle outputs.
3. **Interleave gold questions** — pre-label 10-15 items carefully at session start, re-encounter them later. If your consistency drops below 85%, stop.
4. **Self-consistency check** — after 24h+, re-rate 10-15% of items in different order. Compute kappa with yourself. Expect > 0.80.
5. **Use structured rubrics, not holistic judgments.** Multiple binary dimensions (atomic? provenance? informative?) are more reliable than one 5-point quality scale.
6. **Log decision rationale** for borderline cases (the harness note field).
7. **Decompose subjective into objective.** "Is this claim good?" → "Is it atomic?" + "Is it informative?" + "Is provenance traceable?"

### LLM Judge Rubric Design

When using an LLM judge as Stage 2 (before or instead of human eval):

- **Binary/ternary > Likert.** LLMs collapse 5-point scales to {1, 3, 5}.
- **Each criterion independently evaluable.** "Quality" is too vague. "Does the claim cite a specific source?" is evaluable.
- **Negative examples as important as positive.** Show what "poor" looks like.
- **Criteria order matters.** Objective first (factual accuracy), subjective last (overall quality). LLMs anchor on early criteria.
- **Few-shot: 8 examples, stratified.** 2 clear positive, 2 clear negative, 2 borderline positive, 2 borderline negative.
- **CoT improves 5-15%.** "First analyze along each dimension, then give final ratings."

### The Bootstrap Validation Protocol

When introducing an LLM judge for a new task:

1. Human-label 100 items (the "gold set")
2. LLM-label the same 100 items
3. Compute Cohen's kappa
4. **kappa > 0.7**: LLM trustworthy. Use LLM for remaining N-100 items.
5. **0.5 < kappa < 0.7**: Use cascade — LLM labels most, human reviews uncertain ones.
6. **kappa < 0.5**: LLM not trustworthy. Need more human labels or better rubric.

## Anti-Patterns

**Don't make evaluators do your homework** (from annotation research):
- Don't ask 10 questions per item. 1-2 dimensions max, or people rush.
- Don't show items that don't need human judgment. Pre-filter with the cascade.
- Don't require text input on every item. Only on corrections / disagreements.
- Don't show system confidence BEFORE the user rates — creates anchoring bias.

**Don't waste human attention** (from active learning research):
- Sort by informativeness: disagreements first, confident items last.
- Oversample the decision boundary by 2-3x. Don't ignore the tails (10-15% from high-confidence regions).
- Show running stats so evaluator knows their impact.
- Auto-advance after rating — the Prodigy model.

**Don't compromise data quality** (from calibration research):
- Save to localStorage on every keystroke, not just on export.
- Include resume mechanism (page reload = pick up where you left off).
- Both clipboard AND JSON export — belt and suspenders.
- Randomize item order within sessions — topic clustering induces local biases.
- Don't skip the self-consistency check. Items where you disagree with yourself are the most informative.

## Relationship to Other Skills

| Skill | Use Case | Key Difference |
|-------|----------|----------------|
| **design-explorer** | Visual comparison of design alternatives | Carousel navigation, spatial layout, voice notes |
| **knowledge-probe** | Self-assessment of knowledge | Bayesian propagation, adaptive question ordering |
| **pipeline-eval** | Automated pipeline quality testing | Fixture-based, LLM-as-judge, no human in loop |
| **calibration-eval** | Human ground truth for any structured data | Keyboard-driven rating, clipboard return, generic |

Use **calibration-eval** when you need human judgment as ground truth to validate or tune a system. Use **design-explorer** when comparing visual alternatives. Use **pipeline-eval** for automated regression testing.

## Examples from Past Sessions

### Hirsch Atlas: Extraction Recall Optimization (2026-03-30)
- **Type**: Extraction Recall (Type 4) — automated
- **Ground truth**: 24 human-flagged items from Prologue + Chapter 1 calibration
- **Extraction**: Phase 1 sliding-window extraction output (claims, concepts, cases, thinkers)
- **Metric**: Weighted score (exact=1.0, partial=0.5, miss=0.0)
- **Result**: Improved from 0.854 → 0.948 average via 8 autoresearch experiments
- **Key learning**: The eval was used inside an autoresearch loop — each experiment modified the extraction prompt/approach, ran the eval, and kept/reverted based on the score. High variance (~0.06) from LLM non-determinism required running 2-3x per experiment. Structural changes (sliding window) beat prompt tuning.
- **Workflow**: Type 1 (manual calibration HTML) created ground truth → Type 4 (eval_recall.py) automated optimization → Type 1 again to validate on unseen Chapter 7.

### Otak: Factcheck Verdict Quality (2026-03-20)
- **Type**: Rate + Compare
- **Items**: 112 podcast claims with system verdicts from two search strategies
- **Dimensions**: extraction quality (good/wrong/trivial), verdict accuracy per strategy (correct/wrong/partial), which strategy better
- **Result**: Identified 16% extraction errors, structured search better in 62% of disagreements
- **Key learning**: Show transcript context alongside claims — evaluator needs to see what the speaker actually said

### Otak: Extraction Quality Audit (2026-03-19)
- **Type**: Rate
- **Items**: Stratified sample across thesis/journal/news claims
- **Dimensions**: Is this a genuine claim? Is claim_type correct?
- **Result**: 1,507 boilerplate claims identified for deletion, 10,191 missing claim_type

### MDG: Classification Inter-Rater (2026-02-26)
- **Type**: Automated validation (no HTML page needed)
- **Items**: 9,106 classified items re-classified by second LLM
- **Dimensions**: topic (4% disagreement), specificity (15%), is_local (6%)
- **Result**: 300 topic fixes, 388 specificity fixes applied automatically above confidence threshold
- **Key learning**: When disagreement rate is low (<10%), automated fixes at high confidence are safe. When high (>15%), you need human tiebreaker.

### Petrarca: Novelty Detection NLI (2026-03-07)
- **Type**: Threshold calibration (automated)
- **Items**: 125 claim pairs in the 0.68-0.78 cosine similarity "ambiguous zone"
- **Dimensions**: duplicate/related/different
- **Result**: NLI cross-encoder resolved 59% at zero cost; remaining 41% went to LLM. 70-90% cost reduction.
- **Key learning**: Only human-label the ambiguous middle. High-confidence ends don't need humans.

### Petrarca: Knowledge Probe Calibration (2026-03-19)
- **Type**: Rate (card assessment)
- **Items**: 20-55 knowledge graph nodes
- **Dimensions**: familiarity (new/basic/solid)
- **Result**: Leave-one-out validation showed propagation accuracy of 85%+ with only 40% of nodes directly assessed
- **Key learning**: Adaptive ordering (entropy-maximizing) cuts assessment time in half vs random order
