#!/usr/bin/env bash

set -o pipefail
umask 077

lock_fd=
if [[ -n ${XDG_RUNTIME_DIR:-} && $XDG_RUNTIME_DIR == /* && -d $XDG_RUNTIME_DIR && -O $XDG_RUNTIME_DIR ]]; then
    exec {lock_fd}>"$XDG_RUNTIME_DIR/hypr-screenshot.lock"
    flock -n "$lock_fd" || exit 0
fi

slurp_args=(-d -b "#000000aa" -c "#33ccff" -w 2 -F "sans-serif")

geometry=$(slurp "${slurp_args[@]}")

if [[ -z $geometry ]]; then
    exit 0
fi

if grim -g "$geometry" - | wl-copy --type image/png; then
    notify-send "Screenshot Captured" "Region copied to clipboard." -i "camera-photo" -t 2000
else
    exit $?
fi
