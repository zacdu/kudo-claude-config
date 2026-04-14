# Wiki Scripts

Wiki lifecycle automation for {{PROJECT_NAME}}. All scripts = thin `claude -p` wrappers.

## Scripts

| Script | Purpose | When to run |
|--------|---------|-------------|
| `bootstrap.sh` | Scan codebase → generate initial wiki pages | First-time setup, or full rebuild |
| `generate-claude-md.sh` | Compile wiki → CLAUDE.md (hybrid: static template + wiki sections) | After wiki content changes |
| `ingest-artifact.sh <path>` | Extract wiki-worthy knowledge from completed research/plan artifact | After artifact approval |
| `lint.sh` | Health check: stale pages, orphans, missing coverage, broken refs | Periodically, or before wiki regeneration |

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
