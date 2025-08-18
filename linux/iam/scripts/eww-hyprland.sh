#!/bin/bash

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
  exit 1
fi

# Main command processing
case "$1" in
"select")
  # Check if workspace number is provided
  if [ -z "$2" ]; then
    echo "Error: Workspace number required"
    usage
    exit 1
  fi
  hyprctl dispatch workspace $2
  ;;

"active")
  # Combine id and lastwindowtitle into a single JSON output
  hyprctl activeworkspace -j | jq '{ id: .id, title: .lastwindowtitle }'
  ;;

"list")
  hyprctl workspaces -j | jq -r 'sort_by(.id) | [.[].id] | @json'
  ;;

*)
  exit 1
  ;;
esac
