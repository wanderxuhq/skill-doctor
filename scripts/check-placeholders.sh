#!/usr/bin/env bash
# Find unreplaced {{...}} placeholders in a directory.
# Usage: check-placeholders.sh <directory>
# Output: list of files containing {{...}} markers, or "OK" if none found.
set -euo pipefail

DIR="$1"

if [ ! -d "$DIR" ]; then
  echo "ERROR: directory not found: $DIR"
  exit 1
fi

# Find text files with {{...}} patterns, excluding common non-text and generated directories
matches=$(grep -r --include='*.{md,mjs,js,ts,py,sh,json,yaml,yml,txt,html,css}' \
  --exclude-dir='node_modules' \
  --exclude-dir='.git' \
  --exclude-dir='dist' \
  --exclude-dir='build' \
  --exclude-dir='debug-artifacts' \
  -l '\{\{[A-Z_]+\}\}' "$DIR" 2>/dev/null || true)

if [ -z "$matches" ]; then
  echo "OK: no unreplaced placeholders found"
else
  echo "Files with {{PLACEHOLDER}} markers:"
  echo "$matches"
  echo ""
  echo "Run with -n to show line numbers and content."
fi

# If -n flag is passed, show details
if [ "${2:-}" = "-n" ]; then
  grep -rn --include='*.{md,mjs,js,ts,py,sh,json,yaml,yml,txt,html,css}' \
    --exclude-dir='node_modules' \
    --exclude-dir='.git' \
    --exclude-dir='dist' \
    '\{\{[A-Z_]+\}\}' "$DIR" 2>/dev/null || true
fi
