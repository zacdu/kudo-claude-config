#!/bin/sh
# PostToolUse hook: queue artifacts written to {{ARTIFACT_DIR}}/ for wiki ingestion.
# Deterministic — no LLM. Dedupes on append.
set -u

INPUT=$(cat)
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
QUEUE="$ROOT/.claude/wiki/.ingest-queue"
LOCK="$ROOT/.claude/wiki/.ingest-queue.lock"

# Prefer jq (robust) — fall back to sed for minimal envs.
if command -v jq >/dev/null 2>&1; then
  PATH_MATCH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
else
  PATH_MATCH=$(printf '%s' "$INPUT" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' | head -n1)
fi
[ -z "$PATH_MATCH" ] && exit 0

case "$PATH_MATCH" in
  *{{ARTIFACT_DIR}}/*_RESEARCH.md|*{{ARTIFACT_DIR}}/*_PLAN.md|*{{ARTIFACT_DIR}}/*_IMPLEMENTATION_PLAN.md) ;;
  *) exit 0 ;;
esac

REL=${PATH_MATCH#"$ROOT"/}
mkdir -p "$(dirname "$QUEUE")"

# Serialize append+dedupe: atomic mkdir lock, short-lived, retry briefly.
i=0
while ! mkdir "$LOCK" 2>/dev/null; do
  i=$((i+1))
  [ "$i" -ge 50 ] && exit 0   # 5s cap → skip silently rather than block tool.
  sleep 0.1 2>/dev/null || sleep 1
done
trap 'rmdir "$LOCK" 2>/dev/null' EXIT INT TERM

touch "$QUEUE"
if ! grep -qxF "$REL" "$QUEUE" 2>/dev/null; then
  printf '%s\n' "$REL" >> "$QUEUE"
  printf 'queued for wiki ingest: %s\n' "$REL"
fi
