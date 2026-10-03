#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 The OrangeFox Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from the sky device
$(call inherit-product, device/xiaomi/sky/device.mk)

PRODUCT_DEVICE := sky
PRODUCT_NAME := fox_sky
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := sky
PRODUCT_MANUFACTURER := xiaomi

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

# 1080x2460, density 440
DEVICE_RESOLUTION := 1080x2460

# Exact stock fingerprint from the OS2.0.210.0.VMWMIXM dump. The
# ro.vendor/ro.odm props in that dump still carry a stale Android 12
# fingerprint, so use the ro.product one.
BUILD_FINGERPRINT := Xiaomi/sky/missi:15/AQ3A.240912.001/OS2.0.210.0.VMWMIXM:user/release-keys
