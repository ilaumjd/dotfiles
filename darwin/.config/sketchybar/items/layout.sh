#!/bin/bash

sketchybar --add item layout right \
  --set layout update_freq=5 \
  icon.color="$ACCENT_PRIMARY" \
  label.color="$TEXT_PRIMARY" \
  script="$PLUGIN_DIR/layout.sh" \
  click_script="$PLUGIN_DIR/layout_click.sh" \
  --subscribe layout space_change
