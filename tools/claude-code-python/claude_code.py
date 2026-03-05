"""Python wrapper for calling Claude Code CLI (`claude -p`) as a subprocess.

Provides two modes of invocation:

1. generate_structured() — Single-turn structured JSON generation with no tools.
   Best for: classification, extraction, transformation tasks where you have
   all context in the prompt.

2. generate_with_tools() — Multi-turn agentic sessions with Read/Bash tools.
   Claude can read files, run scripts, and self-correct within the session.
   Best for: generate-then-validate loops, code generation with linting, etc.

Requirements:
    - `claude` CLI installed and authenticated
    - npm install -g @anthropic-ai/claude-code

Usage:
    from claude_code import generate_structured, generate_with_tools, is_available

    if is_available():
        result = generate_structured(
            prompt="Extract entities from this text: ...",
            system_prompt="You are an entity extractor.",
            json_schema={"type": "object", "properties": {"entities": {"type": "array"}}},
        )

        result = generate_with_tools(
            prompt="Generate and validate a config file.",
            system_prompt="You are a config generator.",
            json_schema={"type": "object", "properties": {"config": {"type": "string"}}},
            work_dir="/path/to/project",
        )
"""

import json
import logging
import re
import shutil
import subprocess
import time

logger = logging.getLogger(__name__)

# Defaults — override per call as needed
DEFAULT_TIMEOUT = 120  # seconds, for single-turn generation
DEFAULT_TOOLS_TIMEOUT = 240  # seconds, for multi-turn tool sessions
DEFAULT_MAX_BUDGET = 0.50  # dollars, safety cap for tool-enabled sessions


def is_available() -> bool:
    """Check if the claude CLI is installed and on PATH."""
    return shutil.which("claude") is not None


def _parse_response(proc: subprocess.CompletedProcess) -> tuple[dict, dict]:
    """Parse claude CLI JSON response, returning (result, metadata).

    Returns:
        (result_dict, metadata_dict) where metadata has cost, turns, session info.

    Raises:
        RuntimeError: On error or empty/unparseable response.
    """
    response = json.loads(proc.stdout)

    if response.get("is_error"):
        raise RuntimeError(f"claude error: {response.get('result', 'unknown')}")

    # Prefer structured_output (clean parsed JSON from --json-schema)
    result = response.get("structured_output")
    if not result:
        # Fall back to parsing result text (may have markdown fences)
        text = response.get("result", "")
        text = re.sub(r"^```(?:json)?\s*", "", text.strip())
        text = re.sub(r"\s*```$", "", text)
        if text:
            try:
                result = json.loads(text)
            except json.JSONDecodeError:
                raise RuntimeError(f"Failed to parse response as JSON: {text[:200]}")

    if not result:
        raise RuntimeError(
            f"Empty response from claude. "
            f"structured_output={response.get('structured_output')!r}, "
            f"result={response.get('result', '')[:200]!r}, "
            f"stop_reason={response.get('stop_reason')}"
        )

    metadata = {
        "total_cost_usd": response.get("total_cost_usd", 0),
        "num_turns": response.get("num_turns", 0),
        "session_id": response.get("session_id"),
    }

    return result, metadata


def generate_structured(
    prompt: str,
    system_prompt: str,
    json_schema: dict,
    model: str = "sonnet",
    timeout: int = DEFAULT_TIMEOUT,
) -> dict:
    """Single-turn structured JSON generation (no tools).

    Args:
        prompt: User prompt text.
        system_prompt: System prompt text.
        json_schema: JSON Schema dict for output validation.
        model: Model alias (opus, sonnet, haiku). Default: sonnet.
        timeout: Max seconds to wait. Default: 120.

    Returns:
        Parsed dict matching the provided schema.

    Raises:
        RuntimeError: If claude fails, times out, or returns invalid output.
        FileNotFoundError: If claude CLI is not installed.
    """
    if not is_available():
        raise FileNotFoundError(
            "claude CLI not found. Install: npm install -g @anthropic-ai/claude-code"
        )

    cmd = [
        "claude", "-p",
        "--tools", "",
        "--output-format", "json",
        "--model", model,
        "--no-session-persistence",
        "--json-schema", json.dumps(json_schema),
        "--system-prompt", system_prompt,
    ]

    start = time.time()
    try:
        proc = subprocess.run(
            cmd, input=prompt, capture_output=True, text=True, timeout=timeout
        )
    except subprocess.TimeoutExpired:
        raise RuntimeError(f"claude timed out after {timeout}s")

    elapsed = time.time() - start

    if proc.returncode != 0:
        raise RuntimeError(f"claude exited {proc.returncode}: {proc.stderr[:500]}")

    result, metadata = _parse_response(proc)

    logger.info(
        "generate_structured: model=%s duration=%.1fs cost=$%.3f turns=%d",
        model, elapsed, metadata["total_cost_usd"], metadata["num_turns"],
    )

    return result


def generate_with_tools(
    prompt: str,
    system_prompt: str,
    json_schema: dict,
    work_dir: str,
    model: str = "sonnet",
    tools: str = "Read,Bash",
    max_budget_usd: float = DEFAULT_MAX_BUDGET,
    timeout: int = DEFAULT_TOOLS_TIMEOUT,
) -> dict:
    """Multi-turn agentic session with tools enabled.

    Claude can read files and run scripts within the session, enabling
    self-validation loops (generate -> validate -> fix) in a single call.

    Args:
        prompt: User prompt text.
        system_prompt: System prompt text.
        json_schema: JSON Schema dict for the final structured output.
        work_dir: Directory to grant tool access to. Must exist.
        model: Model alias (opus, sonnet, haiku). Default: sonnet.
        tools: Comma-separated tool names. Default: "Read,Bash".
        max_budget_usd: Safety spending cap in dollars. Default: 0.50.
        timeout: Max seconds to wait. Default: 240.

    Returns:
        Parsed dict matching the provided schema.

    Raises:
        RuntimeError: If claude fails, times out, or returns invalid output.
        FileNotFoundError: If claude CLI is not installed.
    """
    if not is_available():
        raise FileNotFoundError(
            "claude CLI not found. Install: npm install -g @anthropic-ai/claude-code"
        )

    cmd = [
        "claude", "-p",
        "--tools", tools,
        "--dangerously-skip-permissions",
        "--output-format", "json",
        "--model", model,
        "--no-session-persistence",
        "--json-schema", json.dumps(json_schema),
        "--system-prompt", system_prompt,
        "--add-dir", work_dir,
        "--max-budget-usd", str(max_budget_usd),
    ]

    start = time.time()
    try:
        proc = subprocess.run(
            cmd, input=prompt, capture_output=True, text=True,
            timeout=timeout, cwd=work_dir,
        )
    except subprocess.TimeoutExpired:
        raise RuntimeError(f"claude with tools timed out after {timeout}s")

    elapsed = time.time() - start

    if proc.returncode != 0:
        raise RuntimeError(f"claude exited {proc.returncode}: {proc.stderr[:500]}")

    result, metadata = _parse_response(proc)

    logger.info(
        "generate_with_tools: model=%s duration=%.1fs cost=$%.3f turns=%d",
        model, elapsed, metadata["total_cost_usd"], metadata["num_turns"],
    )

    return result
