You are generating CLAUDE.md from the wiki template and wiki pages.

## Process

1. Read `.claude/wiki-scripts/claude-md-template.md` — this is the template with static sections + `<!-- WIKI:X -->` markers.
2. Read `.claude/wiki/index.md` — find all pages by tier.
3. Read all essential + important tier wiki pages.
4. For each marker pair (`<!-- WIKI:X -->` ... `<!-- /WIKI:X -->`):
   - **architecture**: Compile from `wiki/architecture/*.md` — subsystem tree + descriptions.
   - **patterns**: Compile from `wiki/patterns/*.md` — summary bullets, reference PATTERNS.md for full code.
   - **decisions**: Compile from `wiki/decisions/*.md` — one bullet per decision with rationale.
   - **gotchas**: Compile from `wiki/gotchas/*.md` — one bullet per gotcha. Empty if no pages.
5. Write the completed file to `CLAUDE.md`.

## Rules

- Static sections (everything outside WIKI markers) must be preserved VERBATIM — do not edit philosophy, role, routing, build, verify, or reference sections.
- Wiki-compiled sections: terse, compiled knowledge. Not verbose prose.
- Total CLAUDE.md ≤ 250 lines.
- Markers (`<!-- WIKI:X -->`) must remain in the output so future regeneration works.
- If a wiki category has no pages, leave the markers with empty content between them.
