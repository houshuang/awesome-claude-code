# Playwright E2E

Write reliable Playwright end-to-end tests with semantic selectors and accessibility-first assertions. Enforces best practices and catches common anti-patterns.

## What it does

When writing or reviewing Playwright e2e tests, this skill guides Claude Code to:

- Use semantic locators (`getByRole`, `getByLabel`, `getByText`) instead of CSS selectors
- Always pass accessible names with `getByRole` for specificity
- Use auto-retrying semantic assertions (`toBeChecked`, `toBeVisible`, `toHaveCount`)
- Avoid anti-patterns: `waitForTimeout`, CSS class selectors, XPath, ElementHandle API
- Structure tests with proper setup, serial mode for stateful flows, and helper patterns

Includes a locator priority table, assertion comparison chart, and pre-submit checklist.

## Example usage

```
/playwright-e2e write tests for the login flow
```

Or naturally:
- "Write e2e tests for the checkout page"
- "Review my Playwright tests for anti-patterns"
- "Add a test for the search feature"

### Example output

```typescript
test.describe("Login", () => {
  test("shows error for invalid credentials", async ({ page }) => {
    await page.goto("/login");
    await page.getByLabel("Email").fill("bad@example.com");
    await page.getByLabel("Password").fill("wrong");
    await page.getByRole("button", { name: "Sign in" }).click();
    await expect(page.getByText("Invalid credentials")).toBeVisible();
  });
});
```

## Installation

Copy the `playwright-e2e/` directory to your Claude Code skills folder:

```bash
# Global (available in all projects)
cp -r playwright-e2e/ ~/.claude/skills/playwright-e2e/

# Project-specific
cp -r playwright-e2e/ .claude/skills/playwright-e2e/
```

## Files

- `SKILL.md` — The skill prompt with locator priority, assertion patterns, anti-patterns, and checklist
