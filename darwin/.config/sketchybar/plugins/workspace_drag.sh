#!/bin/bash
set -euo pipefail

source_file="$CONFIG_DIR/plugins/workspace_drag.swift"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar"
binary="$cache_dir/workspace-drag"
pid_file="$cache_dir/workspace-drag.pid"

mkdir -p "$cache_dir"
if [[ ! -x "$binary" || "$source_file" -nt "$binary" ]]; then
  if [[ -d /Applications/Xcode.app/Contents/Developer ]]; then
    DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun swiftc -O "$source_file" -o "$binary"
  else
    swiftc -O "$source_file" -o "$binary"
  fi
fi

if [[ -f "$pid_file" ]]; then
  old_pid="$(cat "$pid_file")"
  if [[ "$old_pid" =~ ^[0-9]+$ ]]; then
    process_name="$(ps -p "$old_pid" -o comm= 2>/dev/null || true)"
    if [[ "$process_name" == *workspace-drag* ]]; then
      kill "$old_pid" 2>/dev/null || true
    fi
  fi
fi

"$binary" >>"$cache_dir/workspace-drag.log" 2>&1 &
echo "$!" > "$pid_file"
