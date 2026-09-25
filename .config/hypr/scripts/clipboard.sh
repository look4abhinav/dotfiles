#!/usr/bin/env bash

set -euo pipefail
umask 077

work_dir=
cache_temporary=
thumbnail_path=

cleanup() {
	if [[ -n $cache_temporary ]]; then
		rm -f -- "$cache_temporary" || true
	fi
	if [[ -n $work_dir ]]; then
		rm -rf -- "$work_dir" || true
	fi
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

path_is_safe() {
	[[ -n ${1-} && ${1-} == /* && ${1-} != *$'\n'* && ${1-} != *$'\r'* && ${1-} != *$'\t'* && ${1-} != *$'\x1f'* ]]
}

tmp_root=${TMPDIR:-/tmp}
if ! path_is_safe "$tmp_root"; then
	tmp_root=/tmp
fi
if ! work_dir=$(mktemp -d "$tmp_root/hypr-clipboard.XXXXXX"); then
	work_dir=$(mktemp -d /tmp/hypr-clipboard.XXXXXX) || exit 1
fi
chmod 700 -- "$work_dir" 2>/dev/null || true

cache_base=${XDG_CACHE_HOME-}
if [[ -z $cache_base ]]; then
	cache_base="${HOME-}/.cache"
fi
cache_dir=
if path_is_safe "$cache_base"; then
	candidate_cache_dir="${cache_base%/}/hypr/clipboard/thumbnails"
	if path_is_safe "$candidate_cache_dir" && [[ ! -L $candidate_cache_dir ]]; then
		if [[ ! -e $candidate_cache_dir || -d $candidate_cache_dir ]] &&
			mkdir -p -- "$candidate_cache_dir" 2>/dev/null &&
			chmod 700 -- "$candidate_cache_dir" 2>/dev/null; then
			cache_dir=$candidate_cache_dir
		fi
	fi
fi
if [[ -z $cache_dir ]]; then
	cache_dir="$work_dir/thumbnails"
	if ! mkdir -p -- "$cache_dir" 2>/dev/null || ! chmod 700 -- "$cache_dir" 2>/dev/null; then
		cache_dir=
	fi
fi

list_file=$(mktemp "$work_dir/list.XXXXXX")
entries_file=$(mktemp "$work_dir/entries.XXXXXX")
selection_file=$(mktemp "$work_dir/selection.XXXXXX")
selected_file=$(mktemp "$work_dir/selected.XXXXXX")
source_file=$(mktemp "$work_dir/source.XXXXXX")

binary_preview_re='^\[\[[[:space:]]+binary[[:space:]]+data[[:space:]]+'
mime_re='^image/[[:alnum:]][[:alnum:]._+-]*$'
selection_re=$'^([0-9]+)\t(text/plain|image/[[:alnum:]][[:alnum:]._+-]*)$'
accept_nth=$'{1}\t{2}'

declare -A row_mimes=()
thumbnail_deadline=$((SECONDS + 5))

valid_id() {
	[[ ${1-} =~ ^[0-9]+$ ]]
}

valid_mime() {
	[[ ${1-} == text/plain || ${1-} =~ $mime_re ]]
}

detected_image_mime() {
	local source=${1-}
	local detected

	detected=$(file --mime-type --brief -- "$source" 2>/dev/null) || return 1
	[[ $detected != *$'\n'* && $detected != *$'\r'* ]] || return 1
	[[ $detected =~ $mime_re ]] || return 1
	printf '%s\n' "$detected"
}

render_thumbnail() {
	local source=${1-}
	local hash_line content_hash thumbnail temporary remaining

	thumbnail_path=
	if [[ -z $cache_dir ]] || ! path_is_safe "$cache_dir"; then
		return 1
	fi

	hash_line=$(sha256sum -- "$source" 2>/dev/null) || return 1
	if ! read -r content_hash _ <<<"$hash_line"; then
		return 1
	fi
	[[ $content_hash =~ ^[0-9a-fA-F]{64}$ ]] || return 1
	thumbnail="$cache_dir/$content_hash.png"

	if [[ -f $thumbnail && ! -L $thumbnail ]]; then
		if [[ -s $thumbnail ]]; then
			chmod 600 -- "$thumbnail" 2>/dev/null || return 1
			thumbnail_path=$thumbnail
			return 0
		fi
	elif [[ -e $thumbnail || -L $thumbnail ]]; then
		return 1
	fi

	remaining=$((thumbnail_deadline - SECONDS))
	((remaining > 0)) || return 1
	temporary=$(mktemp "$cache_dir/.${content_hash}.XXXXXX.png" 2>/dev/null) || return 1
	cache_temporary=$temporary
	if ! timeout --kill-after=1 "${remaining}s" ffmpegthumbnailer -i "$source" -o "$temporary" -s 64 >/dev/null 2>&1 ||
		[[ ! -f $temporary || -L $temporary || ! -s $temporary ]] ||
		! chmod 600 -- "$temporary" 2>/dev/null ||
		! mv -f -- "$temporary" "$thumbnail"; then
		rm -f -- "$temporary" "$source" 2>/dev/null || true
		cache_temporary=
		return 1
	fi
	cache_temporary=
	thumbnail_path=$thumbnail
}

build_entries() {
	local row id preview mime detected thumbnail

	: >"$entries_file"
	while IFS= read -r row || [[ -n $row ]]; do
		[[ $row == *$'\t'* ]] || continue
		id=${row%%$'\t'*}
		preview=${row#*$'\t'}
		valid_id "$id" || continue

		mime=text/plain
		thumbnail=
		if [[ $preview =~ $binary_preview_re ]]; then
			if cliphist decode "$id" >"$source_file" 2>/dev/null; then
				if detected=$(detected_image_mime "$source_file"); then
					mime=$detected
					if render_thumbnail "$source_file"; then
						thumbnail=$thumbnail_path
					fi
				fi
			fi
		fi

		row_mimes["$id"]=$mime
		if [[ -n $thumbnail ]]; then
			printf '%s\t%s\t%s\0icon\x1f%s\n' \
				"$id" "$mime" "$preview" "$thumbnail" >>"$entries_file"
		else
			printf '%s\t%s\t%s\n' \
				"$id" "$mime" "$preview" >>"$entries_file"
		fi
	done <"$list_file"
}

cliphist list >"$list_file" 2>/dev/null
build_entries
[[ -s $entries_file ]] || exit 0

if ! fuzzel --namespace clipboard -d -w 80 --no-sort --with-nth=3 --match-nth=3 --accept-nth="$accept_nth" --only-match \
	<"$entries_file" >"$selection_file"; then
	exit 0
fi

selected_lines=()
mapfile -t selected_lines <"$selection_file"
[[ ${#selected_lines[@]} -eq 1 ]] || exit 0
selection=${selected_lines[0]}
[[ $selection =~ $selection_re ]] || exit 0
selected_id=${BASH_REMATCH[1]}
selected_mime=${BASH_REMATCH[2]}
valid_id "$selected_id" || exit 0
valid_mime "$selected_mime" || exit 0
expected_mime=${row_mimes[$selected_id]-}
valid_mime "$expected_mime" || exit 0
[[ $expected_mime == "$selected_mime" ]] || exit 0

if ! cliphist decode "$selected_id" >"$selected_file" 2>/dev/null; then
	exit 0
fi
wl-copy --type "$selected_mime" <"$selected_file"
