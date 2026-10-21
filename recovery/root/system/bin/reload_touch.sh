#!/system/bin/sh

LOGMSG() {
    echo "I:touch: $@" >> /tmp/recovery.log
}

LOGMSG "reload start"

if ! grep -q '^fts_8720 ' /proc/modules 2>/dev/null; then
    LOGMSG "fts_8720 is not a loaded module; nothing to reload"
    exit 0
fi

module="$(find /vendor_dlkm /vendor /system/lib64 -name fts_8720.ko 2>/dev/null | head -n 1)"
if [ -z "$module" ]; then
    LOGMSG "fts_8720.ko not found"
    exit 0
fi

bound=0
if [ -d /vendor/firmware ] && [ -d /firmware_touch ]; then
    if mount -o bind /firmware_touch /vendor/firmware 2>/dev/null; then
        bound=1
        LOGMSG "bind-mounted firmware over /vendor/firmware"
    fi
fi

LOGMSG "reloading $module"
rmmod fts_8720 2>&1 | while read -r line; do LOGMSG "rmmod: $line"; done
sleep 1
insmod "$module" 2>&1 | while read -r line; do LOGMSG "insmod: $line"; done
sleep 1

dmesg 2>/dev/null | grep -i -E 'fts_ts|focaltech' | tail -n 8 | while read -r line; do
    LOGMSG "dmesg: $line"
done

if [ "$bound" -eq 1 ]; then
    umount /vendor/firmware 2>/dev/null
fi
LOGMSG "reload done"
