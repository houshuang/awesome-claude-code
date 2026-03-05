---
allowed-tools: Task, Read, Grep, Glob, LS, Edit, MultiEdit, Write, Bash(npm:*), Bash(npx:*), Bash(pnpm:*), Bash(yarn:*), Bash(make:*), Bash(git:*)
argument-hint: [feedback]
description: Analyzes review feedback for validity and implements fixes if warranted
model: opus
---

# Review Feedback Analysis

You are tasked with analyzing review feedback on the current branch's code. Your job is to critically evaluate whether each piece of feedback is valid before taking action.

## Process

### Step 1: Understand the Feedback

- Parse the feedback provided as the argument. If nothing provided, lookup the PR review feedback. Remember to include inline comments.
- Identify the specific file(s), line(s), and concern being raised
- Read the referenced files fully to understand the current implementation

### Step 2: Analyze Validity

For each piece of feedback, evaluate:

1. **Is the problem real?** Read the actual code — does the issue described actually exist?
2. **Is it the right fix?** Even if the problem is real, is the suggested fix appropriate? Consider:
   - Does the language/framework already handle this? (e.g., React state setters are safe after unmount)
   - Would the fix introduce unnecessary complexity?
   - Is there a simpler or more idiomatic solution?
   - Does the fix match established patterns in the codebase?
3. **Is it worth fixing?** Consider severity, likelihood, and maintenance cost:
   - Is this a real bug or a theoretical concern?
   - What's the blast radius if the issue occurs?
   - Does the fix cost more in complexity than the problem it solves?

### Step 3: Present Your Analysis

For each piece of feedback, clearly state your verdict:

- **Valid — will fix**: The concern is real and the fix is worthwhile. Explain briefly why.
- **Valid concern, different fix**: The problem is real but the suggested approach isn't ideal. Explain your alternative.
- **Not valid — recommend pushing back**: The concern is incorrect, already handled, or not worth the complexity. Explain why with specific technical reasoning.

### Step 4: Implement (if valid)

For feedback you've determined is valid:

1. Make the fix, following existing codebase patterns
2. Run your project's build/typecheck/lint commands to verify
3. Present the changes for the user to review
4. Ask the user if they want to commit

For feedback you've determined is not valid:

- Provide a clear, technically grounded explanation the user can use to respond to the reviewer
- Suggest alternative improvements if any come to mind

## Guidelines

- **Be skeptical, not dismissive.** Take every piece of feedback seriously, but don't implement changes just because someone suggested them.
- **Verify claims against real code.** Don't assume the feedback accurately describes the code — read it yourself.
- **Consider the ecosystem.** Many "issues" are already handled by frameworks (React, browser APIs, etc.).
- **Prefer simplicity.** If a fix adds more complexity than the problem warrants, say so.
- **Back up your reasoning.** Reference specific code, documentation, or framework behavior when explaining your verdict.
