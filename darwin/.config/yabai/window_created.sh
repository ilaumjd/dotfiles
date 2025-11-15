#!/usr/bin/env bash

window_info=$(yabai -m query --windows --window "$YABAI_WINDOW_ID")
app=$(echo "$window_info" | jq -r '.app')
id=$(echo "$window_info" | jq -r '.id')

while IFS=',' read -r app_name icon space; do
  [[ "$app_name" =~ ^#|^$ ]] && continue
  if [[ "$app_name" == "$app" ]]; then
    # Skip if space is set to "-" (current space)
    if [[ "$space" != "-" ]]; then
      yabai -m space --focus "$space"
      yabai -m window "$id" --space "$space"
    fi
    break
  fi
done <~/.config/_vars/apps.conf
