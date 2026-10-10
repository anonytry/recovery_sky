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

DEVICE_PATH := device/xiaomi/sky
COMMON_PATH := $(DEVICE_PATH)/common

# include (not inherit-product) the common settings - works better with device-specific files
-include $(COMMON_PATH)/device-common.mk

# TWRP/OFOX common extras
TW_DEFAULT_LANGUAGE     := en
TW_USE_TOOLBOX          := true
TW_INCLUDE_NTFS_3G      := true
TW_INCLUDE_REPACKTOOLS  := true
TW_INCLUDE_LIBRESETPROP := true
TW_EXTRA_LANGUAGES      := true
TW_EXCLUDE_APEX         := true
TW_INCLUDE_FASTBOOTD    := true

# OEM otacert
PRODUCT_EXTRA_RECOVERY_KEYS += \
    vendor/recovery/security/miui

# Enable updating of APEXes
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Enable virtual A/B OTA
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# clear this, so that the device-specific recovery/root/ folder is included automatically
# requires including, rather than inheriting the common settings
TARGET_RECOVERY_DEVICE_DIRS :=

# copy recovery/root/ from the common directory
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(COMMON_PATH)/twrp/recovery/root/,$(TARGET_COPY_OUT_RECOVERY)/root/)

# copy recovery/root/ from the device directory (if it exists)
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/recovery/root/,$(TARGET_COPY_OUT_RECOVERY)/root/)

# Prebuilt kernel modules shipped inside the recovery ramdisk.
# sky's Novatek (nvt_36672c) and FocalTech (fts_8720) touch drivers are
# buggy in the stock vendor_dlkm; the fixed modules (built from the sky 5.10
# GKI source) are staged at /vendor/lib/modules/1.1 and loaded first by the
# OrangeFox module loader (TW_LOAD_PREBUILT_MODULES_AT_FIRST), so recovery
# touch works regardless of the ROM's vendor_dlkm.
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/prebuilt/modules,$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib/modules/1.1)
