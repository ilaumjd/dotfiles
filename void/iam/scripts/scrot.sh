#!/bin/bash

# Create Pictures directory if it doesn't exist
mkdir -p ~/Pictures

# Function to take screenshot
take_screenshot() {
    local type=$1
    local opts=""
    
    case "$type" in
        "full")
            opts=""
            type="Full Screen"
            ;;
        "select")
            opts="-s"
            type="Selection"
            ;;
        "window")
            opts="-u"
            type="Active Window"
            ;;
    esac

    scrot $opts 'screenshot_%Y%m%d_%H%M%S.png' -e 'mv $f ~/Pictures' && \
    notify-send "Screenshot Taken" 
}

# Call the function with the provided argument
take_screenshot "$1"

