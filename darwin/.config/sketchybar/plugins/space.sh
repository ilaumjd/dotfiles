#!/bin/sh

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item

# Source colors
source "$CONFIG_DIR/plugins/colors.sh"

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" icon.color="$ACCENT_PRIMARY"
else
  sketchybar --set "$NAME" icon.color="$TEXT_MUTED"
fi
