#!/bin/bash

sketchybar --add item chevron left \
  --set chevron icon=󰘍 \
  icon.color="$ACCENT_PRIMARY" \
  label.drawing=off \
  padding_left=5 \
  padding_right=5 \
  click_script="yabai -m space --focus recent"
