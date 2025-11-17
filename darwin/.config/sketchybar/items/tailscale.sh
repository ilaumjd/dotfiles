#!/bin/bash

sketchybar --add item tailscale right \
  --set tailscale update_freq=10 \
  script="$PLUGIN_DIR/tailscale.sh" \
  click_script="$PLUGIN_DIR/tailscale_click.sh"
