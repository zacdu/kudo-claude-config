---
name: large-feature
description: End-to-end workflow for large, new feature development — deep research with case studies, structured planning, phased implementation
wiki_tiers:
  - essential
  - architecture
  - decisions
  - patterns
  - standards
---

# Large Feature Development

New territory, many files, or benefits from studying prior art.

**Context isolation:** Each phase = own session. Artifact on disk bridges phases.

---

## Session Modes

### Orchestrator Mode (default — interactive, no artifacts exist)

**CRITICAL: You are the orchestrator. You do NOT do research, planning, or implementation yourself. You MUST spawn child sessions via `claude -p`. This is non-negotiable — context isolation between phases is the core architecture.**

1. **Derive TOPIC_KEY** from description (e.g. "user auth" → `USER_AUTH`). UPPER_SNAKE. Confirm with user.
2. **Scan `{{ARTIFACT_DIR}}/`** for existing `{KEY}_RESEARCH.md` / `{KEY}_IMPLEMENTATION_PLAN.md`. Skip completed.
3. **Spawn each phase via Bash tool** — use `run_in_background: true`, `timeout: 600000`:

   **Phase A:** `claude -p "<phase A prompt with TOPIC/KEY>" --permission-mode acceptEdits`
   **Phase B:** `claude -p "<phase B prompt referencing {{ARTIFACT_DIR}}/<KEY>_RESEARCH.md>" --permission-mode acceptEdits`
   **Phase C:** `claude -p "<phase C prompt referencing {{ARTIFACT_DIR}}/<KEY>_IMPLEMENTATION_PLAN.md>" --permission-mode acceptEdits`

4. After each child exits: read the artifact from `{{ARTIFACT_DIR}}/`, present 3–5 bullet summary, **ask user approval before next phase**. Child fails → report, ask user. No auto-retry.

**How to verify isolation:** The child's output appears in the Bash tool result. Your own context label should NOT grow significantly during a child phase — if it does, you're doing the work inline instead of spawning. Stop and spawn.

### Direct Phase Mode (artifacts exist)

Router detected artifacts → this session IS the worker. Execute phase directly.

---

## Phase A — Research

**Input**: Feature description + codebase. **Output**: `{{ARTIFACT_DIR}}/<TOPIC>_RESEARCH.md`

0. Parallel `Explore` agents per relevant module → read README.md, report manifests/deps/gotchas.
1. **Research doc structure:** Scope (1-paragraph + TOC) → Theory (core tension, solution landscape) → Case Studies (3–6, parallel agents, each: architecture, decisions, pros/cons, lessons for {{PROJECT_NAME}}) → Tech Details (consult external API docs — don't guess) → Comparison Matrix → Current State Audit (parallel agents, exists vs missing) → Proposed Design (ASCII diagrams, types) → Open Questions → Appendices.
2. Present, surface top questions.

**SESSION END:** Do NOT proceed to Phase B.

---

## Phase B — Plan

**Input**: `{{ARTIFACT_DIR}}/<TOPIC>_RESEARCH.md` **Output**: `{{ARTIFACT_DIR}}/<TOPIC>_IMPLEMENTATION_PLAN.md`

1. Read research doc — internalize scope, design, questions, audit.
2. Resolve open questions — recommend with reasoning.
3. Write phased plan — files, types, decisions, acceptance criteria. **Mark independent files per phase.**
4. Phase 0 = types/interfaces. Early phases = vertical slice. Each phase = passing build check.
5. Get explicit go-ahead.

**SESSION END:** Do NOT proceed to Phase C.

---

## Phase C — Implement

**Input**: `{{ARTIFACT_DIR}}/<TOPIC>_IMPLEMENTATION_PLAN.md` **Output**: Production code.

**Fresh context:**
- Read `STANDARDS.md` + `PATTERNS.md` first.
- Read plan file — single source of truth.
- Read ONLY plan-listed codebase files.
- Plan wrong → stop, tell user. No silent deviation.
- Check ✅ marks — resume from first unmarked phase.

**Per phase:**
1. Announce → identify independent files → parallel Agent writes → `{{BUILD_CHECK_CMD}}` → summarize → **mark ✅ in plan**.
2. Minor discoveries: inline. Major: pause, discuss, update plan.
3. **Verify per phase** — run CLAUDE.md Verify Checklist. Additionally:
   - Grep callers of every changed export — behavioral correctness, not just type compat
   - Trace error path of every new async call — rejection must reach system boundary
   - If phase adds new async resource (interval, listener, child process): verify cleanup in all exit paths including error/abort

**Completion:**
1. Full CLAUDE.md Verify Checklist — every box. `{{BUILD_CHECK_CMD}}` — 0 errors.
2. Walk acceptance criteria from plan.
3. User confirms → delete plan docs (keep research). Update memories.
