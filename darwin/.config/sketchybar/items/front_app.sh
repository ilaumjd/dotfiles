#!/bin/bash

sketchybar --add item front_app left \
  --set front_app icon=󰣆 \
  icon.color="$ACCENT_BLUE" \
  script="$PLUGIN_DIR/front_app.sh" \
  label.color="$TEXT_PRIMARY" \
  --subscribe front_app front_app_switched
