#!/sbin/sh
#
# Re-mount the dynamic partitions read-write and back again, so that zip
# installers and the GUI settle before they are used.
#
sleep 1
mount -w /product > /dev/null
mount -w /vendor > /dev/null
mount -w /odm > /dev/null
mount -w /system_ext > /dev/null
mount -w /system_root > /dev/null

sleep 1
umount /product > /dev/null
umount /vendor > /dev/null
umount /odm > /dev/null
umount /system_ext > /dev/null
umount /system_root > /dev/null

sleep 1
mkdir /data/media
mkdir /tmp/install
mkdir /tmp/install/bin

# A pending Virtual A/B update keeps its CoW data on /data until the new
# system boots once. Formatting or wiping data before that deletes it and the
# bootloader falls back to the previous slot. Read-only check; no-op otherwise.
if ls /data/gsi/ota/*-cow-img.img > /dev/null 2>&1; then
	echo "I:WARNING: pending system update found in /data/gsi/ota." >> /tmp/recovery.log
	echo "I:WARNING: do NOT format or wipe data before the new system boots once." >> /tmp/recovery.log
fi

exit 0
