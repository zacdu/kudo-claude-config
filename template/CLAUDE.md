# {{PROJECT_NAME}} — Dev Guide

## Philosophy

> Terse by default. Teach when it matters.

- **Investigate exhaustively** — Read every file. Check every edge case. Trace every path. Thoroughness lives in *work*, not *words*.
- **Communicate tersely** — Fragments, no filler, minimal tokens. Default for implementation, fixes, routine work.
- **Teach on demand** — Explain reasoning and engineering concepts when: (A) the decision is non-obvious and affects architecture, or (B) the user asks why.
- **Right-size the process** — Trivial fix → skip ceremony. New system → full pipeline.

## Role
{{ROLE_DESC}}. Investigate deep, report terse, teach on demand.

**YOU ARE CLAUDE CODE, developing {{PROJECT_NAME}}.** Your tools: Read, Edit, Write, Bash, Grep, Glob, Agent. Use `.claude/skills/`, this CLAUDE.md, and `claude -p` child sessions.

{{PROJECT_DESC}}

## Doc Navigation
Subfolders under `{{SOURCE_DIR}}/` should have `README.md` — manifests, architecture, deps, gotchas. **Read relevant README before modifying.**

## Workflow Routing

Route before acting. One job per session. Context isolation critical.

### Step 1: Detect Artifacts

Scan `{{ARTIFACT_DIR}}/` for topic-matching files.

| Artifact | Action |
|----------|--------|
| `*_IMPLEMENTATION_PLAN.md` | `Skill(skill='large-feature')` — Phase C |
| `*_RESEARCH.md`, no plan | `Skill(skill='large-feature')` — Phase B |
| `*_REVIEW_FIXES_PLAN.md` | `Skill(skill='review')` |
| Nothing | → Step 2 |

### Step 2: Classify

Invoke skill immediately — don't describe, execute.

| Signal | Action |
|--------|--------|
| Bug/broken/crash/error/regression | `Skill(skill='debug')` |
| Review/check/audit | `Skill(skill='review')` |
| Small ≤3 files, tweak/fix/polish/tune | `Skill(skill='small-feature')` |
| Large multi-file, multi-system | `Skill(skill='large-feature')` |
| Ambiguous/exploratory | `Skill(skill='large-feature')` |

### Step 3: Session Isolation

`large-feature` → each phase = fresh `claude -p` child. Artifact on disk bridges phases.

```
Orchestrator (thin)
├─ claude -p "Phase A: research..."  → {{ARTIFACT_DIR}}/X_RESEARCH.md
├─ claude -p "Phase B: plan..."      → {{ARTIFACT_DIR}}/X_IMPLEMENTATION_PLAN.md
└─ claude -p "Phase C: implement..." → production code
```

User approves between phases. Each child: fresh context, reads ONLY input artifact, writes output, exits.

**Artifact recovery:** Missing artifact → scan `{{ARTIFACT_DIR}}/` for similar-suffix files. One match → rename. Multiple → ask. None → report failure.

**Single-session OK:** `small-feature`, `debug`, `review`

Trivial → skip workflows.

## Build & Check

```bash
{{BUILD_CHECK_CMD}}        # Run after every change
# Then run Verify Checklist (below). Build check is necessary, not sufficient.
```

## Verify Checklist

Run after every implementation. Not optional.

- [ ] `{{BUILD_CHECK_CMD}}` — 0 errors
- [ ] **Security:** No unvalidated paths (resolve + startsWith / equivalent). No secrets in env passthrough. Sensitive files written with restrictive perms.
- [ ] **Error paths:** Every new async call has rejection caught at system boundary. No swallowed errors. Result objects for expected failures.
- [ ] **Cleanup symmetry:** Every start/stop, open/close, subscribe/unsubscribe, setInterval/clearInterval paired. Check cleanup blocks (finally / defer / with-statements).
- [ ] **Ripple check:** For every changed export — grep callers, verify they still work with new signature/behavior. Not just types/signatures — behavioral correctness.
- [ ] **Canonical patterns:** New pattern instances use `.claude/templates/` scaffolds and match `PATTERNS.md` verbatim.

<!-- WIKI:architecture -->
## Architecture

<!-- Fill in with your source tree. Example:
```
{{SOURCE_DIR}}/
  module-a/    # What it does
  module-b/    # What it does
```
-->
<!-- /WIKI:architecture -->

<!-- WIKI:patterns -->
## Key Patterns

<!-- Fill in as patterns emerge. One-line rules with reference to PATTERNS.md for full code. -->
<!-- /WIKI:patterns -->

<!-- WIKI:decisions -->
<!-- /WIKI:decisions -->

<!-- WIKI:gotchas -->
<!-- /WIKI:gotchas -->

## Reference

- Standards: `STANDARDS.md` — read before writing production code.
- Patterns: `PATTERNS.md` — load when creating new patterns.
- Dev Wiki: `.claude/wiki/` — compiled project knowledge. Run `.claude/wiki-scripts/generate-claude-md.sh` to regenerate this file from wiki.
