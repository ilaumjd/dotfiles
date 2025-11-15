#!/bin/sh

# Get WiFi info
CURRENT_WIFI="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)"
SSID="$(echo "$CURRENT_WIFI" | grep -o "SSID: .*" | sed 's/^SSID: //')"
CURR_TX="$(echo "$CURRENT_WIFI" | grep -o "lastTxRate: .*" | sed 's/^lastTxRate: //')"

if [ "$SSID" = "" ]; then
  ICON="󰖪"
  LABEL="Disconnected"
else
  ICON="󰖩"
  LABEL="$SSID"
fi

sketchybar --set "$NAME" icon="$ICON" label="$LABEL"
