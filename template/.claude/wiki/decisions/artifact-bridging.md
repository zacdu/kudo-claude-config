---
title: "ADR: Artifact Bridging"
tier: important
category: decision
confidence: 0.95
last_updated: <!-- YYYY-MM-DD -->
sources:
  - CLAUDE.md
---

## Decision

Phases communicate exclusively through filesystem artifacts in `{{ARTIFACT_DIR}}/`. No in-memory state, no IPC, no shared database.

## Why

- Supports context isolation — each phase reads one input file, writes one output file
- Artifacts are inspectable — user can review, edit, approve between phases
- Artifacts are resumable — a partial run can restart from any completed phase
- Git-trackable — artifact history shows pipeline evolution

## Implementation

- Topic keys: UPPER_SNAKE, derived from feature name
- Naming convention: `{KEY}_RESEARCH.md`, `{KEY}_IMPLEMENTATION_PLAN.md`, `{KEY}_REVIEW_FIXES_PLAN.md`
- Recovery: missing artifact → scan `{{ARTIFACT_DIR}}/` for similar suffix → rename or ask

## Consequences

- Everything serializes to markdown — no binary artifacts
- `{{ARTIFACT_DIR}}/` must be inside project root (security)
- Phase output must be self-contained — next phase reads ONLY the artifact + CLAUDE.md
