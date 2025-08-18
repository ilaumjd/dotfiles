#!/bin/bash

scan_timeout=10 # Scan duration in seconds

get_devices() {
  devices=()
  while read -r line; do
    device_id=$(echo "$line" | cut -d ' ' -f2)
    device_name=$(echo "$line" | cut -d ' ' -f3-)

    if [[ "${device_id//:/}" == *"${device_name//-/}"* ]]; then
      continue
    fi

    connection_status=$(bluetoothctl info "$device_id" | grep "Connected:" | cut -d ' ' -f2)

    if [ "$connection_status" = "yes" ]; then
      status="connected"
    else
      status="disconnected"
    fi

    devices+=("{\"id\":\"$device_id\",\"name\":\"$device_name\",\"status\":\"$status\"}")
  done < <(bluetoothctl devices)

  printf '%s\n' "${devices[@]}" | jq -s '.'
}

start_scan() {
  # Start scanning
  bluetoothctl scan on &
  scan_pid=$!

  # Let it scan for specified duration
  sleep $scan_timeout

  # Stop scanning
  kill $scan_pid 2>/dev/null
  bluetoothctl scan off
}

get_scan_status() {
  if pgrep -f "bluetoothctl scan on" >/dev/null; then
    echo "scanning"
  else
    echo "not-scanning"
  fi
}

get_connection_status() {
  info=$(bluetoothctl info)
  connected=$(echo "$info" | grep "Connected:" | cut -d ' ' -f2)
  name=$(echo "$info" | grep "Name:" | cut -d ' ' -f2-)

  printf '{"status":"%s","device":"%s"}\n' "$connected" "$name"
}

case "$1" in
"get-devices")
  get_devices
  ;;
"toggle-connection")
  connection_status=$(bluetoothctl info "$2" | grep "Connected:" | cut -d ' ' -f2)
  if [ "$connection_status" = "yes" ]; then
    bluetoothctl disconnect "$2"
  else
    bluetoothctl connect "$2"
  fi
  ;;
"toggle-power")
  if [ "$(bluetoothctl show | grep "Powered: yes")" ]; then
    bluetoothctl power off
  else
    bluetoothctl power on
  fi
  ;;
"scan")
  start_scan
  ;;
"scan-status")
  get_scan_status
  ;;
"connection-status")
  get_connection_status
  ;;
esac
