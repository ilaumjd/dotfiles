#!/bin/bash

sketchybar --add item clock right \
  --set clock update_freq=1 \
  icon=󰥔 \
  icon.color="$ACCENT_PURPLE" \
  script="$PLUGIN_DIR/clock.sh" \
  label.color="$TEXT_PRIMARY"
