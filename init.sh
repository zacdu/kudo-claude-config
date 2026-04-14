#!/usr/bin/env bash
# init.sh — Copy claude-config-template into a target project with placeholder substitution.
#
# Usage:
#   ./init.sh [target_dir]           # interactive, defaults target to CWD
#   ./init.sh --force [target_dir]   # overwrite existing files without asking
#   ./init.sh --dry-run [target_dir] # show what would happen, don't write
#   ./init.sh -y                     # non-interactive; use flags + defaults, skip confirm
#
# Non-interactive flags (any subset; prompts fill the rest unless -y):
#   --name <x>         project name (default: basename of target)
#   --desc <x>         one-line description
#   --language <x>     display language (e.g. TypeScript)
#   --role <x>         AI role description
#   --build-cmd <x>    single command that runs after changes (e.g. "npm run check")
#   --ext <x>          primary source file extension (e.g. ".ts")
#   --artifact-dir <x> artifact directory (default: tmp_docs)
#   --source-dir <x>   source root directory (default: src)
#
# Placeholders substituted in copied files:
#   {{PROJECT_NAME}} {{PROJECT_DESC}} {{LANGUAGE}} {{LANGUAGE_LOWER}}
#   {{ROLE_DESC}} {{BUILD_CHECK_CMD}} {{FILE_EXT}} {{ARTIFACT_DIR}}
#   {{SOURCE_DIR}} {{PROJECT_ROOT}} (auto-detected)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/template"

if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "ERROR: template/ not found next to init.sh ($TEMPLATE_DIR)" >&2
  exit 1
fi

FORCE=0
DRY_RUN=0
YES=0
TARGET=""

PROJECT_NAME=""
PROJECT_DESC=""
LANGUAGE=""
ROLE_DESC=""
BUILD_CHECK_CMD=""
FILE_EXT=""
ARTIFACT_DIR=""
SOURCE_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    --force)        FORCE=1 ;;
    --dry-run)      DRY_RUN=1 ;;
    -y|--yes)       YES=1 ;;
    --name)         PROJECT_NAME="$2"; shift ;;
    --desc)         PROJECT_DESC="$2"; shift ;;
    --language)     LANGUAGE="$2"; shift ;;
    --role)         ROLE_DESC="$2"; shift ;;
    --build-cmd)    BUILD_CHECK_CMD="$2"; shift ;;
    --ext)          FILE_EXT="$2"; shift ;;
    --artifact-dir) ARTIFACT_DIR="$2"; shift ;;
    --source-dir)   SOURCE_DIR="$2"; shift ;;
    -h|--help)      sed -n '2,25p' "$0"; exit 0 ;;
    *)              TARGET="$1" ;;
  esac
  shift
done

TARGET="${TARGET:-$PWD}"
TARGET="$(cd "$TARGET" && pwd)"

echo ""
echo "claude-config-template installer"
echo "================================"
echo "Target: $TARGET"
[ "$DRY_RUN" = "1" ] && echo "Mode:   DRY RUN (no files written)"
[ "$YES" = "1" ] && echo "Mode:   non-interactive (-y)"
echo ""

# ── Fill missing values ────────────────────────────────────────────────

prompt() {
  # prompt VAR_NAME "Question" "default"
  local var="$1" question="$2" default="$3" answer
  # Only prompt if var is empty
  local current="${!var}"
  if [ -n "$current" ]; then return 0; fi
  if [ "$YES" = "1" ]; then
    eval "$var=\"\$default\""
    return 0
  fi
  read -r -p "$question [$default]: " answer || true
  eval "$var=\"\${answer:-\$default}\""
}

DEFAULT_NAME="$(basename "$TARGET")"
prompt PROJECT_NAME    "Project name"                              "$DEFAULT_NAME"
prompt PROJECT_DESC    "One-line description"                      "A software project."
prompt LANGUAGE        "Language (TypeScript/Python/Go/...)"       "TypeScript"
prompt ROLE_DESC       "AI role description"                       "Senior $LANGUAGE Dev"
prompt BUILD_CHECK_CMD "Build/check command (runs after changes)"  "npm run check"
prompt FILE_EXT        "Primary source file extension"             ".ts"
prompt ARTIFACT_DIR    "Artifact directory"                        "tmp_docs"
prompt SOURCE_DIR      "Source directory"                          "src"

PROJECT_ROOT="$TARGET"
LANGUAGE_LOWER="$(printf '%s' "$LANGUAGE" | tr '[:upper:]' '[:lower:]')"

