---
allowed-tools: Bash(git:*), Read, Grep, Glob, LS
argument-hint: [none]
description: Reviews the code changes in the current checked-out branch
model: opus
---

# Code Review

You are tasked with reviewing the code changes in the current checked-out branch.

## Process:

1. **Gather context:**

   - Run git fetch origin and ensure the branch is up to date
   - Identify the base branch (commonly main or develop)
   - Run git diff origin/[base-branch]...HEAD to get the full set of changes
   - Optionally run git log origin/[base-branch]..HEAD to see the commit history

2. **Review the changes:**

   - Read through the diff to understand the modifications
   - Look for:
     - Code correctness (does it do what it seems intended to do?)
     - Style consistency with the rest of the codebase
     - Potential bugs or edge cases
     - Readability and maintainability
     - Tests: new ones added? existing ones updated?
     - Documentation updates if relevant
   - Consider the scope: are changes too large for one PR/commit?

3. **Plan your feedback:**

   - Organize comments by file and line range if possible
   - Use clear, constructive language
   - Point out both strengths and weaknesses
   - Suggest concrete improvements where appropriate
   - Separate critical issues from optional/nice-to-have improvements

4. **Present your review to the user:**
   - Provide a summary of your overall impression
   - List detailed comments per file/section
   - Highlight critical blockers vs. suggestions
   - Use the following format where applicable:

```
Possible Race Condition in Auto-Join
File: src/hooks/useAutoJoin.ts

The hasJoinedRef is set to true before the async call completes.
If the call fails, the cleanup might not work properly.

// Line 27: Set before async completion
hasJoinedRef.current = true;

doAsyncWork().catch((error: unknown) => {
  console.error('Failed:', error);
  hasJoinedRef.current = false; // Reset on error, but cleanup might miss this
});

Recommendation: Set hasJoinedRef.current = true only after successful completion.
```

   - End with a clear recommendation: e.g. "Looks good to merge", "Needs changes", or "Consider splitting into smaller PRs"

## Important:

   - Feedback should always be constructive and actionable
   - Do not automatically approve changes — point out what's good and what needs improvement
   - Avoid nitpicking unless style is inconsistent with established patterns
   - Be explicit about whether issues are blocking or non-blocking

## Remember:

   - You have the full diff and commit history available
   - Organize comments so the user can easily translate them into PR review comments
   - The user trusts your judgment to provide a thoughtful and detailed review
