#!/bin/bash

# Create Pictures directory if it doesn't exist
mkdir -p ~/Pictures

# Function to take screenshot
take_screenshot() {
    local type=$1
    local opts=""
    local filename="screenshot_$(date +%Y%m%d_%H%M%S).png"
    
    case "$type" in
        "full")
            grim ~/Pictures/$filename
            type="Full Screen"
            ;;
        "select")
            slurp | grim -g - ~/Pictures/$filename
            type="Selection"
            ;;
        "window")
          hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'  | grim -g - ~/Pictures/$filename
            type="Active Window"
            ;;
    esac

    notify-send "Screenshot Taken: $type"
}

# Call the function with the provided argument
take_screenshot "$1"

