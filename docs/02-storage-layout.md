# Storage Layout

- Windows remains on its original NVMe.
- Ubuntu remains on a separate NVMe.
- `Dual_Boot_Share` is an approximately 500 GB NTFS partition on the Windows NVMe.
- Windows uses drive letter `H:`.
- Ubuntu can read the partition.
- `SSD_Archive(1)` was used for the pre-resize backup.

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

Use a permanent Ubuntu mount point such as `/mnt/Dual_Boot_Share` and mount by UUID rather than `/dev/nvmeXnY`.
