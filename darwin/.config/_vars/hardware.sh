#!/bin/bash

# shellcheck disable=SC2034

# Hardware-specific configurations
HW_MODEL=$(sysctl -n hw.model)

if [ "$HW_MODEL" == "MacBookAir10,1" ]; then
  BAR_HEIGHT=25
  ICON_FONT_SIZE=15.0
  LABEL_FONT_SIZE=12.0
else
  BAR_HEIGHT=38
  ICON_FONT_SIZE=17.0
  LABEL_FONT_SIZE=13.0
fi
