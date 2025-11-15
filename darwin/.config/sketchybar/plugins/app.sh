#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [ "$SENDER" = "front_app_switched" ]; then
  # Read app icons from config file
  ICON="󰣆"  # default icon
  while IFS=',' read -r app_name icon space; do
    [[ "$app_name" =~ ^#|^$ ]] && continue
    if [ "$app_name" = "$INFO" ]; then
      ICON="$icon"
      break
    fi
  done <~/.config/_vars/apps.conf

  sketchybar --set "$NAME" icon="$ICON" label="$INFO"
fi
