---
name: claude-api
description: "Build apps with the Claude API or Anthropic SDK.\nTRIGGER when: code imports `anthropic`/`@anthropic-ai/sdk`/`claude_agent_sdk`, or user asks to use Claude API, Anthropic SDKs, or Agent SDK.\nDO NOT TRIGGER when: code imports `openai`/other AI SDK, general programming questions."
---

# Claude CLI (`claude -p`) Integration for Data Processing

Reference guide for integrating `claude -p` as a programmatic LLM backend in Python projects. Based on patterns from 5 production projects (alif, petrarca, otak, ralph-bot, nrk-kulturperler) and 28,000+ CLI calls/week.

## When to Use `claude -p` vs Direct API vs Agent SDK

| Use `claude -p` | Use Direct API | Use Agent SDK |
|---|---|---|
| **Max plan (free, no per-token cost)** | High-volume batch (Batch API = 50% off) | Production automation needing in-process control |
| Need built-in tools (Read, Bash, Grep) | Need prompt caching (90% savings) | CI/CD pipelines with API budget |
| Quick scripts, prototyping | Production services with persistent connections | Custom tool definitions in-process |
| Multi-turn agentic sessions | Fine-grained token/cost control | Subagent orchestration |
| < 1000 calls/day | > 1000 calls/day or latency-critical | When subprocess overhead is unacceptable |

**Key difference:** `claude -p` uses your existing Max plan subscription (free LLM calls). Both Direct API and Agent SDK require `ANTHROPIC_API_KEY` and bill per-token. If you have a Max plan, `claude -p` is the most cost-effective programmatic interface by far.

## CRITICAL: `--bare` Bypasses Max Plan Auth

Anthropic now recommends `--bare` as the default for scripted calls, and it will become the default for `-p` in a future release. However, **for Max plan users this has major cost implications:**

`--bare` skips auto-discovery of hooks, skills, plugins, MCP servers, auto memory, and CLAUDE.md. It also skips OAuth/keychain discovery, meaning:
- **Requires `ANTHROPIC_API_KEY` env var** (or `apiKeyHelper` via `--settings`) — uses paid API, NOT free Max plan
- Without a key, `--bare` fails with "Not logged in"
- **On servers using `claude setup-token` for free Max plan**: `--bare` either fails or costs money
- **Benchmarked savings**: 3.2s (45%) per call — significant but has cost implications

**Use `--bare` when**: local dev with API key, CI/CD with API key, or cost is acceptable.
**Don't use `--bare` when**: server relies on Max plan auth for free usage (the common case for this skill).
**Free alternative**: `--effort low` saves ~25% latency with no auth changes.

## Essential Flags

### For Max plan (free) scripted calls
```bash
claude -p \
  --output-format json \            # Structured response with metadata
  --no-session-persistence \        # Don't save sessions to disk
  --tools "" \                      # No tools (single-turn generation)
  --model haiku                     # Choose: haiku/sonnet/opus
```

### For paid API scripted calls (faster)
```bash
claude -p \
  --bare \                          # Skip CLAUDE.md, hooks, MCP, plugins (~3s faster)
  --output-format json \
  --no-session-persistence \
  --tools "" \
  --model haiku
```

### For structured output (PREFERRED)
```bash
claude -p \
  --output-format json --no-session-persistence \
  --tools "" \
  --json-schema '{"type":"object","properties":{"items":{"type":"array"}},"required":["items"]}' \
  --system-prompt "You are a classifier."
```
`--json-schema` uses constrained decoding — **guaranteed** valid JSON matching your schema. Result appears in `structured_output` field. Adds ~1s overhead but eliminates JSON parsing failures.

### For tool-enabled agentic sessions
```bash
claude -p \
  --output-format json --no-session-persistence \
  --allowedTools "Read,Bash,Grep" \  # Pre-approve tools (no permission prompts)
  --max-turns 5 \                    # Prevent infinite loops
  --max-budget-usd 1.00 \           # Safety cap
  --add-dir /path/to/project \      # Grant file access
  --model sonnet
```

