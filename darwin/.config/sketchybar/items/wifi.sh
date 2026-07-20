#!/bin/bash

sketchybar --add item wifi right \
  --set wifi update_freq=15 \
  script="$PLUGIN_DIR/wifi.sh" \
  --subscribe wifi system_woke
