#!/bin/bash
# agy-ask.sh - ask Antigravity CLI one question, headless, with guard rails.
#
# Usage:
#   agy-ask.sh "your prompt"
#   AGY_MODEL=gemini-3.8-flash-medium agy-ask.sh "your prompt"
#   AGY_TIMEOUT=60 agy-ask.sh "your prompt"
#
# Why this wrapper exists:
# - agy -p can hang forever if the login token expired and it falls back
#   to the interactive login screen. The timeout keeps that from wedging
#   the calling agent.
# - It runs agy inside a dedicated, nearly empty work directory so the
#   agent never gets to wander around your home directory.
# - It strips ANSI escape codes so the answer can go straight into
#   another agent's context without garbage characters.
#
# Exit codes: 0 ok, 124 timeout (probably needs re-login), 2 bad usage.

set -u

PROMPT="${1:-}"
if [ -z "$PROMPT" ]; then
  echo "usage: agy-ask.sh \"your prompt\"" >&2
  exit 2
fi

AGY_BIN="${AGY_BIN:-$HOME/.local/bin/agy}"
AGY_WORKDIR="${AGY_WORKDIR:-$HOME/agy-workspace}"
AGY_MODEL="${AGY_MODEL:-gemini-4-argon-high}"
AGY_TIMEOUT="${AGY_TIMEOUT:-180}"

mkdir -p "$AGY_WORKDIR"
cd "$AGY_WORKDIR" || exit 2

OUT="$(timeout "$AGY_TIMEOUT" "$AGY_BIN" -p "$PROMPT" --model "$AGY_MODEL" 2>&1)"
STATUS=$?

if [ $STATUS -eq 124 ]; then
  echo "agy timed out after ${AGY_TIMEOUT}s. The login token may have expired - redo the tmux OAuth login." >&2
  exit 124
fi

# Strip ANSI escape sequences.
printf '%s\n' "$OUT" | sed -e 's/\x1b\[[0-9;]*m//g' -e 's/\x1b\[[0-9;]*[A-Za-z]//g'

if printf '%s' "$OUT" | grep -qi "not signed in\|sign in to view\|You are not logged into"; then
  echo "agy looks logged out. Redo the tmux OAuth login." >&2
  exit 124
fi

exit $STATUS
