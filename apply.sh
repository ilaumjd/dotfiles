#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  stow -t "$HOME" darwin
  stow --ignore=.pi -t "$HOME" common
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  stow -t "$HOME" linux
  stow --ignore=.pi -t "$HOME" common
fi
