#!/bin/bash

workspace_ids=()
workspace_items=()
while IFS= read -r sid; do
  [[ "$sid" =~ ^[0-9]+$ ]] && workspace_ids+=("$sid")
done < <(yabai -m query --spaces 2>/dev/null | jq -r '.[].index' 2>/dev/null | sort -n -u)

if [[ "${#workspace_ids[@]}" -eq 0 ]]; then
  workspace_ids=({1..6})
fi

for sid in "${workspace_ids[@]}"; do
  workspace_items+=("workspace.$sid")
  workspace=(
    space="$sid"
    icon="$sid"
    icon.font.family="SF Pro Text"
    icon.padding_left=5
    icon.padding_right=3
    icon.color="$TEXT_INACTIVE"
    icon.highlight_color="$ACCENT_PRIMARY"
    background.drawing=off
    label.drawing=off
    label.font.family="FiraCode Nerd Font"
    label.font.size="$ICON_FONT_SIZE"
    label.color="$TEXT_PRIMARY"
    label.padding_left=0
    label.padding_right=5
    script="$PLUGIN_DIR/workspace.sh"
    click_script="yabai -m space --focus $sid"
  )
  sketchybar --add space workspace."$sid" left \
    --set workspace."$sid" "${workspace[@]}" \
    --subscribe workspace."$sid" space_windows_change space_change
done
