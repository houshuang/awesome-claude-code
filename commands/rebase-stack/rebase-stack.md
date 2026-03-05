---
allowed-tools: Bash(git:*), Bash(gh:*)
argument-hint: [target branch to rebase onto, default: main]
description: Rebase a stack of PRs onto a target branch, trickling changes down through the chain
---

# Rebase PR Stack

You are tasked with rebasing a stack of PRs onto a target branch and force-pushing the results.

The user may provide a target branch as an argument (default: `main`). Use `$ARGUMENTS` if provided, otherwise default to `main`.

## Process:

1. **Discover the PR stack:**
   - Run `git branch --show-current` to identify the current branch
   - Run `gh pr list --author @me --state open --json number,title,headRefName,baseRefName` to find all open PRs
   - Walk the `baseRefName` chain starting from the current branch (or its PR's `headRefName`) back to the target branch to build an ordered list of branches
   - The stack is ordered from bottom (closest to target) to top (current branch or furthest from target)

2. **Show the plan and confirm:**
   - Display the discovered stack as a numbered list showing: branch name, PR number, and PR title
   - Show how many commits the target branch is ahead of the bottom of the stack
   - Use `AskUserQuestion` to confirm the rebase before proceeding

3. **Rebase sequentially:**
   - Start by rebasing the bottom branch onto the target: `git rebase <target> <bottom-branch>`
   - Then rebase each subsequent branch onto the one below it: `git rebase <previous-branch> <next-branch>`
   - Continue up the stack until all branches are rebased
   - If the current branch is not part of the PR stack (i.e., a local branch on top):
     - First, check for uncommitted changes: `git status --porcelain`. If there are any, warn the user and ask for confirmation before proceeding (offer to stash them).
     - Then, check for additional commits beyond the top PR branch: `git log --oneline <top-pr-branch>..<current-branch>`. If there are additional commits, list them and warn the user that these commits will be lost if they proceed with a hard reset.
     - Use `AskUserQuestion` to confirm the action, clearly explaining what will happen (e.g., "Your branch has N unpushed commits that will be lost. Proceed with reset?"). Only proceed if the user confirms.
     - If confirmed, reset it to match the top of the stack: `git checkout <current-branch> && git reset --hard <top-pr-branch>`
   - If any rebase fails with conflicts, stop immediately and inform the user. Do NOT attempt to resolve conflicts automatically.

4. **Force-push all branches:**
   - Run `git push --force-with-lease origin <branch1> <branch2> ...` for all rebased branches in a single command
   - Verify the push succeeded

5. **Report results:**
   - Show a summary table of all branches and their status
   - Confirm the current branch is checked out and up to date

## Important:

- Always use `--force-with-lease` (never `--force`) to prevent overwriting unexpected remote changes
- If a rebase has conflicts, stop and report them — do not auto-resolve
- Never rebase branches that aren't part of the discovered stack
- The stack is discovered from PR metadata, not from branch topology alone
