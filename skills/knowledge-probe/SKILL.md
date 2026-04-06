---
name: knowledge-probe
description: "Adaptively map what a user knows about a topic via an interactive HTML assessment page, then generate a personalized HTML explainer. Uses limbic.amygdala's knowledge_map module for entropy-maximizing probes and Bayesian belief propagation. Can load existing knowledge graphs or generate new ones from topic descriptions. Triggers on: /knowledge-probe, 'probe my knowledge', 'what do I know about', 'map my knowledge', 'knowledge probe'."
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
---

# Knowledge Probe — Adaptive Knowledge Mapping

Map what the user knows about a topic via an **interactive HTML assessment page**, then generate a **personalized HTML explainer** that skips what they know and teaches what they don't.

## Overview

The flow has two phases:
1. **Assessment** — Generate an interactive HTML page with card-based questions. User opens it in the browser, clicks through cards (1/2/3 keys or buttons), and when done the page writes results to a file via a tiny local server.
2. **Explainer** — Read the assessment results, then generate a beautiful self-contained HTML explainer page personalized to what the user knows. Open it in the browser.

## Setup

- **Python**: System python3 (limbic is installed via `pip install git+https://github.com/houshuang/limbic.git`)
- **Core module**: `limbic.amygdala.knowledge_map` — KnowledgeGraph, BeliefState, init_beliefs, next_probe, update_beliefs, coverage_report, is_converged, knowledge_fringes, calibrate_beliefs
- **Graph generation**: `limbic.amygdala.knowledge_map_gen` — graph_from_description (async, needs LLM), graph_from_dict
- **Known graphs directory**: check the limbic package for example graphs

## Two Modes for Graph Input

### Mode 1: Named graph or file path
```
/knowledge-probe loro-mirror
/knowledge-probe hamarquizen
/knowledge-probe ~/path/to/graph.json
```

**Name resolution:**
- `loro-mirror` → look for `loro_mirror.json` in limbic's example graphs
- `hamarquizen` → look for `hamarquizen.json` in limbic's example graphs
- Any name with `.json` → treat as file path
- Any name matching a known graph file (with underscores for hyphens) → load it

### Mode 2: Topic description (generates graph first)
```
/knowledge-probe "React Compiler"
/knowledge-probe "Norwegian medieval history"
```

If the argument doesn't match a known graph or file path, generate a knowledge graph inline.

## Graph Generation (Mode 2)

When generating a graph from a topic description, YOU (Claude) should generate the knowledge graph nodes yourself as JSON, drawing on your own knowledge of the domain. Then validate the nodes via Python:

1. Think through the domain — what are the key concepts, what depends on what?
2. Write out 15-40 nodes as a JSON array
3. Save to `/tmp/knowledge-probe-graph.json`
4. Validate and load:

```bash
python3 -c "
import json
from limbic.amygdala.knowledge_map_gen import graph_from_dict

with open('/tmp/knowledge-probe-graph.json') as f:
    data = json.load(f)

graph = graph_from_dict(data)
print(f'Loaded {len(graph.nodes)} nodes')
# Check for orphan prerequisites
for n in graph.nodes:
    for p in n.get('prerequisites', []):
        if not graph.get(p):
            print(f'WARNING: {n[\"id\"]} references missing prerequisite {p}')
"
```

Node requirements:
- `id`: short snake_case identifier
- `title`: human-readable name
- `description`: 1-2 sentences — what understanding this concept means
- `level`: 1 (broad area) to 4 (specific detail), mostly level 2-3
- `obscurity`: 1 (common knowledge) to 5 (specialist), sets the prior belief
- `prerequisites`: array of node IDs (genuine learning dependencies, not just topic grouping)

Graph quality rules:
- Form a DAG — no circular prerequisites
- Balance breadth across sub-areas
- Mix foundational (level 1-2) and advanced (level 3-4) concepts
- Prerequisites reflect genuine learning dependencies, not reading order

---

## Shared Eval Harness (Alternative)

For the assessment phase, you can optionally use the shared eval harness at `~/.claude/skills/shared/` instead of generating HTML from scratch. This saves ~3K output tokens and provides a battle-tested UI with keyboard shortcuts, localStorage persistence, and clipboard copy.

