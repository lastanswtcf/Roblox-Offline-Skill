#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-all}"
SCOPE="${2:-project}"
FORCE="${3:-}"

SKILL_NAME="roblox-offline-skill"
SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$PWD}"
HOME_ROOT="${HOME:?HOME must be set}"

if [[ "$SCOPE" != "project" && "$SCOPE" != "user" ]]; then
  echo "Scope must be 'project' or 'user'." >&2
  exit 2
fi

case "$TARGET" in
  all)
    TARGETS=(codex antigravity gemini-cli copilot cursor claude-code)
    ;;
  codex|antigravity|gemini-cli|copilot|cursor|claude-code)
    TARGETS=("$TARGET")
    ;;
  *)
    echo "Unknown target: $TARGET" >&2
    exit 2
    ;;
esac

for item in SKILL.md references examples web-ai; do
  if [[ ! -e "$SOURCE_ROOT/$item" ]]; then
    echo "Required package item is missing: $item" >&2
    exit 1
  fi
done

DESTINATIONS=()

for platform in "${TARGETS[@]}"; do
  if [[ "$SCOPE" == "project" ]]; then
    BASE="$PROJECT_ROOT"
    case "$platform" in
      claude-code) RELATIVE_ROOT=".claude/skills" ;;
      *) RELATIVE_ROOT=".agents/skills" ;;
    esac
  else
    BASE="$HOME_ROOT"
    case "$platform" in
      codex|gemini-cli) RELATIVE_ROOT=".agents/skills" ;;
      antigravity) RELATIVE_ROOT=".gemini/config/skills" ;;
      copilot) RELATIVE_ROOT=".copilot/skills" ;;
      cursor) RELATIVE_ROOT=".cursor/skills" ;;
      claude-code) RELATIVE_ROOT=".claude/skills" ;;
    esac
  fi

  DESTINATION="$BASE/$RELATIVE_ROOT/$SKILL_NAME"
  ALREADY_ADDED=0

  for existing in "${DESTINATIONS[@]}"; do
    if [[ "$existing" == "$DESTINATION" ]]; then
      ALREADY_ADDED=1
      break
    fi
  done

  if [[ "$ALREADY_ADDED" -eq 0 ]]; then
    DESTINATIONS+=("$DESTINATION")
  fi
done

for destination in "${DESTINATIONS[@]}"; do
  parent="$(dirname "$destination")"
  mkdir -p "$parent"

  if [[ -e "$destination" ]]; then
    if [[ "$FORCE" != "--force" ]]; then
      echo "Destination already exists: $destination" >&2
      echo "Review it or rerun with --force to replace only this skill folder." >&2
      exit 1
    fi
    rm -rf -- "$destination"
  fi

  mkdir -p "$destination"
  for item in SKILL.md references examples web-ai AI-PLATFORMS.md; do
    if [[ -e "$SOURCE_ROOT/$item" ]]; then
      cp -R "$SOURCE_ROOT/$item" "$destination/"
    fi
  done

  echo "Installed $SKILL_NAME to $destination"
done

echo "Installation completed. Open a new agent session or reload skills where required."
