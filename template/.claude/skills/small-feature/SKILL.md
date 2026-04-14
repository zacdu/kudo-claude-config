---
name: small-feature
description: Lightweight workflow for small refinements — tweaks, config changes, prompt tuning, single-module changes
wiki_tiers:
  - essential
  - patterns
---

# Small Feature / Refinement

For changes touching few files, refining existing systems, no deep research needed.

## Phase A — Quick Research

**Output**: Findings in chat (no doc unless complexity surprises).

0. Read relevant `README.md` (per-folder docs first).
1. **Parallel scan** — 2 `Explore` agents:
   - Agent 1: Read primary files — current behavior, data flow
   - Agent 2: Read callers, subscribers, consumers — ripple risks
   Consult external API/library docs if relevant — don't guess.
2. Summarize: what exists, what changes, risks.
3. Surface ambiguities. If clear, propose plan.

## Phase B — Mini Plan

**Output**: Plan in chat (no doc). Skip if obvious.

1. List: files to modify/create, types, acceptance criteria. Mark independent files.
2. Flag risks: dependency direction violations, lifecycle mismatches, event chain hops.
3. Get go-ahead.

## Phase C — Implement

Read `STANDARDS.md` first.

1. **Independent files in parallel** agents. Sequential only for deps.
2. `{{BUILD_CHECK_CMD}}` → summarize.
3. Scope beyond ~3 files → pause, discuss.
4. **CLAUDE.md Verify Checklist** — every box. Plus:
   - Grep callers of changed exports — behavioral correctness
   - Trace error path of every new async call
5. `{{BUILD_CHECK_CMD}}` final verify.
6. Update memories if architecturally notable.
