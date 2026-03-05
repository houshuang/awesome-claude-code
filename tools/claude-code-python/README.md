# claude-code-python

A Python wrapper for calling the Claude Code CLI (`claude -p`) as a subprocess, with structured JSON output.

## Why use this?

If you have a Claude Max subscription, `claude -p` gives you free LLM calls through the CLI. This wrapper makes it easy to call from Python backends, scripts, and pipelines -- getting structured JSON output with schema validation.

## Two modes

### `generate_structured()` -- Single-turn, no tools

Best for classification, extraction, and transformation tasks where all context is in the prompt.

```python
from claude_code import generate_structured

result = generate_structured(
    prompt="Classify this support ticket: 'My login is broken'",
    system_prompt="You are a ticket classifier. Return a category and priority.",
    json_schema={
        "type": "object",
        "properties": {
            "category": {"type": "string", "enum": ["bug", "feature", "question"]},
            "priority": {"type": "string", "enum": ["low", "medium", "high"]},
        },
        "required": ["category", "priority"],
    },
)
# result = {"category": "bug", "priority": "high"}
```

### `generate_with_tools()` -- Multi-turn agentic session

Claude gets Read and Bash tools, so it can read files, run validation scripts, and self-correct within a single call. Great for generate-then-validate loops.

```python
from claude_code import generate_with_tools

result = generate_with_tools(
    prompt="Generate a valid nginx config for a reverse proxy to localhost:8000",
    system_prompt="You are a config generator. Write the config, then validate it with nginx -t.",
    json_schema={
        "type": "object",
        "properties": {
            "config": {"type": "string"},
            "valid": {"type": "boolean"},
        },
        "required": ["config", "valid"],
    },
    work_dir="/tmp/nginx-gen",
)
```

## API

### `is_available() -> bool`

Check if the `claude` CLI is installed and on PATH. Use this to implement fallback logic.

```python
from claude_code import is_available, generate_structured

if is_available():
    result = generate_structured(...)
else:
    # Fall back to direct API calls via litellm, openai, etc.
    result = litellm.completion(...)
```

### `generate_structured(prompt, system_prompt, json_schema, model="sonnet", timeout=120) -> dict`

Single-turn generation. No tools, no file access. Returns parsed JSON matching your schema.

### `generate_with_tools(prompt, system_prompt, json_schema, work_dir, model="sonnet", tools="Read,Bash", max_budget_usd=0.50, timeout=240) -> dict`

Multi-turn session with tool access. Claude can read files in `work_dir` and run shell commands. Returns parsed JSON matching your schema.

**Parameters common to both:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `prompt` | str | required | User prompt text |
| `system_prompt` | str | required | System prompt text |
| `json_schema` | dict | required | JSON Schema for output validation |
| `model` | str | `"sonnet"` | Model alias: `opus`, `sonnet`, `haiku` |
| `timeout` | int | 120/240 | Max seconds to wait |

**Additional for `generate_with_tools`:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `work_dir` | str | required | Directory for tool access |
| `tools` | str | `"Read,Bash"` | Comma-separated tool names |
| `max_budget_usd` | float | `0.50` | Safety spending cap |

## Requirements

- Python 3.10+
- `claude` CLI installed and authenticated (`npm install -g @anthropic-ai/claude-code`)
- `jq` is NOT required (all parsing is done in Python)

## Error handling

Both functions raise:
- `FileNotFoundError` if `claude` CLI is not installed
- `RuntimeError` if claude exits with an error, times out, or returns unparseable output

```python
try:
    result = generate_structured(...)
except FileNotFoundError:
    print("claude CLI not installed")
except RuntimeError as e:
    print(f"Generation failed: {e}")
```

## Logging

Both functions log timing, cost, and turn count at `INFO` level:

```
generate_structured: model=sonnet duration=3.2s cost=$0.003 turns=1
generate_with_tools: model=sonnet duration=12.5s cost=$0.042 turns=4
```

Enable with:
```python
logging.basicConfig(level=logging.INFO)
```