To use the shared harness for assessment:
1. Format nodes as eval items: `{"id": node_id, "content": title, "meta": description}`
2. Config: `{"type": "rate", "storageKey": "kp-[topic]", "autoAdvance": true, "dimensions": [{"name": "familiarity", "label": "How well do you know this?", "options": [{"value": "none", "label": "New to me", "color": "red"}, {"value": "basic", "label": "Know the basics", "color": "yellow"}, {"value": "solid", "label": "Know this well", "color": "green"}]}]}`
3. Run: `python3 ~/.claude/skills/shared/build_eval.py config.json data.json /tmp/kp-assessment.html`
4. User presses `c` to copy results, pastes back — parse the JSON block for `{node_id: {familiarity: "none|basic|solid"}}` mappings

Note: The shared harness does NOT support adaptive skip-dependents logic (skipping children of unknown nodes). If you need that, generate the HTML from scratch per the instructions below. For simple assessments where all nodes are independent, the shared harness is faster and more reliable.

---

## Phase 1: Interactive HTML Assessment (Full Custom)

### Step 1: Start the results server

Start a tiny Python HTTP server that will receive the assessment results when the user finishes:

```bash
python3 -c "
import http.server, json, threading, signal, sys, os

RESULTS_FILE = '/tmp/knowledge-probe-results.json'

class Handler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers['Content-Length'])
        data = self.rfile.read(length)
        with open(RESULTS_FILE, 'w') as f:
            f.write(data.decode())
        self.send_response(200)
        self.send_header('Content-Type', 'text/plain')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(b'OK')
        # Shut down after receiving results
        threading.Thread(target=self.server.shutdown).start()

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def log_message(self, format, *args):
        pass  # Suppress logs

# Remove stale results
if os.path.exists(RESULTS_FILE):
    os.remove(RESULTS_FILE)

server = http.server.HTTPServer(('127.0.0.1', 19384), Handler)
print('SERVER_READY', flush=True)
server.serve_forever()
print('RESULTS_SAVED', flush=True)
" &
```

Run this in the background (with `&` or `run_in_background`). The server listens on port 19384 and shuts down automatically after receiving results.

### Step 2: Generate the assessment HTML page

Generate a self-contained HTML file at `/tmp/knowledge-probe-assessment.html`. The page should:

