---
name: review
description: Review code changes for bugs, API contract violations, and engineering standard violations
wiki_tiers:
  - essential
  - patterns
  - standards
  - decisions
---

# Code Review

> {{LANGUAGE}} / {{PROJECT_NAME}}
> Thorough, accurate, zero speculation.

Philosophy: Working code is 50% done. Other half: strict adherence to Engineering Standards.

No code changes until Phase 3.

---

## Phase 1: Research

### 1.1 — Gather Diff

`git diff --no-color > /tmp/review_diff.txt` (or `--cached`). Read full diff. Map touched files/modules.

### 1.2 — Parallel Research

3 agents simultaneously:

**Agent A — Docs** (`Explore`): All relevant READMEs. Report architecture, data flow, lifecycle, gotchas.

**Agent B — API Verify** (`general-purpose`): Every external API usage in diff → fetch docs, verify signatures, lifecycle, contracts.

**Agent C — Source** (`Explore`): Every touched file IN FULL. Report behavior, data flow, callers, consumers, pre-existing bugs.

Wait for all agents.

---

## Phase 2: Discuss

Present findings, teach reasoning, build action plan.

### 2.1 — Review Report

**Bug Categories (by severity):**
1. Logic errors — wrong behavior, state transitions, off-by-one
2. Resource leaks — processes/connections/handles not released in cleanup blocks
3. Async errors — unhandled rejections, race conditions, missing await
4. Null/undefined/nil guards — missing checks on optional fields
5. API contract violations — verified against docs
6. Unhandled async rejection — new async call without error boundary at call site or system boundary
7. Missing result objects — expected failures using throw instead of `{ success, error }`
8. Cleanup asymmetry — start/stop, open/close, subscribe/unsubscribe diverged
9. Double-application of transforms/config on same path
10. Event chain depth >3 hops
11. Dependency direction violation
12. Template variable resolution — unresolved `{{vars}}` reaching output or file paths

**Standard Violations (per `STANDARDS.md`):**
1. Missing explicit types on public API
2. Escape hatches (`any`, `!`, `unsafe`) without justified comment
3. File size limits exceeded
4. Naming convention violations
5. Dead code
6. Circular import risk

**Per finding:** file+lines+code, **why** it's a problem, severity (Red: Bug / Yellow: Standard / Green: Suggestion), minimal fix proposal.

### 2.2 — Teach & Discuss

Explain reasoning. Answer questions. Flag anything <90% confidence.

### 2.3 — Fixes Plan

Create `{{ARTIFACT_DIR}}/{topic}_REVIEW_FIXES_PLAN.md`:

```markdown
# {Topic} Review Fixes Plan
## Agreed Changes
| # | Severity | File(s) | Description | Depends On |
|---|----------|---------|-------------|------------|
## Declined/Deferred
| # | Reason | Description |
|---|--------|-------------|
## Lessons Learned
```

Mark dependencies for parallel execution. Proceed only after **explicit approval**.

---

## Phase 3: Execute

Implement approved fixes only.

### 3.1 — Parallel Execution

Group by independence (Depends On column). Independent → parallel agents. Dependent → sequential. Aggregate and resolve conflicts.

### 3.2 — Standards

Run CLAUDE.md Verify Checklist against all changed files. Report violations as Yellow findings.

### 3.3 — Verify

`{{BUILD_CHECK_CMD}}` — 0 errors. Report summary.

---

## Hard Rules

- **No speculative findings** — code evidence or verified docs only
- **No skipping API research**
- **Report pre-existing bugs** if discovered
- **Cross-cutting: list every call site, verify each** — "first path correct, rest missed" is #1 recurring bug
