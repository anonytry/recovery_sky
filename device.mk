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

# prebuilt kernel modules (fixed touch drivers) staged in the ramdisk
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/prebuilt/modules,$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib/modules/1.1)

# Keep the touch/audio firmware outside /vendor so it survives the vendor mount.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/aw87xxx_acf.bin:$(TARGET_COPY_OUT_RECOVERY)/root/firmware_touch/aw87xxx_acf.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/focaltech_8725_fw.bin:$(TARGET_COPY_OUT_RECOVERY)/root/firmware_touch/focaltech_8725_fw.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/focaltech_ft8720_hx.ini:$(TARGET_COPY_OUT_RECOVERY)/root/firmware_touch/focaltech_ft8720_hx.ini \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/focaltech_ts_fw_.bin:$(TARGET_COPY_OUT_RECOVERY)/root/firmware_touch/focaltech_ts_fw_.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/novatek_ts_fw.bin:$(TARGET_COPY_OUT_RECOVERY)/root/firmware_touch/novatek_ts_fw.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/novatek_ts_mp.bin:$(TARGET_COPY_OUT_RECOVERY)/root/firmware_touch/novatek_ts_mp.bin

# AIDL stubs for the prebuilt QTI security HALs (needed on A14+)
ifeq ($(shell [ -n "$(PLATFORM_SDK_VERSION)" ] && [ "$(PLATFORM_SDK_VERSION)" -ge 34 ] && echo yes),yes)
SKY_AIDL_PLATFORM_STUBS := true
else ifneq ($(filter A14 A15 A16 A17 A18,$(FOX_VARIANT)),)
SKY_AIDL_PLATFORM_STUBS := true
endif

ifdef SKY_AIDL_PLATFORM_STUBS
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/aidl/lib64/android.hardware.security.keymint-V1-ndk_platform.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/android.hardware.security.keymint-V1-ndk_platform.so \
    $(DEVICE_PATH)/prebuilt/aidl/lib64/android.hardware.security.secureclock-V1-ndk_platform.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/android.hardware.security.secureclock-V1-ndk_platform.so \
    $(DEVICE_PATH)/prebuilt/aidl/lib64/android.hardware.security.sharedsecret-V1-ndk_platform.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/android.hardware.security.sharedsecret-V1-ndk_platform.so \
    $(DEVICE_PATH)/prebuilt/aidl/lib64/android.hardware.vibrator-V2-ndk_platform.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/android.hardware.vibrator-V2-ndk_platform.so \
    $(DEVICE_PATH)/prebuilt/aidl/lib64/android.system.keystore2-V1-ndk_platform.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/android.system.keystore2-V1-ndk_platform.so
endif
