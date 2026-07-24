# Shared Partition Build Log

## Initial problem

The old `Dual_Boot_Share` partition was about 20 GB and sat at the end of the Windows NVMe. Windows Disk Management could not extend it because the available unallocated space was before the partition, not after it.

## Backup and preparation

- Confirmed BitLocker was off.
- Confirmed Fast Startup and hibernation were off.
- Backed up important Windows data to `SSD_Archive(1)`.
- Disabled the page file and crash dumps temporarily while troubleshooting.

## Windows troubleshooting

Commands used:

```powershell
chkdsk C: /scan
chkdsk C: /spotfix
chkdsk C: /scan
defrag C: /X /U /V
```

The NTFS filesystem was repaired and free space was consolidated, but Disk Management still reported `0 MB` available to shrink. The remaining blocker was unmovable NTFS metadata near the end of C:.

## GParted solution

Ubuntu was booted and the Windows NTFS partition was confirmed to be unmounted. The correct Windows NVMe was identified by its layout:

```text
100 MiB EFI
16 MiB Microsoft Reserved
large Windows NTFS partition
unallocated space
```

GParted resized the Windows partition from its right edge, leaving approximately 500 GB unallocated. The left edge was not moved and the operation was not interrupted.

Windows Disk Management was then used to create:

```text
Label: Dual_Boot_Share
Drive letter: H:
Filesystem: NTFS
```

## Result

- Windows remained bootable.
- Ubuntu remained bootable.
- The shared NTFS partition is accessible from both operating systems.
