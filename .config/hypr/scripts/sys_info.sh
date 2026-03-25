#!/bin/bash

# 1. Function that draws the background progress bar
function notify_bar {
    # The '-h int:value:"$2"' is the secret sauce that tells Mako how far to fill the background!
    notify-send -c osd -h string:x-canonical-private-synchronous:sys-notify -h int:value:"$2" -u low "$1" "$2%"
}

# 2. Function for text-only toggles (Mute, Caps Lock)
function notify_text {
    notify-send -c osd -h string:x-canonical-private-synchronous:sys-notify -u low "$1" "$2"
}

function get_volume {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'
}

function get_brightness {
    max=$(brightnessctl max)
    current=$(brightnessctl get)
    echo $(( current * 100 / max ))
}

case $1 in
    vol_up)
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 10%+
        notify_bar "  Volume" "$(get_volume)"
        ;;
    vol_down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-
        notify_bar "  Volume" "$(get_volume)"
        ;;
    vol_mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED; then
            notify_text "  Volume" "Muted"
        else
            notify_bar "  Volume" "$(get_volume)"
        fi
        ;;
    bright_up)
        current=$(get_brightness)
        if [ "$current" -lt 5 ]; then
            brightnessctl set 5%
        else
            brightnessctl set 5%+
        fi
        notify_bar "  Brightness" "$(get_brightness)"
        ;;
    bright_down)
        current=$(get_brightness)
        if [ "$current" -le 5 ]; then
            brightnessctl set 1%
        else
            brightnessctl set 5%-
        fi
        notify_bar "  Brightness" "$(get_brightness)"
        ;;
    caps)
        sleep 0.1
        if hyprctl devices -j | grep -q '"capsLock": true'; then
            # -h int:value:100 completely fills the background with your cyan color
            notify-send -c osd -h string:x-canonical-private-synchronous:sys-notify -h int:value:100 -u low "  Caps Lock" "ON"
        else
            # -h int:value:0 empties the background
            notify-send -c osd -h string:x-canonical-private-synchronous:sys-notify -h int:value:0 -u low "  Caps Lock" "OFF"
        fi
        ;;
esac
