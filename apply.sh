#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  stow -t $HOME darwin
  stow -t $HOME common
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  stow -t $HOME linux
  stow -t $HOME common
fi
