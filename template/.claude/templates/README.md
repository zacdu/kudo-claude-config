# Code Templates

Scaffold files referenced by skills when creating new modules. Start here, don't invent.

The two TypeScript examples are kept as a baseline. For other languages, replace with equivalent scaffolds (e.g. `module.py.template`, `module.go.template`). Keep the spirit: one primary export per file, types near top, public API, helpers at bottom.

## Adding a template

1. Create `<name>.<ext>.template`.
2. Use `{{DoubleMustache}}` placeholders for names Claude will fill in.
3. Reference it from `STANDARDS.md` and any skill that creates files of that type.

## Rules for scaffolds

- Small (< 50 lines). Scaffolds show structure, not content.
- Placeholders are obvious nouns (`{{ModuleName}}`, `{{PrimaryType}}`), not cryptic.
- Include section markers (`// ── Types ──`) so readers can navigate partially-filled files.
