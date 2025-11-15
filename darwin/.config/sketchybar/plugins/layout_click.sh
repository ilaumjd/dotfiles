#!/bin/bash

# Get current layout mode
LAYOUT=$(yabai -m query --spaces --space | jq -r '.type')

# Cycle through layouts: stack -> bsp -> float -> stack
case "$LAYOUT" in
  "stack")
    yabai -m config layout bsp
    ;;
  "bsp")
    yabai -m config layout float
    ;;
  "float")
    yabai -m config layout stack
    ;;
  *)
    yabai -m config layout stack
    ;;
esac

# Update the sketchybar item immediately
sketchybar --trigger space_change
