# Code Reviewer Agent

An expert code reviewer that analyzes code with the precision of a senior developer conducting a thorough peer review.

## When to use

- Before submitting a PR, to catch issues early
- When you want a second opinion on a complex implementation
- To review a teammate's code changes
- When you need a structured analysis of code quality, security, and performance

## How it works

The agent analyzes code across five dimensions:
1. **Correctness** — logic accuracy, edge cases, error handling
2. **Readability** — naming, structure, clarity
3. **Maintainability** — modularity, coupling, extensibility
4. **Performance** — inefficiencies, resource usage
5. **Security** — vulnerabilities, input validation, data exposure

Issues are categorized by severity (Critical, High, Medium, Low) and type (Bug, Security, Performance, Style). The agent provides specific, actionable fixes with code examples.

## Output

Structured review with:
- Summary of code functionality
- Critical issues (security, logic errors, crashes)
- High/Medium/Low priority findings
- Specific recommendations with examples
- Positive notes on well-implemented aspects

## Installation

Copy `code-reviewer.md` to `.claude/agents/` in your project.
