#!/bin/bash

# shellcheck disable=SC2034

# Hardware-specific configurations
HW_MODEL=$(sysctl -n hw.model)

if [ "$HW_MODEL" == "MacBookAir10,1" ]; then
  BAR_HEIGHT=25
  ICON_FONT_SIZE=15.0
  LABEL_FONT_SIZE=12.0
  BAR_Y_OFFSET=3
  BAR_MARGIN=5
  BAR_CORNER_RADIUS=10
else
  BAR_HEIGHT=32
  ICON_FONT_SIZE=15.0
  LABEL_FONT_SIZE=12.0
  BAR_Y_OFFSET=4
  BAR_MARGIN=6
  BAR_CORNER_RADIUS=12
fi
