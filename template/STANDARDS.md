# {{PROJECT_NAME}} — Engineering Standards

> Loaded on demand by code-writing skills. Your linter/formatter enforces mechanical rules (format, unused symbols, etc.). This doc covers what the linter can't catch.

## Language Conventions

<!-- Fill in language-specific conventions. Examples below for common stacks. -->

### {{LANGUAGE}}

<!-- e.g. for TypeScript:
- `interface` over `type` for object shapes. `type` for unions, intersections, mapped types.
- Discriminated unions with literal `type` discriminants. Exhaustive switches with `default: throw new Error()`.
- One primary export per file. File name = primary export name.
- `.js` extension in relative ES imports.

For Python:
- Type hints on all public functions; `from __future__ import annotations` at module top.
- Dataclasses (`@dataclass(frozen=True)`) for data shapes; `Protocol` for interfaces.
- No mutable default arguments.

For Go:
- Errors returned, not panicked — wrap with `fmt.Errorf("context: %w", err)`.
- Accept interfaces, return concrete types.
- One package per directory; package name = directory name.
-->

## Naming

| Construct | Convention | Notes |
|-----------|-----------|-------|
| Locals/params | <fill in per language> | |
| Types | <fill in> | |
| Constants | <fill in> | |
| Functions | verb+object | `resolveTemplate()` |
| Booleans | is/has/can/should | `isRunning` |
| Events | past=notify, present=action | `phaseComplete` vs `runPhase` |
| Files | <fill in per language> | |

## What the Linter Can't Catch

- **Cleanup symmetry** — every start/stop, open/close, subscribe/unsubscribe paired. Verify cleanup in all exit paths including errors.
- **Result objects for expected failures** — return `{ success: boolean; error?: string }` (or language equivalent), don't throw for expected outcomes.
- **Immutable by default** — prefer readonly / frozen / const. Copy over mutate.
- **Self-contained files** — each understandable with itself + imported types + folder README.
- **Event chains ≤3 hops** — if deeper, refactor to direct call.
- **No circular imports** — extract shared types to a types module.
- **READMEs current** — update on add/remove/rename.

## Templates

New files should start from `.claude/templates/`. Copy + fill placeholders. Canonical forms only — don't invent variants.
