---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(git merge-base:*), Read
argument-hint: [base-branch]
description: Read all changed files in the current git branch to get Claude up to speed
model: sonnet
---

# Catch Up on Branch Changes

You are tasked with reading all changed files in the current git branch to help get context after a /clear command.

The user may provide a base branch as an argument. Use `$ARGUMENTS` if provided, otherwise default to `main`.

## Process:

1. **Identify the current branch and its base:**
   - Run `git branch --show-current` to get current branch name
   - Run `git merge-base HEAD $ARGUMENTS` (or `main` if no argument) to find where the branch diverged
   - Run `git log --oneline <base>..HEAD` to see commit history since divergence

2. **Get the list of changed files:**
   - Run `git diff --name-only <base>..HEAD` to get all files changed in this branch
   - Run `git status` to also see any uncommitted changes

3. **Categorize and summarize the changes:**
   - Group files by type/area (e.g., src/, tests/, docs/, etc.)
   - Note new files vs. modified files
   - Identify the scope of changes (which modules/packages are affected)

4. **Read the changed files systematically:**
   - For each changed file, use the Read tool to load its current content
   - Read files in a logical order:
     - Start with type definitions and interfaces
     - Then core business logic
     - Then API/UI implementations
     - Finally tests and documentation
   - For large files (>500 lines), focus on reading the most relevant sections

5. **Provide a comprehensive summary:**
   - List all files you've read
   - Summarize the key changes and their purpose
   - Highlight any patterns or themes across the changes
   - Note any areas that might need attention (TODOs, incomplete changes, etc.)
   - Explain how the pieces fit together

## Important Guidelines:

- **Be thorough but efficient**: Read all changed files, but prioritize the most important ones
- **Understand the context**: Look at commit messages to understand the "why" behind changes
- **Note dependencies**: Identify how changes in one file affect others
- **Flag concerns**: If you notice incomplete work, inconsistencies, or potential issues, mention them
- **Provide actionable insight**: Your summary should help the user understand what's been done and what might need to happen next

## Output Format:

Your response should include:

1. **Branch Context**:
   - Current branch name
   - Number of commits since base
   - Brief summary of commit history

2. **Changed Files Summary**:
   - Total number of files changed
   - Breakdown by category/area
   - New files vs. modified files

3. **Detailed Analysis**:
   - Key changes in each major area
   - How the changes relate to each other
   - Any notable patterns or architectural decisions

4. **Current State**:
   - What's been completed
   - What appears to be in progress
   - Any uncommitted changes

5. **Ready to Help**:
   - Brief statement that you're now caught up and ready to continue work

## Remember:

- You're helping the user get back up to speed quickly
- Focus on understanding the "big picture" as well as details
- Your goal is to be able to continue work seamlessly as if /clear never happened
