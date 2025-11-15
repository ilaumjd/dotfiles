#!/bin/bash

WORKSPACE_ICONS=("󰲠" "󰲢" "󰲤" "󰲦" "󰲨" "󰲪")
for i in "${!WORKSPACE_ICONS[@]}"; do
  sid="$((i + 1))"
  workspace=(
    space="$sid"
    icon="${WORKSPACE_ICONS[i]}"
    icon.padding_left=0
    icon.padding_right=0
    icon.color="$TEXT_MUTED"
    icon.highlight_color="$ACCENT_PRIMARY"
    background.drawing=off
    label.drawing=off
    click_script="yabai -m space --focus $sid"
  )
  sketchybar --add space workspace."$sid" left --set workspace."$sid" "${workspace[@]}"
done
