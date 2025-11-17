#!/bin/bash

# Get current layout mode
LAYOUT=$(yabai -m query --spaces --space | jq -r '.type')

# Set icon and label based on layout
case "$LAYOUT" in
"bsp")
  ICON="󰕰"
  ;;
"stack")
  ICON=""
  ;;
"float")
  ICON="󰖲"
  ;;
*)
  ICON="󰕰"
  ;;
esac

sketchybar --set "$NAME" icon="$ICON"
