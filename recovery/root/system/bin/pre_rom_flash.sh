#!/system/bin/sh

SCRIPT_NAME="$(basename "$0")"

LOGMSG() {
    echo "I:$@" >> /tmp/recovery.log
}

LOGMSG "---$SCRIPT_NAME start---"

# Payload OTAs use update_engine and do not need the recovery SPL lowered.
if [ -z "$1" ] || ! unzip -l "$1" 2>/dev/null | grep -q 'payload_properties.txt'; then
	LOGMSG "Resetting SPL date to prevent anti-rollback protection..."
	resetprop ro.build.version.security_patch 2022-12-31
else
	LOGMSG "Payload OTA detected; leaving SPL unchanged."
fi

LOGMSG "Detecting active boot slot..."
slot="$(getprop ro.boot.slot_suffix)"
LOGMSG "Active boot slot: $slot"

# Keep a copy of OrangeFox, the ROM installer overwrites the recovery partition
LOGMSG "Backing up recovery.img before ROM overwrites..."
if dd if="/dev/block/bootdevice/by-name/recovery${slot}" of="/tmp/fox_backup.img" bs=1M; then
	sync
	backup_size="$(stat -c %s /tmp/fox_backup.img 2>/dev/null || echo 0)"
	if [ "$backup_size" -ne 104857600 ]; then
		LOGMSG "Recovery backup is incomplete ($backup_size bytes); removing it."
		rm -f /tmp/fox_backup.img
	fi
else
	LOGMSG "Recovery backup failed; removing it."
	rm -f /tmp/fox_backup.img
fi

# Repair /data/system/users while /data is still mounted.
if [ -x /system/bin/fox_fix_data_users.sh ]; then
	/system/bin/fox_fix_data_users.sh
fi

LOGMSG "---$SCRIPT_NAME end---"
