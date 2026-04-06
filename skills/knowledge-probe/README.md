# knowledge-probe — Adaptive Knowledge Mapping

Adaptively map what a user knows about a topic via an interactive HTML assessment page with card-based questions and Bayesian belief propagation. After assessment, generates a personalized HTML explainer that skips known material and teaches from the user's learning edge.

Supports loading existing knowledge graphs or generating new ones from topic descriptions. Uses entropy-maximizing probe ordering to minimize the number of questions needed.

## Install

```bash
cp -r skills/knowledge-probe ~/.claude/skills/
```

## Dependencies

Requires [limbic](https://github.com/houshuang/limbic) (`limbic.amygdala.knowledge_map`) for the knowledge graph, belief propagation, and coverage analysis.

```bash
pip install git+https://github.com/houshuang/limbic.git
```
