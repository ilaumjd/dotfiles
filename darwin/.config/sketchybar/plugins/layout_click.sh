#!/bin/bash

YABAI_BIN="$HOME/.local/src/yabai-macos27/bin/yabai"

# Get current layout mode
LAYOUT=$("$YABAI_BIN" -m query --spaces --space | jq -r '.type')

# Cycle through layouts: stack -> bsp -> float -> stack
case "$LAYOUT" in
  "stack")
    "$YABAI_BIN" -m space --layout bsp
    ;;
  "bsp")
    "$YABAI_BIN" -m space --layout float
    ;;
  "float")
    "$YABAI_BIN" -m space --layout stack
    ;;
  *)
    "$YABAI_BIN" -m space --layout stack
    ;;
esac

# Update the sketchybar item immediately
sketchybar --trigger space_change
