#!/bin/sh
# SessionStart hook — requires the `caveman` plugin. Override default to `ultra`.
# Safe to remove if you don't use caveman; also remove the SessionStart entry in settings.json.
echo "ultra" > "$HOME/.claude/.caveman-active" 2>/dev/null
echo "CAVEMAN ULTRA OVERRIDE: Abbreviate (DB/auth/config/req/res/fn/impl), strip conjunctions, arrows for causality (X→Y), one word when one word enough."
