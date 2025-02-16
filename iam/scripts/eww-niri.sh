#!/bin/bash

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
  exit 1
fi

# Main command processing
case "$1" in
"select")
  if [ -z "$2" ]; then
    echo "Error: Workspace number required"
    usage
    exit 1
  fi
  niri msg action focus-workspace $2
  ;;

"get")
  raw_workspaces="$(niri msg -j workspaces)"
  workspaces="$(echo "$raw_workspaces" | jq 'sort_by(.id) | [.[].id] | @json')"
  active_workspace="$(echo "$raw_workspaces" | jq '.[] | select(.is_active == true) | .id')"

  raw_windows="$(niri msg -j windows)"
  active_window="$(echo "$raw_windows" | jq '.[] | select(.is_focused == true) | .title')"

  jq --arg workspaces "$workspaces" \
    --arg active_workspace "$active_workspace" \
    --arg active_window "$active_window" \
    '{ 
        workspaces: ($workspaces | fromjson), 
        active_workspace: ($active_workspace | tonumber), 
        active_window: ($active_window | fromjson)
      }' <<<'{}'
  ;;

"active-window")
  raw_windows="$(niri msg -j windows)"
  active_window="$(echo "$raw_windows" | jq '.[] | select(.is_focused == true) | .title')"
  echo $active_window
  ;;

*)
  exit 1
  ;;
esac