**Design** (based on the validated Petrarca v2 assessment format):
- Clean, editorial design with warm background (#f7f4ec), serif headings, sans-serif UI
- Card-based flow: one concept per card
- Progress bar at top showing completion
- Each card shows: question number, concept title, description block, and 3 response buttons
- Keyboard shortcuts: 1/2/3 for familiarity, Backspace to go back
- Smooth slide-up animation on card transitions

**Card structure:**
```html
<div class="card">
  <div class="card-top">
    <div class="q-num">Question N</div>
    <button class="back-btn">← Back</button>
  </div>
  <div class="q-title">[Concept Title]</div>
  <div class="q-prompt">Read the description, then rate your familiarity:</div>
  <div class="q-desc">[Concept description]</div>
  <div class="response-row">
    <button class="resp-btn" data-val="none"><span class="key-hint">1</span> New to me</button>
    <button class="resp-btn" data-val="basic"><span class="key-hint">2</span> Know the basics</button>
    <button class="resp-btn" data-val="solid"><span class="key-hint">3</span> Know this well</button>
  </div>
  <div class="key-legend">1-3 familiarity · Backspace to go back</div>
</div>
```

**Assessment logic embedded in the HTML:**
- Nodes are sorted by level (broad first), then by obscurity distance from 2.5
- When a user marks a concept as "New to me" (none), skip its children and dependents (nodes that have it as a prerequisite) — they'll be inferred as unknown too
- When done, POST the results as JSON to `http://127.0.0.1:19384`
- Results format: `{ "answers": { "node_id": "none|basic|solid", ... }, "skipped": ["node_id", ...] }`
- Also show a summary on-screen so the user knows the assessment is complete

**Embed the graph data directly** in the HTML as a `const NODES = [...]` JavaScript array, with each node having `id`, `title`, `description` (use the `desc` key), `level`, `obscurity`, and `prerequisites`.

### Step 3: Open in browser

```bash
open /tmp/knowledge-probe-assessment.html
```

Tell the user: "I've opened the assessment in your browser. Go through the cards — press 1/2/3 for each concept. It takes about 2-4 minutes. Come back here when you're done."

### Step 4: Wait for results

Wait for the user to say they're done (or check if `/tmp/knowledge-probe-results.json` exists). Then read the results:

```bash
cat /tmp/knowledge-probe-results.json
```

### Step 5: Process results through limbic

Feed the assessment answers into the belief system:

```bash
python3 -c "
import json
from limbic.amygdala.knowledge_map import KnowledgeGraph, BeliefState, init_beliefs, update_beliefs, coverage_report, knowledge_fringes

with open('/tmp/knowledge-probe-graph.json') as f:
    data = json.load(f)
with open('/tmp/knowledge-probe-results.json') as f:
    results = json.load(f)

graph = KnowledgeGraph(nodes=data.get('nodes', data))
state = init_beliefs(graph)

# Map HTML assessment levels to limbic familiarity levels
level_map = {'none': 'none', 'basic': 'basic', 'solid': 'solid'}

for node_id, level in results.get('answers', {}).items():
    mapped = level_map.get(level, 'none')
    update_beliefs(graph, state, node_id, mapped)

# Skipped nodes (children of unknown) → mark as none
for node_id in results.get('skipped', []):
    update_beliefs(graph, state, node_id, 'none')

report = coverage_report(graph, state)
fringes = knowledge_fringes(graph, state)

# Save processed state
with open('/tmp/knowledge-probe-state.json', 'w') as f:
    json.dump(state.to_dict(), f)

print(json.dumps({
    'report': report,
    'fringes': fringes,
    'beliefs': {nid: round(b, 2) for nid, b in state.beliefs.items()},
}, indent=2))
"
```

---

## Phase 2: Personalized HTML Explainer

After processing the assessment results, generate a **self-contained HTML explainer page** that teaches the topic personalized to what the user knows. Write it to `/tmp/knowledge-probe-explainer.html` and open it in the browser.

### Explainer structure

The HTML page should be a beautiful, readable document with:

**Design:**
- Editorial/magazine style — serif body text, generous whitespace, warm palette
- Dark/light mode toggle (default to light)
- Sticky section navigation on desktop, horizontal scrollable bar on mobile
- Responsive layout (max-width ~720px for reading comfort)

**Content sections (in this order):**

1. **Your Knowledge Map** — A compact visual summary:
   - Show what they know well (belief >= 0.7) as green pills/tags
   - Show what's new to them (belief <= 0.2) as outlined pills
   - Show their "learning edge" (outer fringe) highlighted — these are the key concepts the explainer focuses on
   - Include stats: "N nodes assessed, X% coverage"

2. **The Explanation** — The personalized content, structured as:
   - **Skip** well-known material — at most a one-sentence bridge: "Since you know [X]..."
   - **Start from the outer fringe** — concepts they're ready to learn next (all prerequisites met)
   - **Expand** unknown areas with full detail, anchored in their existing knowledge
   - **Connect** new material to what they know: "This builds on [known concept] by..."
   - **Flag** prerequisite gaps: "This assumes [X] which you may want to brush up on"
   - Use their demonstrated depth to calibrate detail level — if they showed deep knowledge in one area, don't over-explain similar-level concepts
   - Group explanations by natural topic clusters, not by belief level
   - Use callout boxes for key insights, code examples where relevant, and analogies that connect to known concepts
   - **Weave in codebase-specific usage** — If the topic relates to the current codebase (check by searching relevant config files, source code, docs), include concrete examples from the codebase alongside general principles. Use callout boxes labeled "In this codebase" to show how the concept manifests in practice: which files, what patterns, what bugs were hit, what conventions were established. This grounds abstract concepts in code the user actually works with. Don't force it — only include codebase references when they genuinely illuminate the concept.

3. **Going Deeper** — For each concept on the outer fringe, suggest concrete next steps: articles, docs, experiments to try, or things to build. When the topic is relevant to the current codebase, prioritize codebase-specific next steps (read this file, check this test, look at this config) over generic external resources.

**Technical requirements:**
- Fully self-contained (inline CSS, no external dependencies)
- Print-friendly (hide nav, respect page breaks)
- All code examples syntax-highlighted with inline CSS (no external libs)

### Open the explainer

```bash
open /tmp/knowledge-probe-explainer.html
```

Tell the user the explainer is ready and what it covers based on their assessment.
