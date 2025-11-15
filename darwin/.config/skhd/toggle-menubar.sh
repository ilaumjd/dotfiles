#!/usr/bin/env bash

# Get current menubar opacity
current_opacity=$(yabai -m config menubar_opacity)

# Toggle between 0.0 and 1.0
if (( $(echo "$current_opacity < 0.5" | bc -l) )); then
    yabai -m config menubar_opacity 1.0
else
    yabai -m config menubar_opacity 0.0
fi
