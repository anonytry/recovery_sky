#
# Copyright 2017 The Android Open Source Project
#
# Copyright (C) 2024-2026 The OrangeFox Recovery Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This contains the module build definitions for the hardware-specific
# components for this device. The bulk of the platform configuration is
# provided by the ported sm84xx-common tree (common/BoardConfigCommon.mk);
# the values below are the sky (SM4450) device-specific overrides.

# Device paths (also defined by device.mk; repeated here so BoardConfig is safe
# regardless of product-config evaluation order)
DEVICE_PATH := device/xiaomi/sky
COMMON_PATH := $(DEVICE_PATH)/common

# Inherit from common
-include $(COMMON_PATH)/BoardConfigCommon.mk

# Bootloader / platform
TARGET_BOARD_PLATFORM := parrot
TARGET_BOOTLOADER_BOARD_NAME := sky
TARGET_NO_BOOTLOADER := false
TARGET_USES_UEFI := true
TARGET_USES_REMOTEPROC := true
BOARD_USES_QCOM_HARDWARE := true

# Architecture (SM4450 "parrot": Kryo 300 / Cortex-A75)
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a-dotprod
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := kryo300

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a75

# Kernel - prebuilt Image built from the maintained sky 5.10 GKI source.
# sky uses a dedicated recovery partition + a GKI boot kernel, so the recovery
# image itself is ramdisk-only (BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE, set in
# the common config). The prebuilt kernel is still required by the build graph.
BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_KERNEL_IMAGE_NAME := Image.lz4
BOARD_KERNEL_PAGESIZE := 4096
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel

# Recovery
TARGET_OTA_ASSERT_DEVICE := sky,skyin
TARGET_RECOVERY_FSTAB := $(COMMON_PATH)/recovery.fstab

# Display
TARGET_SCREEN_DENSITY := 440
TARGET_SCREEN_WIDTH := 1080
TARGET_SCREEN_HEIGHT := 2460
DEVICE_RESOLUTION := 1080x2460

# Partition sizes (sky, SM4450)
BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_KERNEL-GKI_BOOTIMAGE_PARTITION_SIZE := $(BOARD_BOOTIMAGE_PARTITION_SIZE)
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600
BOARD_DTBOIMG_PARTITION_SIZE := 24117248
BOARD_USERDATAIMAGE_PARTITION_SIZE := 48318382080
BOARD_PERSISTIMAGE_PARTITION_SIZE := 33554432
BOARD_METADATAIMAGE_PARTITION_SIZE := 16777216
BOARD_FLASH_BLOCK_SIZE := 262144 # (BOARD_KERNEL_PAGESIZE * 64)

# TWRP / OrangeFox flags (sky)
TW_FRAMERATE := 60
TW_BRIGHTNESS_PATH := "/sys/class/backlight/panel0-backlight/brightness"
TW_DEFAULT_BRIGHTNESS := 547
TW_MAX_BRIGHTNESS := 2047
TW_CUSTOM_CPU_TEMP_PATH := "/sys/devices/virtual/thermal/thermal_zone34/temp"
TW_QCOM_ATS_OFFSET := 1666528204500
TW_SCREEN_BLANK_ON_BOOT := true
TW_BACKUP_EXCLUSIONS := /data/fonts/files

# Haptics (leds-qpnp-vibrator-ldo / qti vibrator AIDL)
TW_SUPPORT_INPUT_AIDL_HAPTICS := true
TW_SUPPORT_INPUT_AIDL_HAPTICS_FIX_OFF := true
TW_SUPPORT_INPUT_AIDL_HAPTICS_FQNAME := "IVibrator/default"

# Kernel modules. sky's touch panels are the buggy-in-stock Novatek
# (nvt_36672c) and FocalTech (fts_8720); the fixed modules are shipped inside
# the recovery ramdisk (prebuilt/modules -> /vendor/lib/modules/1.1) and are
# loaded first, so recovery touch works even on a ROM whose vendor_dlkm still
# carries the buggy module. The remaining modules are loaded from the ROM's
# vendor_dlkm/vendor_boot when available.
TW_LOAD_VENDOR_MODULES := "adsp_loader_dlkm.ko q6_dlkm.ko nvt_36672c.ko fts_8720.ko xiaomi_touch.ko xiaomi_touch_notifier.ko ktd3136_bl.ko leds-qpnp-vibrator-ldo.ko qti_battery_charger_main.ko aw87xxx_dlkm.ko"
TW_LOAD_VENDOR_MODULES_EXCLUDE_GKI := true
TW_LOAD_PREBUILT_MODULES_AT_FIRST := true

# Logging
TARGET_USES_LOGD := true
TWRP_INCLUDE_LOGCAT := true
