#!/bin/bash

sketchybar --add item app left \
  --set app icon=󰣆 \
  icon.color="$ACCENT_BLUE" \
  script="$PLUGIN_DIR/app.sh" \
  label.color="$TEXT_PRIMARY" \
  --subscribe app front_app_switched
