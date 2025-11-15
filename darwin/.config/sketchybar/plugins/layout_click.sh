#!/bin/bash

# Get current layout mode
LAYOUT=$(yabai -m query --spaces --space | jq -r '.type')

# Cycle through layouts: stack -> bsp -> float -> stack
case "$LAYOUT" in
  "stack")
    yabai -m space --layout bsp
    ;;
  "bsp")
    yabai -m space --layout float
    ;;
  "float")
    yabai -m space --layout stack
    ;;
  *)
    yabai -m space --layout stack
    ;;
esac

# Update the sketchybar item immediately
sketchybar --trigger space_change
