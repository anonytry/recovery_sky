#!/system/bin/sh

# Create /data/system/users when /data is mounted but the ROM left it missing.

LOG_TAG="I:fox_fix_data_users:"

log_msg() {
	if [ -w /tmp/recovery.log ]; then
		echo "$LOG_TAG $*" >> /tmp/recovery.log
	fi
}

# Never write to the ramdisk mountpoint.
if ! grep -q ' /data ' /proc/mounts 2>/dev/null; then
	exit 0
fi

if [ ! -d /data/system ] || [ -d /data/system/users ]; then
	exit 0
fi

if mkdir -p /data/system/users; then
	chown 1000:1000 /data/system/users 2>/dev/null
	chmod 0775 /data/system/users 2>/dev/null
	if command -v restorecon >/dev/null 2>&1; then
		restorecon -R /data/system/users 2>/dev/null
	fi
	log_msg "created missing /data/system/users"
	exit 0
fi

log_msg "failed to create /data/system/users"
exit 1