### Key flags reference
| Flag | Purpose | When to use |
|---|---|---|
| `--bare` | Skip auto-discovery (needs API key) | Paid API scripts, CI/CD |
| `--effort` | Reasoning depth: `low`/`medium`/`high`/`max` | `low` for simple tasks (25% faster) |
| `--json-schema` | Constrained structured output | When you need reliable JSON |
| `--tools ""` | Disable all tools (`"default"` re-enables all) | Single-turn generation |
| `--allowedTools` | Pre-approve specific tools | Multi-turn with tools |
| `--disallowedTools` | Block specific tools | Restrict dangerous tools |
| `--max-turns N` | Cap agentic turns | Tool-enabled sessions |
| `--max-budget-usd N` | Cost safety cap | Multi-turn sessions |
| `--permission-mode` | `acceptEdits`/`auto`/`dontAsk`/`plan`/`default` | Replaces ad-hoc permission handling |
| `--fallback-model` | Auto-fallback on overload (print mode only) | Production reliability |
| `--system-prompt` | Replace entire system prompt | Custom behavior |
| `--system-prompt-file` | System prompt from file | Long/shared system prompts |
| `--append-system-prompt` | Add to default prompt | Keep Claude Code capabilities |
| `--add-dir` | Additional directory access | Tool sessions needing file access |
| `--model` | Model selection | `haiku` (cheap), `sonnet` (balanced), `opus` (best) |
| `--settings` | Pass settings JSON file | Production config (can include `apiKeyHelper`) |
| `--mcp-config` | MCP server configuration | Headless calls with MCP tools |
| `--input-format stream-json` | Bidirectional streaming input | Real-time streaming integrations |

### `--effort` levels (Sonnet 4.6, Opus 4.6 only)
| Level | Speed | Quality | Notes |
|---|---|---|---|
| `low` | Fast | Lower | Simple tasks, classification |
| `medium` | Default | Default | Most work |
| `high` | Slow | Higher | Complex reasoning. Also triggered by "ultrathink" in prompt |
| `max` | Very slow | Highest | Opus only, unconstrained thinking |

## Python Wrapper — Reference Implementation

Drop this into any project as `claude_cli.py`. Consolidates patterns from 5 production projects:

```python
"""Claude CLI wrapper — structured generation via `claude -p`.

Usage:
    result = generate(prompt="...", system="...", schema={...})
    results = generate_parallel(tasks, max_concurrent=4)
"""
import json, logging, os, re, shutil, subprocess, time
from dataclasses import dataclass, field

logger = logging.getLogger(__name__)

# Strip CLAUDECODE env var to allow nested invocation from Claude Code sessions
_ENV = {k: v for k, v in os.environ.items() if k != "CLAUDECODE"}


def is_available() -> bool:
    return shutil.which("claude") is not None


def generate(
    prompt: str,
    system: str = "",
    schema: dict | None = None,
    model: str = "haiku",
    timeout: int = 120,
    tools: str = "",
    allowed_tools: str | None = None,
    max_turns: int | None = None,
    max_budget: float | None = None,
    work_dir: str | None = None,
) -> tuple[dict | str, dict]:
    """Single-turn or multi-turn structured generation.

    Returns (result, metadata). Result is dict if schema provided, else str.
    Metadata: {cost, turns, duration_s, session_id}.
    """
    cmd = [
        "claude", "-p",
        "--bare",
        "--output-format", "json",
        "--no-session-persistence",
        "--model", model,
    ]
    if tools is not None:
        cmd.extend(["--tools", tools])
    if allowed_tools:
        cmd.extend(["--allowedTools", allowed_tools])
    if schema:
        cmd.extend(["--json-schema", json.dumps(schema)])
    if system:
        cmd.extend(["--system-prompt", system])
    if max_turns:
        cmd.extend(["--max-turns", str(max_turns)])
    if max_budget:
        cmd.extend(["--max-budget-usd", str(max_budget)])
    if work_dir:
        cmd.extend(["--add-dir", work_dir])

    start = time.time()
    proc = subprocess.run(
        cmd, input=prompt, capture_output=True, text=True,
        timeout=timeout, env=_ENV,
    )
    elapsed = time.time() - start

    if proc.returncode != 0:
        raise RuntimeError(f"claude exited {proc.returncode}: {proc.stderr[:300]}")

    response = json.loads(proc.stdout)
    if response.get("is_error"):
        raise RuntimeError(f"claude error: {response.get('result', 'unknown')[:300]}")

    metadata = {
        "cost": response.get("total_cost_usd", 0),
        "turns": response.get("num_turns", 0),
        "duration_s": round(elapsed, 1),
        "session_id": response.get("session_id"),
    }

    # Prefer structured_output (from --json-schema)
    result = response.get("structured_output")
    if not result and schema:
        text = response.get("result", "").strip()
        text = re.sub(r"^```(?:json)?\s*", "", text)
        text = re.sub(r"\s*```$", "", text)
        result = json.loads(text) if text else None
    if not result and not schema:
        result = response.get("result", "")
    if result is None:
        raise RuntimeError(f"Empty response: {response.get('result', '')[:200]}")

    return result, metadata


