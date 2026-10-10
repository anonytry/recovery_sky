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

# Hardware platform (SM4450 "parrot"). Needed before device.mk is evaluated.
PRODUCT_PLATFORM := parrot

# Inherit the official TWRP/OFOX vendor common config
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit from the sky device
$(call inherit-product, device/xiaomi/sky/device.mk)

PRODUCT_DEVICE := sky
PRODUCT_NAME := fox_sky
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := sky
PRODUCT_MANUFACTURER := xiaomi
PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

DEVICE_RESOLUTION := 1080x2460

# Stock fingerprint from the OS2.0.210.0.VMWMIXM dump
BUILD_FINGERPRINT := Xiaomi/sky/missi:15/AQ3A.240912.001/OS2.0.210.0.VMWMIXM:user/release-keys

# ----- OrangeFox settings (ported from OrangeFox/device/garnet fox_16.0) -----

# screen settings
OF_SCREEN_H := 2460
OF_STATUS_H := 100
OF_HIDE_NOTCH := 1
OF_STATUS_INDENT_LEFT := 56
OF_STATUS_INDENT_RIGHT := 48
OF_ALLOW_DISABLE_NAVBAR := 0
OF_USE_GREEN_LED := 0

# other stuff
OF_QUICK_BACKUP_LIST := /boot;/data;
OF_ENABLE_LPTOOLS := 1
OF_NO_TREBLE_COMPATIBILITY_CHECK := 1

# number of list options before scrollbar creation
OF_OPTIONS_LIST_NUM := 9

# A/B with recovery partition
OF_AB_DEVICE_WITH_RECOVERY_PARTITION := 1

# ----- data format stuff -----
# ensure that /sdcard is bind-unmounted before f2fs data repair or format
OF_UNBIND_SDCARD_F2FS := 1

# automatically wipe /metadata after data format
OF_WIPE_METADATA_AFTER_DATAFORMAT := 1

# avoid MTP issues after data format
# OF_BIND_MOUNT_SDCARD_ON_FORMAT := 1

# don't spam the console with loop errors
OF_LOOP_DEVICE_ERRORS_TO_LOG := 1

# lz4 compression
OF_USE_LZ4_COMPRESSION := 1

# build all the partition tools
OF_ENABLE_ALL_PARTITION_TOOLS := 1

# enable the FRP addon
OF_ENABLE_FRP_ADDON := 1

# dmctl
OF_USE_DMCTL := 1

# require rebooting recovery after flashing a ROM
OF_BLOCK_OPERATIONS_AFTER_ROM_FLASH := 1

# force unmount sdcards before rebooting
OF_UNMOUNT_SDCARDS_BEFORE_REBOOT := 1

# wlan
OF_ENABLE_WLAN := 1
