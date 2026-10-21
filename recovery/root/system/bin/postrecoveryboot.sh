#!/sbin/sh

# Prepare /data and toggle dynamic partitions without blocking the UI.
if [ -x /system/bin/fox_fix_data_users.sh ]; then
	/system/bin/fox_fix_data_users.sh
fi

# init loads the touch module before /vendor is mounted, so the FTS firmware
# request fails. Reload it once the firmware is reachable from /system/etc.
if [ -x /system/bin/reload_touch.sh ]; then
	/system/bin/reload_touch.sh
fi

mkdir /data/media
mkdir /tmp/install
mkdir /tmp/install/bin

# warn on a pending Virtual A/B update (read-only, no-op otherwise)
if ls /data/gsi/ota/*-cow-img.img > /dev/null 2>&1; then
	echo "I:WARNING: pending system update found in /data/gsi/ota." >> /tmp/recovery.log
	echo "I:WARNING: do NOT format or wipe data before the new system boots once." >> /tmp/recovery.log
fi

# Remount in the background; the old synchronous loop blocked touch for ~10s.
(
	echo "I:postrecoveryboot: remount started" >> /tmp/recovery.log
	sleep 1
	mount -w /product > /dev/null 2>&1
	mount -w /vendor > /dev/null 2>&1
	mount -w /odm > /dev/null 2>&1
	mount -w /system_ext > /dev/null 2>&1
	mount -w /system_root > /dev/null 2>&1
	sleep 1
	umount /product > /dev/null 2>&1
	umount /vendor > /dev/null 2>&1
	umount /odm > /dev/null 2>&1
	umount /system_ext > /dev/null 2>&1
	umount /system_root > /dev/null 2>&1
	echo "I:postrecoveryboot: remount done" >> /tmp/recovery.log
) </dev/null >/dev/null 2>&1 &

exit 0
