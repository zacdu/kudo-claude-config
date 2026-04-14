You are extracting wiki-worthy knowledge from a completed artifact into the dev wiki at `.claude/wiki/`.

## Process

1. Read the artifact file (path provided below).
2. Read `.claude/wiki/index.md` to understand existing pages.
3. Extract durable knowledge by category:
   - Architecture insights → `architecture/` (update existing or create new)
   - Design decisions with rationale → `decisions/` (create ADR)
   - Gotchas, pitfalls, things that broke → `gotchas/` (create)
   - Validated patterns → `patterns/` (update with provenance)
   - Failed approaches → `gotchas/` with "antipattern" note
4. For each extraction: check if an existing wiki page covers this topic → update in-place (don't duplicate).
5. Update `.claude/wiki/index.md` with any new pages.
6. Append to `.claude/wiki/log.md`.

## Page Format

```yaml
---
title: Page Title
tier: essential | important | optional
category: architecture | decision | gotcha | pattern | standard
confidence: 0.8
last_updated: YYYY-MM-DD
sources:
  - path/to/artifact
---
```

## Rules

- Extract DURABLE knowledge only — not task-specific details or temporary state.
- Terse. Compiled knowledge, not prose.
- Deduplicate — if existing page covers same topic, update it rather than creating new.
- Preserve existing page content when updating — merge, don't replace.
- New gotchas and decisions are typically "important" tier.
- Architecture pages that change core understanding should be "essential" tier.
- Update index.md Stats section (page count, date, token estimates).
