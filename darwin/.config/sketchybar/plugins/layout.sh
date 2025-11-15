#!/bin/bash

# Get current layout mode
LAYOUT=$(yabai -m query --spaces --space | jq -r '.type')

# Set icon and label based on layout
case "$LAYOUT" in
"bsp")
  ICON="󰕰"
  LABEL="BSP"
  ;;
"stack")
  ICON=""
  LABEL="STACK"
  ;;
"float")
  ICON="󰖲"
  LABEL="FLOAT"
  ;;
*)
  ICON="󰕰"
  LABEL="?"
  ;;
esac

sketchybar --set "$NAME" icon="$ICON" label="$LABEL"
