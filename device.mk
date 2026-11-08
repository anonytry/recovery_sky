#
# Copyright (C) 2024-2026 The Android Open Source Project
# Copyright (C) 2024-2026 The OrangeFox Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/sky

# Enable Virtual A/B OTA
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Enable APEX updates
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# TWRP & OrangeFox extras
TW_DEFAULT_LANGUAGE     := en
TW_USE_TOOLBOX          := true
TW_INCLUDE_NTFS_3G      := true
TW_INCLUDE_REPACKTOOLS  := true
TW_INCLUDE_LIBRESETPROP := true
TW_EXTRA_LANGUAGES      := true
TW_EXCLUDE_APEX         := true
TW_INCLUDE_FASTBOOTD    := true

# Clear device dirs to allow device recovery root inclusion
TARGET_RECOVERY_DEVICE_DIRS :=

# Include device recovery root
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/recovery/root/,$(TARGET_COPY_OUT_RECOVERY)/root/)

# Prebuilt kernel modules staged in ramdisk
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(DEVICE_PATH)/prebuilt/modules,$(TARGET_COPY_OUT_RECOVERY)/root/vendor/lib/modules/1.1)

# Persistent touch modules outside /vendor (survives vendor unmount during flashing)
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/modules/fts_8720.ko:$(TARGET_COPY_OUT_RECOVERY)/root/modules_touch/fts_8720.ko \
    $(DEVICE_PATH)/prebuilt/modules/nvt_36672c.ko:$(TARGET_COPY_OUT_RECOVERY)/root/modules_touch/nvt_36672c.ko

# Persistent touch and audio firmware outside /vendor
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/aw87xxx_acf.bin:$(TARGET_COPY_OUT_RECOVERY)/root/firmware_touch/aw87xxx_acf.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/focaltech_8725_fw.bin:$(TARGET_COPY_OUT_RECOVERY)/root/firmware_touch/focaltech_8725_fw.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/focaltech_ft8720_hx.ini:$(TARGET_COPY_OUT_RECOVERY)/root/firmware_touch/focaltech_ft8720_hx.ini \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/focaltech_ts_fw_.bin:$(TARGET_COPY_OUT_RECOVERY)/root/firmware_touch/focaltech_ts_fw_.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/novatek_ts_fw.bin:$(TARGET_COPY_OUT_RECOVERY)/root/firmware_touch/novatek_ts_fw.bin \
    $(DEVICE_PATH)/recovery/root/vendor/firmware/novatek_ts_mp.bin:$(TARGET_COPY_OUT_RECOVERY)/root/firmware_touch/novatek_ts_mp.bin

# Boot control HAL & update tools
PRODUCT_PACKAGES += \
    android.hardware.boot@1.0-impl \
    android.hardware.boot@1.0-service \
    bootctrl.parrot \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_verifier \
    update_engine_sideload

PRODUCT_STATIC_BOOT_CONTROL_HAL := \
    bootctrl.parrot \
    libgptutils \
    libz \
    libcutils
