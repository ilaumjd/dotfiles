#!/usr/bin/env bash

# Cycle through windows in yabai's stack without retaining a stale window ID.
YABAI_BIN="$HOME/.local/src/yabai-macos27/bin/yabai"

case "${1:-next}" in
next) selector="stack.next" ;;
prev) selector="stack.prev" ;;
*)
  echo "Usage: ${0##*/} [next|prev]" >&2
  exit 2
  ;;
esac

exec "$YABAI_BIN" -m window --focus "$selector"
