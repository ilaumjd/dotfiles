#!/bin/bash

sketchybar --add item battery right \
  --set battery update_freq=120 \
  script="$PLUGIN_DIR/battery.sh" \
  icon.color="$ACCENT_PRIMARY" \
  label.color="$TEXT_PRIMARY" \
  --subscribe battery system_woke power_source_change
