#!/bin/bash

# Check if tailscale is running and connected
STATUS=$(tailscale status --json 2>/dev/null | jq -r '.BackendState' 2>/dev/null)

if [ "$STATUS" = "Running" ]; then
  ICON="󰱓"
else
  ICON="󰲛"
fi

sketchybar --set "$NAME" icon="$ICON"
