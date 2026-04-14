---
title: "ADR: Terse by Default"
tier: important
category: decision
confidence: 0.95
last_updated: <!-- YYYY-MM-DD -->
sources:
  - CLAUDE.md
---

## Decision

Default communication style = terse. Teach only on demand. Token economy is a first-class constraint.

## Why

- Token cost scales with verbosity — terse output = cheaper, faster phases
- Users who need explanations get them via opt-in (question words, "explain", "why")
- Terse output is more actionable — less noise, faster scanning

## Implementation

- Skills default to short fragments
- CLAUDE.md itself written terse — practices what it preaches
- Teaching surfaces only when: (A) non-obvious architecture decision, or (B) user asks

## Consequences

- All dev communication defaults to fragments, no filler
- Wiki pages written terse — compiled knowledge, not prose
