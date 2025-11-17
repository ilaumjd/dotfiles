#!/bin/bash

sketchybar --add item app left \
  --set app \
  icon=󰣆 \
  icon.padding_left=10 \
  icon.padding_right=2 \
  script="$PLUGIN_DIR/app.sh" \
  --subscribe app front_app_switched
