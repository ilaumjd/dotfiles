#!/bin/bash

output_dir="$HOME/Videos"
output_file="recording_$(date +%Y%m%d_%H%M%S).mp4"
framerate=60
pid_file="/tmp/recording.pid"

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

record() {
  [ -f "$pid_file" ] && exit 1

  if [ "$3" = "true" ]; then
    ffmpeg -f x11grab \
      -video_size "$1" \
      -framerate $framerate \
      -i "$2" \
      -f pulse -ac 2 -i default \
      -c:v h264 \
      -preset ultrafast \
      -pix_fmt yuv420p \
      "$output_dir/$output_file" &>/dev/null &
  else
    ffmpeg -f x11grab \
      -video_size "$1" \
      -framerate $framerate \
      -i "$2" \
      -c:v h264 \
      -preset ultrafast \
      -pix_fmt yuv420p \
      "$output_dir/$output_file" &>/dev/null &
  fi

  echo "Recording started (PID: $!)"
  echo "Size: $1"
  echo "Location: $2"
  echo "Audio: $([ "$with_audio" = "true" ] && echo "enabled" || echo "disabled")"
  echo "Output: $output_dir/$output_file"
  echo $! >"$pid_file"
}

record_fullscreen() {
  resolution=$(xdpyinfo | awk '/dimensions/{print $2}')
  record "$resolution" ":0.0" "$with_audio"
}

record_selected() {
  selection=$(slop -f "%x %y %w %h" 2>/dev/null)
  [ -z "$selection" ] && exit 1
  read -r X Y W H < <(echo $selection)
  record "${W}x${H}" ":0.0+${X},${Y}" "$with_audio"
}

[ $# -eq 0 ] && exit 1

with_audio=false

# Process audio flag first
for arg in "$@"; do
  if [[ "$arg" == "a" ]] || [[ "$arg" == "audio" ]]; then
    with_audio=true
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
  a | audio) shift ;;
  *) exit 1 ;;
  esac
done
