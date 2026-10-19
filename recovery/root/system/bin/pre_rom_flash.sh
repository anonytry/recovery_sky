#!/system/bin/sh

SCRIPT_NAME="$(basename "$0")"

LOGMSG() {
    echo "I:$@" >> /tmp/recovery.log
}

LOGMSG "---$SCRIPT_NAME start---"

# reset the SPL the installer sees, so a newer ROM is not seen as a downgrade
LOGMSG "Resetting SPL date to prevent anti-rollback protection..."
resetprop ro.build.version.security_patch 2022-12-31

LOGMSG "Detecting active boot slot..."
slot="$(getprop ro.boot.slot_suffix)"
LOGMSG "Active boot slot: $slot"

# Keep a copy of OrangeFox, the ROM installer overwrites the recovery partition
LOGMSG "Backing up recovery.img before ROM overwrites..."
dd if="/dev/block/bootdevice/by-name/recovery${slot}" of="/tmp/fox_backup.img" bs=1M
sync

# Repair /data/system/users while /data is still mounted.
if [ -x /system/bin/fox_fix_data_users.sh ]; then
	/system/bin/fox_fix_data_users.sh
fi

LOGMSG "---$SCRIPT_NAME end---"
