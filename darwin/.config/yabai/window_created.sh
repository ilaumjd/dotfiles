#!/usr/bin/env bash

window_info=$(yabai -m query --windows --window "$YABAI_WINDOW_ID")
app=$(echo "$window_info" | jq -r '.app')
id=$(echo "$window_info" | jq -r '.id')

while IFS='=' read -r key val; do
  [[ "$key" =~ ^#|^$ ]] && continue
  if [[ "$key" == "$app" ]]; then
    yabai -m space --focus "$val"
    yabai -m window "$id" --space "$val"
    break
  fi
done <~/.config/yabai/app_spaces.conf