# ── Parallel batch processing ────────────────────────────────────

@dataclass
class Task:
    prompt: str
    system: str = ""
    schema: dict = field(default_factory=dict)
    model: str = "haiku"
    timeout: int = 120
    tag: str = ""


def generate_parallel(
    tasks: list[Task],
    max_concurrent: int = 4,
) -> list[tuple[dict | None, dict]]:
    """Run multiple tasks in parallel via Popen + polling.

    Returns list of (result_or_None, metadata) in input order.
    """
    results: list[tuple[dict | None, dict]] = [(None, {})] * len(tasks)
    running: list[tuple[int, subprocess.Popen, float, Task]] = []
    next_idx = 0

    def _launch(idx):
        nonlocal next_idx
        task = tasks[idx]
        cmd = [
            "claude", "-p", "--bare",
            "--output-format", "json", "--no-session-persistence",
            "--tools", "", "--model", task.model,
        ]
        if task.schema:
            cmd.extend(["--json-schema", json.dumps(task.schema)])
        if task.system:
            cmd.extend(["--system-prompt", task.system])
        proc = subprocess.Popen(
            cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, text=True, env=_ENV,
        )
        proc.stdin.write(task.prompt)
        proc.stdin.close()
        running.append((idx, proc, time.time(), task))

    def _collect():
        for i, (idx, proc, start, task) in enumerate(running):
            if proc.poll() is not None:
                elapsed = time.time() - start
                running.pop(i)
                meta = {"duration_s": round(elapsed, 1), "tag": task.tag}
                try:
                    resp = json.loads(proc.stdout.read())
                    meta["cost"] = resp.get("total_cost_usd", 0)
                    result = resp.get("structured_output")
                    if not result:
                        text = resp.get("result", "").strip()
                        text = re.sub(r"^```(?:json)?\s*", "", text)
                        text = re.sub(r"\s*```$", "", text)
                        result = json.loads(text) if text else None
                    results[idx] = (result, meta)
                except Exception as e:
                    meta["error"] = str(e)
                    results[idx] = (None, meta)
                return True
            elif time.time() - start > task.timeout:
                proc.kill()
                running.pop(i)
                results[idx] = (None, {"error": "timeout", "tag": task.tag})
                return True
        return False

    while next_idx < len(tasks) or running:
        while len(running) < max_concurrent and next_idx < len(tasks):
            _launch(next_idx)
            next_idx += 1
        if not _collect():
            time.sleep(0.1)

    return results
