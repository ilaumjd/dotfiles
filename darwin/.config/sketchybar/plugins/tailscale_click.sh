#!/bin/bash

# Check current Tailscale status
STATUS=$(tailscale status --json 2>/dev/null | jq -r '.BackendState' 2>/dev/null)

if [ "$STATUS" = "Running" ]; then
  # If connected, disconnect
  tailscale down
else
  # If disconnected or stopped, connect
  tailscale up
fi

# Update the sketchybar item immediately
sleep 1  # Give Tailscale a moment to change state
sketchybar --trigger forced_update --update
