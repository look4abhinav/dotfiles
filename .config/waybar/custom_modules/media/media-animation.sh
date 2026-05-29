#!/usr/bin/env bash

status_file="/tmp/waybar_media_status_$$"
trap "rm -f $status_file" EXIT
echo "Stopped" > "$status_file"

# Update status continuously in the background
playerctl status --follow > "$status_file" 2>/dev/null &
PLAYER_PID=$!
trap "kill $PLAYER_PID; rm -f $status_file" EXIT

animation_frames=("▂▄▆" "▄▂▆" "▄▆▂" "▆▄▂" "▆▂▄")

while :; do
  status=$(cat "$status_file" 2>/dev/null)
  if [ "$status" == "Playing" ]; then
    for frame in "${animation_frames[@]}"; do
      echo "$frame"
      sleep 0.15
      
      # Re-check status mid-animation for responsiveness
      status=$(cat "$status_file" 2>/dev/null)
      if [ "$status" != "Playing" ]; then
          break
      fi
    done
  elif [ "$status" == "Paused" ]; then
    echo ""
    sleep 1
  else
    echo ""
    sleep 2
  fi
done
