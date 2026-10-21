#!/system/bin/sh

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

LOGMSG "---$SCRIPT_NAME start---"
log_slot_state

if [ -f /tmp/fox_payload_ota ]; then
    # update_engine already switched the slot. Do not write recovery into the
    # new slot: its recovery hash is part of the signed vbmeta for that slot.
    LOGMSG "Payload OTA: leaving the new slot's recovery untouched (AVB-safe)."

    # update_engine normally sets the inactive slot. Re-assert it only after a
    # successful payload install, otherwise we could boot a partial slot.
    if [ -f /tmp/fox_flash_success ]; then
        if [ "$is_sideload" -eq 1 ]; then
            case "$(getprop ro.boot.slot_suffix)" in
                _a) target_slot=1 ;;
                _b) target_slot=0 ;;
                *) target_slot="" ;;
            esac
            if [ -n "$target_slot" ] && [ -x /system/bin/bootctl ]; then
                out="$(/system/bin/bootctl set-active-boot-slot "$target_slot" 2>&1)"
                rc=$?
                [ -n "$out" ] && LOGMSG "bootctl: $out"
                LOGMSG "set-active-boot-slot $target_slot rc=$rc"
                log_slot_state
            fi
        else
            # Manual payload flash: update_engine already set the slot. Do not
            # touch it again; the legacy boot HAL can make a re-assert fall back.
            LOGMSG "Manual payload OTA: update_engine selected the new slot; not reasserting it."
            LOGMSG "Manual payload OTA: reboot to system for the first boot."
            LOGMSG "Manual payload OTA: to reboot recovery and flash extra modules, install OrangeFox in the new slot first."
        fi
    else
        LOGMSG "Payload install did not report success; not changing the active slot."
    fi
elif [ -f /tmp/fox_backup.img ]; then
    backup_size="$(stat -c %s /tmp/fox_backup.img 2>/dev/null || echo 0)"
    if [ "$backup_size" -eq 104857600 ]; then
        for slot in _a _b; do
            LOGMSG "Restoring OrangeFox to slot ${slot}..."
            if dd if="/tmp/fox_backup.img" of="/dev/block/bootdevice/by-name/recovery${slot}" bs=1M; then
                sync
            else
                LOGMSG "Failed to flash to slot ${slot}..."
            fi
        done
    else
        LOGMSG "Recovery backup is incomplete ($backup_size bytes); skipping restore."
        rm -f /tmp/fox_backup.img
    fi
else
    LOGMSG "Unable to find OrangeFox image for restoring..."
fi

# Repair /data/system/users before the first recovery reboot.
if [ -x /system/bin/fox_fix_data_users.sh ]; then
    /system/bin/fox_fix_data_users.sh
fi

# warn on a pending Virtual A/B update (read-only, no-op otherwise)
if ls /data/gsi/ota/*-cow-img.img > /dev/null 2>&1; then
    LOGMSG "WARNING: pending system update found in /data/gsi/ota."
    LOGMSG "WARNING: do NOT format or wipe data before the new system boots once."
fi

LOGMSG "---$SCRIPT_NAME end---"
: > /tmp/fox_flash_done
rm -f /tmp/fox_payload_ota /tmp/fox_flash_success

# Persist the complete flash log before the user reboots.
for dir in /sdcard /data/media/0; do
    [ -d "$dir" ] || continue
    mkdir -p "$dir/Fox/logs" 2>/dev/null
    if cp /tmp/recovery.log "$dir/Fox/logs/manual_flash_$(date +%Y%m%d_%H%M%S).log" 2>/dev/null; then
        break
    fi
done
sync
