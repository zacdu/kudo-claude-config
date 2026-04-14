# kudo-claude-config

A reusable Claude Code configuration for software projects. Drop it into any codebase and Claude Code starts working with tighter workflows, durable project knowledge, and a terser communication style.

> **Who this is for:** Engineers already using [Claude Code](https://claude.com/claude-code) who want a batteries-included `.claude/` setup instead of rebuilding skills, hooks, and a wiki from scratch each project.

## What you get

After install, your project has:

```
CLAUDE.md         # Dev guide loaded into every Claude Code session
STANDARDS.md      # Engineering standards (language-agnostic skeleton)
PATTERNS.md       # Canonical code patterns (starts empty, grows with project)
.claude/
  skills/         # /small-feature /large-feature /debug /review — structured workflows
  hooks/          # SessionStart + PostToolUse hooks
  templates/      # File scaffolds (module, types)
  wiki/           # Tiered project knowledge (essential / important / optional)
  wiki-scripts/   # bootstrap / generate / ingest / lint automation
  settings.json   # Permissions + hook wiring
```

**Four skills**, each a structured workflow with context isolation, parallel research, and enforced verification:

| Skill | When to use |
|-------|-------------|
| `small-feature` | Tweaks, refinements, changes touching ≤3 files |
| `large-feature` | New systems, multi-file work — spawns `claude -p` child sessions per phase, bridged by disk artifacts |
| `debug` | Bugs — reproduce → investigate → diagnose → fix → verify, no guessing |
| `review` | Code review — diff + full-file research, API contract checks, fix plan before execution |

**Workflow routing** in CLAUDE.md classifies each request → picks the right skill automatically.

**A dev wiki** that compiles into CLAUDE.md. Knowledge compiled once, injected into every session.

See [Philosophy](#philosophy) below for the worldview this encodes.

---

## Install

Two paths. Pick one.

### Path A — Let Claude Code install it (recommended)

Open Claude Code in the project you want to configure, then paste this to Claude:

> Please install the kudo-claude-config template into this project. The repo is https://github.com/zacdu/kudo-claude-config. Clone it somewhere (e.g. `/tmp/kudo-claude-config`), then run its `init.sh` against the current working directory. I want you to:
>
> 1. Detect the project's language, build command, source directory, and file extension by reading the repo (package.json / pyproject.toml / go.mod / Cargo.toml / README).
> 2. Run `init.sh -y` with the correct flags so it runs non-interactively.
> 3. After install, fill in the Architecture section of `CLAUDE.md` with the project's real source tree, and add any obvious language conventions to `STANDARDS.md`.
> 4. Summarize what was installed and what I should do next.

Claude Code will read this repo, detect your stack, run `init.sh` with the right flags, and hand you a personalized setup. You don't touch the placeholder list.

### Path B — Install it yourself

```bash
git clone https://github.com/zacdu/kudo-claude-config ~/Dev/kudo-claude-config
cd /path/to/your/project
~/Dev/kudo-claude-config/init.sh
```

`init.sh` prompts you for each placeholder, shows a summary, asks for confirmation, then copies files in.

Preview without writing:

```bash
~/Dev/kudo-claude-config/init.sh --dry-run
```

Overwrite an existing install:

```bash
~/Dev/kudo-claude-config/init.sh --force
```

### `init.sh` reference

```
init.sh [target_dir] [flags]

flags:
  -y, --yes            non-interactive; use defaults + provided flags, no prompts/confirm
  --force              overwrite existing CLAUDE.md / STANDARDS.md / PATTERNS.md / .claude/
  --dry-run            list files that would be written, don't write
  -h, --help           show help

values (any subset; anything omitted is prompted or defaulted):
  --name <x>           project name
  --desc <x>           one-line description
  --language <x>       display language (e.g. TypeScript, Python, Go, Rust)
  --role <x>           AI role description (e.g. "Senior Backend Dev")
  --build-cmd <x>      single command run after changes (e.g. "npm run check", "pytest -q", "go vet ./...")
  --ext <x>            primary source file extension (e.g. ".ts", ".py", ".go")
  --artifact-dir <x>   where research/plan artifacts live (default: tmp_docs)
  --source-dir <x>     source root (default: src)
```

Example non-interactive install (this is what a Claude agent will run):

```bash
~/Dev/kudo-claude-config/init.sh -y \
  --name my-api \
  --desc "Payment processing REST API" \
  --language Python \
  --role "Senior Python Backend Dev" \
  --build-cmd "pytest -q && ruff check ." \
  --ext .py \
  --source-dir src \
  /path/to/my-api
```

---

## First session after install

Open Claude Code in the installed project. Try:

- **"Fix the typo in the login error message"** → routes to `small-feature`
- **"The session cookie isn't being cleared on logout"** → routes to `debug`
- **"Review my last three commits"** → routes to `review`
- **"Design a plugin system for third-party integrations"** → routes to `large-feature`

Claude picks the skill based on the signal. You can also invoke explicitly: `/small-feature <task>`, `/debug <bug>`, etc.

### Before your second session (recommended)

Fill in project-specific context so skills have real knowledge to ground in:

1. **CLAUDE.md → Architecture section:** paste in your source tree with one-line descriptions per module.
2. **STANDARDS.md:** add language-specific conventions (the skeleton has placeholders).
3. **Per-module READMEs:** add `README.md` to each folder under `{source-dir}/` describing purpose, dependencies, gotchas. Skills read these first.

Or let Claude do this too — point it at the repo and say "fill in CLAUDE.md and per-module READMEs based on the codebase."

### Optional: bootstrap the wiki

If the project has existing docs (architecture notes, research, plans) and you want them compiled into the wiki:

```bash
./.claude/wiki-scripts/bootstrap.sh
```

This spawns a Claude session that reads your docs and generates tiered wiki pages. After that, regenerate CLAUDE.md to inject the wiki content:

```bash
./.claude/wiki-scripts/generate-claude-md.sh
```

See `.claude/wiki/GUIDE.md` for the full wiki workflow.

---

## What each piece does

### `CLAUDE.md`
Loaded into every Claude Code session automatically. Contains the philosophy, role, workflow routing rules, build command, and verify checklist. The source of truth for how Claude should operate in this project.

### Skills (`.claude/skills/`)
Each skill is a structured multi-phase workflow. They enforce: parallel research agents, explicit planning before code, approval gates between phases, and a verify checklist after. `large-feature` adds context isolation — each phase runs in a fresh `claude -p` subprocess, bridged by artifact files on disk.

### Hooks (`.claude/hooks/`)
- `build-check.sh` — fires after `Edit`/`Write` tool use; if a source file changed, reminds Claude to run the build check.
- `caveman-ultra.sh` — fires at session start; activates the [caveman](https://github.com/...) plugin in ultra-compressed mode for token savings. Remove if you don't use caveman.

### Wiki (`.claude/wiki/`)
Project knowledge tiered as `essential` / `important` / `optional`. Essential is always injected into CLAUDE.md; important goes in too. Pages are YAML-fronted markdown with `sources:` fields so `lint.sh` can detect staleness.

Four wiki scripts:
- `bootstrap.sh` — generate all pages from existing docs (first-time setup)
- `ingest-artifact.sh <path>` — extract durable knowledge from a research/plan artifact
- `generate-claude-md.sh` — compile wiki into CLAUDE.md's `<!-- WIKI:X -->` markers
- `lint.sh` — health check: stale pages, orphans, missing coverage

### Templates (`.claude/templates/`)
Scaffold files referenced by skills when creating new modules. Ship with TypeScript examples; swap in language equivalents as needed (e.g. `module.py.template`).

### Settings (`.claude/settings.json`)
Wires the hooks in and grants the necessary read/bash permissions. `settings.local.json` holds per-user allowances (WebSearch, build commands).

---

## Customize / remove parts

- **Skip the wiki system:** delete `.claude/wiki/` and `.claude/wiki-scripts/`. Nothing else depends on it.
- **Skip caveman mode:** delete `.claude/hooks/caveman-ultra.sh` and remove the `SessionStart` entry from `settings.json`.
- **Change artifact convention:** search-replace `tmp_docs` across `CLAUDE.md` and skill files, update `settings.json` paths if you reference them.
- **Add a skill:** drop a `SKILL.md` in a new `.claude/skills/<name>/` folder with a frontmatter `name:` and `description:`.
- **Add templates for other languages:** put `module.py.template` / `module.go.template` next to the existing `.ts` ones. Reference them from `STANDARDS.md`.
- **Different placeholder values post-install:** no undo helper — edit CLAUDE.md, STANDARDS.md, PATTERNS.md, `settings.json`, and `build-check.sh` by hand. Or nuke `.claude/` + the three root docs and re-run `init.sh`.

---

## Philosophy

From the CLAUDE.md you install:

> **Terse by default. Teach when it matters.**
>
> - **Investigate exhaustively** — Read every file. Check every edge case. Trace every path. Thoroughness lives in work, not words.
> - **Communicate tersely** — Fragments, no filler, minimal tokens. Default for implementation, fixes, routine work.
> - **Teach on demand** — Explain reasoning when the decision is non-obvious and affects architecture, or when the user asks why.
> - **Right-size the process** — Trivial fix → skip ceremony. New system → full pipeline.

The skills enforce the first three; the workflow router enforces the fourth.

---

## Credits

Extracted from the [pi-kudo](https://github.com/...) project, where this config was developed and validated. See that repo for domain-specific skills and the product-layer version of these ideas.
