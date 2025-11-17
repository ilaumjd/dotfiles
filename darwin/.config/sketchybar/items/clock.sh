#!/bin/bash

sketchybar --add item clock right \
  --set clock update_freq=1 \
  icon=󰥔 \
  icon.color="$ACCENT_PRIMARY" \
  label.width=65 \
  label.color="$TEXT_PRIMARY" \
  script="$PLUGIN_DIR/clock.sh"
