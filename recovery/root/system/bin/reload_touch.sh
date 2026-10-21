#!/system/bin/sh

LOGMSG() {
    echo "I:touch: $@" >> /tmp/recovery.log
}

reload_one() {
    name="$1"
    if ! grep -q "^$name " /proc/modules 2>/dev/null; then
        LOGMSG "$name is not a loaded module; skipping"
        return
    fi

    modules="$(find /vendor_dlkm /vendor /modules_touch /system/lib64 -name "$name.ko" 2>/dev/null)"
    if [ -z "$modules" ]; then
        LOGMSG "$name.ko not found"
        return
    fi

    LOGMSG "reloading $name"
    out="$(rmmod "$name" 2>&1)"
    [ -n "$out" ] && LOGMSG "rmmod $name: $out"
    sleep 1

    for module in $modules; do
        out="$(insmod "$module" 2>&1)"
        rc=$?
        [ -n "$out" ] && LOGMSG "insmod $module: $out"
        if [ "$rc" -eq 0 ]; then
            LOGMSG "loaded $module"
            break
        fi
    done
    sleep 1
}

LOGMSG "reload start"

bound=0
if [ -d /vendor/firmware ] && [ -d /firmware_touch ]; then
    if mount -o bind /firmware_touch /vendor/firmware 2>/dev/null; then
        bound=1
        LOGMSG "bind-mounted firmware over /vendor/firmware"
    fi
fi

reload_one nvt_36672c
reload_one fts_8720

dmesg 2>/dev/null | grep -i -E 'fts_ts|nvt|focaltech|novatek' | tail -n 12 | while read -r line; do
    LOGMSG "dmesg: $line"
done

if [ "$bound" -eq 1 ]; then
    umount /vendor/firmware 2>/dev/null
fi
LOGMSG "reload done"
