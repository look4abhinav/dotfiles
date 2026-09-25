#!/bin/bash
# Kanshi dock hook: consolidate workspaces onto the active display and
# save/restore laptop brightness. Safe no-op on machines without these outputs.
set -u
umask 077

runtime_dir="${XDG_RUNTIME_DIR-}"
brightness_file=
lock_file=
if [ -n "$runtime_dir" ] &&
	[ "${runtime_dir#/}" != "$runtime_dir" ] &&
	[ -d "$runtime_dir" ] &&
	[ -O "$runtime_dir" ] &&
	[ ! -L "$runtime_dir" ] &&
	[ "$(stat -c '%a' -- "$runtime_dir" 2>/dev/null)" = 700 ]; then
	brightness_file="$runtime_dir/dock-brightness"
	lock_file="$runtime_dir/dock-brightness.lock"
fi

valid_brightness() {
	case "${1-}" in
		''|*[!0-9]*) return 1 ;;
		*) return 0 ;;
	esac
}

journal_failure() {
	local message="${1-}"
	command -v systemd-cat >/dev/null 2>&1 || return 0
	printf '%s\n' "$message" |
		systemd-cat --user --identifier=dock.sh --priority=warning >/dev/null 2>&1 || :
	return 0
}

save_brightness() {
	local value temporary
	[ -n "$brightness_file" ] || return 0
	if [ -e "$brightness_file" ] || [ -L "$brightness_file" ]; then
		journal_failure 'Pending laptop brightness state was not overwritten'
		return 0
	fi
	if ! value="$(brightnessctl -q get 2>/dev/null)" || ! valid_brightness "$value"; then
		journal_failure 'Failed to save laptop brightness'
		return 0
	fi
	if ! temporary="$(mktemp "${brightness_file}.tmp.XXXXXX" 2>/dev/null)"; then
		journal_failure 'Failed to save laptop brightness'
		return 0
	fi
	if ! printf '%s\n' "$value" >"$temporary" ||
		! chmod 600 "$temporary" 2>/dev/null ||
		! mv -fT -- "$temporary" "$brightness_file"; then
		rm -f -- "$temporary" 2>/dev/null || :
		journal_failure 'Failed to save laptop brightness'
	fi
	return 0
}

restore_brightness() {
	local value
	local -a values
	[ -n "$brightness_file" ] || return 0
	if [ ! -e "$brightness_file" ] && [ ! -L "$brightness_file" ]; then
		return 0
	fi
	if [ ! -f "$brightness_file" ] || [ -L "$brightness_file" ]; then
		journal_failure 'Saved laptop brightness is not a regular file'
		return 0
	fi
	if ! chmod 600 "$brightness_file" 2>/dev/null ||
		! mapfile -t values <"$brightness_file"; then
		journal_failure 'Failed to read saved laptop brightness'
		return 0
	fi
	if [ "${#values[@]}" -ne 1 ] || ! valid_brightness "${values[0]}"; then
		journal_failure 'Saved laptop brightness is invalid'
		rm -f -- "$brightness_file" 2>/dev/null || :
		return 0
	fi
	value="${values[0]}"
	if ! brightnessctl -q set "$value" >/dev/null 2>&1; then
		journal_failure 'Failed to restore laptop brightness; saved state was kept'
		return 0
	fi
	if ! rm -f -- "$brightness_file" 2>/dev/null; then
		journal_failure 'Laptop brightness was restored, but saved state could not be removed'
	fi
	return 0
}

acquire_lock() {
	[ -n "$lock_file" ] || return 1
	command -v flock >/dev/null 2>&1 || return 1
	exec 9>>"$lock_file" || return 1
	flock -x -w 5 9
}

active_names() {
	local monitors
	monitors="$(hyprctl monitors -j 2>/dev/null)" || return 1
	jq -er '
		if type == "array" then
			.[] | select(.disabled == false) | .name |
			select(type == "string" and length > 0)
		else
			error("invalid monitor data")
		end
	' <<<"$monitors" 2>/dev/null
}

observe_dock_state() {
	local name names
	observed_state=
	target=
	names="$(active_names)" || return 1
	[ -n "$names" ] || return 1
	while IFS= read -r name; do
		if [ "$name" != eDP-1 ]; then
			target="$name"
			break
		fi
	done <<<"$names"
	if [ -n "$target" ]; then
		observed_state=docked
	else
		observed_state=undocked
		target=eDP-1
	fi
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

event="${1-}"
case "$event" in
docked|undocked) ;;
*)
	echo "Usage: $0 {docked|undocked}" >&2
	exit 1
	;;
esac

if ! acquire_lock; then
	journal_failure 'Failed to acquire dock state lock'
	exit 1
fi

observe_dock_state || exit 0
[ "$event" = "$observed_state" ] || exit 0

case "$event" in
docked)
	save_brightness
	wake_displays
	move_workspaces "$target"
	;;
undocked)
	wake_displays
	move_workspaces "$target"
	restore_brightness
	;;
esac
