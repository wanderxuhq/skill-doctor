#!/usr/bin/env bash
# Extract and validate YAML frontmatter from a SKILL.md file.
# Usage: check-yaml.sh <path/to/SKILL.md>
# Output: "OK" if valid, error message if not.
set -euo pipefail

FILE="$1"

if [ ! -f "$FILE" ]; then
  echo "ERROR: file not found: $FILE"
  exit 1
fi

# Extract content between first and second --- delimiters
YAML=$(sed -n '/^---$/,/^---$/p' "$FILE" | sed '1d;$d')

if [ -z "$YAML" ]; then
  echo "ERROR: no YAML frontmatter found (missing --- delimiters)"
  exit 1
fi

# Check required fields
if ! echo "$YAML" | grep -q '^name:'; then
  echo "ERROR: missing required frontmatter field: 'name'"
  exit 1
fi

if ! echo "$YAML" | grep -q '^description:'; then
  echo "ERROR: missing required frontmatter field: 'description'"
  exit 1
fi

# Check for common YAML errors: unclosed quotes
if echo "$YAML" | grep -qE "^\w+:\s*'[^']*$"; then
  echo "WARNING: possible unclosed single quote in frontmatter"
fi

if echo "$YAML" | grep -qE '^\w+:\s*"[^"]*$'; then
  echo "WARNING: possible unclosed double quote in frontmatter"
fi

echo "OK: valid frontmatter with required fields"
