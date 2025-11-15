#!/bin/bash

sketchybar --add item battery right \
  --set battery update_freq=120 \
  script="$PLUGIN_DIR/battery.sh" \
  icon.color="$ACCENT_PRIMARY" \
  icon.width=20 \
  label.color="$TEXT_PRIMARY" \
  label.width=42 \
  --subscribe battery system_woke power_source_change
