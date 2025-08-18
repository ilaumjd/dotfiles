#!/bin/bash

output_dir="$HOME/Videos"
output_file="recording_$(date +%Y%m%d_%H%M%S).mp4"
framerate=60
pid_file="/tmp/recording.pid"

status() {
  [ -f "$pid_file" ] && echo "true" || echo "false"
}

stop_recording() {
  if [ -f "$pid_file" ]; then
    pid=$(cat "$pid_file")
    kill -15 "$pid" 2>/dev/null
    rm -f "$pid_file"
    echo "Recording stopped"
  else
    echo "No recording in progress"
  fi
}

record_fullscreen() {
  wf-recorder $mic_flag -f "$output_dir/$output_file" &
  echo $! >"$pid_file"
  echo "Recording fullscreen..."
}

record_selected() {
  wf-recorder $mic_flag -g "$(slurp)" -f "$output_dir/$output_file" &
  echo $! >"$pid_file"
  echo "Recording selected area..."
}

if [ $# -eq 0 ]; then
  echo "Usage: $0 [f|full|s|select|k|kill] [m|mic]"
  exit 1
fi

mic_flag=""

# Process audio flag first
for arg in "$@"; do
  if [[ "$arg" == "m" ]] || [[ "$arg" == "mic" ]]; then
    mic_flag="--audio"
    break
  fi
done

while [[ $# -gt 0 ]]; do
  case $1 in
  f | full)
    record_fullscreen
    shift
    ;;
  s | select)
    record_selected
    shift
    ;;
  k | kill)
    stop_recording
    shift
    ;;
  m | mic) shift ;;
  status)
    status
    shift
    ;;
  *) exit 1 ;;
  esac
done
