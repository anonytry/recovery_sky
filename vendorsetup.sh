#
#	This file is part of the OrangeFox Recovery Project
# 	Copyright (C) 2024-2026 The OrangeFox Recovery Project
#
#	OrangeFox is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	any later version.
#
#	OrangeFox is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
# 	This software is released under GPL version 3 or any later version.
#	See <http://www.gnu.org/licenses/>.
#
# 	Please maintain this if you use this script or any part of it
#

#set -o xtrace
FDEVICE="sky"

fox_get_target_device() {
  if echo "$BASH_SOURCE" | grep -q "/$FDEVICE/"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  elif set | grep BASH_ARGV | grep -w \"$FDEVICE\"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  elif echo "${BASH_SOURCE[0]}" | grep -q "/$FDEVICE/"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  elif echo "$0" | grep -q "$FDEVICE"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  fi
}

if [ -z "$1" -a -z "$FOX_BUILD_DEVICE" ]; then
   fox_get_target_device
fi

if [ "$1" = "$FDEVICE" -o "$FOX_BUILD_DEVICE" = "$FDEVICE" ]; then
	export FOX_VIRTUAL_AB_DEVICE=1
	export FOX_VANILLA_BUILD=1
	export FOX_ENABLE_APP_MANAGER=1
	export FOX_RECOVERY_SYSTEM_PARTITION="/dev/block/mapper/system"
	export FOX_RECOVERY_VENDOR_PARTITION="/dev/block/mapper/vendor"
	export FOX_USE_BASH_SHELL=1
	export FOX_ASH_IS_BASH=1
	export FOX_USE_TAR_BINARY=1
	export FOX_USE_LZ4_BINARY=1
	export FOX_USE_SED_BINARY=1
	export FOX_USE_XZ_UTILS=1
	export FOX_USE_ZSTD_BINARY=1
	export FOX_USE_NANO_EDITOR=1
	export FOX_DELETE_AROMAFM=1
	export FOX_USE_DATE_BINARY=1
	export FOX_USE_BUSYBOX_BINARY=1
	export FOX_SETTINGS_ROOT_DIRECTORY=/data/recovery
	export FOX_MISCELLANEOUS_ROOT_DIRECTORY=/sdcard

	# maintainer identity
	export OF_MAINTAINER="Sarim Rasool (@TopexGuy)"

	# keymaster version shipped by the stock ROM
	export OF_DEFAULT_KEYMASTER_VERSION=4.1

	# build variant/type (the CI exports MANIFEST_BRANCH)
	if [ "$MANIFEST_BRANCH" = "16.0" ]; then
		export FOX_VARIANT="A16"
	else
		export FOX_VARIANT="A12"
	fi
	export FOX_BUILD_TYPE="Stable"

	# early settings
	export FOX_ALLOW_EARLY_SETTINGS_LOAD=1

	# KSU, etc.
	export FOX_ENABLE_KERNELSU_SUPPORT=1
	export FOX_ENABLE_KERNELSU_NEXT_SUPPORT=1
	export FOX_ENABLE_SUKISU_SUPPORT=1

	# patchelf
	export FOX_USE_PATCHELF_BINARY=1

	# extra binaries kept in the ramdisk (grep, magiskboot, magisk installer)
	export FOX_USE_GREP_BINARY=1
	export FOX_USE_UPDATED_MAGISKBOOT=1
	export FOX_MOVE_MAGISK_INSTALLER_TO_RAMDISK=1

	# Apply the vold/recovery fixes from patches/ (FOX_SKY_SKIP_PATCHES=1 disables).
	if [ -z "$FOX_SKY_PATCHES_DONE" -a -z "$FOX_SKY_SKIP_PATCHES" ]; then
		SKY_PATCH_TOP="${ANDROID_BUILD_TOP:-${TOP:-$PWD}}"
		if [ -d "$SKY_PATCH_TOP/system/vold" -a -d "$SKY_PATCH_TOP/bootable/recovery" ]; then
			export FOX_SKY_PATCHES_DONE=1
			SKY_DEVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
			if ! "$SKY_DEVICE_DIR/patches/apply.sh" "$SKY_PATCH_TOP"; then
				echo "E: Sky source fixes were NOT applied - the decrypt fix will be missing!"
			fi
		fi
	fi
else
	if [ -z "$FOX_BUILD_DEVICE" -a -z "$BASH_SOURCE" ]; then
		echo "I: This script requires bash. Not processing the $FDEVICE $(basename $0)"
	fi
fi
#
