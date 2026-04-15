#!/bin/sh
# PostToolUse hook: regenerate CLAUDE.md when wiki content changes.
# Deterministic (no LLM) — safe to auto-run.
#
# Design:
#   - Parse file_path from tool payload (avoid matching on cwd/transcript substrings).
#   - Coalesce concurrent edits: one regen process; any edit during a run sets
#     a dirty flag and the running loop picks it up. Prevents interleaved writes
#     to CLAUDE.md and avoids spawning N claude-p children on rapid edits.
#   - All output (including failures) captured in .claude/wiki/.generate.log.
set -u

INPUT=$(cat)
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0

if command -v jq >/dev/null 2>&1; then
  FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
else
  FILE_PATH=$(printf '%s' "$INPUT" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' | head -n1)
fi
[ -z "$FILE_PATH" ] && exit 0

case "$FILE_PATH" in
  *"/.claude/wiki/"*) ;;
  *) exit 0 ;;
esac

# Never regen from edits to the wiki's own sentinel/log files.
case "$FILE_PATH" in
  *"/.claude/wiki/.ingest-"*|*"/.claude/wiki/.regen."*|*"/.claude/wiki/.generate.log"|*"/.claude/wiki/.lint.log") exit 0 ;;
esac

cd "$ROOT" || exit 0
DIRTY=".claude/wiki/.regen.dirty"
LOCK=".claude/wiki/.regen.lock"
LOG=".claude/wiki/.generate.log"

touch "$DIRTY"

# Single-writer: atomic mkdir lock. Loser exits; winner drains dirty flag.
if ! mkdir "$LOCK" 2>/dev/null; then
  echo "wiki changed → regen queued (in-flight run will pick it up)"
  exit 0
fi

(
  trap 'rmdir "$LOCK" 2>/dev/null' EXIT INT TERM
  while [ -f "$DIRTY" ]; do
    rm -f "$DIRTY"
    {
      printf '=== %s regen start ===\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      sh .claude/wiki-scripts/generate-claude-md.sh 2>&1
      printf '=== exit: %s ===\n' "$?"
    } >> "$LOG" 2>&1 || true
  done
) >/dev/null 2>&1 &

echo "wiki changed → regenerating CLAUDE.md (bg; log: $LOG)"