```

## Patterns & Best Practices

### 1. Model selection by task type

| Task | Model | Why |
|---|---|---|
| Classification, tagging, extraction | `haiku` | Fast, cheap, reliable for simple structured output |
| Sentence/text generation | `sonnet` | Better quality, still fast |
| Complex reasoning, creative writing | `opus` | Best quality, use sparingly |
| Verification, quality gate | `haiku` | Cheap enough to run on every item |
| Multi-turn agentic (file reading, self-correction) | `sonnet` | Balances quality + tool use cost |

### 2. Batching: single call vs many calls

**Batch in a single prompt** when:
- Items are independent but share a system prompt (amortizes context)
- Total input fits in context (~200K tokens)
- You want atomicity (all-or-nothing)

```python
# 20 items in one call — 1 context load instead of 20
result, _ = generate(
    prompt=f"Classify these items:\n{json.dumps(items)}",
    schema={"type": "object", "properties": {"results": {"type": "array"}}},
    model="haiku",
)
```

**Use parallel calls** when:
- Items need different system prompts or schemas
- Individual items are large (approach context limits)
- You want per-item error isolation
- Wall-clock time matters more than token cost

```python
tasks = [Task(prompt=f"Analyze: {item}", schema=item_schema) for item in items]
results = generate_parallel(tasks, max_concurrent=4)
```

### 3. Structured output — always use `--json-schema`

Never rely on "please return JSON" in the prompt. `--json-schema` uses constrained decoding — the response is **guaranteed** to match. Supports:
- `type`, `properties`, `required`, `enum`
- `items` (for arrays), `minimum`/`maximum` (for numbers)
- Nested objects, `$ref` (limited)

```python
schema = {
    "type": "object",
    "properties": {
        "sentiment": {"type": "string", "enum": ["positive", "negative", "neutral"]},
        "confidence": {"type": "number", "minimum": 0, "maximum": 1},
        "entities": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "type": {"type": "string", "enum": ["person", "org", "place"]}
                },
                "required": ["name", "type"]
            }
        }
    },
    "required": ["sentiment", "confidence", "entities"]
}
```

### 4. Error handling and retries

```python
import time

def generate_with_retry(prompt, schema, model="haiku", retries=2, **kwargs):
    """Generate with automatic retry on transient failures."""
    for attempt in range(retries + 1):
        try:
            return generate(prompt=prompt, schema=schema, model=model, **kwargs)
        except (RuntimeError, subprocess.TimeoutExpired, json.JSONDecodeError) as e:
            if attempt == retries:
                raise
            logger.warning("Attempt %d failed: %s — retrying in 2s", attempt + 1, e)
            time.sleep(2)
```

### 5. Nested invocation (calling from within Claude Code)

When your script might run inside a Claude Code session, strip the `CLAUDECODE` env var:

```python
env = {k: v for k, v in os.environ.items() if k != "CLAUDECODE"}
proc = subprocess.run(cmd, ..., env=env)
```

Without this, nested `claude -p` calls may fail or behave unexpectedly.

### 6. Session resumption for multi-step workflows

```python
# Step 1: analyze (capture session_id)
result1, meta1 = generate(
    prompt="Analyze this codebase for security issues",
    model="sonnet",
    tools="default",
    allowed_tools="Read,Grep,Glob",
)
session_id = meta1["session_id"]

# Step 2: fix (resume with full context from step 1)
cmd = ["claude", "-p", "--bare", "--resume", session_id, ...]
```

### 7. Cost tracking

Log every call for post-hoc analysis:

```python
def log_call(task_type, model, result, metadata, log_dir="data/logs"):
    """Append call metadata to daily JSONL log."""
    from datetime import datetime
    from pathlib import Path
    Path(log_dir).mkdir(parents=True, exist_ok=True)
    entry = {
        "ts": datetime.now().isoformat(),
        "task": task_type,
        "model": model,
        "success": result is not None,
        "cost": metadata.get("cost", 0),
        "duration_s": metadata.get("duration_s", 0),
    }
    log_file = Path(log_dir) / f"llm_calls_{datetime.now():%Y-%m-%d}.jsonl"
    with open(log_file, "a") as f:
        f.write(json.dumps(entry) + "\n")
