#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  stow -t $HOME darwin
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  stow -t $HOME linux
fi

stow -t $HOME common
