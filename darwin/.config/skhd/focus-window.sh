#!/usr/bin/env bash

# Usage: focus-window.sh [next|prev]
direction="${1:-next}"

# Get all window IDs in current space, sorted
window_ids=($(yabai -m query --windows --space | jq -r '.[].id' | sort -n))

# Get currently focused window ID
focused_id=$(yabai -m query --windows --window | jq -r '.id')

# Find index of focused window
focused_index=-1
for i in "${!window_ids[@]}"; do
    if [[ "${window_ids[$i]}" == "$focused_id" ]]; then
        focused_index=$i
        break
    fi
done

# If no focused window found, focus first window
if [[ $focused_index -eq -1 ]]; then
    if [[ ${#window_ids[@]} -gt 0 ]]; then
        yabai -m window --focus "${window_ids[0]}"
    fi
    exit 0
fi

# Calculate next/prev index
if [[ "$direction" == "next" ]]; then
    next_index=$(( (focused_index + 1) % ${#window_ids[@]} ))
else
    next_index=$(( (focused_index - 1 + ${#window_ids[@]}) % ${#window_ids[@]} ))
fi

# Focus the window
yabai -m window --focus "${window_ids[$next_index]}"
