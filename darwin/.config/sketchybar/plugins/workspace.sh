#!/bin/bash

sid="${NAME#workspace.}"
case "$sid" in
  '' | *[!0-9]*) exit 0 ;;
esac

icons=""
apps_file="$(dirname "$CONFIG_DIR")/_vars/apps.conf"

while IFS= read -r app_name; do
  [[ -z "$app_name" ]] && continue
  glyph="$(awk -F, -v name="$app_name" '$1 == name { print $2; exit }' "$apps_file")"
  [[ -z "$glyph" ]] && glyph="󰣆"
  icons+="$glyph "
done < <(yabai -m query --windows --space "$sid" 2>/dev/null | jq -r '[.[].app] | unique | .[]' 2>/dev/null)

if [[ -n "$icons" ]]; then
  sketchybar --set "$NAME" label="${icons% }" label.drawing=on
else
  sketchybar --set "$NAME" label.drawing=off
fi
