#!/usr/bin/env bash
# ingest-artifact.sh — Extract wiki knowledge from a completed artifact.
# Usage: ./.claude/wiki-scripts/ingest-artifact.sh <artifact_path>
# Example: ./.claude/wiki-scripts/ingest-artifact.sh {{ARTIFACT_DIR}}/QUEST_SYSTEM_RESEARCH.md

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

ARTIFACT="${1:-}"
if [ -z "$ARTIFACT" ]; then
  echo "ERROR: Usage: $0 <artifact_path>" >&2
  exit 1
fi

if [ ! -f "$ARTIFACT" ]; then
  echo "ERROR: Artifact not found: $ARTIFACT" >&2
  exit 1
fi

claude -p "$(cat .claude/wiki-scripts/prompts/ingest-prompt.md)

Artifact to ingest: $ARTIFACT" \
  --allowedTools "Read,Write,Glob,Grep" \
  --model sonnet \
  --max-turns 30 \
  --permission-mode acceptEdits
