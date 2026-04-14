#!/usr/bin/env bash
# bootstrap.sh — Generate initial wiki pages from existing knowledge sources.
# Usage: ./.claude/wiki-scripts/bootstrap.sh
# Idempotent: overwrites existing wiki pages.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

claude -p "$(cat .claude/wiki-scripts/prompts/bootstrap-prompt.md)" \
  --allowedTools "Read,Glob,Grep,Write,Agent" \
  --model sonnet \
  --max-turns 50 \
  --permission-mode acceptEdits
