#!/usr/bin/env bash

# Prevent multiple instances of slurp from opening if the shortcut is spammed
if pidof slurp > /dev/null; then
    exit 0
fi

# Modern & Professional slurp styling
# -d: Display selection dimensions
# -b: Background color (semi-transparent black to dim the screen)
# -c: Border color (cyan, matching your Hyprland active border theme)
# -w: Border weight
# -F: Font for dimensions
slurp_args="-d -b #000000aa -c #33ccff -w 2 -F sans-serif"

# Run slurp to get the selected region
geometry=$(slurp $slurp_args)

# Exit if user canceled the selection (e.g., by pressing Esc)
if [ -z "$geometry" ]; then
    exit 0
fi

# Take screenshot of the selected region and copy to clipboard
grim -g "$geometry" - | wl-copy

# Notify the user
notify-send "Screenshot Captured" "Region copied to clipboard." -i "camera-photo" -t 2000
