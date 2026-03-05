---
name: playwright-e2e
description: Write Playwright e2e tests with semantic selectors and accessibility-first assertions. Use when creating or modifying e2e tests (*.spec.ts files using Playwright).
---

# E2E Test (Playwright)

Guide for writing reliable, accessible Playwright e2e tests.

## When to Use

- Creating new Playwright e2e test files (`*.spec.ts`)
- Modifying existing e2e tests
- Reviewing e2e test code for best practices

## Locator Priority

Always prefer locators higher in this list. Drop to the next level only when the one above cannot express what you need.

| Priority | Locator | When to use |
|----------|---------|-------------|
| 1 | `getByRole('button', { name: 'Submit' })` | Interactive elements with accessible roles |
| 2 | `getByLabel('Email')` | Form fields with associated labels |
| 3 | `getByPlaceholder('Search...')` | Inputs that only have placeholder text |
| 4 | `getByText('Welcome')` | Non-interactive text content |
| 5 | `getByTestId('diff-insert-text')` | Elements without semantic roles (last resort) |

### Role + Name Rule

Always pass the accessible name when using `getByRole`:

```typescript
// Good — targets a specific button
page.getByRole("checkbox", { name: "Terms" });

// Bad — ambiguous if multiple buttons exist
page.getByRole("checkbox");
```

Bare `getByRole` (without `{ name }`) is acceptable only when the test asserts count or the role is unique in scope:

```typescript
// Acceptable — asserting total count, not targeting one element
await expect(page.getByRole("checkbox")).toHaveCount(2);
```

## Semantic Assertions

Use Playwright's built-in semantic assertions instead of checking attributes or booleans manually.

| Use this | Instead of |
|----------|------------|
| `await expect(loc).toBeChecked()` | `expect(await loc.isChecked()).toBe(true)` |
| `await expect(loc).not.toBeChecked()` | `expect(await loc.getAttribute("data-checked")).toBe("false")` |
| `await expect(loc).toBeDisabled()` | `expect(await loc.getAttribute("disabled")).not.toBeNull()` |
| `await expect(loc).toBeVisible()` | `expect(await loc.isVisible()).toBe(true)` |
| `await expect(loc).toHaveCount(3)` | `expect(await loc.count()).toBe(3)` |
| `await expect(loc).toHaveText("hi")` | `expect(await loc.textContent()).toBe("hi")` |
| `await expect(loc).toBeHidden()` | manual visibility checks |

Semantic assertions auto-retry until timeout — manual checks do not.

## Anti-Patterns

### Never use these

| Pattern | Why | Fix |
|---------|-----|-----|
| CSS class selectors (`.btn-primary`, `#submit`) | Fragile — classes change with styling | Use `getByRole` or `getByTestId` |
| XPath | Hard to read and maintain | Use Playwright locators |
| `waitForTimeout(ms)` | Flaky — arbitrary delays | Use `toBeVisible()` or `toBeHidden()` |
| `expect(await loc.isChecked()).toBe(true)` | No auto-retry, races | Use `await expect(loc).toBeChecked()` |
| `page.$(selector)` / `page.$$(selector)` | ElementHandle API, no auto-wait | Use `page.locator(selector)` |

### Acceptable exceptions

These selectors are fine when semantic alternatives don't exist:

| Selector | Reason |
|----------|--------|
| `.ProseMirror` | ProseMirror framework convention for editor root |
| `[cmdk-root]` | cmdk library renders this attribute; no ARIA role available |
| Tag selectors (`ol`, `table`) | Asserting specific HTML structure when roles don't distinguish |

## Test Structure

### Basic test setup

```typescript
import { test, expect } from "@playwright/test";

test.describe("MyFeature", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("http://localhost:YOUR_PORT/");
  });

  test("does something", async ({ page }) => {
    // Use semantic locators
    await page.getByRole("button", { name: "Submit" }).click();
    await expect(page.getByText("Success")).toBeVisible();
  });
});
```

### Serial mode

Use `test.describe.configure({ mode: "serial" })` when tests share state within a describe block:

```typescript
test.describe("Stateful flow", () => {
  test.describe.configure({ mode: "serial" });

  test("step 1 — create item", async ({ page }) => { /* ... */ });
  test("step 2 — edit item", async ({ page }) => { /* ... */ });
});
```

### Helper patterns

Extract reusable selectors into helper functions at the top of the describe block:

```typescript
const menuIsOpen = () => page.locator("[cmdk-root]");

const selectCommand = async (filter: string) => {
  await page.keyboard.type(filter);
  await page.keyboard.press("Enter");
};
```

## Running E2E Tests

```bash
# Run all e2e tests
npx playwright test

# Run a specific spec file
npx playwright test src/e2e/my-feature.spec.ts

# Run in headed mode (visible browser)
npx playwright test --headed

# Debug a specific test
npx playwright test --debug src/e2e/my-feature.spec.ts
```

## Checklist

Before considering e2e tests complete:

- Locators prefer `getByRole` > `getByLabel` > `getByPlaceholder` > `getByText` > `getByTestId`
- `getByRole` calls include `{ name }` unless asserting count or role is unique in scope
- Assertions use semantic matchers (`toBeChecked`, `toBeVisible`, `toHaveCount`) — no manual boolean checks
- No `waitForTimeout()` — use auto-retrying assertions instead
- No CSS class or ID selectors unless they fall under acceptable exceptions
- Tests pass: `npx playwright test`
