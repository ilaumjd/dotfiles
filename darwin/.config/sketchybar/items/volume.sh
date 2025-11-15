#!/bin/bash

sketchybar --add item volume right \
  --set volume script="$PLUGIN_DIR/volume.sh" \
  icon.color="$ACCENT_CYAN" \
  label.color="$TEXT_PRIMARY" \
  --subscribe volume volume_change
