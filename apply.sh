#!/bin/bash

DOTFILES_DIR="$(dirname "$(readlink -f "$0")")"

if [[ "$OSTYPE" == "darwin"* ]]; then
  ln -s "$DOTFILES_DIR/nvim" ~/.config/nvim
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  ln -s "$DOTFILES_DIR/nvim" ~/.config/nvim
  ln -s "$DOTFILES_DIR/dunst" ~/.config/dunst
  ln -s "$DOTFILES_DIR/eww" ~/.config/eww
  ln -s "$DOTFILES_DIR/rofi" ~/.config/rofi

  # x11
  ln -s "$DOTFILES_DIR/i3" ~/.config/i3
  ln -s "$DOTFILES_DIR/picom" ~/.config/picom

  # wayland
  ln -s "$DOTFILES_DIR/hypr" ~/.config/hypr
  ln -s "$DOTFILES_DIR/niri" ~/.config/niri
  ln -s "$DOTFILES_DIR/sway" ~/.config/sway

  # scripts
  ln -s "$DOTFILES_DIR/iam" ~/.config/iam
fi
