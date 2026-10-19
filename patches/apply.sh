#!/usr/bin/env bash
# Apply the Sky vold/recovery fixes to a full OrangeFox tree.
# Usage: ./patches/apply.sh [ANDROID_BUILD_TOP]
# FOX_SKY_SKIP_PATCHES=1 disables automatic application.
set -euo pipefail

DEVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOP="${1:-${ANDROID_BUILD_TOP:-$PWD}}"

if [ ! -d "$TOP/system/vold" ] || [ ! -d "$TOP/bootable/recovery" ]; then
	echo "E: $TOP does not look like an Android/OrangeFox source tree" >&2
	echo "E: expected $TOP/system/vold and $TOP/bootable/recovery" >&2
	exit 1
fi

apply_patch() {
	local repo="$1"
	local patch="$2"
	local name
	name="$(basename "$patch")"

	if git -C "$TOP/$repo" apply --reverse --check "$patch" >/dev/null 2>&1; then
		echo "I: already applied: $name"
		return 0
	fi

	if git -C "$TOP/$repo" apply --check "$patch" >/dev/null 2>&1; then
		git -C "$TOP/$repo" apply "$patch"
		echo "I: applied: $name"
		return 0
	fi

	echo "E: failed to apply $name to $TOP/$repo" >&2
	echo "E: the source tree has drifted from the version these patches target" >&2
	return 1
}

apply_patch "system/vold" "$DEVICE_DIR/patches/0001-vold-create-data-system-users-parent.patch"
apply_patch "bootable/recovery" "$DEVICE_DIR/patches/0002-recovery-stop-fake-fde-decrypt-success.patch"

echo "I: Sky source fixes are applied"
