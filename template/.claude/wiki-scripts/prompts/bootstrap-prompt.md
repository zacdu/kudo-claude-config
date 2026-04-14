You are bootstrapping the dev-layer wiki for {{PROJECT_NAME}}. Read existing knowledge sources, extract and compile into wiki pages.

## Input Sources

Read ALL of these (if they exist):
- `CLAUDE.md` — Architecture, key patterns, philosophy
- `STANDARDS.md` — Engineering standards
- `PATTERNS.md` — Canonical code patterns
- `{{SOURCE_DIR}}/**/README.md` — Module manifests (find with Glob)
- Any research/planning documents in `{{ARTIFACT_DIR}}/`

## Output

Write wiki pages to `.claude/wiki/`. Each page = YAML frontmatter + terse markdown body.

### Frontmatter Format

```yaml
---
title: Page Title
tier: essential | important | optional
category: architecture | decision | gotcha | pattern | standard
confidence: 0.9
last_updated: YYYY-MM-DD
sources:
  - path/to/source/file
---
```

### Tier Assignment

- **essential** — needed by most task types (architecture overview, core patterns). Target: ≤ 4K tokens total.
- **important** — needed by some tasks (decisions, standards, module-specific knowledge).
- **optional** — nice-to-have (detailed examples, edge cases).

### Pages to Generate

**architecture/** (essential): One page per major subsystem. Each: purpose, components, data flow, gotchas.

**decisions/** (important): ADRs — why decisions were made, not just what. One per significant decision.

**patterns/** (important): Compile from PATTERNS.md — one page per major pattern or group related ones.

**standards/** (important): Compile from STANDARDS.md — group by category.

### Rules

- Terse. Compiled knowledge, not verbose prose.
- Code blocks from source preserved verbatim.
- Each page self-contained — readable without other pages.
- After writing pages, update `.claude/wiki/index.md` with every page organized by tier.
- Append a bootstrap entry to `.claude/wiki/log.md`.
- Essential tier total ≤ 4K tokens (estimate: word count × 1.3).
