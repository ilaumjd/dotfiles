#!/usr/bin/env bash

YABAI_BIN="$HOME/.local/src/yabai-macos27/bin/yabai"

# Get current menubar opacity
current_opacity=$("$YABAI_BIN" -m config menubar_opacity)

# Toggle between 0.0 and 1.0
if (( $(echo "$current_opacity < 0.5" | bc -l) )); then
    "$YABAI_BIN" -m config menubar_opacity 1.0
else
    "$YABAI_BIN" -m config menubar_opacity 0.0
fi
