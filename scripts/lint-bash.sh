#!/usr/bin/env bash
# Syntax-check all .sh files in a directory.
# Usage: lint-bash.sh <directory>
# Output: "OK" for each valid file, error details for invalid ones.
set -euo pipefail

DIR="$1"

if [ ! -d "$DIR" ]; then
  echo "ERROR: directory not found: $DIR"
  exit 1
fi

# Find all .sh files (excluding node_modules and .git)
sh_files=$(find "$DIR" -name '*.sh' \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -not -path '*/dist/*' 2>/dev/null || true)

if [ -z "$sh_files" ]; then
  echo "OK: no shell scripts found"
  exit 0
fi

had_errors=0
while IFS= read -r f; do
  result=$(bash -n "$f" 2>&1) && rc=$? || rc=$?
  if [ $rc -eq 0 ]; then
    echo "OK: $f"
  else
    echo "FAIL: $f"
    echo "  $result"
    had_errors=1
  fi
done <<< "$sh_files"

if [ $had_errors -eq 1 ]; then
  exit 1
fi
