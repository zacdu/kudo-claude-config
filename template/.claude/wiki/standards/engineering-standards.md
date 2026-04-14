---
title: Engineering Standards
tier: important
category: standard
confidence: 0.9
last_updated: <!-- YYYY-MM-DD -->
sources:
  - STANDARDS.md
---

## Linter-Enforced (automatic)

Fill in from your linter config. Typical: no dead code, no escape hatches without comment, dependency direction, file/function size limits.

## Manual Standards (linter can't catch)

| Standard | Rule |
|----------|------|
| Cleanup symmetry | Every start/stop, open/close, subscribe/unsubscribe paired |
| Result objects | Expected failures → `{ success, error? }`, not exceptions |
| Immutable default | Readonly / frozen / const. Copy over mutate. |
| Self-contained files | Each understandable with itself + imports + folder README |
| Event chains | ≤3 hops. Deeper → refactor to direct call |
| No circular imports | Extract shared types to a types module |
| READMEs current | Update on add/remove/rename |

## Templates

New files from `.claude/templates/`. Canonical forms only.
