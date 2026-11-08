#!/system/bin/sh
#
# Copyright (C) 2024-2026 The OrangeFox Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

SCRIPT_NAME="$(basename "$0")"

LOGMSG() {
    echo "I:$@" >> /tmp/recovery.log
}

log_slot_state() {
    LOGMSG "Current boot slot: $(getprop ro.boot.slot_suffix)"
    LOGMSG "misc slot_suffix: $(dd if=/dev/block/bootdevice/by-name/misc bs=1 skip=2048 count=32 2>/dev/null | tr -d '\0')"
    for slot in _a _b; do
        if strings /dev/block/bootdevice/by-name/misc 2>/dev/null | grep -qx "$slot"; then
            LOGMSG "misc slot: $slot"
        fi
    done
    if [ -x /system/bin/bootctl ]; then
        LOGMSG "bootctl current slot: $(/system/bin/bootctl get-current-slot 2>&1)"
    fi
}

if [ -f /tmp/fox_post_done ]; then
    exit 0
fi
: > /tmp/fox_post_done

case "$1" in
    /sideload/*) is_sideload=1 ;;
    *) is_sideload=0 ;;
esac

LOGMSG "---$SCRIPT_NAME start--- (sideload=$is_sideload)"
log_slot_state

# Always compute the inactive target slot
case "$(getprop ro.boot.slot_suffix)" in
    _a) target_slot=1; target_suffix="_b" ;;
    _b) target_slot=0; target_suffix="_a" ;;
    *) target_slot=""; target_suffix="" ;;
esac

# Handle active slot switch for both manual flash and sideload
if [ -n "$target_slot" ] && [ -x /system/bin/bootctl ]; then
    LOGMSG "Switching active boot slot to $target_slot ($target_suffix)..."
    out="$(/system/bin/bootctl set-active-boot-slot "$target_slot" 2>&1)"
    rc=$?
    [ -n "$out" ] && LOGMSG "bootctl: $out"
    LOGMSG "set-active-boot-slot $target_slot rc=$rc"
    log_slot_state
else
    LOGMSG "E: Unable to switch active slot: target_slot='$target_slot' or bootctl missing"
fi

# For payload OTAs, leave the new slot's recovery untouched so it boots the ROM's recovery.
# Restore OrangeFox only if not a payload OTA or if explicitly requested.
if [ -f /tmp/fox_payload_ota ]; then
    LOGMSG "Payload OTA: leaving the new slot's recovery untouched (ROM recovery intact)."
elif [ -f /tmp/fox_backup.img ]; then
    backup_size="$(stat -c %s /tmp/fox_backup.img 2>/dev/null || echo 0)"
    if [ "$backup_size" -eq 104857600 ]; then
        if [ -n "$target_suffix" ]; then
            LOGMSG "Restoring OrangeFox to slot recovery${target_suffix}..."
            if dd if="/tmp/fox_backup.img" of="/dev/block/bootdevice/by-name/recovery${target_suffix}" bs=1M 2>/dev/null; then
                sync
                LOGMSG "Recovery restored to slot ${target_suffix} successfully."
            else
                LOGMSG "E: Failed to flash recovery to slot ${target_suffix}"
            fi
        fi
    else
        LOGMSG "Recovery backup size mismatch ($backup_size bytes); skipping recovery restore."
        rm -f /tmp/fox_backup.img
    fi
fi

# Repair /data/system/users before reboot
if [ -x /system/bin/fox_fix_data_users.sh ]; then
    /system/bin/fox_fix_data_users.sh
fi

# Warn if a pending Virtual A/B OTA update exists in /data
if ls /data/gsi/ota/*-cow-img.img > /dev/null 2>&1; then
    LOGMSG "WARNING: pending system update found in /data/gsi/ota."
    LOGMSG "WARNING: do NOT format or wipe data before the new system boots once."
fi

LOGMSG "---$SCRIPT_NAME end---"
: > /tmp/fox_flash_done
rm -f /tmp/fox_payload_ota /tmp/fox_flash_success

# Persist complete flash log before reboot
for dir in /sdcard /data/media/0; do
    [ -d "$dir" ] || continue
    mkdir -p "$dir/Fox/logs" 2>/dev/null
    if cp /tmp/recovery.log "$dir/Fox/logs/manual_flash_$(date +%Y%m%d_%H%M%S).log" 2>/dev/null; then
        break
    fi
done
sync
