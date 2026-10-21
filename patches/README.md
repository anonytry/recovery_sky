# Sky source fixes

Three fixes live outside the device tree. `vendorsetup.sh` applies them
automatically when building in a full OrangeFox tree. To apply manually:

    ./patches/apply.sh /path/to/android

Set `FOX_SKY_SKIP_PATCHES=1` to disable automatic application.

## 0001 - vold: create missing `/data/system/users`

`fscrypt_prepare_user_storage()` calls `prepare_dir("/data/system/users/<id>")`,
which uses a non-recursive `mkdir()`. If `/data/system` exists but
`/data/system/users` does not (freshly formatted `/data`, or a ROM that has not
completed its first boot), the DE key installs but storage preparation fails:

    Failed to mkdir(/data/system/users/0): No such file or directory
    Failed to prepare user 0 storage

`Decrypt_DE()` then fails, `TW_IS_FBE` becomes 0, and recovery reports
`Storage is not encrypted`. The patch creates only the missing parent
directory; it never creates `/data/system` itself.

## 0002 - recovery: stop fake FDE decrypt success

When `TW_IS_FBE` is 0, the legacy FDE branch forks a child whose
`cryptfs_check_passwd()` call is commented out. The child falls through and the
parent reads exit status 0, so any password is reported as successful. The
child also keeps running recovery code after `fork()` without `exec()`, which
triggers `libbinder ProcessState can not be used after fork`. The patch makes
the child `_exit(1)` and makes the parent return `-1` when
`ro.crypto.fs_crypto_blkdev` is still `error`.

## 0003 - recovery: prefer the A/B payload over `update-binary`

TWRP's manual ZIP installer checks `META-INF/com/google/android/update-binary`
before it checks for an A/B payload. Payload OTAs that also carry a stub
`update-binary` therefore run the stub on a manual flash, while ADB sideload
uses the AOSP installer, which selects the payload from `ota-type=AB`. The two
paths then disagree about switching the active slot. The patch prefers the
payload (with `payload_properties.txt` and `payload.bin`) when both are present.
It also disables the automatic OrangeFox reflash for payload OTAs, so the new
slot keeps its signed recovery image instead of having it replaced with an
unsigned one. A successful payload install is marked in `/tmp`, so the
post-flash hook only touches the slot after `update_engine` succeeds.

For a manual payload flash, `post_rom_flash_completion.sh` leaves the slot set
by `update_engine` alone and does not force a reboot. The user can choose the
reboot target. Booting the new system once is the safe default: rebooting
recovery or formatting data before the first boot can make the bootloader fall
back to the old slot. To reboot recovery and flash extra modules, OrangeFox
must first be installed in the new slot. ADB sideload keeps its existing
post-flash behavior.

## Touch firmware

Both FTS (`fts_8720`) and NVT (`nvt_36672c`) panels are supported. init loads
the matching module before `/vendor` is mounted, so its firmware request fails.
The firmware is copied to `/firmware_touch` and both modules are reloaded from
`postrecoveryboot.sh`, before the UI starts.

## Ramdisk safety net

`recovery/root/system/bin/fox_fix_data_users.sh` performs the same
`/data/system/users` repair from the ramdisk. It is called from
`pre_rom_flash.sh`, `post_rom_flash_completion.sh`, and `postrecoveryboot.sh`.
It does not replace patch 0001: only vold can create the directory early enough
for the first decrypt.
