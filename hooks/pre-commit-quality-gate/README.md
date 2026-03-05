# pre-commit-quality-gate

Runs lint and typecheck on staged files before Claude Code commits. Blocks the commit if any checks fail.

This only affects Claude Code — your regular git workflow and git hooks are unaffected.

## Why

Claude Code can introduce type errors or lint violations during multi-file changes. This hook acts as a final quality gate, ensuring that every commit Claude makes passes both linting and type checking. It pairs well with `post-edit-lint` (which catches lint errors early) by adding typecheck at commit time when the codebase should be in a consistent state.

## Installation

1. Copy the script to your project:
   ```bash
   mkdir -p .claude/hooks
   cp pre-commit-quality-gate.sh .claude/hooks/
   chmod +x .claude/hooks/pre-commit-quality-gate.sh
   ```

2. Add the hook config to `.claude/settings.json` or `.claude/settings.local.json`:
   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "Bash",
           "command": ".claude/hooks/pre-commit-quality-gate.sh"
         }
       ]
     }
   }
   ```

## Configuration

Configure via environment variables:

| Variable | Default | Description |
|---|---|---|
| `LINT_COMMAND` | `eslint` | Linter command to run on each staged file |
| `LINT_ARGS` | _(empty)_ | Extra arguments for the linter |
| `TYPECHECK_COMMAND` | `npx tsc --noEmit` | Typecheck command (use `{pkg_dir}` as placeholder) |
| `PACKAGE_MANAGER` | `npm` | Package manager for monorepo `--filter` commands |
| `FILE_EXTENSIONS` | `ts tsx js jsx` | File extensions to check (space-separated) |
| `MONOREPO_DIRS` | `apps packages services tools` | Top-level monorepo directories (space-separated) |

**Examples for different setups:**

```bash
# pnpm monorepo with oxlint
export PACKAGE_MANAGER="pnpm"
export LINT_COMMAND="oxlint"
export LINT_ARGS="--deny-warnings"

# Biome in a single-package repo
export LINT_COMMAND="biome check"
export TYPECHECK_COMMAND="npx tsc --noEmit -p {pkg_dir}/tsconfig.json"

# npm with ESLint (defaults — no configuration needed)
```

## How it works

1. Intercepts `git commit` commands via a `PreToolUse` hook on Bash
2. Finds all staged TypeScript/JavaScript files (or whatever `FILE_EXTENSIONS` is set to)
3. Runs the configured linter on each staged file
4. Detects which monorepo packages have staged changes and runs typecheck on each
5. If any check fails, returns a `deny` decision with all errors, blocking the commit
6. Claude Code sees the errors and can fix them before retrying the commit
