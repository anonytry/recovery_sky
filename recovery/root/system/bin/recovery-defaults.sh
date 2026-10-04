#!/sbin/sh
F=/data/media/0/TWRP/backup.tw
D=/data/media/0/TWRP
M=$D/.sky_defaults

i=0
while [ "$i" -lt 300 ]; do
	[ -f "$F" ] && break
	sleep 1
	i=$((i + 1))
done

[ -f "$M" ] && exit 0

mkdir -p "$D" 2>/dev/null
[ -f "$F" ] || : > "$F"

sed -i '/^tw_military_time=/d;/^tw_unmount_vendor=/d' "$F" 2>/dev/null
{
	echo "tw_military_time=0"
	echo "tw_unmount_vendor=0"
} >> "$F"

chmod 0600 "$F" 2>/dev/null
cp "$F" /tmp/backup.tw 2>/dev/null
touch "$M" 2>/dev/null
exit 0