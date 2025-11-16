#!/bin/bash

# shellcheck disable=SC2034

# Hardware-specific configurations
HW_MODEL=$(sysctl -n hw.model)

if [ "$HW_MODEL" == "MacBookAir10,1" ]; then
  BAR_HEIGHT=25
else
  BAR_HEIGHT=38
fi
