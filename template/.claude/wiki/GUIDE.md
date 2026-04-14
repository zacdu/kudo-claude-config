# Dev Wiki — Usage Guide

> Compiled project knowledge that persists across Claude Code sessions.

## What This Wiki Is

Compiled knowledge that every session starts with, via CLAUDE.md. Architecture, decisions, gotchas, patterns — compiled once, reused forever.

Two jobs:
1. **Prevents knowledge re-derivation** — injected into CLAUDE.md automatically
2. **Compounds learning** — each session can deposit knowledge for future sessions

## Daily Workflow

### Starting a Session

Wiki content flows into CLAUDE.md automatically after `generate-claude-md.sh` runs. Just start working.

### During a Session

**Discover something worth preserving?** Note it — ingest after session to avoid context pollution.

- Architecture insight → `wiki/architecture/`
- "This broke because..." → `wiki/gotchas/`
- "We chose X over Y because..." → `wiki/decisions/`
- "This pattern works well" → `wiki/patterns/`

### After a Session

**Research/plan produced?**
```bash
./.claude/wiki-scripts/ingest-artifact.sh {{ARTIFACT_DIR}}/YOUR_ARTIFACT.md
```

**Wiki changed?**
```bash
./.claude/wiki-scripts/generate-claude-md.sh
```

## Scripts Reference

| Script | When | What |
|--------|------|------|
| `bootstrap.sh` | First-time / full rebuild | Scans codebase → generates all wiki pages |
| `generate-claude-md.sh` | After wiki changes | Compiles wiki → CLAUDE.md dynamic sections |
| `ingest-artifact.sh <path>` | After artifact approval | Extracts knowledge from research/plan docs |
| `lint.sh` | Periodically | Reports stale pages, orphans, missing coverage |

## Page Tiers

| Tier | What | Injected when |
|------|------|---------------|
| **essential** | Architecture overview, core structure | Every session via CLAUDE.md |
| **important** | ADRs, patterns, standards | Most sessions via CLAUDE.md |
| **optional** | Examples, edge cases | On demand |

## Page Format

```markdown
---
title: Descriptive Title
tier: essential | important | optional
category: architecture | decision | gotcha | pattern | standard
confidence: 0.9
last_updated: YYYY-MM-DD
sources:
  - {{SOURCE_DIR}}/path/to/file
  - {{ARTIFACT_DIR}}/SOME_RESEARCH.md
---

Terse compiled knowledge.
```

## What Makes a Good Wiki Page

- **Terse** — compiled knowledge, not verbose explanation
- **Self-contained** — readable without other pages
- **Sourced** — `sources:` enables staleness lint
- **Actionable** — reader knows what to do differently

**Good:** "Subprocesses must be killed in finally blocks — leaked processes consume resources indefinitely."
**Bad:** "It is generally recommended that one should consider ensuring subprocesses are properly terminated..."

## Memory vs Wiki

| | Memory (`~/.claude/.../memory/`) | Wiki (`.claude/wiki/`) |
|---|---|---|
| **What** | Preferences, user corrections | Compiled project knowledge |
| **Lifecycle** | Quick save, rarely updated | Actively maintained, linted |
| **Structure** | Flat files | Categorized + index + frontmatter |
| **When** | "User prefers X" | "Architecture works like X, because Y" |

When memory contains compilable knowledge, extract to wiki page.
