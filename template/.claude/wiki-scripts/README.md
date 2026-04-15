# Wiki Scripts

Wiki lifecycle automation for {{PROJECT_NAME}}. All scripts = thin `claude -p` wrappers.

## Scripts

| Script | Purpose | When to run |
|--------|---------|-------------|
| `bootstrap.sh` | Scan codebase → generate initial wiki pages | First-time setup, or full rebuild |
| `generate-claude-md.sh` | Compile wiki → CLAUDE.md (hybrid: static template + wiki sections) | After wiki content changes (auto via hook) |
| `ingest-artifact.sh <path>` | Extract wiki-worthy knowledge from one artifact | After artifact approval |
| `ingest-queue.sh [--status\|--skip PATH\|--clear\|--all]` | Batch process queued artifacts | When Stop gate surfaces pending artifacts |
| `lint.sh` | Health check: stale pages, orphans, missing coverage, broken refs | Auto at session end via Stop hook |

## Automation Hooks

Three hooks wire wiki lifecycle into Claude Code (see `.claude/hooks/`). All are POSIX `sh`; `jq` is preferred for JSON parsing and transparently falls back to `sed` if unavailable.

- **`wiki-enqueue.sh`** (PostToolUse) — any Write/Edit of `{{ARTIFACT_DIR}}/*_RESEARCH.md|*_PLAN.md|*_IMPLEMENTATION_PLAN.md` appends the path to `.claude/wiki/.ingest-queue` (deduped under an atomic `mkdir` lock). No LLM.
- **`wiki-generate.sh`** (PostToolUse) — any Write/Edit to a file path under `.claude/wiki/` coalesces into a single background `generate-claude-md.sh` run. Concurrent edits set a dirty flag that the in-flight run drains, so rapid edits never spawn parallel regens or interleave writes to `CLAUDE.md`. All output (including failures) appends to `.claude/wiki/.generate.log`.
- **`wiki-stop-gate.sh`** (Stop) — on session end: auto-prunes missing queue entries; if real pending artifacts exist → blocks Stop once per session and surfaces ingest commands; if queue is empty → surfaces *previous* lint run warnings (if any) and kicks off a fresh lint in the background (lint is LLM-backed and can exceed any reasonable hook timeout, so it never blocks Stop). JSON escaping for the block reason uses an awk-based encoder — no Python dependency. Sentinel `.claude/wiki/.ingest-prompted` prevents loops.

### Sentinel / state files (all git-ignored)

| File | Purpose |
|------|---------|
| `.claude/wiki/.ingest-queue` | Deduped list of pending artifacts |
| `.claude/wiki/.ingest-queue.lock` | Atomic lock (dir) for queue mutations |
| `.claude/wiki/.ingest-prompted` | One-shot sentinel for Stop gate |
| `.claude/wiki/.regen.dirty` | "Regen needed" flag; drained by the in-flight run |
| `.claude/wiki/.regen.lock` | Single-writer lock for `CLAUDE.md` regen |
| `.claude/wiki/.generate.log` | Append-only log of regen runs |
| `.claude/wiki/.lint.lock` | Single-writer lock for background lint |
| `.claude/wiki/.lint.log` | Last lint run's output; surfaced on next Stop |

## Wiki Structure

```
.claude/wiki/
  index.md          — Master catalog (pages by tier)
  log.md            — Append-only activity log
  architecture/     — How {{PROJECT_NAME}} is built
  decisions/        — ADRs: why, not just what
  gotchas/          — Hard-won debugging/implementation knowledge
  patterns/         — Validated code patterns with provenance
  standards/        — Engineering standards with examples
```

## Page Format

YAML frontmatter + markdown body:
- `title`, `tier` (essential/important/optional), `category`, `confidence` (0-1), `last_updated`, `sources`

## Coordination with Claude Code Memory

- **Memory** (`.claude/memory/`) = lightweight preferences, session corrections (built-in, fixed path)
- **Wiki** (`.claude/wiki/`) = compiled persistent knowledge (architecture, decisions, gotchas, patterns)
- Memory stays lightweight. Compilable knowledge → promote to a wiki page.
- `MEMORY.md` cross-references the wiki index where relevant.

## CLAUDE.md Generation

Template: `claude-md-template.md` — static skeleton with `<!-- WIKI:X -->` markers.
Generator reads wiki pages → compiles into marker sections → writes CLAUDE.md.
Static sections (philosophy, role, routing, build, verify) preserved verbatim.
