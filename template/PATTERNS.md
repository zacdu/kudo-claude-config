# {{PROJECT_NAME}} — Canonical Patterns

> Loaded on demand when creating new patterns. Not needed during reviews or planning.

**ONE form per pattern. Use verbatim.** When a new pattern appears in the codebase 3+ times, promote it here in its canonical form.

<!-- Start empty. Add patterns as they stabilize. Structure below is a template. -->

## Example structure

### {Pattern Name}

When to use: {situation}

```{{LANGUAGE_LOWER}}
// Canonical form — copy verbatim, adjust only names.
```

Rules:
- {non-obvious invariant 1}
- {non-obvious invariant 2}

---

<!-- Recommended first patterns to capture (if applicable):

- **Error Result** — expected failure returns structured result, not exception
- **Resource Lifecycle** — start/prompt/wait in try, stop in finally
- **Config Validation** — bounds + type guards, fail fast with descriptive error
- **Async Cleanup** — setInterval/clearInterval, listener/removeListener paired in all exit paths
-->
