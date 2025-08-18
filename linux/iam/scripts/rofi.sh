#!/bin/bash

# Function to handle rofi launchers
rofi_launch() {
  local mode=$1

  case "$mode" in
  "launcher")
    rofi -show drun
    ;;
  "power")
    rofi -show menu \
      -modi "menu:~/.config/rofi/rofi-power-menu --choices=suspend/shutdown/reboot/lockscreen/logout/hibernate"
    ;;
  esac
}

# Call the function with the provided argument
rofi_launch "$1"
