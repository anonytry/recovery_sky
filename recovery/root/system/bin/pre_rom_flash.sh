#!/system/bin/sh

SCRIPT_NAME="$(basename "$0")"

LOGMSG() {
    echo "I:$@" >> /tmp/recovery.log
}

LOGMSG "---$SCRIPT_NAME start---"

# Keep a rolling copy on internal storage so a failed flash still leaves a log.
rm -f /tmp/fox_flash_done /tmp/fox_flash_success /tmp/fox_post_done
rm -f /tmp/fox_payload_ota /tmp/fox_backup.img
mkdir -p /sdcard/Fox/logs 2>/dev/null
(
	while [ ! -f /tmp/fox_flash_done ]; do
		cp /tmp/recovery.log /sdcard/Fox/logs/manual_flash_live.log 2>/dev/null
		sync
		sleep 2
	done
) </dev/null >/dev/null 2>&1 &

# Payload OTAs use update_engine and do not need the recovery SPL lowered.
# The installer already creates the marker; keep it even if unzip cannot read
# the package path (for example, a FUSE sideload path).
if [ -f /tmp/fox_payload_ota ] || { [ -n "$1" ] && unzip -l "$1" 2>/dev/null | grep -q -e 'payload.bin' -e 'payload_properties.txt'; }; then
	payload=1
	: > /tmp/fox_payload_ota
	LOGMSG "Payload OTA detected; leaving SPL unchanged."
else
	payload=0
	rm -f /tmp/fox_payload_ota
	LOGMSG "Resetting SPL date to prevent anti-rollback protection..."
	resetprop ro.build.version.security_patch 2022-12-31
fi

LOGMSG "Detecting active boot slot..."
slot="$(getprop ro.boot.slot_suffix)"
LOGMSG "Active boot slot: $slot"

if [ "$payload" -eq 1 ]; then
	# update_engine writes the inactive slot and leaves recovery_a alone.
	# Writing OrangeFox into the new slot would invalidate its signed recovery.
	LOGMSG "Payload OTA: skipping recovery backup; the new slot keeps its signed recovery."
else
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
fi

# Repair /data/system/users while /data is still mounted.
if [ -x /system/bin/fox_fix_data_users.sh ]; then
	/system/bin/fox_fix_data_users.sh
fi

LOGMSG "---$SCRIPT_NAME end---"
