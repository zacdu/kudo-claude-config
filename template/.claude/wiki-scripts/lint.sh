#!/usr/bin/env bash
# lint.sh — Wiki health check.
# Usage: ./.claude/wiki-scripts/lint.sh
# Output: Report to stdout. Exit 0 = clean, exit 1 = issues found.
# Read-only — never writes wiki files.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

claude -p "$(cat .claude/wiki-scripts/prompts/lint-prompt.md)" \
  --allowedTools "Read,Glob,Grep,Bash" \
  --model sonnet \
  --max-turns 30 \
  --permission-mode plan
