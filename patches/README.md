# Sky source fixes

Two fixes live outside the device tree. `vendorsetup.sh` applies them
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

## Ramdisk safety net

`recovery/root/system/bin/fox_fix_data_users.sh` performs the same
`/data/system/users` repair from the ramdisk. It is called from
`pre_rom_flash.sh`, `post_rom_flash_completion.sh`, and `postrecoveryboot.sh`.
It does not replace patch 0001: only vold can create the directory early enough
for the first decrypt.
