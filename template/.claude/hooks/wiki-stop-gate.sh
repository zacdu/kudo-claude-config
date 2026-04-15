#!/bin/sh
# Stop hook: fire ONCE per session when wiki ingest queue has real artifacts.
# Auto-prunes missing files. Sets a sentinel so re-Stop passes through.
# When queue is empty: kicks off lint in the background and surfaces the
# previous run's warnings (if any). Never blocks Stop on lint.
set -u

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$ROOT" || exit 0

QUEUE=".claude/wiki/.ingest-queue"
SENTINEL=".claude/wiki/.ingest-prompted"
LINT_LOG=".claude/wiki/.lint.log"
LINT_LOCK=".claude/wiki/.lint.lock"

# POSIX JSON string escaper using awk (no python/jq dependency).
# Handles: backslash, double-quote, control chars, newlines.
json_escape() {
  awk '
    BEGIN { ORS=""; printf "\"" }
    {
      s = $0
      gsub(/\\/, "\\\\", s)
      gsub(/"/,  "\\\"", s)
      gsub(/\t/, "\\t",  s)
      gsub(/\r/, "\\r",  s)
      # Strip other control chars (rare in our reason text).
      gsub(/[\001-\010\013\014\016-\037]/, "", s)
      if (NR > 1) printf "\\n"
      printf "%s", s
    }
    END { printf "\"" }
  '
}

# Auto-prune stale entries (missing files) silently.
if [ -s "$QUEUE" ]; then
  : > "$QUEUE.tmp"
  while IFS= read -r entry; do
    [ -z "$entry" ] && continue
    [ -f "$entry" ] && printf '%s\n' "$entry" >> "$QUEUE.tmp"
  done < "$QUEUE"
  mv "$QUEUE.tmp" "$QUEUE"
fi

# Queue empty → clear sentinel, surface prior lint warnings, kick off fresh lint.
if [ ! -s "$QUEUE" ]; then
  rm -f "$SENTINEL"

  # Surface *previous* lint run's warnings (current run is async).
  if [ -f "$LINT_LOG" ]; then
    case "$(cat "$LINT_LOG" 2>/dev/null)" in
      *stale*|*orphan*|*missing*|*broken*)
        printf 'wiki lint (previous run):\n'
        cat "$LINT_LOG"
        ;;
    esac
  fi

  # Fire new lint async (LLM call — can exceed hook timeout). Single-writer.
  if [ -x .claude/wiki-scripts/lint.sh ] && mkdir "$LINT_LOCK" 2>/dev/null; then
    (
      trap 'rmdir "$LINT_LOCK" 2>/dev/null' EXIT INT TERM
      {
        printf '=== %s lint start ===\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
        sh .claude/wiki-scripts/lint.sh 2>&1
        printf '=== exit: %s ===\n' "$?"
      } > "$LINT_LOG" 2>&1 || true
    ) >/dev/null 2>&1 &
  fi

  exit 0
fi

# Already prompted this session → allow Stop (don't loop).
if [ -f "$SENTINEL" ]; then
  exit 0
fi

# First Stop with real pending artifacts → block once, list, set sentinel.
touch "$SENTINEL"
PENDING=$(sed 's/^/  - /' "$QUEUE")
REASON=$(printf 'Pending wiki ingest artifacts:\n%s\n\nInform the user and ask which to ingest. Options:\n  Ingest all:   .claude/wiki-scripts/ingest-queue.sh\n  Ingest one:   .claude/wiki-scripts/ingest-artifact.sh <path>\n  Skip one:     .claude/wiki-scripts/ingest-queue.sh --skip <path>\n  Clear all:    .claude/wiki-scripts/ingest-queue.sh --clear\n\nThis prompt fires once per session. Next Stop will pass through.' "$PENDING")
printf '{"decision":"block","reason":%s}\n' "$(printf '%s' "$REASON" | json_escape)"
exit 0
