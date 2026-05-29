#!/usr/bin/env bash

# Use playerctl follow to efficiently wait for metadata changes instead of polling
playerctl metadata --follow --format '{{title}} - {{artist}}' 2>/dev/null | while read -r line; do
    status=$(playerctl status 2>/dev/null)
    if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
        # Limit length to 40 chars
        echo "${line:0:40}"
    else
        echo ""
    fi
done
