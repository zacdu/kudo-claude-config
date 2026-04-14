---
title: "ADR: Context Isolation"
tier: important
category: decision
confidence: 0.95
last_updated: <!-- YYYY-MM-DD -->
sources:
  - CLAUDE.md
---

## Decision

Each pipeline phase gets a fresh `claude -p` session with its own context window. No shared context between phases.

## Why

- Cross-phase context contamination degrades reasoning quality. Research context pollutes implementation focus.
- Context rot: LLM performance degrades as input tokens increase. Fresh context per phase keeps each window focused.
- Predictable behavior: each phase sees only its input artifact + CLAUDE.md. No hidden state from prior phases.

## Trade-off

Forces knowledge recompilation — each phase must re-derive understanding from artifacts. The wiki system addresses this: compile knowledge once, inject tier-appropriate subsets per phase.

## Consequences

- Artifacts are the ONLY bridge between phases (not memory, not shared state)
- Orchestrator must not do the work inline — always spawn via `claude -p`
- CLAUDE.md is injected into every phase as baseline context
- Phase prompts must be self-contained — can't reference prior conversation
