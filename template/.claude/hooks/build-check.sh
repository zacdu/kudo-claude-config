#!/bin/sh
# PostToolUse hook: flag source modifications for build check verification
INPUT=$(cat)
case "$INPUT" in
  *"{{FILE_EXT}}"*) echo "{{FILE_EXT}} changed — run {{BUILD_CHECK_CMD}} before completing" ;;
esac
