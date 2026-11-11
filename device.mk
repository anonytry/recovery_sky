#
# Copyright (C) 2024-2026 The Android Open Source Project
# Copyright (C) 2024-2026 The OrangeFox Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/sky

# Inherit from common AOSP config
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)

# Enable project quotas and casefolding for emulated storage without sdcardfs
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Enable virtual A/B OTA
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Enable APEX updates
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Installs gsi keys into ramdisk, to boot a GSI with verified boot.
$(call inherit-product, $(SRC_TARGET_DIR)/product/developer_gsi_keys.mk)

# Platform & Dynamic Partitions
TARGET_BOARD_PLATFORM := parrot
TARGET_BOOTLOADER_BOARD_NAME := sky
PRODUCT_USE_DYNAMIC_PARTITIONS := true
TARGET_HAS_GENERIC_KERNEL_HEADERS := true
PRODUCT_TARGET_VNDK_VERSION := 31
BOARD_SHIPPING_API_LEVEL := 31
PRODUCT_SHIPPING_API_LEVEL := 31

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += $(DEVICE_PATH)

SOONG_CONFIG_NAMESPACES += ufsbsg
SOONG_CONFIG_ufsbsg += ufsframework
SOONG_CONFIG_ufsbsg_ufsframework := bsg

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

# AIDL stubs for prebuilt QTI security HALs (needed on A14+)
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

# Qualcomm Decryption
PRODUCT_PACKAGES += \
    qcom_decrypt \
    qcom_decrypt_fbe

# Boot control HAL & update tools
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_client \
    update_verifier \
    update_engine_sideload \
    android.hardware.boot@1.2-impl-qti \
    android.hardware.boot@1.2-impl-qti.recovery \
    android.hardware.boot@1.2-service

# fastbootd
PRODUCT_PACKAGES += \
    fastbootd \
    android.hardware.fastboot@1.1-impl-mock

# f2fs utilities & Userdata checkpoint
PRODUCT_PACKAGES += \
    sg_write_buffer \
    f2fs_io \
    check_f2fs \
    checkpoint_gc

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=ext4 \
    POSTINSTALL_OPTIONAL_vendor=true

# OEM otacerts
PRODUCT_EXTRA_RECOVERY_KEYS += \
    $(DEVICE_PATH)/security/otacert \
    vendor/recovery/security/miui

# Enable Fuse Passthrough
PRODUCT_PROPERTY_OVERRIDES += persist.sys.fuse.passthrough.enable=true
