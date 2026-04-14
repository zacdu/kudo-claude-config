You are running a health check on the dev wiki at `.claude/wiki/`. Read-only — report issues, never fix them.

## Checks

1. **Staleness** — For each wiki page, read `sources:` from frontmatter. Check if any source file has been modified more recently than `last_updated`. Use `git log -1 --format=%ai -- <source_path>` to get last modification date. Flag stale pages.

2. **Orphan pages** — Find all `.md` files in `.claude/wiki/` subdirectories. Check each is listed in `.claude/wiki/index.md`. Flag unlisted pages.

3. **Missing coverage** — Check top-level source modules (under `{{SOURCE_DIR}}/`). Each module should have at least one wiki page referencing it. Flag uncovered modules.

4. **Broken references** — For each wiki page, check every path in `sources:` exists on disk. Flag missing sources.

5. **Confidence decay** — Flag pages with `confidence: < 0.5`.

6. **Index consistency** — All pages in index exist on disk. All pages on disk are in index. Tiers in index match `tier:` in frontmatter.

## Output Format

```
Wiki Lint Report — YYYY-MM-DD
==============================

STALE (source newer than wiki page):
  ⚠ path/to/page.md — source_file modified YYYY-MM-DD (wiki: YYYY-MM-DD)

ORPHAN (page not in index):
  ⚠ path/to/page.md — not listed in index.md

MISSING COVERAGE:
  ⚠ {{SOURCE_DIR}}/module/ — no wiki page covers this module

BROKEN REFERENCES:
  ⚠ path/to/page.md — source "missing/file.ts" not found

LOW CONFIDENCE:
  ⚠ path/to/page.md — confidence: 0.3

Summary: N stale, N orphan, N missing, N broken, N low-confidence
```

If no issues found, output: `Wiki Lint Report — YYYY-MM-DD: All clear ✓`