echo ""
echo "Summary:"
printf "  %-18s %s\n" "PROJECT_NAME"    "$PROJECT_NAME"
printf "  %-18s %s\n" "PROJECT_DESC"    "$PROJECT_DESC"
printf "  %-18s %s\n" "LANGUAGE"        "$LANGUAGE"
printf "  %-18s %s\n" "ROLE_DESC"       "$ROLE_DESC"
printf "  %-18s %s\n" "BUILD_CHECK_CMD" "$BUILD_CHECK_CMD"
printf "  %-18s %s\n" "FILE_EXT"        "$FILE_EXT"
printf "  %-18s %s\n" "ARTIFACT_DIR"    "$ARTIFACT_DIR"
printf "  %-18s %s\n" "SOURCE_DIR"      "$SOURCE_DIR"
printf "  %-18s %s\n" "PROJECT_ROOT"    "$PROJECT_ROOT"
echo ""

if [ "$YES" != "1" ]; then
  read -r -p "Proceed? [y/N]: " confirm
  case "$confirm" in
    y|Y|yes|YES) ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

# ── Overwrite handling ─────────────────────────────────────────────────

CONFLICTS=0
for rel in CLAUDE.md STANDARDS.md PATTERNS.md .claude; do
  if [ -e "$TARGET/$rel" ] && [ "$FORCE" != "1" ]; then
    echo "Conflict: $TARGET/$rel already exists."
    CONFLICTS=$((CONFLICTS+1))
  fi
done

if [ "$CONFLICTS" -gt 0 ]; then
  echo ""
  echo "Re-run with --force to overwrite, or back up / remove these first."
  exit 1
fi

# ── Copy + substitute ──────────────────────────────────────────────────

export PROJECT_NAME PROJECT_DESC LANGUAGE LANGUAGE_LOWER ROLE_DESC \
       BUILD_CHECK_CMD FILE_EXT ARTIFACT_DIR SOURCE_DIR PROJECT_ROOT

substitute() {
  local file="$1"
  perl -pi -e '
    s/\{\{PROJECT_NAME\}\}/$ENV{PROJECT_NAME}/g;
    s/\{\{PROJECT_DESC\}\}/$ENV{PROJECT_DESC}/g;
    s/\{\{LANGUAGE_LOWER\}\}/$ENV{LANGUAGE_LOWER}/g;
    s/\{\{LANGUAGE\}\}/$ENV{LANGUAGE}/g;
    s/\{\{ROLE_DESC\}\}/$ENV{ROLE_DESC}/g;
    s/\{\{BUILD_CHECK_CMD\}\}/$ENV{BUILD_CHECK_CMD}/g;
    s/\{\{FILE_EXT\}\}/$ENV{FILE_EXT}/g;
    s/\{\{ARTIFACT_DIR\}\}/$ENV{ARTIFACT_DIR}/g;
    s/\{\{SOURCE_DIR\}\}/$ENV{SOURCE_DIR}/g;
    s/\{\{PROJECT_ROOT\}\}/$ENV{PROJECT_ROOT}/g;
  ' "$file"
}

echo ""
echo "Installing..."

if [ "$DRY_RUN" = "1" ]; then
  (cd "$TEMPLATE_DIR" && find . -type f | sort | sed 's|^\./|  would write: |')
  echo ""
  echo "Dry run complete. No changes made."
  exit 0
fi

(cd "$TEMPLATE_DIR" && find . -type d -print0) | while IFS= read -r -d '' dir; do
  mkdir -p "$TARGET/$dir"
done

(cd "$TEMPLATE_DIR" && find . -type f -print0) | while IFS= read -r -d '' file; do
  rel="${file#./}"
  # Skip .gitkeep — only there to preserve empty dirs in the template repo
  case "$rel" in */.gitkeep) continue ;; esac
  cp "$TEMPLATE_DIR/$rel" "$TARGET/$rel"
  substitute "$TARGET/$rel"
done

chmod +x "$TARGET/.claude/hooks/"*.sh 2>/dev/null || true
chmod +x "$TARGET/.claude/wiki-scripts/"*.sh 2>/dev/null || true

echo ""
echo "Done."
echo ""
echo "Next steps:"
echo "  1. Review CLAUDE.md — fill Architecture section with your source tree"
echo "  2. Review STANDARDS.md — add language-specific conventions"
echo "  3. (Optional) Run .claude/wiki-scripts/bootstrap.sh to auto-populate wiki"
echo "  4. Add patterns to PATTERNS.md as they emerge"
