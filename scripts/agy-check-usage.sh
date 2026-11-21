#!/bin/bash
# agy-check-usage.sh - print Antigravity quota left, warn when low.
#
# Usage: agy-check-usage.sh [threshold_percent]   (default 10)
# Exit code 1 when any Gemini pool is at or below the threshold.

set -u

THRESHOLD="${1:-10}"
AGY_BIN="${AGY_BIN:-$HOME/.local/bin/agy}"
AGY_WORKDIR="${AGY_WORKDIR:-$HOME/agy-workspace}"

mkdir -p "$AGY_WORKDIR"
cd "$AGY_WORKDIR" || exit 2

OUT="$(timeout 60 "$AGY_BIN" -p "/usage" 2>&1)"
printf '%s\n' "$OUT"

LOW=0
while IFS= read -r line; do
  PCT="$(printf '%s' "$line" | grep -oE '[0-9]+%' | head -1 | tr -d '%')"
  case "$PCT" in
    ''|*[!0-9]*) continue ;;
  esac
  if [ "$PCT" -le "$THRESHOLD" ]; then
    echo "LOW QUOTA (${PCT}%): $line" >&2
    LOW=1
  fi
done <<EOF
$OUT
EOF

exit $LOW
