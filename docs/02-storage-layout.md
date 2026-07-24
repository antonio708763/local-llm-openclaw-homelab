# Storage Layout

- Windows remains on its original NVMe.
- Ubuntu remains on a separate NVMe.
- `Dual_Boot_Share` is an approximately 500 GB NTFS partition on the Windows NVMe.
- Windows uses drive letter `H:`.
- Ubuntu mounts the partition at `/mnt/Dual_Boot_Share`.
- `SSD_Archive(1)` was used for the pre-resize backup.

## Permanent Ubuntu mount

The stable partition identifier is:

```text
UUID=48003BD2003BC62A
```

The mount point is:

```text
/mnt/Dual_Boot_Share
```

The `/etc/fstab` entry is:

```fstab
UUID=48003BD2003BC62A /mnt/Dual_Boot_Share ntfs3 uid=1000,gid=1000,umask=022,nofail,x-systemd.device-timeout=10 0 0
```

The configuration was tested without rebooting:

```bash
sudo mount -a
findmnt /mnt/Dual_Boot_Share
touch /mnt/Dual_Boot_Share/ubuntu-write-test.txt
```

`findmnt` confirmed:

- Device: `/dev/nvme2n1p4` during that boot
- Filesystem: `ntfs3`
- Access: read/write
- User mapping: `uid=1000,gid=1000`

A post-reboot `findmnt` check remains the final confirmation that automatic mounting works during startup.

## Recommended shared folders

```text
Dual_Boot_Share/
├── AI-Projects/
├── Code/
├── Documents/
├── Homelab/
├── OpenClaw-Workspace/
├── Shared-Media/
└── Transfer/
```

Use the UUID rather than `/dev/nvmeXnY`, because Linux NVMe device numbers may change between boots.
