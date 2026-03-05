---
name: useeffect-review
description: Reviews React code for correct useEffect usage. Use when reviewing React components, checking for useEffect anti-patterns, or deciding whether useEffect is appropriate for a given use case.
---

# useEffect Review

Reviews React code for correct useEffect usage based on official React documentation and team guidelines.

## Core Principle

**useEffect is for synchronizing with external systems, not for reacting to state changes.** Before adding a useEffect, ask: "Am I connecting to something outside React?"

## When useEffect is Appropriate

| Use Case               | Example                                         |
| ---------------------- | ----------------------------------------------- |
| Event subscriptions    | `window.addEventListener`, WebSocket, event bus |
| External subscriptions | CRDT `onChange` handlers, real-time databases    |
| Third-party libraries  | Animation libraries, maps, charts               |
| Timers and intervals   | `setTimeout`, `setInterval`                     |
| DOM measurements       | Reading element dimensions after render         |

## Common Anti-Patterns to Flag

| Anti-Pattern                   | Problem                | Solution                     |
| ------------------------------ | ---------------------- | ---------------------------- |
| Computing derived values       | Extra render cycle     | Calculate during render      |
| Expensive calculations         | Extra render cycle     | Use `useMemo`                |
| Resetting state on prop change | Cascading re-renders   | Use `key` prop               |
| Adjusting state based on props | Cascading re-renders   | Derive during render         |
| Responding to user events      | Loses event context    | Use event handlers           |
| Chaining state updates         | Multiple render passes | Update all state together    |
| Notifying parent of changes    | Extra render cycle     | Call parent in event handler |

## Review Checklist

When reviewing useEffect usage, check:

1. **Is this synchronizing with an external system?**
   - YES: useEffect is appropriate
   - NO: Don't use useEffect

2. **Does the effect call setState?**
   - If so, this is probably wrong. The value should likely be:
     - Calculated during render
     - Computed with `useMemo`
     - Updated in an event handler

3. **Does the effect involve async operations?**
   - Must have cleanup with cancelled flag or AbortController

4. **Does the effect set up subscriptions?**
   - Must return a cleanup function

## Required Patterns

### Async Operations Must Have Cleanup

```tsx
// Correct pattern
useEffect(() => {
  let cancelled = false;

  async function load() {
    const result = await fetchData(id);
    if (!cancelled) {
      setData(result);
    }
  }

  load();
  return () => {
    cancelled = true;
  };
}, [id]);
```

### Fetch Must Use AbortController

```tsx
useEffect(() => {
  const controller = new AbortController();

  fetch(url, { signal: controller.signal })
    .then((res) => res.json())
    .then(setData)
    .catch((err) => {
      if (err.name !== "AbortError") {
        setError(err);
      }
    });

  return () => controller.abort();
}, [url]);
```

### Subscriptions Must Return Cleanup

```tsx
useEffect(() => {
  const unsubscribe = eventBus.on("event", handler);
  return unsubscribe;
}, [handler]);
```

## Decision Flowchart

```
Is this synchronizing with an external system?
|
+- YES -> useEffect is appropriate
|   +- Does it involve async operations?
|       +- YES -> Add cleanup (cancelled flag or AbortController)
|       +- NO -> Ensure cleanup for subscriptions
|
+- NO -> Don't use useEffect
    |
    +- Is it derived from props/state?
    |   +- Calculate during render
    |
    +- Is it an expensive calculation?
    |   +- Use useMemo
    |
    +- Is it responding to a user action?
    |   +- Handle in event handler
    |
    +- Does state need to reset when a prop changes?
    |   +- Use key prop on component
    |
    +- Are you chaining multiple state updates?
        +- Update all state in one event handler
```

## References

- https://react.dev/learn/you-might-not-need-an-effect
- https://react.dev/reference/react/useEffect
- https://overreacted.io/a-complete-guide-to-useeffect/
