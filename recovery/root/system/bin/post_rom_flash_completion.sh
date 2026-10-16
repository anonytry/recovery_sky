#!/system/bin/sh

SCRIPT_NAME="$(basename "$0")"

LOGMSG() {
    echo "I:$@" >> /tmp/recovery.log
}

LOGMSG "---$SCRIPT_NAME start---"

if [ -f /tmp/fox_backup.img ]; then
	for slot in _a _b; do
		LOGMSG "Restoring OrangeFox to slot ${slot}..."
		if dd if="/tmp/fox_backup.img" of="/dev/block/bootdevice/by-name/recovery${slot}" bs=1M; then
			sync
		else
			LOGMSG "Failed to flash to slot ${slot}..."
		fi
	done
else
	LOGMSG "Unable to find OrangeFox image for restoring..."
fi

# A Virtual A/B update keeps its CoW data on /data until the new system boots
# once. Formatting or wiping data before that deletes it, and the bootloader
# then falls back to the previous slot so the new ROM never appears.
# Read-only check: a no-op when no update is pending.
if ls /data/gsi/ota/*-cow-img.img > /dev/null 2>&1; then
	LOGMSG "WARNING: pending system update found in /data/gsi/ota."
	LOGMSG "WARNING: do NOT format or wipe data before the new system boots once."
fi

LOGMSG "---$SCRIPT_NAME end---"
