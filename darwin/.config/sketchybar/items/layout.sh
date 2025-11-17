#!/bin/bash

sketchybar --add item layout right \
  --set layout update_freq=5 \
  icon.width=16 \
  script="$PLUGIN_DIR/layout.sh" \
  click_script="$PLUGIN_DIR/layout_click.sh" \
  --subscribe layout space_change
