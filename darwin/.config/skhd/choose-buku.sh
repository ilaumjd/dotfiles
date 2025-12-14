#!/usr/bin/env bash

menu=$(
  buku --nostdin -p -j |
    jq -r '
      .[] | "🌐 \(.title) | \(.uri)"
    '
  buku --nostdin -p -j |
    jq -r '
      .[] | "📋 \(.title) | \(.uri)"
    '
)

selection=$(printf "%s\n" "$menu" | choose)
[ -z "$selection" ] && exit 0

uri="${selection##* | }"

case "$selection" in
🌐*)
  open "$uri"
  ;;
📋*)
  printf "%s" "$uri" | pbcopy
  ;;
esac
