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

# Stock fingerprint
BUILD_FINGERPRINT := Xiaomi/sky/missi:15/AQ3A.240912.001/OS2.0.210.0.VMWMIXM:user/release-keys

# OrangeFox screen settings
OF_SCREEN_H := 2460
OF_STATUS_H := 100
OF_HIDE_NOTCH := 1
OF_STATUS_INDENT_LEFT := 56
OF_STATUS_INDENT_RIGHT := 48
OF_ALLOW_DISABLE_NAVBAR := 0
OF_USE_GREEN_LED := 0
OF_CLOCK_POS := 1
OF_USE_LOCKSCREEN_BUTTON := 1

# Quick backup & tools
OF_QUICK_BACKUP_LIST := /boot;/data;
OF_ENABLE_LPTOOLS := 1
OF_NO_TREBLE_COMPATIBILITY_CHECK := 1

# Flashlight
OF_FL_PATH1 := /tmp/flashlight

# Default time zone (India)
OF_DEFAULT_TIMEZONE := IST-5:30

# UI List options before scrollbar
OF_OPTIONS_LIST_NUM := 9

# Dedicated recovery partition on A/B architecture
OF_AB_DEVICE_WITH_RECOVERY_PARTITION := 1

# Data format & storage handling
OF_UNBIND_SDCARD_F2FS := 1
OF_WIPE_METADATA_AFTER_DATAFORMAT := 1
OF_LOOP_DEVICE_ERRORS_TO_LOG := 1

# Performance & prebuilts
OF_USE_LZ4_COMPRESSION := 1
OF_FORCE_PREBUILT_KERNEL := 1
OF_ENABLE_ALL_PARTITION_TOOLS := 1
OF_ENABLE_FRP_ADDON := 1
OF_USE_DMCTL := 1

# Hardening & Security
OF_BLOCK_OPERATIONS_AFTER_ROM_FLASH := 1
OF_NO_REFLASH_CURRENT_ORANGEFOX := 1
OF_ADVANCED_SECURITY := 1
OF_UNMOUNT_SDCARDS_BEFORE_REBOOT := 1
OF_ENABLE_WLAN := 1
