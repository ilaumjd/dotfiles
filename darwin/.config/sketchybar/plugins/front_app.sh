#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [ "$SENDER" = "front_app_switched" ]; then
  # Map app names to Nerd Font icons
  case "$INFO" in
    "Ghostty")
      ICON="󰆍"
      ;;
    "WezTerm")
      ICON=""
      ;;
    "Firefox")
      ICON="󰈹"
      ;;
    "Xcode")
      ICON="󰛐"
      ;;
    "zoom.us")
      ICON="󰍩"
      ;;
    "Slack")
      ICON="󰒱"
      ;;
    *)
      ICON="󰣆"
      ;;
  esac

  sketchybar --set "$NAME" icon="$ICON" label="$INFO"
fi
