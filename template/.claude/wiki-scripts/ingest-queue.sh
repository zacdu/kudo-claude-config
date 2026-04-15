#!/usr/bin/env bash
# ingest-queue.sh — Process, skip, or inspect the wiki ingest queue.
# Usage:
#   ingest-queue.sh              Process all queued artifacts
#   ingest-queue.sh --status     List pending artifacts
#   ingest-queue.sh --skip PATH  Drop one artifact from the queue (no ingest)
#   ingest-queue.sh --clear      Wipe the queue (no ingest)

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

QUEUE=".claude/wiki/.ingest-queue"
INGEST=".claude/wiki-scripts/ingest-artifact.sh"

ensure_queue() {
  mkdir -p "$(dirname "$QUEUE")"
  touch "$QUEUE"
}

case "${1:-}" in
  --status)
    ensure_queue
    if [ ! -s "$QUEUE" ]; then
      echo "queue empty"
      exit 0
    fi
    echo "pending ingest:"
    sed 's/^/  - /' "$QUEUE"
    ;;

  --skip)
    ensure_queue
    TARGET="${2:-}"
    [ -z "$TARGET" ] && { echo "ERROR: --skip requires a path" >&2; exit 1; }
    grep -vxF "$TARGET" "$QUEUE" > "$QUEUE.tmp" || true
    mv "$QUEUE.tmp" "$QUEUE"
    echo "skipped: $TARGET"
    ;;

  --clear)
    ensure_queue
    : > "$QUEUE"
    echo "queue cleared"
    ;;

  ""|--all)
    ensure_queue
    if [ ! -s "$QUEUE" ]; then
      echo "queue empty — nothing to ingest"
      exit 0
    fi
    FAIL_LIST="$QUEUE.failed"
    : > "$FAIL_LIST"
    SNAPSHOT="$QUEUE.snapshot"
    cp "$QUEUE" "$SNAPSHOT"
    while IFS= read -r artifact; do
      [ -z "$artifact" ] && continue
      if [ ! -f "$artifact" ]; then
        echo "skip (missing): $artifact"
        grep -vxF "$artifact" "$QUEUE" > "$QUEUE.tmp" || true
        mv "$QUEUE.tmp" "$QUEUE"
        continue
      fi
      echo "=== ingesting: $artifact ==="
      if "$INGEST" "$artifact"; then
        grep -vxF "$artifact" "$QUEUE" > "$QUEUE.tmp" || true
        mv "$QUEUE.tmp" "$QUEUE"
      else
        echo "FAILED: $artifact (left in queue)" >&2
        printf '%s\n' "$artifact" >> "$FAIL_LIST"
      fi
    done < "$SNAPSHOT"
    rm -f "$SNAPSHOT"
    if [ -s "$FAIL_LIST" ]; then
      echo "failures:" >&2
      sed 's/^/  - /' "$FAIL_LIST" >&2
      rm -f "$FAIL_LIST"
      exit 1
    fi
    rm -f "$FAIL_LIST"
    echo "queue drained"
    ;;

  *)
    echo "ERROR: unknown arg: $1" >&2
    echo "Usage: $0 [--status|--skip PATH|--clear|--all]" >&2
    exit 1
    ;;
esac
