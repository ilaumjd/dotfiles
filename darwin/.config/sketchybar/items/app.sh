#!/bin/bash

sketchybar --add item app left \
  --set app icon=󰣆 \
  script="$PLUGIN_DIR/app.sh" \
  --subscribe app front_app_switched
