#!/usr/bin/env bash
# generate-claude-md.sh — Compile wiki into CLAUDE.md
# Usage: ./.claude/wiki-scripts/generate-claude-md.sh
# Safe: backs up current CLAUDE.md before overwriting.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

cp CLAUDE.md CLAUDE.md.bak

claude -p "$(cat .claude/wiki-scripts/prompts/generate-prompt.md)" \
  --allowedTools "Read,Write,Glob" \
  --model sonnet \
  --max-turns 20 \
  --permission-mode acceptEdits
