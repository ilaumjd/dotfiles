#!/bin/sh

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

# Determine battery icon based on level and charging status
if [[ "$CHARGING" != "" ]]; then
  # Charging icons (nf-md-battery_charging_*)
  case "${PERCENTAGE}" in
    100) ICON="󰂅"  # battery_charging_100
    ;;
    9[0-9]) ICON="󰂋"  # battery_charging_90
    ;;
    8[0-9]) ICON="󰂊"  # battery_charging_80
    ;;
    7[0-9]) ICON="󰢞"  # battery_charging_70
    ;;
    6[0-9]) ICON="󰂉"  # battery_charging_60
    ;;
    5[0-9]) ICON="󰢝"  # battery_charging_50
    ;;
    4[0-9]) ICON="󰂈"  # battery_charging_40
    ;;
    3[0-9]) ICON="󰂇"  # battery_charging_30
    ;;
    2[0-9]) ICON="󰂆"  # battery_charging_20
    ;;
    1[0-9]) ICON="󰢜"  # battery_charging_10
    ;;
    *) ICON="󰢜"  # battery_charging_10
  esac
else
  # Discharging icons (nf-md-battery_*)
  case "${PERCENTAGE}" in
    100) ICON="󰁹"  # battery_100
    ;;
    9[0-9]) ICON="󰂂"  # battery_90
    ;;
    8[0-9]) ICON="󰂁"  # battery_80
    ;;
    7[0-9]) ICON="󰂀"  # battery_70
    ;;
    6[0-9]) ICON="󰁿"  # battery_60
    ;;
    5[0-9]) ICON="󰁾"  # battery_50
    ;;
    4[0-9]) ICON="󰁽"  # battery_40
    ;;
    3[0-9]) ICON="󰁼"  # battery_30
    ;;
    2[0-9]) ICON="󰁻"  # battery_20
    ;;
    1[0-9]) ICON="󰁺"  # battery_10
    ;;
    *) ICON="󰂎"  # battery_alert
  esac
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%"
