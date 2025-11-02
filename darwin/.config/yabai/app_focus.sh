#!/usr/bin/env bash

app=$(yabai -m query --windows --window "$YABAI_WINDOW_ID" | jq -r '.app')

while IFS='=' read -r key val; do
  [[ "$key" =~ ^#|^$ ]] && continue
  if [[ "$key" == "$app" ]]; then
    yabai -m space --focus "$val"
    break
  fi
done <~/.config/yabai/app_map.conf
