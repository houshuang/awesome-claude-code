---
allowed-tools: Task, Read, Grep, Glob, LS, Write, Edit, Bash(git:*)
argument-hint: [path|--all]
description: Verifies documentation against actual code to detect semantic drift
model: opus
---

# Verify Documentation

You verify that documentation accurately describes the current codebase. This detects **semantic drift** — when docs describe behaviors, patterns, or structures that no longer match reality.

## Usage

```
/verify-docs src/auth          # Verify docs for a specific module
/verify-docs docs/api.md       # Verify a specific doc file
/verify-docs --all             # Full verification (expensive)
```

## Process

### Step 1: Identify What to Verify

Based on the argument provided:

**If a source directory** (e.g., `src/auth`, `lib/database`):
1. Look for `README.md`, `ARCHITECTURE.md`, or similar docs in that directory
2. Look for references to this module in top-level documentation
3. Search for mentions in any architecture or API docs

**If a documentation file** (e.g., `docs/api.md`):
1. Read the file
2. Identify all code components it documents

**If `--all`**:
1. Find all documentation files (README.md, ARCHITECTURE.md, docs/*.md)
2. Process each systematically

### Step 2: Read the Documentation

For each relevant doc file:
1. Read the full file content
2. Extract key claims about:
   - **Module/package structure** — What modules exist and their purposes
   - **Key types and interfaces** — Important type definitions mentioned
   - **Data flow** — How data moves between components
   - **Dependencies** — What depends on what
   - **Patterns** — Documented patterns and conventions
   - **Code links** — Links to source files

### Step 3: Verify Against Actual Code

Spawn parallel Task agents to verify each category:

**Structure verification:**
- Do the documented modules/packages exist?
- Do they have the described purposes (check exports, main files)?
- Are there new modules not documented?

**Type verification:**
- Do documented interfaces/types exist?
- Do they have the documented properties/methods?
- Have signatures changed?

**Data flow verification:**
- Do the documented flows still exist?
- Follow actual imports and function calls to verify

**Dependency verification:**
- Check actual package.json / requirements / go.mod dependencies
- Verify import statements match documented relationships

**Pattern verification:**
- Search for usage of documented patterns
- Check if patterns are still followed consistently

### Step 4: Generate Drift Report

Create a structured report with three sections:

```markdown
## Documentation Drift Report: [path]

**Verified**: [date]
**Docs checked**: [list of doc files]

### Verified Accurate
- [List items that match reality]

### Drift Detected
- **[Doc file:line]**: [What the doc claims]
  - **Reality**: [What the code actually does]
  - **Severity**: Minor|Moderate|Significant
  - **Suggested fix**: [Brief suggestion]

### Unable to Verify
- [Items that couldn't be verified and why]

### Missing Documentation
- [New code/patterns not reflected in docs]
```

### Step 5: Offer to Fix (Optional)

After presenting the report, ask:
> Would you like me to update the documentation to fix the detected drift?

If yes, use Edit tool to update the relevant doc files.

## Drift Categories

### Minor Drift
- Renamed variables/functions (but same behavior)
- Outdated file paths that still work
- Minor API changes

### Moderate Drift
- Missing new features/components
- Changed data flow
- New dependencies not documented

### Significant Drift
- Documented behavior that no longer exists
- Architectural patterns that changed fundamentally
- Security-relevant changes not documented

## Verification Checklist

When verifying a doc, check:

1. **File Links**
   - Do linked files exist?
   - Do they contain what's described?
   - Are relative paths correct from the doc's location?

2. **Type Definitions**
   - Are mentioned interfaces/types current?
   - Check with: Grep for `interface TypeName` or `type TypeName`

3. **Function/Class References**
   - Are documented functions/classes still exported?
   - Have signatures changed significantly?

4. **Diagrams**
   - Do diagram components map to real code?
   - Are relationships accurate?

5. **Code Examples**
   - Do embedded code examples still work?
   - Flag large code blocks (>5 lines) as candidates for linking to source instead

## Important Notes

- This command focuses on **semantic** accuracy, not formatting or style
- Use sub-agents for deep code inspection when verifying complex claims
- Be specific about line numbers in drift reports
- When in doubt, flag as "Unable to Verify" rather than false positive
- Consider the audience: drift that confuses developers is more critical
