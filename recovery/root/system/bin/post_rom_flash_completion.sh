#!/system/bin/sh

SCRIPT_NAME="$(basename "$0")"

LOGMSG() {
    echo "I:$@" >> /tmp/recovery.log
}

LOGMSG "---$SCRIPT_NAME start---"

if [ -f /tmp/fox_backup.img ]; then
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