```

## Common Pitfalls

1. **Using `--bare` with Max plan auth** — `--bare` skips OAuth, requires `ANTHROPIC_API_KEY`. Uses paid API instead of free Max plan. Anthropic now recommends `--bare` as default for scripted calls and it will become the `-p` default in a future release — but this only makes sense if you're on paid API. For Max plan users, avoid `--bare` to keep calls free.

2. **Not stripping `CLAUDECODE` env var** — nested invocation from within Claude Code sessions fails or behaves differently. Always strip: `env = {k: v for k, v in os.environ.items() if k != "CLAUDECODE"}`. Found missing in 4 of 6 audited projects.

3. **Using prompt-based JSON instead of `--json-schema`** — LLMs hallucinate JSON structure. Constrained decoding doesn't. Note: adds ~1s overhead per call.

4. **No `--max-turns` on tool-enabled sessions** — Claude can loop indefinitely reading files and running commands. Always set a cap.

5. **No `--max-budget-usd` on agentic sessions** — multi-turn sessions with tools can accumulate significant cost. Set a safety cap.

6. **Fragile markdown fence stripping** — most wrappers use `re.sub(r"^```json?\s*", "", text)` which misses edge cases. Better: `re.search(r'```(?:json)?\s*\n?([\s\S]*?)\n?\s*```', text)` (non-greedy, matches between fences).

7. **Not committing wrapper changes** — the Alif migration was written locally but never deployed for 3 days (3,600 wasted API calls). Always commit + deploy LLM routing changes.

8. **`--no-session-persistence` breaks `--resume`** — session ID is returned but conversation isn't saved. Don't try to resume stateless sessions.

9. **`--effort` on unsupported models** — only works on Sonnet 4.6 and Opus 4.6. Silently ignored on Haiku (no error, no effect).

## Benchmarks (measured 2026-04-03, local Mac + Hetzner server)

| Config | Mean latency | vs baseline |
|---|---|---|
| haiku (OAuth, default) | 7.1s | baseline |
| haiku + `--effort low` | 5.3s | -25% |
| haiku + `--bare` (API key) | 3.9s | -45% |
| haiku + `--bare` + `--effort low` | 3.0s | -57% |
| sonnet (OAuth) | 5.9s | -16% (sonnet faster than haiku!) |
| sonnet + `--bare` | 2.5s | -65% |
| Direct API (claude-haiku-4-5, no CLI) | 1.3s | -82% |

Server-side CLI overhead: ~11s median (vs 1.1s direct API). The startup cost dominates for small prompts.

## Agent SDK — When (and When Not) to Use It

The `claude-agent-sdk` (Python/TypeScript) is Anthropic's recommended programmatic interface. It provides:
- In-process `query()` — no subprocess spawn overhead (~3-5s savings per call)
- Built-in tools (Read, Edit, Bash, Glob, Grep, WebSearch, WebFetch)
- Hooks as callback functions, subagent orchestration, MCP integration
- Streaming output, session management with resume/fork

**However, the Agent SDK always requires `ANTHROPIC_API_KEY` and bills per-token.** If you have a Max plan, `claude -p` is dramatically cheaper — every call is free. The Agent SDK only makes sense when:
- You don't have a Max plan (or are OK with per-token billing)
- Subprocess overhead is unacceptable (latency-critical paths)
- You need in-process tool definitions or streaming callbacks
- You're building a production service that needs the SDK's API surface

For batch data processing, content generation, and scripted workflows where Max plan is available, `claude -p` remains the right choice.

## Migrating an Existing Project

1. **Copy the wrapper** or adapt from the reference implementation above
2. **Add availability check**: `if is_available(): use CLI else: use API`
3. **Always strip CLAUDECODE** in the subprocess env
4. **Use `--json-schema`** for structured output (replaces `response_format`)
5. **Add `--max-turns` and `--max-budget-usd`** for tool-enabled sessions
6. **Log calls** with task_type to JSONL for monitoring
7. **Test on server**: Claude CLI must be installed + authenticated (`claude setup-token`)
8. **Consider `--bare`** only if using API key (not Max plan auth)
