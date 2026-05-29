#!/usr/bin/env bash

status=$(playerctl status 2>/dev/null)
if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
    position=$(playerctl metadata --format '{{duration(position)}}' 2>/dev/null)
    length=$(playerctl metadata --format '{{duration(mpris:length)}}' 2>/dev/null)
    
    if [ -n "$length" ] && [ "$length" != "0:00" ] && [ "$length" != "" ]; then
        echo "$position / $length"
    elif [ -n "$position" ] && [ "$position" != "0:00" ] && [ "$position" != "" ]; then
        echo "$position"
    else
        # If both are missing or 0:00 (like some Firefox YouTube tabs), just show a simple icon
        echo "♪"
    fi
else
    echo ""
fi
