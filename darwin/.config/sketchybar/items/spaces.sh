#!/bin/bash

SPACE_ICONS=("󰲠" "󰲢" "󰲤" "󰲦" "󰲨" "󰲪")
for i in "${!SPACE_ICONS[@]}"; do
  sid="$((i + 1))"
  space=(
    space="$sid"
    icon="${SPACE_ICONS[i]}"
    icon.padding_left=0
    icon.padding_right=0
    icon.color="$TEXT_MUTED"
    icon.highlight_color="$ACCENT_PRIMARY"
    background.drawing=off
    label.drawing=off
    click_script="yabai -m space --focus $sid"
  )
  sketchybar --add space space."$sid" left --set space."$sid" "${space[@]}"
done
