#!/usr/bin/env bash

YABAI_BIN="$HOME/.local/src/yabai-macos27/bin/yabai"

window_info=$("$YABAI_BIN" -m query --windows --window "$YABAI_WINDOW_ID")
app=$(echo "$window_info" | jq -r '.app')
id=$(echo "$window_info" | jq -r '.id')

while IFS=',' read -r app_name icon space; do
  [[ "$app_name" =~ ^#|^$ ]] && continue
  if [[ "$app_name" == "$app" ]]; then
    # Skip if space is set to "-" (current space)
    if [[ "$space" != "-" ]]; then
      "$YABAI_BIN" -m space --focus "$space"
      "$YABAI_BIN" -m window "$id" --space "$space"
    fi
    break
  fi
done <~/.config/_vars/apps.conf
