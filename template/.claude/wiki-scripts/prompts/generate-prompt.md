You are generating CLAUDE.md from the wiki template and wiki pages.

## Process

1. Read `.claude/wiki-scripts/claude-md-template.md` — this is the template with static sections + `<!-- WIKI:X -->` markers.
2. Read `.claude/wiki/index.md` — find all pages by tier.
3. Read all essential + important tier wiki pages ONLY. Skip optional tier — it must never be injected into CLAUDE.md.
4. For each marker pair (`<!-- WIKI:X -->` ... `<!-- /WIKI:X -->`) present in the template:
   - **architecture**: Compile from `wiki/architecture/*.md` (essential/important only) — subsystem tree + descriptions. Keep any existing diagram, update descriptions if wiki has richer info.
   - **patterns**: Compile from `wiki/patterns/*.md` (essential/important only) — summary bullets, reference PATTERNS.md for full code. Preserve ALL items under "Critical Rules" verbatim — do not drop or paraphrase bullets.
   - **decisions**: Compile from `wiki/decisions/*.md` (essential/important only) — one bullet per decision with rationale.
   - **gotchas**: Compile from `wiki/gotchas/*.md` (essential/important only) — one bullet per gotcha. NEVER invent gotchas from source code. If no gotcha pages exist, leave section empty with a comment.
   - If the template has no marker for a category, do NOT inject that category. Markers absent from the template = intentionally excluded.
5. Write the completed file to `CLAUDE.md`.

## Rules

- Static sections (everything outside WIKI markers) must be preserved VERBATIM — do not edit philosophy, role, routing, build, verify, or reference sections.
- Wiki-compiled sections: terse, compiled knowledge. Not verbose prose.
- Total CLAUDE.md ≤ 250 lines.
- Markers (`<!-- WIKI:X -->`) must remain in the output so future regeneration works.
- If a wiki category has no pages, leave the markers with empty content between them.
