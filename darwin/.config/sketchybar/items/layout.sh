#!/bin/bash

sketchybar --add item layout right \
  --set layout update_freq=5 \
  icon.color="$ACCENT_PRIMARY" \
  icon.width=20 \
  label.color="$TEXT_PRIMARY" \
  label.width=48 \
  script="$PLUGIN_DIR/layout.sh" \
  click_script="$PLUGIN_DIR/layout_click.sh" \
  --subscribe layout space_change
