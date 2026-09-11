#!/bin/bash
# Kanshi dock hook: consolidate workspaces onto the active display and
# save/restore laptop brightness. Safe no-op on machines without these outputs.
set -u

brightness_file="${XDG_RUNTIME_DIR:-/tmp}/dock-brightness"

save_brightness() {
	brightnessctl -q get >"$brightness_file" 2>/dev/null || true
}

restore_brightness() {
	if [ -f "$brightness_file" ]; then
		brightnessctl -q set "$(cat "$brightness_file")" 2>/dev/null ||
			brightnessctl -q set 50% 2>/dev/null || true
	fi
}

active_names() {
	hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.disabled == false) | .name'
}

wake_displays() {
	hyprctl dispatch 'hl.dsp.dpms({action="on"})' >/dev/null 2>&1
}

move_workspaces() {
	local target="$1"
	[ -n "$target" ] || return 0
	hyprctl workspaces -j 2>/dev/null | jq -r '.[].id' | while read -r ws; do
		[ "$ws" -gt 0 ] 2>/dev/null || continue
		hyprctl dispatch "hl.dsp.workspace.move({workspace=$ws, monitor=\"$target\"})" >/dev/null 2>&1
	done
}

sleep 0.5

case "${1-}" in
docked)
	save_brightness
	wake_displays
	move_workspaces "$(active_names | grep -v '^eDP-1$' | head -1)"
	;;
undocked)
	target="$(active_names | grep '^eDP-1$' | head -1)"
	[ -n "$target" ] || target="$(hyprctl monitors -j 2>/dev/null | jq -r '[.[] | select(.focused == true) | .name] | first // empty')"
	wake_displays
	move_workspaces "$target"
	restore_brightness
	;;
*)
	echo "Usage: $0 {docked|undocked}" >&2
	exit 1
	;;
esac
