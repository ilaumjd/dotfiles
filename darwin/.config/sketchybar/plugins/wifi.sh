#!/bin/sh

INFO="$(system_profiler SPAirPortDataType 2>/dev/null)"
STATUS="$(echo "$INFO" | awk -F': ' '/Status:/{print $2; exit}')"

if [ "$STATUS" != "Connected" ]; then
  sketchybar --set "$NAME" icon="󰤭"
  exit 0
fi

RSSI="$(echo "$INFO" | grep -m1 'Signal / Noise' | grep -Eo -- '-[0-9]+' | head -1)"

if [ -z "$RSSI" ]; then
  ICON="󰤭"  # wifi_strength_off (unknown/no signal data)
elif [ "$RSSI" -ge -54 ]; then
  ICON="󰤨"  # wifi_strength_4
elif [ "$RSSI" -ge -64 ]; then
  ICON="󰤥"  # wifi_strength_3
elif [ "$RSSI" -ge -74 ]; then
  ICON="󰤢"  # wifi_strength_2
else
  ICON="󰤟"  # wifi_strength_1
fi

sketchybar --set "$NAME" icon="$ICON"
