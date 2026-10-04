#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# AndroidProducts.mk is what actually registers the lunches. vendorsetup.sh
# add_lunch_combo is obsolete and ignored since android-12.1.
PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/fox_sky.mk

COMMON_LUNCH_CHOICES := \
    fox_sky-eng \
    fox_sky-user \
    fox_sky-userdebug