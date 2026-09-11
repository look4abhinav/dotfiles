#!/usr/bin/env bash

# Prevent multiple instances of slurp from opening if the shortcut is spammed
if pidof slurp > /dev/null; then
    exit 0
fi

# Region prompt: dimmed background with a cyan border
slurp_args=(-d -b "#000000aa" -c "#33ccff" -w 2 -F "sans-serif")

geometry=$(slurp "${slurp_args[@]}")

# Exit if user canceled the selection (e.g., by pressing Esc)
if [ -z "$geometry" ]; then
    exit 0
fi

# Take screenshot of the selected region and copy to clipboard
grim -g "$geometry" - | wl-copy

# Notify the user
notify-send "Screenshot Captured" "Region copied to clipboard." -i "camera-photo" -t 2000
