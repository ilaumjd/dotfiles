#!/bin/bash

swaybg -i "$(find ~/.config/iam/wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)" -m fill &
eww open bar &
dunst &
hypridle &

# void
pipewire &
