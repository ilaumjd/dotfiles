#!/bin/bash

DOTFILES_DIR="$(dirname "$(readlink -f "$0")")"

if [[ "$OSTYPE" == "darwin"* ]]; then
  ln -s "$DOTFILES_DIR/nvim" ~/.config/nvim
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  ln -s "$DOTFILES_DIR/nvim" ~/.config/nvim
  ln -s "$DOTFILES_DIR/bluetuith" ~/.config/bluetuith
  ln -s "$DOTFILES_DIR/eww" ~/.config/eww
  ln -s "$DOTFILES_DIR/rofi" ~/.config/rofi

  # x11
  ln -s "$DOTFILES_DIR/i3" ~/.config/i3
  ln -s "$DOTFILES_DIR/picom" ~/.config/picom

  # wayland
  ln -s "$DOTFILES_DIR/hypr" ~/.config/hypr
  ln -s "$DOTFILES_DIR/labwc" ~/.config/labwc
  ln -s "$DOTFILES_DIR/niri" ~/.config/niri
  ln -s "$DOTFILES_DIR/sway" ~/.config/sway

  ln -s "$DOTFILES_DIR/kanshi" ~/.config/kanshi
  ln -s "$DOTFILES_DIR/waybar" ~/.config/waybar
  ln -s "$DOTFILES_DIR/wayfire/wayfire.ini" ~/.config/wayfire.ini
  ln -s "$DOTFILES_DIR/xdg-desktop-portal" ~/.config/xdg-desktop-portal

  # scripts
  ln -s "$DOTFILES_DIR/iam" ~/.config/iam
fi
