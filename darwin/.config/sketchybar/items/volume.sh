#!/bin/bash

sketchybar --add item volume right \
  --set volume script="$PLUGIN_DIR/volume.sh" \
  icon.color="$ACCENT_PRIMARY" \
  icon.width=32 \
  label.color="$TEXT_PRIMARY" \
  label.width=42 \
  --subscribe volume volume_change
