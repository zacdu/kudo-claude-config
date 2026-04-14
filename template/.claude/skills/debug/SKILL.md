---
name: debug
description: Structured debugging — reproduce, hypothesize, isolate root cause, fix surgically, verify no regressions
wiki_tiers:
  - essential
  - architecture
  - gotchas
---

# Debug Workflow

> {{LANGUAGE}} / {{PROJECT_NAME}}
> Methodical, evidence-driven, zero guesswork.

---

## Phase 1: Reproduce & Scope

### 1.1 — Bug Report

Extract/confirm:

| Field | |
|-------|-|
| **Symptoms** | What user sees |
| **Expected** | Correct behavior |
| **Trigger** | Repro steps/conditions |
| **Frequency** | Always/sometimes/once? Pattern? |
| **Regression?** | Worked before? What changed? |
| **Severity** | Red: Crash/data-loss, Yellow: Wrong behavior, Green: Cosmetic |

Unclear → ask before proceeding.

### 1.2 — Blast Radius

ID modules possibly involved. Preliminary — Phase 2 narrows.

---

## Phase 2: Investigate

### 2.1 — Read Docs

README.md for every blast-radius module. Manifests, data flow, gotchas.

### 2.2 — Parallel Fan-out

3 agents simultaneously:

**Agent A — Code Path Trace** (`Explore`): From trigger → symptom. Every function, branch, state read/mutated. Flag suspicious code, don't conclude.

**Agent B — State Audit** (`Explore`): Data lifecycle of involved state. Init, mutations, reads, event balance. Check known patterns:
- Cleanup asymmetry — start() without stop(), open() without close()
- Double-injection (any config/transform applied twice on same path)
- Event chain >3 hops
- Resource not released in cleanup block (finally/defer)
- Async operations not properly awaited
- Config field read but not validated

**Agent C — Context** (`general-purpose`): If regression → `git log -20` + `git diff HEAD~5`. Check TODOs/HACKs/BUGs. Verify API usage against official docs.

Wait for ALL agents.

### 2.3 — Synthesize

Classify each finding:

| Class | Meaning |
|-------|---------|
| **Confirmed root cause** | Direct evidence: trigger → symptom |
| **Contributing factor** | Doesn't cause alone, enables/worsens |
| **Red herring** | Provably uninvolved — state why |
| **Uncertain** | Needs deeper evidence |

### 2.4 — Deep Dive (if needed)

For each **Uncertain**: focused `Explore` agent → full file, value lifecycle, edge cases. Repeat until root cause confirmed. **Do NOT proceed without confirmed root cause.**

---

## Phase 3: Diagnose & Plan

No code changes. Present to user:

### 3.1 — Root Cause

1. **Root cause** — exact file, lines, what's wrong, mechanism (trigger → faulty path → symptom)
2. **Teaching moment** — why it was non-obvious, underlying concept

### 3.2 — Proposed Fix

| # | File | Lines | Change | Risk |
|---|------|-------|--------|------|
| 1 | ... | ... | ... | Low/Med/High |

Minimal. Safe. Complete — check same pattern in symmetric/parallel paths.

### 3.3 — Regression Plan

- Original bug no longer reproduces
- Related paths still work
- Build check passes
- Cleanup symmetry preserved

**Get explicit approval before Phase 4.**

---

## Phase 4: Fix

Read `STANDARDS.md` first.

### 4.1 — Execute

1. Independent changes → parallel agents. Sequential for deps.
2. Apply standards: explicit types, cleanup symmetry, canonical patterns from PATTERNS.md, dependency direction, file size limits, update READMEs.
3. Run CLAUDE.md Verify Checklist on all changed files.

### 4.2 — Same-Pattern Sweep

After primary fix, `Grep` for structurally similar code. Same flaw → fix (same bug). No flaw → move on.

---

## Phase 5: Verify

1. CLAUDE.md Verify Checklist — every box. `{{BUILD_CHECK_CMD}}` — 0 errors.
2. Manual verification steps for user: repro original, smoke-test related, try edge cases
3. Summary: root cause, fix, files, same-pattern count, confidence
4. Update memories if new gotcha/pattern discovered

---

## Hard Rules

- **Evidence over intuition** — trace and prove, don't guess
- **No code in Phases 1–3**
- **No drive-by improvements** — fix the bug only
- **Reproduce before fixing** — if can't trace trigger→symptom, haven't found root cause
- **Don't guess APIs** — verify against official docs
